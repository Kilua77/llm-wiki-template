---
type: Constraint
title: Wind River Linux LTS Constraints
description: Constraints and requirements for Wind River Linux LTS in ECMTCP.
tags: [architecture, constraints, windriver, linux, lts, os]
status: stable
stale_after: 2027-10-21
generated: { by: hermes/mistral-medium, at: 2026-10-21T17:30:00Z }
applies_to:
  - /concepts/platforms.md
  - /constraints/embedded-limits.md
sources:
  - id: flc-components
    resource: observation:2026-10
    title: FLC Components Documentation
sources:
  - id: windriver-docs
    resource: observation:2026-10
    title: Wind River Linux documentation
---

# Wind River Linux LTS Constraints

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

## Security Constraints

### User and Permission Model

1. **User Accounts**:
   - **Root**: Disabled for interactive login (SSH, console)
   - **ecmtcp**: Primary service account (UID 1000)
   - **Maintenance**: Read-only account for diagnostics (UID 1001)
   - **No additional accounts** permitted without approval

2. **File Permissions**:
   - **Configuration files**: 640 (owner: ecmtcp, group: ecmtcp)
   - **Log files**: 640 (owner: ecmtcp, group: ecmtcp)
   - **Database files**: 600 (owner: ecmtcp, group: ecmtcp)
   - **Executables**: 750 (owner: root, group: ecmtcp)
   - **Directories**: 750 (owner: root, group: ecmtcp)

3. **SUID/SGID**: **Forbidden** on all files

### Network Security

1. **Firewall**:
   - **Enabled**: On all platforms
   - **Default Policy**: DROP for incoming, ACCEPT for outgoing
   - **Allowed Services**: Only explicitly configured services

2. **SSH**:
   - **Protocol**: SSHv2 only
   - **Authentication**: Key-based only (password authentication disabled)
   - **Ciphers**: AES-256-GCM, ChaCha20-Poly1305
   - **MACs**: HMAC-SHA2-256, HMAC-SHA2-512
   - **Key Exchange**: curve25519-sha256, diffie-hellman-group-exchange-sha256

3. **TLS**:
   - **Minimum Version**: TLS 1.2
   - **Preferred Version**: TLS 1.3
   - **Cipher Suites**: Only strong cipher suites (AES-256, SHA-2)

## Update and Patch Management

### Update Policy

1. **LTS Updates**:
   - **Security Updates**: Applied within 30 days of release
   - **Bug Fix Updates**: Applied within 90 days of release
   - **Feature Updates**: Not applied (LTS only)

2. **Testing Requirements**:
   - All updates must be **tested on non-production systems first**
   - Rollback plan must be **documented and tested**
   - Production deployment requires **explicit approval**

3. **Update Frequency**:
   - **Security**: Monthly (or as needed for critical vulnerabilities)
   - **Bug Fixes**: Quarterly
   - **LTS Upgrade**: Every 2 years (aligned with WRL LTS cycle)

### Patch Management

1. **Custom Patches**:
   - Must be **minimal and focused**
   - Must include **detailed documentation**
   - Must be **forward-portable**
   - Must be **reviewed by architecture team**

2. **Patch Tracking**:
   - All patches tracked in **version control**
   - Patch status (applied, pending, rejected) documented
   - Patch testing results documented

## Monitoring and Logging

### System Monitoring

1. **Required Metrics**:
   - CPU usage (per-core and total)
   - Memory usage (RAM and swap)
   - Storage usage (per-filesystem)
   - Network I/O (per-interface)
   - Process count
   - Thread count

2. **Monitoring Frequency**:
   - **Critical metrics**: Every 10 seconds
   - **Standard metrics**: Every 60 seconds
   - **Health checks**: Every 5 minutes

3. **Alert Thresholds**:
   - **Warning**: 70% of any resource limit
   - **Critical**: 85% of any resource limit
   - **Emergency**: 95% of any resource limit

### Logging

1. **Log Files**:
   - **Location**: `/var/log/ecmtcp/`
   - **Rotation**: Daily, keep last 30 days
   - **Compression**: Enabled for logs older than 7 days
   - **Maximum Size**: 10MB per file

2. **Log Levels**:
   - **Emergency**: System is unusable
   - **Alert**: Immediate action required
   - **Critical**: Critical conditions
   - **Error**: Error conditions
   - **Warning**: Warning conditions
   - **Notice**: Normal but significant conditions
   - **Info**: Informational messages
   - **Debug**: Debug-level messages (disabled in production)

3. **Log Content**:
   - Must **not** contain sensitive information
   - Must **not** contain personal data
   - Must use **structured logging** format

## See Also

- [Platforms](/concepts/platforms.md) — Platform details
- [Embedded Limits](/constraints/embedded-limits.md) — Resource constraints
- [FLC Overview](/concepts/flc-overview.md) — System architecture

## Sources

- [FLC Components Documentation - Digest](../references/flc-components-digest.md)
- [Raw: FLC Components Documentation](../raw/2026-10-21-flc-components.md)
- [ClearCase to Git Migration - Digest](../references/cc2git-digest.md)
- [Raw: ClearCase to Git Migration](../raw/2026-10-21-cc2git.md)