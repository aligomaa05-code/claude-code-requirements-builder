import { z } from 'zod';

// TODO [REQ:2025-01-27-1430-user-authentication] [ID:TODO-003] [P:1] Add password validation schema (8+ chars, uppercase, number)
// WHY: Password strength requirements for security compliance
// DONE WHEN: passwordSchema validates correctly; tests pass
// SPEC: requirements/2025-01-27-1430-user-authentication/06-requirements-spec.md

// Existing validation schemas
export const emailSchema = z.string().email();

export const validateEmail = (input: string) => {
  return emailSchema.safeParse(input);
};

export const nameSchema = z.string().min(2).max(50);

export const validateName = (input: string) => {
  return nameSchema.safeParse(input);
};

// TODO [REQ:2025-01-27-1430-user-authentication] [ID:TODO-016] [P:3] Add input sanitization helper for XSS prevention
