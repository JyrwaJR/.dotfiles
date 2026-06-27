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

## Usage Patterns

### Pattern 1: TanStack Query Wrapper (read — `useQuery`)

This is the **most common pattern** — wrap `rpc()` inside a custom hook using `useQuery`:

```typescript
// src/features/salary/hooks/use-salary-statements.ts
import { useQuery } from '@tanstack/react-query';
import { rpc } from '@utils/api';
import { METHODS, QUERY_KEYS } from '@utils/constants';
import { SalarySlip } from '../types';

export function useSalaryStatements() {
  const { emp_cd, isSignedIn } = useAuthStore();

  const { data, isFetched, isError, error, refetch, isLoading, isFetching } = useQuery({
    queryKey: QUERY_KEYS.SALARY.STATEMENTS(emp_cd),
    queryFn: () => rpc<SalarySlip[]>(METHODS.GET_EMP_SALARY_STATEMENTS, { emp_cd }),
    select: (response) => response?.data,  // ⬅ Unwrap ApiResponse.data
    enabled: !!emp_cd && isSignedIn,        // ⬅ Don't fire until authenticated
  });

  return { data, isFetched, isError, error, refetch, isLoading, isFetching };
}
```

**Key rules for query wrappers:**
1. Always pass the generic `rpc<TResult>` with your expected response type
2. Use `select: (res) => res.data` to unwrap `ApiResponse` so consumers get `TResult | undefined`
3. Check `enabled` — never fire a query before the user is signed in
4. Use `QUERY_KEYS` (defined in `src/shared/utils/constants/query-keys.ts`) for cache key structure

### Pattern 2: RPC Call with `select` unwrapping + params

```typescript
// src/features/leave/hooks/use-leave-detail.ts
import { useQuery } from '@tanstack/react-query';
import { QUERY_KEYS, METHODS } from '@utils/constants';
import { rpc } from '@utils/api';

interface LeaveResponse extends Leave {
  leave_bal: LeaveBal;
}

export function useLeaveDetail(id: string) {
  const { isSignedIn } = useAuthStore();

  return useQuery({
    queryKey: QUERY_KEYS.LEAVE.DETAILS(id),
    queryFn: () => rpc<LeaveResponse>(METHODS.GET_EMP_LEAVE_DETAILS_DETAILS, { leave_id: id }),
    enabled: !!id && isSignedIn,
    select: (data) => data.data,
  });
}
```

### Pattern 3: Mutation (write — `useMutation`)

```typescript
// src/features/auth/hooks/use-login-mutation.ts
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { rpc } from '@utils/api';
import { ApiResponse } from '@sharedTypes/api';
import { METHODS } from '@utils/constants';

type LoginResponse = {
  access_token: string;
  expires_in: number;
  scope: 'default';
  token_type: 'Barear' | 'Basic';
};

export const useLoginMutation = () => {
  const queryClient = useQueryClient();

  return useMutation<ApiResponse<LoginResponse>, unknown, LoginFormInputs>({
    mutationFn: (data) =>
      rpc<LoginResponse>(METHODS.EMP_LOGIN, {
        password: data.password,
        emp_cd: data.emp_cd,
      }),
    onSuccess: (response) => {
      if (response.success) {
        // Handle successful login — invalidate queries, store tokens
        queryClient.invalidateQueries({ queryKey: ['me'] });
      }
    },
  });
};
```

**Mutation rules:**
1. The mutation generic is `useMutation<ApiResponse<T>, Error, TParams>` — the first param is what `mutationFn` returns
2. Check `response.success` inside `onSuccess` — failed RPCs still resolve as HTTP 200 with `success: false`
3. Use `meta: { auth: true }` to skip auth headers for login/register endpoints

### Pattern 4: Direct RPC call (in stores / services)

```typescript
// Inside a Zustand store action
const res = await rpc<UserT>(METHODS.GET_EMP_DETAILS, { emp_cd: empCode });

if (res.success && res.data) {
  set({ user: res.data });
} else {
  // Don't swallow the failure
  throw new Error(res.message || 'Failed to fetch employee details');
}
```

**Store pattern rules:**
1. Always check `res.success` before using `res.data`
2. Throw or return an error state on failure — don't silently fall through to a stale state
3. The `data` field is `T | undefined`, so guard with `&& res.data` for TypeScript narrow
```
