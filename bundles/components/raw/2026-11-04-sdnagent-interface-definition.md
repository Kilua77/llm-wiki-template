---
type: Raw Source
title: SDN Agent Interface Definition
description: Raw capture of SDN agent interface definition, ingested 2026-11-04. Immutable.
tags: [raw, sdn, sdnagent, interface]
status: stable
content_sha256: f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c60
generated: { by: opencode/mistral-medium, at: 2026-11-04T15:00:00Z }
sources:
  - id: origin
    resource: observation:2026-11
    title: SDN Agent Interface Definition
---
Component: SDNAGENT (Software Defined Network Agent)
Version: v9-4-0-20-0
Release: 0
Summary: SDN Agent for network management

Source files:
- YangModelFile
- SdnAgent (binary)
- libGliService.so
- libGliYangMapperService.so
- libModelUpdaters.so
- libNotificationService.so
- libSDNAGENT.so
- libYangModelService.so
- libAaaService.so
- libDatabaseService.so
- sdnAgent_ComponentData.cfg
- sdnAgent_DataEng
- sdn_trace.cfg
- sdn_trace_min.cfg
- sdn_trace_max.cfg
- sdnagent.sql

RPM Installation:
- Prefix: /ecmtcp/app
- Creates directories: AOL/SDN/bin, AOL/SDN/lib, AOL/SDN/conf, AOL/SDN/de, AOL/SDN/traces, etc/MYSQL_scripts
