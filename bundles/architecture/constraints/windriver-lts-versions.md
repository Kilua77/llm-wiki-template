---
type: Constraint
title: Wind River Linux LTS Versions and Platform Constraints
description: Supported WRL LTS versions, kernel constraints, and toolchain requirements for ECMTCP platforms.
tags: [architecture, constraints, windriver, linux, lts, os, kernel, compiler]
status: stable
stale_after: 2027-10-21
generated: { by: hermes/mistral-medium, at: 2026-10-21T18:00:00Z }
applies_to:
  - /concepts/platforms.md
  - /constraints/embedded-limits.md
sources:
  - id: flc-components
    resource: observation:2026-10
    title: FLC Components Documentation
  - id: windriver-docs
    resource: observation:2026-10
    title: Wind River Linux documentation
---

# Wind River Linux LTS Versions and Platform Constraints

The ECMTCP system runs exclusively on **Wind River Linux (WRL) Long-Term Support (LTS)** versions. This choice imposes specific constraints on the system architecture, development practices, and deployment strategies.

## Version Constraints

### Supported WRL LTS Versions

| Version | Release Date | EOL Date | ECMTCP Support | Notes |
|---------|--------------|----------|----------------|-------|
| WRL 8 | 2018 | 2028 | Full | Primary version for ESCT2000, EASE2000 |
| WRL 9 | 2020 | 2030 | Full | Primary version for ESCT3000, XFLC1000 |
| WRL 10 | 2022 | 2032 | Partial | Evaluation for XFLC1000 |
| WRL 7 | 2016 | 2026 | Legacy | CFLC(Z) only, no new development |

### Version Selection Rules

1. **Platform Mapping**:
   - CFLC(Z): WRL 7 (legacy) or WRL 8
   - ESCT2000: WRL 8
   - EASE2000: WRL 8
   - ESCT3000: WRL 9
   - XFLC1000: WRL 9 or WRL 10

2. **LTS Only**: Only LTS versions are permitted; no development or maintenance releases
3. **EOL Compliance**: Platforms must run a WRL version that is **not end-of-life**
4. **Upgrade Path**: Must be able to upgrade to a newer LTS version within 12 months

## Kernel Constraints

### Kernel Versions

| WRL Version | Kernel Version | Custom Patches | Notes |
|-------------|----------------|----------------|-------|
| WRL 7 | 4.4.x | ECMTCP-specific | Legacy support |
| WRL 8 | 4.19.x | ECMTCP-specific | Mainstream |
| WRL 9 | 5.4.x | ECMTCP-specific | Mainstream |
| WRL 10 | 5.10.x | ECMTCP-specific | Evaluation |

### Kernel Configuration

1. **Required Kernel Features**:
   - Real-time extensions (PREEMPT_RT)
   - Memory protection
   - Process isolation
   - Extended file system support (squashfs, overlayfs)
   - Network namespace support

2. **Disabled Kernel Features** (for security and stability):
   - Debugging options (CONFIG_DEBUG_*)
   - Unnecessary file systems
   - Unnecessary device drivers
   - Kernel module loading (on production systems)

3. **Custom Patches**:
   - All custom patches must be **minimal and focused**
   - Each patch must have a **detailed justification**
   - Patches must be **forward-portable** to newer kernels
   - Maximum 20 custom patches per kernel version

## Library and Toolchain Constraints

### C Library

- **Primary**: glibc (WRL standard)
- **Version**: Matched to WRL version
- **Constraints**:
  - No custom glibc builds
  - No glibc modifications
  - Use only standard library functions

### Compiler

- **Primary**: GCC
- **Version**: Matched to WRL version
- **Constraints**:
  - GCC 7.x for WRL 7/8
  - GCC 9.x for WRL 9
  - GCC 10.x for WRL 10
  - No compiler modifications
  - Standard optimization levels only (-O2 maximum)

### Build System

- **Supported**: Make, CMake
- **Constraints**:
  - No custom build system modifications
  - Cross-compilation required for all platforms
  - Build must be **reproducible**

## Package Constraints

### Allowed Packages

Only packages from the following sources are permitted:
1. **WRL Standard Packages**: All packages included in the WRL LTS distribution
2. **WRL Layer Packages**: Packages from officially supported WRL layers
3. **ECMTCP Custom Packages**: Pre-approved custom packages (see below)

### Custom Package Requirements

1. **Approval Process**:
   - All custom packages must be **approved by architecture team**
   - Each package must have a **detailed justification**
   - Security review required for network-facing packages

2. **Package Constraints**:
   - **Minimum Size**: No minimum (but small packages preferred)
   - **Maximum Size**: 10MB installed (50MB for exceptional cases)
   - **Dependencies**: Must not introduce circular dependencies
   - **Licensing**: Must be compatible with ECMTCP licensing

3. **Pre-Approved Custom Packages**:
   - OpenSSL (custom build with ECMTCP-specific configurations)
   - OpenSSH (custom build with ECMTCP-specific configurations)
   - Net-SNMP (custom build with ECMTCP-specific configurations)
   - Custom telemetry agents

### Forbidden Packages

The following are **explicitly forbidden**:
- Any package not in WRL standard or approved custom list
- Development tools (compilers, debuggers) on production systems
- Desktop environment packages
- Unnecessary server packages (web servers, database servers)
- Any package with known critical vulnerabilities

## See Also

- [Wind River Linux LTS Operations and Security](/constraints/windriver-lts-operations.md) — Update policy, security, monitoring
- [Platforms](/concepts/platforms.md) — Platform details
- [Embedded Limits](/constraints/embedded-limits.md) — Resource constraints
