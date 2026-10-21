---
type: Concept
title: FLC Overview
description: Global architecture of the FLC/ECMTCP system, its purpose, and high-level organization.
tags: [architecture, flc, ecmtcp, system-overview]
status: draft
stale_after: 2027-10-21
generated: { by: hermes/mistral-medium, at: 2026-10-21T17:30:00Z }
sources:
  - id: flc-intro
    resource: observation:2026-10
    title: FLC Documentation Index
  - id: flc-components
    resource: observation:2026-10
    title: FLC Components Documentation
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

```mermaid
flowchart TD
    %% Platforms Layer
    subgraph Platforms["Supported Platforms"]
        ESCT2000["ESCT2000\n(PowerPC, Montavista)"]
        EASE2000["EASE2000\n(Intel, RHEL 6.x)"]
        ESCT3000["ESCT3000\n(ARMv7 Xilinx, WRL)"]
        XFLC1000["XFLC1000/CFLC(Z)\n(ARM Xilinx, WRL 64-bit)"]
    end
    
    %% FLC Core Layer
    subgraph FLCCore["FLC Core Layer"]
        GOL["GOL\nGeneric Object Layer"]
        SOL["SOL\nSpecific Object Layer"]
        AVAIL["AVAIL\nAvailability Manager"]
        Other["Other Components"]
    end
    
    %% Service & Data Layer
    subgraph ServiceData["Service & Data Layer"]
        DB["Databases\n(ADDR, MAIN, MAINPM)"]
        Agents["Agents\n(TL1, SDN)"]
        External["External Systems\n(Network, SEPS)"]
    end
    
    %% Connections
    ESCT2000 --> GOL
    EASE2000 --> GOL
    ESCT3000 --> GOL
    XFLC1000 --> GOL
    
    GOL --> SOL
    SOL --> AVAIL
    AVAIL --> Other
    
    GOL --> DB
    SOL --> DB
    AVAIL --> Agents
    Other --> Agents
    
    Agents --> External
    DB --> External
    
    %% Styling
    classDef deprecated fill:#f9f,stroke:#333;
    class ESCT2000,EASE2000 deprecated;
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

## Sources

- [FLC Documentation Index - Digest](../references/flc-intro-digest.md)
- [FLC Components Documentation - Digest](../references/flc-components-digest.md)
- [Raw: FLC Documentation Index](../raw/2026-10-21-flc-intro.md)
- [Raw: FLC Components Documentation](../raw/2026-10-21-flc-components.md)