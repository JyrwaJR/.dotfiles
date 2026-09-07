/**
 * Commit Security Guard Plugin for OpenCode
 *
 * Prevents committing files that contain API keys, secrets, or credentials.
 * Intercepts `git commit` and `git add` tool calls, scans staged files
 * for known secret patterns, and blocks the commit if secrets are found.
 *
 * Uses tool.execute.before hook to intercept bash calls containing git commands.
 *
 * @module commit-security
 */

import type { Plugin } from "@opencode-ai/plugin"

/**
 * Regex patterns for common secret formats.
 * Each pattern has a name, regex to match, and severity.
 */
const SECRET_PATTERNS = [
  // AWS Access Key ID
  { name: "AWS Access Key ID", regex: /AKIA[0-9A-Z]{16}/, severity: "critical" },
  // AWS Secret Access Key
  {
    name: "AWS Secret Access Key",
    regex: /aws(.{0,20})?(?<![A-Z0-9])[A-Z0-9]{40}(?![A-Z0-9])/i,
    severity: "critical",
  },
  // Google API Key
  {
    name: "Google API Key",
    regex: /AIza[0-9A-Za-z\-_]{35}/,
    severity: "critical",
  },
  // OpenAI API Key
  {
    name: "OpenAI API Key",
    regex: /sk-[a-zA-Z0-9]{20,}/,
    severity: "critical",
  },
  // Anthropic API Key
  {
    name: "Anthropic API Key",
    regex: /sk-ant-[a-zA-Z0-9\-_]{20,}/,
    severity: "critical",
  },
  // Stripe API Key
  {
    name: "Stripe API Key",
    regex: /(?:sk|rk|pk)_(?:test|live)_[a-zA-Z0-9]{10,}/,
    severity: "critical",
  },
  // GitHub Personal Access Token
  {
    name: "GitHub Token",
    regex: /ghp_[a-zA-Z0-9]{36}/,
    severity: "critical",
  },
  // GitHub OAuth Token
  {
    name: "GitHub OAuth Token",
    regex: /gho_[a-zA-Z0-9]{36}/,
    severity: "critical",
  },
  // Slack Token
  {
    name: "Slack Token",
    regex: /xox[baprs]-[0-9a-zA-Z-]{10,}/,
    severity: "critical",
  },
  // JWT Token
  {
    name: "JWT Token",
    regex: /eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}/,
    severity: "high",
  },
  // Private Key Block
  {
    name: "Private RSA Key",
    regex: /-----BEGIN (?:RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----/,
    severity: "critical",
  },
  // Generic password assignment
  {
    name: "Hardcoded Password",
    regex: /(?:password|passwd|pwd)\s*[:=]\s*["'][^"']{6,}["']/i,
    severity: "high",
  },
  // Generic secret assignment
  {
    name: "Hardcoded Secret",
    regex: /(?:secret|api[_-]?key|token|auth[_-]?token)\s*[:=]\s*["'][A-Za-z0-9+/=_-]{16,}["']/i,
    severity: "high",
  },
  // PostgreSQL connection string with password
  {
    name: "Postgres Connection String",
    regex: /postgres(?:ql)?:\/\/[^:]+:[^@]+@[^:]+:\d+/, 
    severity: "critical",
  },
  // Mongoose connection string with password
  {
    name: "MongoDB Connection String",
    regex: /mongodb(?:\+srv)?:\/\/[^:]+:[^@]+@/,
    severity: "critical",
  },
  // General connection string with password
  {
    name: "Connection String with Credentials",
    regex: /:\/\/[^:\s@]+:[^@\s]+@/,
    severity: "high",
  },
] as const

/**
 * Environment variable values pattern (excluding .env.example and .env.test).
 */
const ENV_VAR_PATTERN = /^\s*[A-Z0-9_]+=\s*["']?[A-Za-z0-9+/=_-]{16,}["']?/m

/** Files that should never be committed. */
const BLOCKED_FILENAMES = [
  ".env",
  ".env.local",
  ".env.production",
  ".env.development",
  ".env.staging",
]

/** Currently staged files path pattern for binary detection. */
const BINARY_EXTENSIONS = [".png", ".jpg", ".jpeg", ".gif", ".ico", ".pdf", ".zip", ".tar", ".gz"]

/**
 * Checks if a file path matches blocked filenames.
 *
 * @param filePath - The file path to check
 * @returns True if the file should be blocked
 */
function isBlockedFile(filePath: string): boolean {
  const base = filePath.split("/").pop() ?? ""
  return BLOCKED_FILENAMES.includes(base)
}

/**
 * Checks if a file path is a binary file.
 *
 * @param filePath - The file path to check
 * @returns True if the file is binary
 */
function isBinaryFile(filePath: string): boolean {
  return BINARY_EXTENSIONS.some((ext) => filePath.toLowerCase().endsWith(ext))
}

/**
 * Extracts the git command from a bash command string.
 *
 * @param command - The bash command to inspect
 * @returns True if the command is a git commit or git add
 */
function isGitCommit(command: string): boolean {
  const normalized = command.trim()
  return (
    /^git\s+commit/.test(normalized) ||
    /^git\s+add/.test(normalized) ||
    /^git\s+commit\s+-/.test(normalized) ||
    /\bgit\s+commit\b/.test(normalized)
  )
}

/**
 * Converts a bytes buffer to a string, ignoring binary data.
 *
 * @param buffer - The buffer to convert
 * @returns The string content
 */
function bufferToString(buffer: Uint8Array): string {
  return new TextDecoder("utf-8").decode(buffer)
}

/**
 * Scans file content for secret patterns.
 *
 * @param content - The file content to scan
 * @param filePath - The path of the file being scanned
 * @returns Array of found secret patterns with names and severity
 */
function scanForSecrets(content: string, filePath: string): string[] {
  const found: string[] = []

  for (const pattern of SECRET_PATTERNS) {
    if (pattern.regex.test(content)) {
      found.push(`${pattern.name} (${pattern.severity}) in ${filePath}`)
    }
  }

  // Check for env var values (but skip .env.example / .env.test)
  if (
    !filePath.includes(".env.example") &&
    !filePath.includes(".env.test") &&
    ENV_VAR_PATTERN.test(content)
  ) {
    found.push(`Possible secret value assignment (environment variable) in ${filePath}`)
  }

  return found
}

/**
 * Gets the list of staged files using git.
 *
 * @param $ - The shell API from plugin context
 * @returns Array of staged file paths
 */
async function getStagedFiles($: any): Promise<string[]> {
  try {
    const result = await $`git diff --cached --name-only --diff-filter=ACM`
    const output = await result.text()
    return output
      .split("\n")
      .map((line: string) => line.trim())
      .filter(Boolean)
  } catch {
    return []
  }
}

/**
 * Reads a file's content.
 *
 * @param $ - The shell API from plugin context
 * @param filePath - The file path to read
 * @param directory - The workspace directory
 * @returns File content as string, or empty string on error
 */
async function readFileContent($: any, filePath: string, directory: string): Promise<string> {
  try {
    // Use git show to read the staged version of the file
    const result = await $`git show :${filePath}`
    const output = await result.text()
    return output
  } catch {
    // Fall back to reading from disk
    try {
      const fullPath = filePath.startsWith("/") ? filePath : `${directory}/${filePath}`
      const result = await $`cat ${fullPath}`
      return await result.text()
    } catch {
      return ""
    }
  }
}

/**
 * Commit Security Guard plugin.
 *
 * Intercepts git commit and git add commands, scans staged files
 * for secret patterns, and blocks the operation if secrets are found.
 *
 * Triggers on:
 * - `bash` tool calls containing `git commit` or `git add`
 *
 * Actions:
 * - Scans staged files for API keys, tokens, passwords, private keys
 * - Blocks commit if critical/high severity secrets found
 * - Alerts for medium severity findings
 */
export const CommitSecurityGuard: Plugin = async ({ $, directory }) => {
  return {
    "tool.execute.before": async (input, output) => {
      // Only intercept bash commands
      if (input.tool !== "bash") {
        return
      }

      const command = output.args?.command as string | undefined
      if (!command || !isGitCommit(command)) {
        return
      }

      // Get staged files
      const stagedFiles = await getStagedFiles($)

      if (stagedFiles.length === 0) {
        return
      }

      const findings: string[] = []
      const blockedFiles: string[] = []

      for (const filePath of stagedFiles) {
        // Skip binary files (can't scan reliably)
        if (isBinaryFile(filePath)) {
          continue
        }

        // Check for blocked env files
        if (isBlockedFile(filePath)) {
          blockedFiles.push(filePath)
          continue
        }

        // Read and scan file content
        const content = await readFileContent($, filePath, directory)
        if (!content) continue

        const fileFindings = scanForSecrets(content, filePath)
        if (fileFindings.length > 0) {
          findings.push(...fileFindings)
        }
      }

      // Compose block message
      const messages: string[] = []

      if (blockedFiles.length > 0) {
        messages.push(`BLOCKED FILES: ${blockedFiles.join(", ")}`)
      }
      if (findings.length > 0) {
        messages.push("POTENTIAL SECRETS FOUND:")
        findings.forEach((f) => messages.push(`  - ${f}`))
      }

      if (messages.length > 0) {
        // Block the commit
        throw new Error(
          `[CommitSecurityGuard] Cannot proceed: ${
            messages.join("\n")
          }\n\nFix the issue or use git add -p to stage only safe files. Remove secrets before committing.`
        )
      }
    },
  }
}

export default CommitSecurityGuard
