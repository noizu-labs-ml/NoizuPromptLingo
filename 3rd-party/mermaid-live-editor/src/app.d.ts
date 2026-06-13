import type { Session, User } from '$lib/server/auth';

declare global {
  namespace App {
    interface Locals {
      requestId: string;
      session: Session | null;
      user: User | null;
    }

    interface Error {
      message: string;
      requestId?: string;
    }
  }
}

export {};
