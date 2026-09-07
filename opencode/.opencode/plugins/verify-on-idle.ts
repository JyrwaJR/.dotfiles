/**
 * Verify-On-Idle Plugin for OpenCode
 *
 * Runs verification checks when a session becomes idle (agent finishes a turn).
 * Uses the event hook to listen for session.idle events.
 *
 * Behavior:
 * - Only runs in projects with package.json (skips non-Node projects silently)
 * - Only runs tsc --noEmit when typescript is a dependency
 * - Only runs npm test when a test script exists
 * - Never fails loudly for missing tooling — logs a quiet skip
 *
 * @module verify-on-idle
 */

import type { Plugin } from "@opencode-ai/plugin"

/**
 * Reads a file from the workspace, returning null if it does not exist.
 *
 * @param $ - The shell API from plugin context
 * @param directory - The workspace directory
 * @param relativePath - Path relative to the workspace root
 * @returns File contents as parsed JSON, or null on error
 */
async function readJson($: any, directory: string, relativePath: string): Promise<any | null> {
  try {
    const result = await $`cat ${directory}/${relativePath}`
    const text = await result.text()
    return JSON.parse(text)
  } catch {
    return null
  }
}

/**
 * Verify-On-Idle plugin that triggers verification when the agent finishes.
 *
 * Triggers on:
 * - `session.idle` event (agent turn completed)
 *
 * Actions (project-aware):
 * - Runs `tsc --noEmit` only if typescript is a dependency
 * - Runs `npm test` only if a test script exists
 * - Logs results; silent skips for non-Node/non-TS projects
 */
export const VerifyOnIdle: Plugin = async ({ $, directory }) => {
  return {
    event: async ({ event }) => {
      // Only trigger on session idle (agent finished a turn)
      if (event.type !== "session.idle") {
        return
      }

      // Only run in Node projects with a package.json
      const pkg = await readJson($, directory, "package.json")
      if (!pkg) {
        return // not a Node project — skip silently
      }

      const results: string[] = []
      const errors: string[] = []

      // Run type checking only if TypeScript is a dependency
      const hasTypeScript =
        (pkg.dependencies?.typescript || pkg.devDependencies?.typescript) != null
      if (hasTypeScript) {
        try {
          await $`cd ${directory} && npx tsc --noEmit`
          results.push("tsc: passed")
        } catch {
          errors.push("tsc: type errors found")
        }
      }

      // Run tests only if a test script is defined
      const hasTestScript = typeof pkg.scripts?.test === "string"
      if (hasTestScript) {
        try {
          await $`cd ${directory} && npm test --silent`
          results.push("test: passed")
        } catch {
          errors.push("test: failures detected")
        }
      }

      // Only log when something meaningful happened
      if (results.length === 0 && errors.length === 0) {
        return // nothing to verify — stay silent
      }

      if (errors.length > 0) {
        console.warn("[verify-on-idle] Verification issues found:")
        errors.forEach((e) => console.warn(`  - ${e}`))
      }
      if (results.length > 0 && errors.length === 0) {
        console.log("[verify-on-idle] All checks passed")
      }
    },
  }
}

export default VerifyOnIdle