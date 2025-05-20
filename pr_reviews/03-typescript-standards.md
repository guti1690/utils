# TypeScript Standards

## Type Safety

- Always type function parameters and return values
- Prefer interfaces for complex domain objects (e.g., `Deal`, `Plan`, `User`)
- Use `unknown` instead of `any` when type is unclear
- Use explicit type annotations for function parameters
- Leverage indexed access types for consistent property access

## Type Organization

- Group related types in domain-specific files (e.g., `deal.d.ts`, `user.d.ts`)
- Use `.d.ts` extension for declaration files with interfaces
- Use `.ts` extension for files with type utility functions
- Co-locate component prop types with their components when simple
- Move complex prop types to dedicated type files when reused

## Type Definitions

- Use union types for string literals: `'success' | 'error' | 'warning'`
- Use enums for constant values with semantic meaning (e.g., `DEAL_STAGE`, `CommentType`)
- Prefer discriminated unions for state management
- Use optional properties (`?:`) instead of conditionals
- Use null coalescing (`??`) and optional chaining (`?.`) operators

## Utility Types

- Use `Record<K, T>` for dynamic object properties
- Use `Partial<T>` for objects with optional fields
- Use `Pick<T, K>` to select specific properties
- Always prefer type guards over casting
- Use type narrowing with `instanceof` and type predicates

## Type Guards

- Implement custom type guards with is-type predicates
- Use `typeof` checks for primitive types
- Use `instanceof` for class instances
- Create precise error typing with discriminated unions

## Configuration

- Use path aliases with `~/*` for imports
