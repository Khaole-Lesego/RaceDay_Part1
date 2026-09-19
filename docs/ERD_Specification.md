# RaceDay entity relationship diagram specification

## Diagram overview

The RaceDay data model contains seven entities. The diagram is supplied as [`RaceDay_ERD.png`](RaceDay_ERD.png); this document is its accessible, implementation-level specification. `PK` denotes a primary key, `FK` a foreign key, `UQ` a unique constraint, and `NN` a required (NOT NULL) value.

The design separates repeating concepts into their own relations and uses an associative entity (`Enrolment`) to preserve the participant, event, selected category, enrolment date, and status for each entry. This keeps the schema in a form suited to relational querying and later EF Core modelling (Troelsen and Japikse, 2021).

## Entity dictionary

### 1. User

| Attribute | SQL Server type | Key / constraint | Description |
|---|---|---|---|
| `UserId` | `INT IDENTITY(1,1)` | PK | Surrogate identifier. |
| `FullName` | `VARCHAR(150)` | NN | User display name. |
| `Email` | `VARCHAR(150)` | NN, UQ | Sign-in email address. |
| `PasswordHash` | `VARCHAR(255)` | NN | Hashed password only; no plaintext password is stored. |
| `Role` | `VARCHAR(20)` | NN, CHECK | `Organiser` or `Participant`. |
| `ContactNumber` | `VARCHAR(20)` | NULL | Optional contact number. |
| `ProfilePictureUrl` | `VARCHAR(255)` | NULL | Part 3 Blob Storage URL. |
| `CreatedAt` | `DATETIME` | NN, DEFAULT `GETDATE()` | Account creation timestamp. |

### 2. EventType

| Attribute | SQL Server type | Key / constraint | Description |
|---|---|---|---|
| `EventTypeId` | `INT IDENTITY(1,1)` | PK | Lookup identifier. |
| `TypeName` | `VARCHAR(50)` | NN, UQ | Event type: Run, Walk, or Cycle. |

### 3. Event

| Attribute | SQL Server type | Key / constraint | Description |
|---|---|---|---|
| `EventId` | `INT IDENTITY(1,1)` | PK | Event identifier. |
| `OrganiserId` | `INT` | FK -> `User.UserId`, NN | User accountable for the event. |
| `EventTypeId` | `INT` | FK -> `EventType.EventTypeId`, NN | Run, Walk, or Cycle. |
| `Name` | `VARCHAR(150)` | NN | Event name. |
| `Description` | `VARCHAR(1000)` | NULL | Optional event details. |
| `EventDate` | `DATETIME` | NN | Scheduled date and start time. |
| `Location` | `VARCHAR(150)` | NN | Venue or starting location. |
| `Distance` | `DECIMAL(6,2)` | NN, CHECK > 0 | Distance in kilometres. |
| `BannerImageUrl` | `VARCHAR(255)` | NULL | Part 3 Blob Storage URL for an event banner. |
| `CreatedAt` | `DATETIME` | NN, DEFAULT `GETDATE()` | Event-record creation timestamp. |

### 4. Category

| Attribute | SQL Server type | Key / constraint | Description |
|---|---|---|---|
| `CategoryId` | `INT IDENTITY(1,1)` | PK | Category identifier. |
| `EventId` | `INT` | FK -> `Event.EventId`, NN | Event to which the category belongs. |
| `Name` | `VARCHAR(100)` | NN | E.g. Senior, Under 20, 10 km. |
| `MinAge` | `INT` | NULL, CHECK >= 0 | Optional lower age bound. |
| `MaxAge` | `INT` | NULL, CHECK >= `MinAge` | Optional upper age bound. |
| `DistanceKm` | `DECIMAL(6,2)` | NULL, CHECK > 0 | Optional category distance in kilometres, for distance-based categories (e.g. 10 km, 21 km). |

`(EventId, Name)` is unique so an event cannot define the same category twice. A category must supply at least one of `MinAge`, `MaxAge`, or `DistanceKm`, since the brief defines categories as age- or distance-based. A category `DistanceKm` may legitimately differ from its parent event `Distance`, since one event can offer more than one distance option (e.g. a family 5 km alongside the event headline 10 km).

### 5. Enrolment

| Attribute | SQL Server type | Key / constraint | Description |
|---|---|---|---|
| `EnrolmentId` | `INT IDENTITY(1,1)` | PK | Event-entry identifier. |
| `ParticipantId` | `INT` | FK -> `User.UserId`, NN | Participant who entered. |
| `EventId` | `INT` | FK -> `Event.EventId`, NN | Entered event. |
| `CategoryId` | `INT` | FK -> `Category.CategoryId`, NN | Category selected on entry. |
| `EnrolmentDate` | `DATETIME` | NN, DEFAULT `GETDATE()` | Entry timestamp. |
| `Status` | `VARCHAR(20)` | NN, DEFAULT `Pending`, CHECK | Pending, Confirmed, or Cancelled. |

`(ParticipantId, EventId)` is unique so a participant cannot enter the same event more than once.
