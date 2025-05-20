# React Best Practices

## Naming Conventions

- Use PascalCase for components: `UserCard.tsx`, `SimpleButton.tsx`, `CurrencySelector.tsx`
- Use camelCase for hooks and utility functions: `useLocalStorage.ts`, `useCurrency.ts`, `useDiscussionStats.ts`
- Name files after the default export: `ProductList.tsx` → `export default ProductList`
- Use directory-based organization for related components (e.g., `/components/discussions/card/`)

## Functional Components & Hooks

- Always use function components: `function SimpleButton({ ... })`
- Export memoized components: `export default memo(SimpleButton);`
- Use named function components for better debugging: `const InlineNotificationSignup = memo(function InlineNotificationSignup({ ... })`
- Prefer `useEffect` with cleanups when side-effects are necessary
- Extract reusable logic into custom hooks with domain-specific names (e.g., `useCurrency`, `useTimerReasons`)

## Component Design

- Keep components small and focused (max 500 LOC)
- Do not add more than one component per file
- Use composition instead of prop drilling
- Prefer controlled inputs for forms when using Dorado Form components
- Use React Hook Form with `yupResolver` for form validation
- Implement TypeScript interfaces for component props
- Use default values for optional props: `className = ''`, `size = SimpleButtonSizes.md`
- Use `Readonly` for components props (e.g., `export default memo(function Credits({ onClick }: Readonly<RemoveCartButtonProps>): ReactElement {`)

## State Management

- Prefer `useState` and `useReducer` for local state
- Use context API for shared state in the component tree (e.g., `PDPContext`, `CartContext`)
- Use GlobalContext only for shared states across all the codebase. (e.g., experiment variants)
- Implement domain-specific contexts for different parts of the app (e.g., `PDPContext`, `CartContext`)
- Use async state management patterns with loading/error states

## Accessibility

- Use semantic HTML (`<button>`, `<nav>`, etc.)
- Apply proper ARIA attributes: `aria-label`, `aria-current`, `aria-expanded`
- Use appropriate roles in custom components: `role="navigation"`, `role="img"`
- Ensure proper focus management in modals and interactive elements

## Performance

- Extensively use `React.memo` for component memoization
- Implement `useMemo` for computed values: `const options = useMemo(() => {...}, [dependencies])`
- Apply `useCallback` for event handlers and functions passed as props
- Use proper dependency arrays in React hooks
- Leverage code-splitting and dynamic imports
- Minimize re-renders with proper state management

## UI Component Library

- Use Dorado React components from `@appsumo/dorado-react` when available (`Button`, `Form`, `Heading`)
- Apply Tailwind v3.2.4 CSS utility classes for styling
- Implement consistent spacing and typography with utility classes
- Use clsx for conditional class name composition
- Use Shadcn UI components as the primary component library, unless there is a React component available under `@appsumo/dorado-react`
- Follow Shadcn UI's component patterns and conventions
- Extend Shadcn UI components when needed, maintaining their API
- Implement proper accessibility attributes
- Use semantic HTML elements
