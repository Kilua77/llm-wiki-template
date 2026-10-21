---
type: Concept
title: Supported Platforms
description: Hardware platforms supported by the ECMTCP system and their characteristics.
tags: [architecture, platforms, hardware, ecmtcp]
status: draft
stale_after: 2027-10-21
generated: { by: hermes/mistral-medium, at: 2026-10-21T17:30:00Z }
sources:
  - id: target-env
    resource: observation:2026-10
    title: Target Environment Documentation
---

# Supported Platforms

The ECMTCP system is designed to run on multiple **embedded hardware platforms**, each with specific capabilities and constraints. The FLC architecture abstracts platform-specific details, allowing the same software to run across different hardware.

## Platform Overview

| Platform | Description | Primary Use Case | Constraints |
|----------|-------------|-----------------|-------------|
| ESCT2000 | Embedded System Controller 2000 | Medium-scale deployments | Limited memory, single-core |
| EASE2000 | Enhanced Availability System 2000 | High-availability scenarios | Redundant hardware required |
| ESCT3000 | Embedded System Controller 3000 | Large-scale deployments | Multi-core, higher memory |
| XFLC1000 | eXtended FLC 1000 | Next-generation systems | Modern architecture, highest capacity |
| CFLC(Z) | Compact FLC (Z variant) | Space-constrained environments | Minimal footprint |

## Platform Characteristics

### ESCT2000
- **Architecture**: Single-core embedded processor
- **Memory**: 256MB - 512MB RAM
- **Storage**: 1GB - 4GB flash storage
- **Operating System**: Wind River Linux (LTS version)
- **Special Features**: Legacy hardware support, proven stability

### EASE2000
- **Architecture**: Dual-core embedded processor
- **Memory**: 1GB - 2GB RAM
- **Storage**: 4GB - 8GB flash storage
- **Operating System**: Wind River Linux (LTS version)
- **Special Features**: Hardware redundancy, hot-swap capabilities

### ESCT3000
- **Architecture**: Multi-core (4-8 cores) embedded processor
- **Memory**: 4GB - 8GB RAM
- **Storage**: 8GB - 16GB SSD
- **Operating System**: Wind River Linux (LTS version)
- **Special Features**: Virtualization support, advanced networking

### XFLC1000
- **Architecture**: Modern multi-core (8-16 cores) processor
- **Memory**: 8GB - 16GB RAM
- **Storage**: 16GB - 32GB SSD
- **Operating System**: Wind River Linux (LTS version)
- **Special Features**: Highest performance, future-proof design

### CFLC(Z)
- **Architecture**: Compact single-core processor
- **Memory**: 128MB - 256MB RAM
- **Storage**: 512MB - 1GB flash storage
- **Operating System**: Wind River Linux (LTS version, minimal)
- **Special Features**: Smallest footprint, lowest power consumption

## Platform Abstraction

The FLC architecture provides a **Platform Abstraction Layer (PAL)** that:

1. **Hides hardware differences**: Presents a uniform interface to upper layers
2. **Manages platform-specific features**: Handles unique capabilities of each platform
3. **Optimizes resource usage**: Adapts to platform constraints (memory, CPU, storage)
4. **Ensures portability**: Allows code to run unchanged across platforms

## Platform-Specific Considerations

### Memory Constraints
- CFLC(Z) and ESCT2000 have strict memory limits
- Memory-intensive operations must be carefully managed
- See [Embedded Limits](/constraints/embedded-limits.md) for details

### Processing Power
- Single-core platforms require efficient algorithms
- Multi-core platforms enable parallel processing
- Load balancing is handled by the FLC scheduler

### Storage Limitations
- Flash storage has limited write cycles
- Logging and temporary files must be managed carefully
- Critical data is stored in RAM when possible

## See Also

- [FLC Overview](/concepts/flc-overview.md) — High-level architecture
- [Embedded Limits](/constraints/embedded-limits.md) — Platform constraints
- [Wind River LTS](/constraints/windriver-lts.md) — OS constraints

## Sources

- [Target Environment Documentation - Digest](../references/target-env-digest.md)
- [Raw: Target Environment Documentation](../raw/2026-10-21-target-env.md)