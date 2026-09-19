/*
    RaceDay - Part 1 database schema and seed data
    Target: Microsoft SQL Server / SSMS
    This script is safely re-runnable: it drops and recreates the RaceDay
    tables (in reverse foreign-key order) if they already exist, then
    reseeds sample data. Run it as many times as needed during a demo.
*/

USE master;
GO

IF DB_ID(N'RaceDay') IS NULL
BEGIN
    CREATE DATABASE RaceDay;
END;
GO

USE RaceDay;
GO

/* Guarded drops so this script can be re-run against an existing
   RaceDay database without erroring. Order respects foreign-key
   dependencies: children are dropped before the parents they reference. */
DROP TABLE IF EXISTS dbo.Result;
DROP TABLE IF EXISTS dbo.Enrolment;
DROP TABLE IF EXISTS dbo.RouteInfo;
DROP TABLE IF EXISTS dbo.Category;
DROP TABLE IF EXISTS dbo.[Event];
DROP TABLE IF EXISTS dbo.EventType;
DROP TABLE IF EXISTS dbo.[User];
GO

CREATE TABLE dbo.[User]
(
    UserId              INT IDENTITY(1,1) NOT NULL,
    FullName            VARCHAR(150) NOT NULL,
    Email               VARCHAR(150) NOT NULL,
    PasswordHash        VARCHAR(255) NOT NULL,
    [Role]              VARCHAR(20) NOT NULL,
    ContactNumber       VARCHAR(20) NULL,
    ProfilePictureUrl   VARCHAR(255) NULL,
    CreatedAt           DATETIME NOT NULL CONSTRAINT DF_User_CreatedAt DEFAULT (GETDATE()),
    CONSTRAINT PK_User PRIMARY KEY (UserId),
    CONSTRAINT UQ_User_Email UNIQUE (Email),
    CONSTRAINT CK_User_Role CHECK ([Role] IN ('Organiser', 'Participant'))
);
GO

CREATE TABLE dbo.EventType
(
    EventTypeId         INT IDENTITY(1,1) NOT NULL,
    TypeName            VARCHAR(50) NOT NULL,
    CONSTRAINT PK_EventType PRIMARY KEY (EventTypeId),
    CONSTRAINT UQ_EventType_TypeName UNIQUE (TypeName),
    CONSTRAINT CK_EventType_TypeName CHECK (TypeName IN ('Run', 'Walk', 'Cycle'))
);
GO

CREATE TABLE dbo.[Event]
(
    EventId             INT IDENTITY(1,1) NOT NULL,
    OrganiserId         INT NOT NULL,
    EventTypeId         INT NOT NULL,
    [Name]              VARCHAR(150) NOT NULL,
    [Description]       VARCHAR(1000) NULL,
    EventDate           DATETIME NOT NULL,
    [Location]          VARCHAR(150) NOT NULL,
    [Distance]          DECIMAL(6,2) NOT NULL,
    BannerImageUrl      VARCHAR(255) NULL,
    CreatedAt           DATETIME NOT NULL CONSTRAINT DF_Event_CreatedAt DEFAULT (GETDATE()),
    CONSTRAINT PK_Event PRIMARY KEY (EventId),
    CONSTRAINT FK_Event_Organiser FOREIGN KEY (OrganiserId) REFERENCES dbo.[User](UserId),
    CONSTRAINT FK_Event_EventType FOREIGN KEY (EventTypeId) REFERENCES dbo.EventType(EventTypeId),
    CONSTRAINT CK_Event_Distance CHECK ([Distance] > 0)
);
GO

CREATE TABLE dbo.Category
(
    CategoryId          INT IDENTITY(1,1) NOT NULL,
    EventId             INT NOT NULL,
    [Name]              VARCHAR(100) NOT NULL,
    MinAge              INT NULL,
    MaxAge              INT NULL,
    DistanceKm          DECIMAL(6,2) NULL,
    CONSTRAINT PK_Category PRIMARY KEY (CategoryId),
    CONSTRAINT FK_Category_Event FOREIGN KEY (EventId) REFERENCES dbo.[Event](EventId),
    CONSTRAINT UQ_Category_Event_Name UNIQUE (EventId, [Name]),
    CONSTRAINT CK_Category_MinAge CHECK (MinAge IS NULL OR MinAge >= 0),
    CONSTRAINT CK_Category_MaxAge CHECK (MaxAge IS NULL OR MaxAge >= 0),
    CONSTRAINT CK_Category_AgeRange CHECK (MinAge IS NULL OR MaxAge IS NULL OR MaxAge >= MinAge),
    CONSTRAINT CK_Category_DistanceKm CHECK (DistanceKm IS NULL OR DistanceKm > 0),
    CONSTRAINT CK_Category_HasAgeOrDistance CHECK (MinAge IS NOT NULL OR MaxAge IS NOT NULL OR DistanceKm IS NOT NULL)
);
GO

CREATE TABLE dbo.Enrolment
(
    EnrolmentId         INT IDENTITY(1,1) NOT NULL,
    ParticipantId       INT NOT NULL,
    EventId             INT NOT NULL,
    CategoryId          INT NOT NULL,
    EnrolmentDate       DATETIME NOT NULL CONSTRAINT DF_Enrolment_EnrolmentDate DEFAULT (GETDATE()),
    [Status]            VARCHAR(20) NOT NULL CONSTRAINT DF_Enrolment_Status DEFAULT ('Pending'),
    CONSTRAINT PK_Enrolment PRIMARY KEY (EnrolmentId),
    CONSTRAINT FK_Enrolment_Participant FOREIGN KEY (ParticipantId) REFERENCES dbo.[User](UserId),
    CONSTRAINT FK_Enrolment_Event FOREIGN KEY (EventId) REFERENCES dbo.[Event](EventId),
    CONSTRAINT FK_Enrolment_Category FOREIGN KEY (CategoryId) REFERENCES dbo.Category(CategoryId),
    CONSTRAINT UQ_Enrolment_Participant_Event UNIQUE (ParticipantId, EventId),
    CONSTRAINT CK_Enrolment_Status CHECK ([Status] IN ('Pending', 'Confirmed', 'Cancelled'))
);
GO

