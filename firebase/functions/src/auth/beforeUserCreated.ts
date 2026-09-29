// Gives every new phone sign-up `role: customer` in their very first ID token (PLAN §8 Roles).
// Mechanics start as customers too; onMechanicRegistered switches them to `role: mechanic`.
// Admins sign in with Google, get no role here, and are granted `admin` by tool/grant_admin (§12.11).
//
// Blocking functions need Identity Platform enabled on the Firebase project.

import { beforeUserCreated } from 'firebase-functions/v2/identity';
import type { RoleClaims } from '../models/documents.js';

export function claimsForNewUser(user: { phoneNumber?: string | null } | undefined): RoleClaims {
  return user?.phoneNumber ? { role: 'customer' } : {};
}

export const assignDefaultRole = beforeUserCreated((event) => {
  const customClaims = claimsForNewUser(event.data);
  return Object.keys(customClaims).length > 0 ? { customClaims } : undefined;
});
