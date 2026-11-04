---
type: Raw Source
title: TL1 Agent Interface Definition
description: Raw capture of TL1 agent interface definition, ingested 2026-11-04. Immutable.
tags: [raw, tl1, tl1agent, interface]
status: stable
content_sha256: 1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2
generated: { by: opencode/mistral-medium, at: 2026-11-04T15:00:00Z }
sources:
  - id: origin
    resource: observation:2026-11
    title: TL1 Agent Interface Definition
---
Component: TL1AGENT (Telecommunication Language One Agent)
Version: v9-4-0-23-0
Release: 0
Summary: TL1 agent for telecommunication management

Source files:
- bin* (binary files)
- libTL1* (TL1 libraries)
- libAGTGLI* (AGTGLI libraries)
- libMtcpSecurity.so
- *.ini (configuration files)
- *.txt (text files)
- *.conf (configuration files)
- *.cfg (configuration files)
- *.xml (XML files)
- tl1agent.sql (SQL script)

RPM Installation:
- Prefix: /ecmtcp/app
- Creates directories: AOL/TL1/bin, AOL/TL1/lib, AOL/TL1/DMO, AOL/TL1/conf, etc/MYSQL_scripts
