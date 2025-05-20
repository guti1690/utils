# TailwindCSS Guidelines

## Utility-First

- Embrace utility classes directly in markup: `py-4 px-6 text-gray-700`
- Prefer layout and spacing with Tailwind utilities over custom CSS

## Responsiveness

- Mobile-first approach: start with base styles and add responsive variants
- Use responsive prefixes consistently: `md:flex`, `lg:grid-cols-3`
- Leverage breakpoint modifiers in this order: base → sm → md → lg → xl → 2xl → 4xl
- Hide/show elements responsively with `hidden md:block` or `md:hidden`

## Custom Theming

- Use theme-specific color scales in `tailwind.config.js` (dorado, bolt, brick, etc.)
- Leverage Tailwind's theme extension for custom colors, spacing, and components
- Access theme values in SCSS with `theme('colors.bolt.DEFAULT')`
- Use defined classes in `styles/globals.scss`
- Extend grid templates for specialized layouts

## Component Styling

- Create component patterns with `@layer components` in `styles/globals.scss`
- Use consistent spacing and typography with utility classes
- Add custom animations with `@keyframes` and animation classes

## Class Management

- Use `clsx` for conditional class composition: `clsx('base-class', { 'conditional-class': condition })`
- Group related utilities for readability
- Break long class strings into logical groupings for complex components
- Format multi-line class strings with template literals for readability

## Tailwind Integration

- Use standard directives in SCSS: `@tailwind base`, `@tailwind components`, `@tailwind utilities`
- Create utility patterns with `@layer utilities` in `styles/globals.scss`
- Configure JIT mode for optimal development experience
