# TODO Manifest: User Authentication

**Requirement**: 2025-01-27-1430-user-authentication
**Generated**: 2025-01-27T16:00:00Z
**Status**: 12 open, 3 done of 15 total

## TODOs

### TODO-001 ✅
**File**: `src/db/prisma/schema.prisma:45`
**Priority**: P1
**Task**: Add User, Session, PasswordReset models to schema
**Done when**: Models exist with all required fields; migrations run successfully
**Completed**: 2025-01-27T17:00:00Z

### TODO-002 ⬜
**File**: `src/services/AuthService.ts:1`
**Priority**: P1
**Task**: Create auth service with register, login, logout methods
**Done when**: AuthService class exports register(), login(), logout() methods

### TODO-003 ✅
**File**: `src/utils/validation.ts:25`
**Priority**: P1
**Task**: Add password validation schema (8+ chars, uppercase, number)
**Done when**: passwordSchema validates correctly; tests pass
**Completed**: 2025-01-27T17:15:00Z

### TODO-004 ⬜
**File**: `src/services/EmailService.ts:1`
**Priority**: P1
**Task**: Create email service for verification and reset emails
**Done when**: Can send verification and password reset emails

### TODO-005 ⬜
**File**: `src/api/routes/auth.ts:1`
**Priority**: P1
**Task**: Create auth routes (register, login, logout, verify, reset)
**Done when**: All 7 endpoints respond correctly

### TODO-006 ⬜
**File**: `src/middleware/auth.ts:1`
**Priority**: P1
**Task**: Create auth middleware for protected routes
**Done when**: Middleware validates JWT and attaches user to request

### TODO-007 ⬜
**File**: `src/middleware/rateLimit.ts:1`
**Priority**: P2
**Task**: Add auth-specific rate limiting
**Done when**: Auth endpoints limited to 5 requests/minute per IP

### TODO-008 ⬜
**File**: `src/pages/auth/Login.tsx:1`
**Priority**: P1
**Task**: Create Login page with form and validation
**Done when**: User can submit email/password; errors display; redirects on success

### TODO-009 ⬜
**File**: `src/pages/auth/Register.tsx:1`
**Priority**: P1
**Task**: Create Register page with form and validation
**Done when**: User can register; validation errors show; redirects to verify notice

### TODO-010 ⬜
**File**: `src/pages/auth/ForgotPassword.tsx:1`
**Priority**: P2
**Task**: Create ForgotPassword page
**Done when**: User can request reset email; confirmation shown

### TODO-011 ⬜
**File**: `src/pages/auth/ResetPassword.tsx:1`
**Priority**: P2
**Task**: Create ResetPassword page
**Done when**: User can set new password with valid token

### TODO-012 ⬜
**File**: `src/pages/auth/VerifyEmail.tsx:1`
**Priority**: P2
**Task**: Create email verification handler page
**Done when**: Page handles verification token; shows success/error

### TODO-013 ✅
**File**: `src/components/auth/AuthForm.tsx:1`
**Priority**: P1
**Task**: Create shared AuthForm component
**Done when**: Reusable form wrapper with consistent styling
**Completed**: 2025-01-27T17:30:00Z

### TODO-014 ⬜
**File**: `src/components/auth/PasswordInput.tsx:1`
**Priority**: P2
**Task**: Create PasswordInput with visibility toggle
**Done when**: Input toggles between password/text; eye icon works

### TODO-015 ⬜
**File**: `src/api/routes/index.ts:12`
**Priority**: P1
**Task**: Wire auth routes into main router
**Done when**: /api/auth/* routes accessible

## Files Modified

| File | TODOs | Action |
|------|-------|--------|
| src/db/prisma/schema.prisma | TODO-001 | Modified |
| src/services/AuthService.ts | TODO-002 | Created |
| src/utils/validation.ts | TODO-003 | Modified |
| src/services/EmailService.ts | TODO-004 | Created |
| src/api/routes/auth.ts | TODO-005 | Created |
| src/middleware/auth.ts | TODO-006 | Created |
| src/middleware/rateLimit.ts | TODO-007 | Created |
| src/pages/auth/Login.tsx | TODO-008 | Created |
| src/pages/auth/Register.tsx | TODO-009 | Created |
| src/pages/auth/ForgotPassword.tsx | TODO-010 | Created |
| src/pages/auth/ResetPassword.tsx | TODO-011 | Created |
| src/pages/auth/VerifyEmail.tsx | TODO-012 | Created |
| src/components/auth/AuthForm.tsx | TODO-013 | Created |
| src/components/auth/PasswordInput.tsx | TODO-014 | Created |
| src/api/routes/index.ts | TODO-015 | Modified |
