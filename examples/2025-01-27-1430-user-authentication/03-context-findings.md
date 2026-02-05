# Context Findings: User Authentication

**Analyzed**: 2025-01-27 15:00:00
**Files Examined**: 47
**Patterns Identified**: 5

## Codebase Overview

### Technology Stack
- **Frontend**: React 18 with TypeScript
- **Backend**: Node.js with Express
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: Currently none (greenfield)

### Existing Structure
```
src/
├── api/
│   └── routes/
│       └── index.ts          # Main router
├── components/
│   └── common/
│       └── Button.tsx        # Reusable components
├── pages/
│   └── Home.tsx              # Main pages
├── services/
│   └── UserService.ts        # User-related operations
├── middleware/
│   └── logger.ts             # Request logging
├── utils/
│   └── validation.ts         # Input validation helpers
└── db/
    └── prisma/
        └── schema.prisma     # Database schema
```

## Files That Need Modification

### Existing Files
| File | Purpose | Modification Needed |
|------|---------|---------------------|
| src/api/routes/index.ts | Main router | Add auth routes |
| src/services/UserService.ts | User operations | Add auth methods |
| src/utils/validation.ts | Validation | Add password rules |
| src/db/prisma/schema.prisma | DB schema | Add User model |

### New Files Required
| File | Purpose |
|------|---------|
| src/pages/auth/Login.tsx | Login page |
| src/pages/auth/Register.tsx | Registration page |
| src/pages/auth/ForgotPassword.tsx | Password reset request |
| src/middleware/auth.ts | Authentication middleware |
| src/services/EmailService.ts | Email sending |
| src/api/routes/auth.ts | Auth endpoints |

## Similar Features Analyzed

### UserService Pattern (src/services/UserService.ts)
```typescript
// Existing pattern: service class with static methods
export class UserService {
  static async getById(id: string): Promise<User | null> { ... }
  static async update(id: string, data: UpdateUserDTO): Promise<User> { ... }
}
```
**Recommendation**: Follow same pattern for auth methods.

### Validation Pattern (src/utils/validation.ts)
```typescript
// Existing pattern: exported functions with Zod schemas
export const emailSchema = z.string().email();
export const validateEmail = (input: string) => emailSchema.safeParse(input);
```
**Recommendation**: Add passwordSchema following same pattern.

### Route Pattern (src/api/routes/index.ts)
```typescript
// Existing pattern: Express router with controller functions
router.get('/users/:id', UserController.getById);
router.put('/users/:id', UserController.update);
```
**Recommendation**: Create auth.ts with same structure.

## Technical Constraints

1. **Session Storage**: Project uses Redis for caching - can reuse for sessions
2. **Email**: No email service exists - need to add (suggest SendGrid or AWS SES)
3. **Password Hashing**: bcrypt is already a dependency (unused)
4. **JWT**: jsonwebtoken package not installed - need to add
5. **Rate Limiting**: express-rate-limit exists but not configured for auth

## Integration Points

- **Database**: Prisma client at `src/db/client.ts`
- **Error Handling**: Custom AppError class at `src/utils/errors.ts`
- **Response Format**: Standard JSON response helper at `src/utils/response.ts`
- **Environment**: Config loaded from `src/config/env.ts`
