---
type: Constraint
title: Wind River Linux LTS Operations and Security Constraints
description: Security constraints, update policy, patch management, and monitoring for WRL LTS in ECMTCP.
tags: [architecture, constraints, windriver, linux, lts, security, monitoring]
status: stable
stale_after: 2027-10-21
generated: { by: hermes/mistral-medium, at: 2026-10-21T18:00:00Z }
applies_to:
  - /concepts/platforms.md
  - /constraints/embedded-limits.md
  - /constraints/windriver-lts-versions.md
sources:
  - id: flc-components
    resource: observation:2026-10
    title: FLC Components Documentation
  - id: windriver-docs
    resource: observation:2026-10
    title: Wind River Linux documentation
---

# Wind River Linux LTS Operations and Security Constraints

This document details the **operational and security constraints** for Wind River Linux LTS versions used in ECMTCP.

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

- [Wind River Linux LTS Versions and Platform Constraints](/constraints/windriver-lts-versions.md) — Version details, kernel, toolchain
- [Platforms](/concepts/platforms.md) — Platform details
- [Embedded Limits](/constraints/embedded-limits.md) — Resource constraints
