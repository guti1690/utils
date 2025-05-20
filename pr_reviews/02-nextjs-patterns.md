# Next.js Patterns & Conventions

## Project Structure

- Use `/pages` approach for the directory structure
- Modular architecture with clear separation of concerns:
  - `/components` - Reusable UI components
  - `/contexts` - React context providers
  - `/hooks` - Custom React hooks
  - `/lib` - Core business logic and utilities
  - `/providers` - Service providers and wrappers
  - `/schemas` - Data validation schemas
  - `/types` - TypeScript type definitions

## Routing & Pages

- Dynamic routes using `[...slug].js` for catch-all routes
- Organized route grouping:
  - `/account` - User account related pages
  - `/cart` - Shopping cart functionality
  - `/checkout` - Checkout process
  - `/products` - Product related pages
- Custom error handling with `_error.tsx` and `404.tsx`

## Middleware & Authentication

- Robust middleware implementation for:
  - User state management
  - A/B testing and experiments
  - Dynamic redirects
  - Custom path handling
- Cookie-based authentication with environment-aware session handling

## Performance Optimization

- Optimize Web Vitals (LCP, CLS, FID)
- Use dynamic imports for non-critical components
- Implement proper image optimization:
  - Use WebP format
  - Include size data
  - Implement lazy loading
- Minimize client-side JavaScript
- Leverage Next.js built-in optimizations

## State Management

- Context-based state management
- Custom hooks for shared business logic
- Modular data fetching patterns

## API Integration

- Internal API communication with Django backend
- Structured error handling and response formatting
- Use SWR for client-side data fetching and caching
- Implement proper error boundaries
- Wrap client components in `Suspense` with fallback
