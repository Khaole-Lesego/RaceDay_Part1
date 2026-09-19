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
