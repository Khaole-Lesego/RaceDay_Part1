# RaceDay API endpoint plan

## API conventions

- Base route: `/api`.
- Dates use ISO 8601 (`YYYY-MM-DDTHH:mm:ss`); elapsed results use `HH:mm:ss`.
- Protected routes require the authenticated session established by `POST /api/auth/login`.
- An organiser may access only resources for events they own. A participant may access only their own profile, enrolments, and results.
- Validation failures return `400 Bad Request`; an unauthenticated request returns `401 Unauthorized`; a logged-in user without the required role or ownership returns `403 Forbidden`; an unknown resource returns `404 Not Found`; a duplicate or conflicting state returns `409 Conflict`.

The routes use resource-oriented nouns and HTTP methods consistently so the Part 2 implementation can be documented and tested in Swagger (Troelsen and Japikse, 2021).

## Request-body field guide

| Body label | JSON fields |
|---|---|
| Register | `{ "fullName", "email", "password", "role", "contactNumber" }` where role is `Organiser` or `Participant`. |
| Login | `{ "email", "password" }` |
| Profile update | `{ "fullName", "contactNumber", "profilePictureUrl" }` |
| Event create/update | `{ "name", "description", "eventDate", "location", "distance", "eventTypeId", "bannerImageUrl" }` |
| Category create/update | `{ "name", "minAge", "maxAge" }` |
| Route create/update | `{ "routeMapUrl", "elevationGain", "startPoint", "endPoint" }` |
| Enrolment create | `{ "eventId", "categoryId" }` |
| Enrolment status | `{ "status" }` where status is `Pending`, `Confirmed`, or `Cancelled`. |
| Result create/update | `{ "enrolmentId", "finishTime", "finishPosition" }` (`enrolmentId` is omitted when updating an existing result). |

## Endpoint specification

