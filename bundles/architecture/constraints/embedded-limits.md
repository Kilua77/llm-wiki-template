---
type: Constraint
title: Embedded Platform Resource Limits
description: Hard constraints on resource usage for embedded platforms in ECMTCP.
tags: [architecture, constraints, embedded, limits, memory, storage]
status: stable
stale_after: 2027-10-21
generated: { by: hermes/mistral-medium, at: 2026-10-21T15:30:00Z }
applies_to:
  - /concepts/platforms.md
  - /entities/databases.md
sources:
  - id: platform-specs
    resource: observation:2026-10
    title: Platform specification documents
---

# Embedded Platform Resource Limits

The ECMTCP system runs on **resource-constrained embedded platforms** with strict limits on memory, storage, and processing power. These constraints fundamentally shape the architecture and must be respected by all components.

## Memory Constraints

### Per-Platform Memory Limits

| Platform | Total RAM | Available for ECMTCP | Notes |
|----------|-----------|----------------------|-------|
| CFLC(Z) | 128-256MB | ≤ 160MB | Minimal footprint required |
| ESCT2000 | 256-512MB | ≤ 384MB | Conservative usage recommended |
| EASE2000 | 1-2GB | ≤ 1.5GB | Redundancy overhead included |
| ESCT3000 | 4-8GB | ≤ 6GB | Virtualization overhead considered |
| XFLC1000 | 8-16GB | ≤ 12GB | Highest capacity platform |

### Memory Allocation Rules

1. **Static Allocation**: All critical memory must be allocated at startup
2. **Dynamic Allocation Limits**: 
   - Maximum single allocation: 16MB (CFLC/Z) to 64MB (XFLC1000)
   - Total dynamic allocations: ≤ 50% of available RAM
3. **Stack Size**: 
   - Main thread: 8KB (CFLC/Z) to 32KB (XFLC1000)
   - Worker threads: 4KB (CFLC/Z) to 16KB (XFLC1000)
4. **Buffer Sizes**:
   - Network buffers: ≤ 64KB each
   - File I/O buffers: ≤ 128KB each
   - Message queues: ≤ 1MB total per component

### Memory Usage Monitoring

- **Thresholds**: Warnings at 70% usage, critical alerts at 85%
- **Recovery Actions**: 
  - At 85%: Log warning, start memory cleanup
  - At 95%: Reject new connections, aggressive cleanup
  - At 98%: Emergency shutdown of non-critical components

## Storage Constraints

### Per-Platform Storage Limits

| Platform | Total Storage | Available for ECMTCP | Notes |
|----------|---------------|----------------------|-------|
| CFLC(Z) | 512MB-1GB | ≤ 800MB | Flash storage |
| ESCT2000 | 1-4GB | ≤ 3GB | Flash storage |
| EASE2000 | 4-8GB | ≤ 6GB | Flash storage |
| ESCT3000 | 8-16GB | ≤ 12GB | SSD storage |
| XFLC1000 | 16-32GB | ≤ 24GB | SSD storage |

### Storage Allocation Rules

1. **Database Sizes**:
   - ADDR: ≤ 100MB (all platforms)
   - MAIN: ≤ 1GB (ESCT2000), ≤ 2GB (EASE2000+)
   - MAINPM: ≤ 50MB (all platforms)
   - TL1AGENT/SDNAGENT: ≤ 50MB each
   - Total databases: ≤ 50% of available storage

2. **Log Files**:
   - Maximum log file size: 10MB
   - Maximum total logs: 100MB
   - Rotation: Daily, keep last 7 days
   - Compression: Enabled for logs older than 1 day

3. **Temporary Files**:
   - Maximum size: 10MB per file
   - Maximum total: 50MB
   - Automatic cleanup: Files older than 1 hour

4. **Configuration Files**:
   - Maximum size: 1MB per file
   - Maximum total: 20MB

### Storage Usage Monitoring

- **Thresholds**: Warnings at 70% usage, critical alerts at 85%
- **Recovery Actions**:
  - At 85%: Log warning, start cleanup of temporary files
  - At 95%: Reject new data writes, aggressive cleanup
  - At 98%: Emergency mode, read-only operations only

## Processing Constraints

### CPU Limits

| Platform | Cores | Max ECMTCP Usage | Notes |
|----------|-------|-------------------|-------|
| CFLC(Z) | 1 | 100% | Single-threaded |
| ESCT2000 | 1 | 100% | Single-threaded |
| EASE2000 | 2 | 150% | Light multithreading |
| ESCT3000 | 4-8 | 300% | Moderate multithreading |
| XFLC1000 | 8-16 | 600% | Heavy multithreading |

### Processing Rules

1. **Thread Limits**:
   - CFLC(Z): ≤ 10 threads total
   - ESCT2000: ≤ 20 threads total
   - EASE2000: ≤ 50 threads total
   - ESCT3000: ≤ 100 threads total
   - XFLC1000: ≤ 200 threads total

2. **Priority Levels**:
   - Real-time: Network I/O, critical timers
   - High: Database operations, component communication
   - Normal: Business logic, non-critical operations
   - Low: Background tasks, maintenance

3. **CPU Usage Monitoring**:
   - **Thresholds**: Warnings at 70% usage, critical alerts at 85%
   - **Recovery Actions**:
     - At 85%: Log warning, reduce non-critical operations
     - At 95%: Shed load, reject new requests
     - At 98%: Emergency mode, critical operations only

## Network Constraints

### Connection Limits

| Platform | Max Concurrent Connections | Max Connection Rate | Notes |
|----------|----------------------------|---------------------|-------|
| CFLC(Z) | 100 | 10/sec | Very conservative |
| ESCT2000 | 500 | 50/sec | Conservative |
| EASE2000 | 1000 | 100/sec | Balanced |
| ESCT3000 | 5000 | 500/sec | High capacity |
| XFLC1000 | 10000 | 1000/sec | Maximum capacity |

### Bandwidth Limits

- **Per-connection**: ≤ 10Mbps (CFLC/Z), ≤ 100Mbps (others)
- **Total**: ≤ 100Mbps (CFLC/Z), ≤ 1Gbps (ESCT2000/EASE2000), ≤ 10Gbps (ESCT3000/XFLC1000)

## File System Constraints

### File Count Limits

- **Maximum files**: 10,000 (CFLC/Z), 50,000 (ESCT2000), 100,000 (EASE2000+)
- **Maximum directories**: 1,000 (CFLC/Z), 5,000 (ESCT2000), 10,000 (EASE2000+)
- **Directory depth**: ≤ 8 levels (all platforms)

### File Name Limits

- **Maximum length**: 64 characters (CFLC/Z), 128 characters (others)
- **Allowed characters**: Alphanumeric, underscore, hyphen, period
- **Case sensitivity**: Case-sensitive on all platforms

## See Also

- [Platforms](/concepts/platforms.md) — Platform details
- [Wind River LTS](/constraints/windriver-lts.md) — OS constraints
- [FLC Overview](/concepts/flc-overview.md) — System architecture