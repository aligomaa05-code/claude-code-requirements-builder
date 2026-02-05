# Detail Questions

Based on codebase analysis, these technical questions clarify implementation approach.

## Q1: Should we follow the existing UserService pattern (static class methods) for auth operations?
**Default if unknown:** Yes (maintains architectural consistency with src/services/UserService.ts)

## Q2: Should JWT tokens be stored in httpOnly cookies rather than localStorage?
**Default if unknown:** Yes (more secure against XSS attacks)

## Q3: Should we use the existing Prisma schema extension pattern for the User model?
**Default if unknown:** Yes (follows db/prisma/schema.prisma conventions)

## Q4: Should password reset tokens expire after 1 hour (vs 24 hours)?
**Default if unknown:** Yes (1 hour is more secure, standard practice)

## Q5: Should we add rate limiting specifically for auth endpoints (separate from global)?
**Default if unknown:** Yes (auth endpoints are prime targets for brute force)
