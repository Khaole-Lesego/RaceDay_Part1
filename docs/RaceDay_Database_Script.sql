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
