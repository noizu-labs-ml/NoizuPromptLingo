---
id: US-061
title: "User Permissions and Roles Management"
slug: "user-permissions-roles"
personas: [P-007]
epic: "Admin Dashboard"
priority: "should-have"
complexity: "M"
tags: [admin, permissions, roles, access-control, security]
---

# US-061: User Permissions and Roles Management

## User Story

**As a** site administrator,
**I want to** define roles (Admin, Client, Prospect) and assign permissions per role,
**So that** each user type can only access the data and actions appropriate to their relationship with my consulting practice.

## Acceptance Criteria

- [ ] Given the system has predefined roles (Admin, Client, Prospect), when a user is assigned a role, then they can only access routes and actions permitted for that role.
- [ ] Given I navigate to `/admin/permissions`, when I view a role, then I see a list of capabilities (view projects, download deliverables, submit RFIs, view invoices) with enabled/disabled toggles.
- [ ] Given I modify a role's permissions and save, when an affected user next loads a page, then their access reflects the updated permissions without requiring re-login.
- [ ] Given a user attempts to access a route outside their role's permissions, when the request is made, then they receive a 403 response and are redirected to an appropriate landing page.
- [ ] Given I assign a user to the Client role, when the assignment is saved, then the user gains access to the client dashboard and loses access to admin routes.
- [ ] Given a permission change is made, when it saves, then an audit log entry records who changed what permission on which role.

## Notes

MVP roles: Admin (full access), Client (own project data only), Prospect (RFI submission + status tracking only). Future: team/sub-admin roles if Keith brings on staff. Related: US-052, US-063.
