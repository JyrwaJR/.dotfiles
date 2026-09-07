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
 * Auto-Lint plugin that runs linting and formatting after file edits.
 *
 * Triggers on:
 * - `edit` tool calls
 * - `write` tool calls
 *
 * Actions:
 * - Runs Prettier formatting on supported files
 * - Runs ESLint fix on TypeScript/JavaScript files
 * - Logs results to output metadata
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
        try {
          await $`npx prettier --write ${fullPath}`
          results.push("prettier: formatted")
        } catch {
          // Prettier not available or failed — skip silently
        }
      }

      // Run ESLint fix
      if (matchesExtension(fullPath, LINT_EXTENSIONS)) {
        try {
          await $`npx eslint --fix ${fullPath} 2>/dev/null || true`
          results.push("eslint: checked")
        } catch {
          // ESLint not available or failed — skip silently
        }
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
