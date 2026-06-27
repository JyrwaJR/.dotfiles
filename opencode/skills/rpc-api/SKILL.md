---
name: calling-rpc-apis
description: Use when calling backend functions via the custom RPC API (rpc() helper, single POST /make_request endpoint, typed ApiResponse wrappers). Also use when implementing new feature hooks that call the backend, debugging RPC call failures, or adding new METHODS entries.
origin: project
---

# RPC API Patterns

This project uses a **custom RPC (Remote Procedure Call) pattern** — not tRPC, not REST — where all backend operations are routed through a single `POST /make_request` endpoint. The `rpc()` helper function provides a typed interface.

## When to Activate

- You need to call a backend function from a hook, store, or service
- You are adding a new RPC method (adding to `METHODS` constant and calling it)
- You are debugging an RPC call that returns unexpected data
- You are writing a new feature that fetches or mutates data from the backend
- You see `rpc()` or `http.post('/make_request', ...)` in the codebase and need to understand the pattern