CREATE TABLE dbo.Result
(
    ResultId            INT IDENTITY(1,1) NOT NULL,
    EnrolmentId         INT NOT NULL,
    FinishTime          TIME(0) NULL,
    FinishPosition      INT NULL,
    CapturedAt          DATETIME NULL,
    CONSTRAINT PK_Result PRIMARY KEY (ResultId),
    CONSTRAINT FK_Result_Enrolment FOREIGN KEY (EnrolmentId) REFERENCES dbo.Enrolment(EnrolmentId),
    CONSTRAINT UQ_Result_Enrolment UNIQUE (EnrolmentId),
    CONSTRAINT CK_Result_FinishPosition CHECK (FinishPosition IS NULL OR FinishPosition > 0)
);
GO

CREATE TABLE dbo.RouteInfo
(
    RouteInfoId         INT IDENTITY(1,1) NOT NULL,
    EventId             INT NOT NULL,
    RouteMapUrl         VARCHAR(255) NULL,
    ElevationGain       DECIMAL(6,2) NULL,
    StartPoint          VARCHAR(150) NULL,
    EndPoint            VARCHAR(150) NULL,
    CONSTRAINT PK_RouteInfo PRIMARY KEY (RouteInfoId),
    CONSTRAINT FK_RouteInfo_Event FOREIGN KEY (EventId) REFERENCES dbo.[Event](EventId),
    CONSTRAINT UQ_RouteInfo_Event UNIQUE (EventId),
    CONSTRAINT CK_RouteInfo_ElevationGain CHECK (ElevationGain IS NULL OR ElevationGain >= 0)
);
GO

/* Lookup values */
INSERT INTO dbo.EventType (TypeName)
VALUES ('Run'), ('Walk'), ('Cycle');
GO

/* Two organisers and three participants. PasswordHash values are illustrative BCrypt-format placeholders. */
INSERT INTO dbo.[User] (FullName, Email, PasswordHash, [Role], ContactNumber, ProfilePictureUrl)
VALUES
    ('Thandi Mokoena', 'thandi.mokoena@raceday.co.za', '$2a$12$seededHashForThandiMokoena000000000000000000000000000000000', 'Organiser', '0825550101', NULL),
    ('Sibusiso Dlamini', 'sibusiso.dlamini@raceday.co.za', '$2a$12$seededHashForSibusisoDlamini00000000000000000000000000000', 'Organiser', '0835550102', NULL),
    ('Naledi Khumalo', 'naledi.khumalo@example.com', '$2a$12$seededHashForNalediKhumalo0000000000000000000000000000000', 'Participant', '0845550103', NULL),
    ('Aiden Williams', 'aiden.williams@example.com', '$2a$12$seededHashForAidenWilliams000000000000000000000000000000000', 'Participant', '0715550104', NULL),
    ('Zinhle Ndlovu', 'zinhle.ndlovu@example.com', '$2a$12$seededHashForZinhleNdlovu000000000000000000000000000000000', 'Participant', '0725550105', NULL);
GO

/* One completed event (2026, in the past) so it can carry real results,
   plus two upcoming 2027 events that correctly have no results yet. */
INSERT INTO dbo.[Event] (OrganiserId, EventTypeId, [Name], [Description], EventDate, [Location], [Distance], BannerImageUrl)
VALUES
    (1, 1, 'Comrades Marathon 2026', 'An iconic ultra-marathon route for experienced road runners.', '2026-06-13T05:30:00', 'Pietermaritzburg to Durban', 89.90, NULL),
    (2, 3, 'Cape Town Cycle Tour 2027', 'A scenic timed cycle event around the Cape Peninsula.', '2027-03-14T06:00:00', 'Cape Town Civic Centre', 109.00, NULL),
    (1, 2, 'Soweto Heritage Walk 2027', 'A community walk celebrating Soweto history and culture, offering a shorter family route alongside the main 10 km route.', '2027-09-24T07:00:00', 'Vilakazi Street, Soweto', 10.00, NULL);
GO

/* Categories may be age-based, distance-based, or both, via the nullable
   DistanceKm column. Distance-based categories can legitimately differ
   from the event's headline Distance (e.g. a 5 km family option inside
   a 10 km walk event). */
INSERT INTO dbo.Category (EventId, [Name], MinAge, MaxAge, DistanceKm)
VALUES
    (1, 'Senior', 20, 59, NULL),
    (1, 'Veteran 60+', 60, NULL, NULL),
    (2, 'Open 109 km', 18, NULL, 109.00),
    (2, 'Veteran 50+', 50, NULL, NULL),
    (3, 'Family 5 km', NULL, NULL, 5.00),
    (3, 'Open 10 km', 12, NULL, 10.00);
GO

/* A single route-information record is seeded for every event. */
INSERT INTO dbo.RouteInfo (EventId, RouteMapUrl, ElevationGain, StartPoint, EndPoint)
VALUES
    (1, 'https://example.org/routes/comrades-2026', 1100.00, 'Pietermaritzburg City Hall', 'Durban Kingsmead precinct'),
    (2, 'https://example.org/routes/cycle-tour-2027', 1250.00, 'Cape Town Civic Centre', 'Cape Town Stadium precinct'),
    (3, 'https://example.org/routes/soweto-walk-2027', 85.00, 'Vilakazi Street', 'Walter Sisulu Square');
GO
