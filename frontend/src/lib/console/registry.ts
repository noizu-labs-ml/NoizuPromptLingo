// Domain → descriptor registry (ticket 0f8453f5). DetailView resolves a related
// collection's descriptor by its domain key to render an embedded read-only mini
// DataTable. Per-domain generics are erased to ConsoleDescriptor<any, any> at this
// seam (the registry is heterogeneous by nature); call sites stay typed.
/* eslint-disable @typescript-eslint/no-explicit-any */
import type { ConsoleDescriptor } from './types';
import {
  ticketsDescriptor,
  chatroomsDescriptor,
  sessionsDescriptor,
  projectsDescriptor,
  organizationsDescriptor,
  boardsDescriptor,
} from './descriptors';

export type AnyDescriptor = ConsoleDescriptor<any, any>;

export const DESCRIPTORS: Record<string, AnyDescriptor> = {
  tickets: ticketsDescriptor,
  chatrooms: chatroomsDescriptor,
  sessions: sessionsDescriptor,
  projects: projectsDescriptor,
  organizations: organizationsDescriptor,
  boards: boardsDescriptor,
};

/** Look up a descriptor by domain key; undefined if no descriptor is registered yet. */
export function getDescriptor(domain: string): AnyDescriptor | undefined {
  return DESCRIPTORS[domain];
}
