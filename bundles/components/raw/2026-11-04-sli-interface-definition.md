---
type: Raw Source
title: SLI Interface Definition
description: Raw capture of SLI interface definition, ingested 2026-11-04. Immutable.
tags: [raw, sli, interface]
status: stable
content_sha256: e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c50
generated: { by: opencode/mistral-medium, at: 2026-11-04T15:00:00Z }
sources:
  - id: origin
    resource: observation:2026-11
    title: SLI Interface Definition
---
Component: SLI (Service Layer Interface)
Version: v9-4-0-8-0
Release: 0
Summary: SOL interface and messages

Source libraries:
- libSLIgol.so
- libSLIsol.so
- libSLImsgcommon.so
- libSLImsgdata.so
- libSLImsgbase.so
- libSLImsgsdh.so

RPM Installation:
- Prefix: /ecmtcp/app
- Target directory: SLI/lib
- All library files are copied to the target directory
