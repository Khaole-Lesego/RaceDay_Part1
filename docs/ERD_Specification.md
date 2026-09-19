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
