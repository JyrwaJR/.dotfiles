/**
 * Verify-On-Idle Plugin for OpenCode
 *
 * Runs verification checks when a session becomes idle (agent finishes a turn).
 * Uses the event hook to listen for session.idle events.
 *
 * @module verify-on-idle
 */

import type { Plugin } from "@opencode-ai/plugin"

/**
 * Verify-On-Idle plugin that triggers verification when the agent finishes.
 *
 * Triggers on:
 * - `session.idle` event (agent turn completed)
 *
 * Actions:
 * - Runs type checking (tsc --noEmit)
 * - Runs tests (npm test)
 * - Logs verification results
 *
 * Note: This plugin uses the event hook, not tool hooks.
 * It fires after the agent completes a turn, providing a safety net
 * for catching issues before the user reviews the output.
 */
export const VerifyOnIdle: Plugin = async ({ $, client, directory }) => {
  return {
    event: async ({ event }) => {
      // Only trigger on session idle (agent finished a turn)
      if (event.type !== "session.idle") {
        return
      }

      const results: string[] = []
      const errors: string[] = []

      // Run type checking
      try {
        await $`cd ${directory} && npx tsc --noEmit 2>&1`
        results.push("tsc: passed")
      } catch (err) {
        const output = err instanceof Error ? err.message : String(err)
        errors.push(`tsc: ${output.slice(0, 200)}`)
      }

      // Run tests (if test script exists)
      try {
        await $`cd ${directory} && npm test 2>&1`
        results.push("test: passed")
      } catch (err) {
        const output = err instanceof Error ? err.message : String(err)
        errors.push(`test: ${output.slice(0, 200)}`)
      }

      // Log results if there are failures
      if (errors.length > 0) {
        console.warn("[verify-on-idle] Verification issues found:")
        errors.forEach((e) => console.warn(`  - ${e}`))
      }

      // Log success if all passed
      if (results.length > 0 && errors.length === 0) {
        console.log("[verify-on-idle] All checks passed")
      }
    },
  }
}

export default VerifyOnIdle
