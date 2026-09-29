import js from '@eslint/js';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  { ignores: ['lib/**', 'node_modules/**'] },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    rules: {
      // Logs go through firebase-functions/logger with uid + bookingId only (PLAN §12.6).
      'no-console': 'error',
      '@typescript-eslint/no-explicit-any': 'error',
    },
  },
);
