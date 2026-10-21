---
type: Concept
title: FLC Overview
description: Global architecture of the FLC/ECMTCP system, its purpose, and high-level organization.
tags: [architecture, flc, ecmtcp, system-overview]
status: draft
stale_after: 2027-10-21
generated: { by: hermes/mistral-medium, at: 2026-10-21T15:30:00Z }
sources:
  - id: observation
    resource: observation:2026-10
    title: Direct observation of ECMTCP architecture
---

# FLC/ECMTCP Overview

The **FLC (Flexible Logical Controller)** is the core architectural framework for the **ECMTCP** system, designed to manage embedded telecommunication platforms. It provides a unified abstraction layer over heterogeneous hardware, enabling consistent service delivery across multiple product lines.

## Core Purpose

FLC serves as the **central nervous system** for ECMTCP, orchestrating:
- **Component lifecycle management** (GOL, SOL, AVAIL, etc.)
- **Platform abstraction** (ESCT2000, EASE2000, ESCT3000, XFLC1000, CFLC(Z))
- **Data flow coordination** between subsystems
- **Fault tolerance and redundancy** mechanisms

## High-Level Organization

```
┌─────────────────────────────────────────────────────────────┐
│                    FLC/ECMTCP System                           │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌───────────────────────┐ │
│  │   Platform   │  │   Platform   │  │      Platform          │ │
│  │  ESCT2000    │  │  EASE2000    │  │   ESCT3000/XFLC1000    │ │
│  └──────┬──────┘  └──────┬──────┘  └───────────┬───────────┘ │
│         │                 │                      │              │
│         ▼                 ▼                      ▼              │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                    FLC Core Layer                          │ │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌───────────────────┐ │ │
│  │  │   GOL   │ │   SOL   │ │  AVAIL  │ │      Other          │ │ │
│  │  │         │ │         │ │         │ │     Components       │ │ │
│  │  └─────────┘ └─────────┘ └─────────┘ └───────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                         │ │ │                                  │
│                         ▼ ▼ ▼                                  │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 Service & Data Layer                        │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │ │
│  │  │   Databases  │  │    Agents    │  │   External Systems    │ │ │
│  │  │ (ADDR, MAIN) │  │ (TL1, SDN)   │  │   (Network, SEPS)     │ │ │
│  │  └─────────────┘  └─────────────┘  └─────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Key Characteristics

- **Modularity**: Components are loosely coupled and independently deployable
- **Platform Independence**: Abstracts hardware-specific details
- **Scalability**: Supports systems ranging from small embedded devices to large-scale deployments
- **Reliability**: Built-in redundancy and failover mechanisms

## See Also

- [Components](/concepts/components.md) — Individual FLC components
- [Platforms](/concepts/platforms.md) — Supported hardware platforms
- [Databases](/entities/databases.md) — Data storage entities
- [Acronyms](/concepts/acronyms.md) — ECMTCP/FLC terminology reference