| HTTP method | Route | Description | Role required | Request body | Expected response |
|---|---|---|---|---|---|
| POST | `/api/auth/register` | Creates an Organiser or Participant account. | None (public) | Register | `201 Created` - user profile; `400` invalid fields/role; `409` email already exists. |
| POST | `/api/auth/login` | Validates credentials and starts an authenticated session. | None (public) | Login | `200 OK` - profile and role; `400` invalid body; `401` invalid credentials. |
| POST | `/api/auth/logout` | Ends the current authenticated session. | Any authenticated user | None | `204 No Content`; `401` no active session. |
| GET | `/api/auth/session` | Returns the current session identity and role for the MVC client. | Any authenticated user | None | `200 OK` - session profile; `401` no active session. |
| GET | `/api/users/profile` | Returns the current user's profile. | Any authenticated user | None | `200 OK` - profile; `401` unauthenticated. |
| PUT | `/api/users/profile` | Updates the current user's permitted profile fields. | Any authenticated user | Profile update | `200 OK` - updated profile; `400` invalid data; `401` unauthenticated. |
| GET | `/api/event-types` | Returns Run, Walk, and Cycle lookup values. | None (public) | None | `200 OK` - event-type collection. |
| GET | `/api/events` | Lists events; supports optional `eventTypeId`, `fromDate`, `toDate`, and `location` query filters. | None (public) | None | `200 OK` - filtered event summaries; `400` invalid filter values. |
| GET | `/api/events/{eventId}` | Returns one event with its type, categories, route information, and public detail. | None (public) | None | `200 OK` - event detail; `404` event not found. |
| POST | `/api/events` | Creates an event owned by the logged-in organiser. | Organiser | Event create | `201 Created` - event; `400` invalid fields/type/date; `401`; `403`. |
| PUT | `/api/events/{eventId}` | Updates an event owned by the logged-in organiser. | Organiser and owner | Event update | `200 OK` - updated event; `400`; `401`; `403`; `404`. |
| DELETE | `/api/events/{eventId}` | Deletes an owned event that has no dependent enrolments, or reports the conflict. | Organiser and owner | None | `204 No Content`; `401`; `403`; `404`; `409` dependent data exists. |
| GET | `/api/events/mine` | Lists events created by the current organiser, with enrolment counts. | Organiser | None | `200 OK` - organiser's event collection; `401`; `403`. |
| GET | `/api/events/{eventId}/categories` | Lists categories available for an event. | None (public) | None | `200 OK` - category collection; `404` event not found. |
| POST | `/api/events/{eventId}/categories` | Adds a category to an owned event. | Organiser and owner | Category create | `201 Created` - category; `400`; `401`; `403`; `404`; `409` duplicate category name. |
| PUT | `/api/categories/{categoryId}` | Updates a category belonging to an owned event. | Organiser and owner | Category update | `200 OK` - updated category; `400`; `401`; `403`; `404`; `409` duplicate category name. |
| DELETE | `/api/categories/{categoryId}` | Removes an unused category from an owned event. | Organiser and owner | None | `204 No Content`; `401`; `403`; `404`; `409` category has enrolments. |
| GET | `/api/events/{eventId}/route-info` | Gets public route details for an event. | None (public) | None | `200 OK` - route information; `404` event or route record not found. |
| POST | `/api/events/{eventId}/route-info` | Creates route information for an owned event. | Organiser and owner | Route create | `201 Created` - route information; `400`; `401`; `403`; `404`; `409` route already exists. |
| PUT | `/api/events/{eventId}/route-info` | Updates route information for an owned event. | Organiser and owner | Route update | `200 OK` - updated route information; `400`; `401`; `403`; `404`. |
| GET | `/api/enrolments` | Returns own enrolments for a participant, or enrolments across the current organiser's events for an organiser. Optional organiser filter: `eventId`. | Any authenticated user | None | `200 OK` - role-scoped enrolment collection; `400` invalid filter; `401`. |
| GET | `/api/enrolments/{enrolmentId}` | Returns one enrolment when it belongs to the caller or to their event. | Participant (own) or Organiser (owner) | None | `200 OK` - enrolment detail; `401`; `403`; `404`. |
| POST | `/api/enrolments` | Enrols the logged-in participant in an event and selected category. | Participant | Enrolment create | `201 Created` - enrolment; `400` category does not belong to event; `401`; `403`; `404`; `409` already enrolled. |
| PUT | `/api/enrolments/{enrolmentId}/status` | Changes the status of an enrolment in the organiser's own event. | Organiser and owner | Enrolment status | `200 OK` - updated enrolment; `400` invalid status; `401`; `403`; `404`. |
| DELETE | `/api/enrolments/{enrolmentId}` | Cancels an enrolment. A participant may cancel their own entry; an organiser may cancel an entry for an event they own. | Participant (own) or Organiser (owner) | None | `204 No Content`; `401`; `403`; `404`; `409` result already captured. |
| GET | `/api/results` | Returns personal results for a participant or results for events owned by an organiser. Optional organiser filter: `eventId`. | Any authenticated user | None | `200 OK` - role-scoped result collection; `400` invalid filter; `401`. |
| GET | `/api/results/{resultId}` | Returns one result when it belongs to the caller or to their event. | Participant (own) or Organiser (owner) | None | `200 OK` - result detail; `401`; `403`; `404`. |
| POST | `/api/results` | Captures a finish time and position for an enrolment in an owned event. | Organiser and owner | Result create | `201 Created` - result; `400` invalid time/position or unconfirmed enrolment; `401`; `403`; `404`; `409` result already exists. |
| PUT | `/api/results/{resultId}` | Corrects a result for an enrolment in an owned event. | Organiser and owner | Result update | `200 OK` - updated result; `400`; `401`; `403`; `404`. |

## Planned response shapes

Successful collection endpoints return a JSON array or a paged wrapper such as `{ "items": [...], "totalCount": 3 }`. Single-resource responses return the resource and its relevant nested data. Password hashes and raw passwords are never returned. Deletion uses `204 No Content` rather than returning the deleted record.

## Part 2 test alignment

The test suite should demonstrate a successful and unsuccessful register/login flow; an organiser creating, updating, and deleting only their own event; a participant being rejected from organiser-only routes; successful participant enrolment; duplicate-enrolment rejection; and participant visibility limited to personal results. Swagger descriptions should use this plan's routes and statuses.

## Reference

Microsoft (2023) REST API Guidelines. Available at: https://github.com/microsoft/api-guidelines (Accessed: 20 September 2026).

Richardson, L., Amundsen, M. and Ruby, S. (2013) RESTful Web APIs. Sebastopol, CA: O'Reilly Media.

Troelsen, A. and Japikse, P. (2021) Pro C# 10 with .NET 6: Foundational principles and practices in programming. 11th edn. Berkeley, CA: Apress.

