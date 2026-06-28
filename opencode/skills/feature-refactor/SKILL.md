---
name: feature-refactor
description: Standardizes feature architecture using barrel exports and shared identity infrastructure. Use this skill when creating new features or refactoring existing ones to ensure they follow the project's modular design patterns.
---

# Feature Refactor & Standardization Skill

You are an expert in modular React Native architecture and project-wide refactoring. Your mission is to maintain a strict separation of concerns between feature-specific logic and global infrastructure.

## 🏛️ Core Principles

1.  **Global Identity First**: All authentication, biometrics, and session-state MUST reside in `src/shared/`.
2.  **Public API Enforcement**: Every feature must expose its capabilities through an `index.ts` barrel file.
3.  **Encapsulation**: UI Components (Screens) should use custom hooks or services, never direct `http` or `api` calls.

---

## 🏗️ Feature Structure Template

Every feature in `src/features/[name]/` should follow this layout:

```text
src/features/[name]/
├── api/             # API Endpoint definitions
├── components/      # Feature-specific UI components
├── hooks/           # TanStack Query or logic hooks
├── screens/         # Main screen components
├── services/        # HTTP fetching logic (Pure functions)
├── types/           # Domain-specific TypeScript models
├── validators/      # Zod schemas for forms/API
└── index.ts        # THE PUBLIC API (MANDATORY)
```

---

## 📦 Barrel Export (index.ts) Patterns

### 1. Re-exporting Default Exports (Screens)
If a screen uses `export default`, you MUST alias it in the index:
```typescript
// ✅ CORRECT
export { default as MyScreen } from './screens/MyScreen';

// ❌ INCORRECT (Will fail resolution)
export * from './screens/MyScreen';
```

### 2. Grouped Exports
Organize `index.ts` into logical sections for readability:
```typescript
// public exports
export * from './api/feature.endpoints';
// Components
export * from './components/MyComponent';
// Hooks
export * from './hooks/useFeature';
// Screens
export { default as MyScreen } from './screens/MyScreen';
// Types
export * from './types';
```

---

## 🛡️ Identity & Auth Integration

When adding auth to a feature:
1.  **ALWAYS** import `useAuth` from `@/src/shared/hooks/useAuth`.
2.  **ALWAYS** import `useLocalAuth` from `@/src/shared/hooks/useLocalAuth`.
3.  **NEVER** re-implement token storage or session checks within a feature.

---

## 🚀 Execution Workflow

1.  **Map**: Identify existing direct dependencies (e.g., `http.get` in a Screen).
2.  **Extract**: Move that logic to a `service.ts` and wrap it in a `hook.ts`.
3.  **Expose**: Add the new hook/service to the feature's `index.ts`.
4.  **Update**: Switch the Screen to use the new hook and update all external imports to use the feature's barrel.
5.  **Verify**: Run `npx eslint .` to ensure no barrel resolution errors.
