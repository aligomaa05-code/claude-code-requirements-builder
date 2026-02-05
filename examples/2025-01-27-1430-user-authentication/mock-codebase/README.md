# Mock Codebase

This folder demonstrates what a codebase looks like **after** running `/requirements-inject-todos`.

## What This Shows

### New Files Created
- `src/services/AuthService.ts` - Created with TODO at top
- `src/pages/auth/Login.tsx` - Created with TODO and boilerplate

### Existing Files Modified  
- `src/utils/validation.ts` - TODO inserted after imports, before existing code

## TODO Format Example

```typescript
// TODO [REQ:2025-01-27-1430-user-authentication] [ID:TODO-002] [P:1] Create auth service
// WHY: Core authentication functionality required for all user interactions
// DONE WHEN: AuthService class exports register(), login(), logout() methods
// SPEC: requirements/2025-01-27-1430-user-authentication/06-requirements-spec.md
```

## Finding All TODOs

```bash
# From project root
grep -rn "TODO \[REQ:2025-01-27-1430" src/

# Output:
# src/services/AuthService.ts:4: // TODO [REQ:2025-01-27-1430-user-authentication] ...
# src/utils/validation.ts:3: // TODO [REQ:2025-01-27-1430-user-authentication] ...
# src/pages/auth/Login.tsx:4: // TODO [REQ:2025-01-27-1430-user-authentication] ...
```

## Note

This is a **demonstration only**. In real usage:
- Files would be in your actual project's `src/` directory
- More files would be modified based on the Implementation Map
- The manifest (08-todo-manifest.md) tracks all modifications
