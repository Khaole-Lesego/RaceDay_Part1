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
