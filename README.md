# RaceDay - Event Management System

**Module:** Programming 2B (PROG6212)  
**Assessment:** Portfolio of Evidence - Part 1: System Planning and Database  
**Student:** Lesego Khaole  
**Student number:** ST10455441

## Project overview

RaceDay is a planned web-based event management system for South African road-running, walking, and cycling events. It replaces paper registrations, spreadsheet-based administration, and fragmented participant communication with a single platform for event creation, category management, enrolments, results, route information, and participant performance history.

Part 1 contains planning artefacts only. No C# or API implementation is included. The documents in `docs/` are the baseline specification for the Part 2 REST API and the Part 3 MVC application.

## Roles

| Role        | Planned capabilities                                                                                                                                                      |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Organiser   | Creates, updates, and removes owned events; manages event categories and route information; views enrolments for owned events; captures and corrects participant results. |
| Participant | Registers and maintains a personal profile; browses events and categories; enrols in an event; views personal enrolments and results.                                     |

The API will enforce role and ownership checks server-side in Part 2. A participant cannot administer an event, and an organiser cannot retrieve another organiser's private event-management data.

## Contents

_To be completed as planning artefacts are added._

## Running the database script in SSMS

_To be completed when the SQL script is added._

## ERD design decisions

_To be completed when the ERD specification is added._

## CI/CD evidence

_To be completed after the GitHub Actions workflow runs._

## Video presentation

_To be completed after recording the Part 1 walkthrough._

## AI usage disclosure

_To be completed before submission._

## Local review checklist

_To be completed before submission._

## Tools planned for the assessment

- Lucidchart or an equivalent ERD tool.
- Microsoft SQL Server Management Studio (SSMS 22).
- Visual Studio 2022 for Part 2 and Part 3.
- Git and GitHub for version control and CI/CD.

## References

Troelsen, A. and Japikse, P. (2021) _Pro C# 10 with .NET 6: Foundational principles and practices in programming_. 11th edn. Berkeley, CA: Apress.

