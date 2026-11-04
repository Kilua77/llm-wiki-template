---
type: Tool
title: wpack
description: Packaging tool used in ECMTCP for creating distributable packages and installers.
tags: [packaging, distribution, ecmtcp, build-tools]
status: draft
stale_after: 2027-11-04
generated: { by: opencode/mistral-medium, at: 2026-11-04T00:00:00Z }
sources:
  - id: wpack-internal-docs
    resource: observation:2026-11
    title: Internal wpack documentation and usage patterns
    author: ECMTCP Team
    last_modified: 2026-11-04
---

wpack is the packaging tool used within the ECMTCP project for creating distributable packages, installers, and deployment artifacts.

## Overview

wpack takes compiled binaries and resources, and packages them into various formats suitable for distribution and deployment. It works in conjunction with [Albie](albie.md) to provide a complete build-to-package pipeline, as described in the [build process](../concepts/build-process.md).

## Key Features

- **Multi-format packaging**: Supports various package formats (RPM, DEB, MSI, tar.gz, etc.)
- **Dependency bundling**: Includes all required dependencies in the package
- **Platform-specific packaging**: Generates packages appropriate for target platforms
- **Metadata generation**: Creates package metadata and manifests
- **Signature and verification**: Supports package signing and integrity verification

## Supported Package Formats

| Format | Platform | Description |
|--------|----------|-------------|
| RPM | Linux (Red Hat, CentOS, Fedora) | Red Hat Package Manager format |
| DEB | Linux (Debian, Ubuntu) | Debian package format |
| MSI | Windows | Windows Installer format |
| PKG | macOS | macOS package format |
| tar.gz | Cross-platform | Compressed tarball |
| zip | Cross-platform | ZIP archive |

## Architecture

```mermaid
graph TD
    A[wpack CLI] --> B[Input Analyzer]
    B --> C[Package Format Selector]
    C --> D[Dependency Bundler]
    D --> E[Metadata Generator]
    E --> F[Package Builder]
    F --> G[Signer]
    
    B --> H[Platform Detector]
    C --> I[Format Templates]
```

## Usage Patterns

### Basic Packaging Command
```bash
wpack package [input] [options]
```

### Common Options
- `--format`: Specify package format (rpm, deb, msi, etc.)
- `--output`: Specify output directory
- `--name`: Override package name
- `--version`: Override package version
- `--arch`: Specify target architecture
- `--sign`: Enable package signing

## Configuration

wpack uses configuration files to define packaging parameters, file lists, and platform-specific settings.

### Example Configuration Structure
```yaml
package:
  name: ecmtcp-application
  version: 2.0.0
  description: ECMTCP Application Package
  vendor: ECMTCP
  
files:
  include:
    - bin/*
    - lib/*
    - config/*
    - share/*
  exclude:
    - "*.debug"
    - "*.pdb"
    
dependencies:
  runtime:
    - libace.so.6.5.0
    - libssl.so.3
  
platforms:
  - linux-x86_64
  - windows-x64
```

## Integration with Albie

wpack is typically invoked as part of the Albie build pipeline. After Albie compiles the components, wpack takes the build artifacts and creates distributable packages.

## Build Pipeline Integration

```mermaid
sequenceDiagram
    participant Developer
    participant Albie
    participant Compiler
    participant wpack
    participant Repository
    
    Developer->>Albie: albie build
    Albie->>Compiler: Compile components
    Compiler-->>Albie: Build artifacts
    Albie->>wpack: wpack package
    wpack->>Repository: Upload packages
```

## Open Questions

- How does wpack handle platform-specific dependency resolution?
- What are the signing mechanisms and key management approaches?
- How are package repositories managed and versioned?
