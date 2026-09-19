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
