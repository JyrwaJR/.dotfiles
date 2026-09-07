/**
 * Auto-Lint Plugin for OpenCode
 *
 * Runs linting and formatting after file edits.
 * Uses tool.execute.after hook to trigger checks on edit/write operations.
 *
 * @module auto-lint
 */

import type { Plugin } from "@opencode-ai/plugin"

/** File extensions to lint */
const LINT_EXTENSIONS = [".ts", ".tsx", ".js", ".jsx"]

/** File extensions to format */
const FORMAT_EXTENSIONS = [".ts", ".tsx", ".js", ".jsx", ".json", ".css", ".md"]

/**
 * Checks if a file path matches the given extensions.
 *
 * @param filePath - The file path to check
 * @param extensions - Array of extensions to match (e.g., [".ts", ".tsx"])
 * @returns True if the file matches any extension
 */
function matchesExtension(filePath: string, extensions: string[]): boolean {
  return extensions.some((ext) => filePath.endsWith(ext))
}

/**
 * Runs a shell command and reports whether it succeeded.
 * Missing binaries or non-zero exits are swallowed (returns false),
 * so absent tooling does not spam the session.
 *
 * @param $ - The shell API from plugin context
 * @param command - The command to run (single string, no shell metacharacters)
 * @returns True if the command exited successfully
 */
async function runSilently($: any, command: string): Promise<boolean> {
  try {
    await $`${command}`
    return true
  } catch {
    return false
  }
}

/**
 * Auto-Lint plugin that runs linting and formatting after file edits.
 *
 * Triggers on:
 * - `edit` tool calls
 * - `write` tool calls
 *
 * Actions:
 * - Runs Prettier formatting on supported files (missing formatter = silent skip)
 * - Runs ESLint fix on TypeScript/JavaScript files (missing linter = silent skip)
 * - Attaches results to output metadata
 */
export const AutoLint: Plugin = async ({ $, directory }) => {
  return {
    "tool.execute.after": async (input, output) => {
      // Only trigger on file mutation tools
      if (input.tool !== "edit" && input.tool !== "write") {
        return
      }

      const filePath = input.args?.filePath as string | undefined
      if (!filePath) {
        return
      }

      // Resolve relative paths
      const fullPath = filePath.startsWith("/")
        ? filePath
        : `${directory}/${filePath}`

      const results: string[] = []

      // Run Prettier formatting
      if (matchesExtension(fullPath, FORMAT_EXTENSIONS)) {
        const ok = await runSilently($, `npx prettier --write ${fullPath}`)
        if (ok) results.push("prettier: formatted")
      }

      // Run ESLint fix
      if (matchesExtension(fullPath, LINT_EXTENSIONS)) {
        const ok = await runSilently($, `npx eslint --fix ${fullPath}`)
        if (ok) results.push("eslint: checked")
      }

      // Attach results to output metadata
      if (results.length > 0) {
        output.metadata = {
          ...output.metadata,
          autoLint: results,
        }
      }
    },
  }
}

export default AutoLint