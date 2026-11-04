---
type: Raw Source
title: ADDR Database Purge Script
description: Raw capture of ADDR database purge SQL script, ingested 2026-11-05. Immutable.
tags: [raw, addr, database, sql, purge]
status: stable
content_sha256: 3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4
generated: { by: opencode/mistral-medium, at: 2026-11-05T10:00:00Z }
sources:
  - id: origin
    resource: observation:2026-11
    title: ADDR Database Purge Script
---
ADDR Database Purge SQL Script

This script removes all data from the ADDR database tables:
- ADDRDBVER
- DCC
- IPITEM
- LANITEM
- MGRADDRSUPP
- MGRADDRSUPP_NTP_SERVERDATA
- OCS
- OSPFAREA
- OSPFINTERFACE
- OSPFROUTER
- PORTACCESS
- PPP
- ROUTITEM
- TUNNEL
- UDCCHANNEL

Purpose: Complete reset of the ADDR (Address) database in the ECMTCP system.
