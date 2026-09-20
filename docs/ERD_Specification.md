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

### 6. Result

| Attribute | SQL Server type | Key / constraint | Description |
|---|---|---|---|
| `ResultId` | `INT IDENTITY(1,1)` | PK | Result identifier. |
| `EnrolmentId` | `INT` | FK -> `Enrolment.EnrolmentId`, NN, UQ | Enrolment being scored. |
| `FinishTime` | `TIME(0)` | NULL | Recorded elapsed finish time. |
| `FinishPosition` | `INT` | NULL, CHECK > 0 | Overall finishing position. |
| `CapturedAt` | `DATETIME` | NULL | When an organiser captured the result. |

The unique `EnrolmentId` makes the relationship one-to-one: an enrolment can have at most one result.

### 7. RouteInfo

| Attribute | SQL Server type | Key / constraint | Description |
|---|---|---|---|
| `RouteInfoId` | `INT IDENTITY(1,1)` | PK | Route-information identifier. |
| `EventId` | `INT` | FK -> `Event.EventId`, NN, UQ | Event served by the route. |
| `RouteMapUrl` | `VARCHAR(255)` | NULL | Link to a route map. |
| `ElevationGain` | `DECIMAL(6,2)` | NULL, CHECK >= 0 | Elevation gain in metres. |
| `StartPoint` | `VARCHAR(150)` | NULL | Route start. |
| `EndPoint` | `VARCHAR(150)` | NULL | Route end. |

## Relationship and cardinality matrix

| # | Parent | Child | Cardinality | Foreign key / business meaning |
|---:|---|---|---|---|
| 1 | User (Organiser) | Event | 1 : many | `Event.OrganiserId`; one organiser can create many events. |
| 2 | EventType | Event | 1 : many | `Event.EventTypeId`; one lookup type applies to many events. |
| 3 | Event | Category | 1 : many | `Category.EventId`; an event has one or more planned categories. |
| 4 | Event | RouteInfo | 1 : 1 | `RouteInfo.EventId` is unique; each planned event has one route-information record. |
| 5 | User (Participant) | Enrolment | 1 : many | `Enrolment.ParticipantId`; a participant can enter many events. |
| 6 | Event | Enrolment | 1 : many | `Enrolment.EventId`; many participants can enter an event. |
| 7 | Category | Enrolment | 1 : many | `Enrolment.CategoryId`; many entries may select a category. |
| 8 | Enrolment | Result | 1 : 0..1 | `Result.EnrolmentId` is unique; results are absent until captured. |

`User` appears at both ends of different relationships because one account table stores both roles. The SQL foreign keys ensure a valid user exists. API-level authorization in Part 2 must ensure that an `OrganiserId` references an organiser, a `ParticipantId` references a participant, and the authenticated organiser owns any event they modify.

The database can enforce "at most one" `RouteInfo` record with a unique foreign key. The API will create the required route record in the same event-creation workflow, thereby enforcing the business rule of one route record for each planned event. This avoids a circular foreign-key design.

## Mermaid source

```mermaid
erDiagram
    USER ||--o{ EVENT : organises
    EVENTTYPE ||--o{ EVENT : classifies
    EVENT ||--|{ CATEGORY : offers
    EVENT ||--|| ROUTEINFO : has
    USER ||--o{ ENROLMENT : enters
    EVENT ||--o{ ENROLMENT : receives
    CATEGORY ||--o{ ENROLMENT : selected_for
    ENROLMENT ||--o| RESULT : produces

    USER {
        int UserId PK
        varchar FullName
        varchar Email UK
        varchar PasswordHash
        varchar Role
        varchar ContactNumber
        varchar ProfilePictureUrl
        datetime CreatedAt
    }
    EVENTTYPE {
        int EventTypeId PK
        varchar TypeName UK
    }
    EVENT {
        int EventId PK
        int OrganiserId FK
        int EventTypeId FK
        varchar Name
        varchar Description
        datetime EventDate
        varchar Location
        decimal Distance
        varchar BannerImageUrl
        datetime CreatedAt
    }
    CATEGORY {
        int CategoryId PK
        int EventId FK
        varchar Name
        int MinAge
        int MaxAge
        decimal DistanceKm
    }
    ENROLMENT {
        int EnrolmentId PK
        int ParticipantId FK
        int EventId FK
        int CategoryId FK
        datetime EnrolmentDate
        varchar Status
    }
    RESULT {
        int ResultId PK
        int EnrolmentId FK_UK
        time FinishTime
        int FinishPosition
        datetime CapturedAt
    }
    ROUTEINFO {
        int RouteInfoId PK
        int EventId FK_UK
        varchar RouteMapUrl
        decimal ElevationGain
        varchar StartPoint
        varchar EndPoint
    }
```

## Implementation alignment checklist

- The ERD, SQL script, and endpoint plan use the same singular table/resource names and identifiers.
- `BannerImageUrl` and `ProfilePictureUrl` are intentionally nullable until Part 3 upload functionality exists.
- The `EventType` lookup is seeded with exactly Run, Walk, and Cycle.
- The category selected in an enrolment must belong to the supplied event. This cross-table rule is validated by the API because independent foreign keys cannot prove it.
- Roles, ownership, enrolment status transitions, and result capture are API business rules, not substitutes for the keys and constraints defined in SQL.

## Reference

Satzinger, J.W., Jackson, R.B. and Burd, S.D. (2016) _Systems analysis and design in a changing world_. 7th edn. Boston, MA: Cengage Learning.

Troelsen, A. and Japikse, P. (2021) *Pro C# 10 with .NET 6: Foundational principles and practices in programming*. 11th edn. Berkeley, CA: Apress.
