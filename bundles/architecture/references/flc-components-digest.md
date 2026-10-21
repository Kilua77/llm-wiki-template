---
type: Reference
title: FLC Components Documentation Digest
description: Summary of the FLC components documentation.
tags: [reference, flc, components, architecture]
status: stable
stale_after: 2027-10-21
generated: { by: hermes/mistral-medium, at: 2026-10-21T16:15:00Z }
sources:
  - id: flc-components
    resource: observation:2026-10
    title: FLC Components Documentation
---

# FLC Components Documentation - Digest

This source provides a **comprehensive overview** of the FLC (First Level Controller) software components and their architecture.

## Key Points

- FLC is the main controller of a network element system, responsible for configuration, monitoring, security, and software upgrades
- FLC is part of a controller hierarchy (EC, SLC, SC, TLC)
- The system is based on a robust object-oriented architecture with multiple components
- Main components: AVAIL (Availability Manager), DB Manager, GOL (Generic Object Layer), SOL (Specific Object Layer), TL1 Agent, SDN Agent

## Architecture

The source includes a **Mermaid diagram** showing:
- Component relationships and dependencies
- Database connections (ADDR, MAIN, MAINPM, SDNAGENT, TL1AGENT)
- Startup sequence and monitoring relationships

## Platform Support

Components run on multiple embedded platforms:
- ESCT2000 (legacy, PowerPC, Montavista Linux) — deprecated
- EASE2000 (Intel, RHEL 6.x) — deprecated
- ESCT3000 (ARMv7 Xilinx, Wind River Linux)
- XFLC1000 and CFLC(Z) (ARM Xilinx, Wind River Linux, 64-bit)
- Host environments (RHEL workstations for simulation)

### Wind River Linux

- Embedded Linux distribution based on Yocto project
- Long Term Support (LTS) versions updated with Rolling Cumulative Patch Layer (RCPL)

## Component Dependencies

The source details a **dependency matrix** showing:
- Which components are deliverable (Y/N)
- Dependencies between components
- Build tool requirements
- Component descriptions

### Core Dependencies

- ECMTCP: Core framework, depends on all components
- AVAIL: Depends on APPSERV and build tools
- APPSERV: Application Server, foundational for many components
- GOLWDM/SOLWDM: Object layers with multiple dependencies
- SDNAGENT/TL1AGENT: Protocol agents with specific dependencies

## Versioning System

### Historical (ClearCase)

- Version format: `FLC-<COMPONENT>-V<BRANCH>.<VERSION>-<BUILD>-<ARCH>.rpm`
- Example: `FLC-SOLWDM-V02.08.25-01-arm.rpm`

### Current (Git)

- Simplified format: `a.b.c.d.e`
- `a.b.c`: Release numbers
- `d.e`: Component version (major.minor)
- Each component has a `version.sh` script for version management

## Build and Delivery

- **Albie**: Build automation tool
- **wpack**: Delivery packaging tool (Python3)
- **version.sh**: Per-component version management
- **mtcp_magic_delivery.sh**: Patch building script
- Delivery process: build → package → generate notes → track

## See Also
- [Raw source](../raw/2026-10-21-flc-components.md)
