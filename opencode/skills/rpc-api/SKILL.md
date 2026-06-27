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

## Core Concepts

### How the RPC System Works

| Concept | Detail |
|---------|--------|
| **Endpoint** | `POST /make_request` — all backend functions route through this single URL |
| **Transport** | Axios-based HTTP client (or `rn-fetch-blob` in some RN environments) |
| **Request shape** | `{ functionName: string, ...params }` — the method name + spread params |
| **Response shape** | Always wrapped in `ApiResponse<T>` = `{ success: boolean; message: string; data?: T }` |
| **Auth** | Token refresh interceptor on the Axios instance handles 401 → refresh → retry |
| **Type safety** | `rpc<TResult>(functionName, params)` infers response type via generic |

### Key Files

| File | Purpose |
|------|---------|
| `src/shared/utils/api/rpc.ts` | The `rpc()` function — single entry point for all RPC calls |
| `src/shared/utils/api/http.ts` | Axios HTTP client with `get`/`post`/`put`/`delete` methods |
| `src/shared/utils/api/response.ts` | `handleResponse` / `handleError` — response unwrapping and error normalization |
| `src/shared/utils/api/interceptors.ts` | Axios interceptors (auth headers, token refresh) |
| `src/shared/utils/api/axios.ts` | Axios instance configuration |
| `src/shared/utils/constants/method.ts` | `METHODS` constant — string enum of all RPC function names |
| `src/shared/types/api.ts` | `ApiResponse<T>` type definition |

## Quick Reference

### The `rpc()` Function

```typescript
// src/shared/utils/api/rpc.ts (simplified)
const rpc = async <TResult, TParams = unknown>(
  functionName: string,       // Key from METHODS constant
  params?: TParams            // Params object (spread into request body)
): Promise<ApiResponse<TResult>> => {
  return http.post<TResult>('/make_request', {
    functionName,
    ...params,
  });
};
```

**Key detail:** `params` are **spread** into the top-level request body alongside `functionName`. The request body sent to the server is:

```json
{
  "functionName": "get_employee_details",
  "emp_cd": "EMP001",
  ...// every key from params at top level
}
```

### The `METHODS` Constant

```typescript
// src/shared/utils/constants/method.ts
export const METHODS = {
  GET_EMP_DETAILS: 'get_employee_details',
  EMP_LOGIN: 'employee_login',
  GET_EMP_LEAVE_DETAILS: 'get_employee_leave_details',
  GET_EMP_LEAVE_DETAILS_DETAILS: 'get_employee_leave_details_details',
  GET_EMP_SALARY_STATEMENTS: 'get_employee_salary_statements',
  GET_EMP_SALARY_STATEMENTS_DETAILS: 'get_employee_salary_statements_DETAILS',
} as const;

export type METHODS = keyof typeof METHODS;
```

**Always use `METHODS.X` not raw strings.** The type `METHODS` is used by Zod validators to restrict allowed function names server-side.

### The `ApiResponse<T>` Type

```typescript
// src/shared/types/api.ts
interface ApiResponse<T> {
  success: boolean;    // Always check this before using data
  message: string;     // Human-readable result/error
  data?: T;            // The typed payload (undefined on failure)
}
```
