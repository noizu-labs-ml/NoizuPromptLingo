// Console domain descriptors (epic 8920d294). Authored to yuki §6 (ticket 7e269bff);
// consumed by the DataTable/DetailView/EditForm primitives (0f8453f5) once they land.
// mei-frontend lane: tickets, chatrooms, sessions. Others added by their owners.
export { ticketsDescriptor } from './tickets';
export { chatroomsDescriptor } from './chatrooms';
export { sessionsDescriptor } from './sessions';
// ava-frontend lane:
export { projectsDescriptor } from './projects';
export { organizationsDescriptor } from './organizations';
export { boardsDescriptor } from './boards';
