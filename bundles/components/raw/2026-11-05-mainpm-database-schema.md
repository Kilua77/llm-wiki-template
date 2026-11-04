---
type: Raw Source
title: MAIN_PM Database Schema
description: Raw capture of MAIN_PM database schema SQL, ingested 2026-11-05. Immutable.
tags: [raw, mainpm, database, sql, schema]
status: stable
content_sha256: 4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5
generated: { by: opencode/mistral-medium, at: 2026-11-05T10:00:00Z }
sources:
  - id: origin
    resource: observation:2026-11
    title: MAIN_PM Database Schema
---
MAIN_PM Database Schema for ECMTCP SOL Domain

Product: 162x System
Abstract: TABLE of PM Definition (Performance Management)

Tables defined:

1. PmSolItem
   - pmItemOid_: BIGINT UNSIGNED NOT NULL (Primary Key)
   - numSuppressionInterval_: INTEGER UNSIGNED
   Engine: INNODB

2. PmSolHistoryCollection
   - id_: SMALLINT UNSIGNED NOT NULL
   - pmItemOid_: BIGINT UNSIGNED NOT NULL
   - ellapsedTime_: INTEGER UNSIGNED
   - periodeEndTime_: INTEGER UNSIGNED
   - suspectIntervalFlag_: TINYINT(1)
   - isSuppressed_: TINYINT(1)
   - counterList_: BLOB
   - collectedFlag_: TINYINT(1)
   Engine: INNODB

Purpose: Performance Management data storage for the ECMTCP system.
