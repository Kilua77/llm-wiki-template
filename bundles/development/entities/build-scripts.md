---
type: Tool
title: Build Scripts
description: Collection of scripts used in ECMTCP build processes for automation and customization.
tags: [scripts, automation, build, ecmtcp]
status: draft
stale_after: 2027-11-04
generated: { by: opencode/mistral-medium, at: 2026-11-04T00:00:00Z }
sources:
  - id: build-scripts-observation
    resource: observation:2026-11
    title: Observed build scripts and automation patterns
    author: ECMTCP Team
    last_modified: 2026-11-04
---

Build scripts in ECMTCP provide automation, customization, and control over the build process beyond what [Albie](albie.md) and [wpack](wpack.md) offer out of the box.

## Overview

Build scripts are used for:
- Custom build steps not covered by Albie
- Pre- and post-build operations
- Environment setup and validation
- Specialized packaging requirements
- Build system integration

These scripts complement the overall [build process](../concepts/build-process.md) and [dependency management](../concepts/dependency-management.md) in ECMTCP.

## Script Categories

### Configuration Scripts
Scripts that generate or modify build configuration files.

**Examples:**
- `configure-build.sh`: Generates platform-specific build configurations
- `set-env.sh`: Sets up build environment variables
- `validate-config.sh`: Validates build configuration files

### Build Helper Scripts
Scripts that assist in the build process.

**Examples:**
- `pre-build.sh`: Pre-build operations (cleanup, preparation)
- `post-build.sh`: Post-build operations (validation, cleanup)
- `parallel-build.sh`: Manages parallel build execution

### Packaging Scripts
Scripts that handle specialized packaging requirements.

**Examples:**
- `create-installer.sh`: Creates platform-specific installers
- `generate-metadata.sh`: Generates package metadata
- `sign-packages.sh`: Signs packages with digital signatures

### Deployment Scripts
Scripts that handle deployment and distribution.

**Examples:**
- `deploy.sh`: Deploys build artifacts to repositories
- `publish.sh`: Publishes packages to distribution channels
- `install-dependencies.sh`: Installs runtime dependencies

### Utility Scripts
General-purpose utility scripts for build management.

**Examples:**
- `clean.sh`: Cleans build artifacts
- `status.sh`: Reports build status
- `log-analyzer.sh`: Analyzes build logs

## Script Structure and Conventions

### File Naming
- Use kebab-case for script names
- Include platform/architecture in name when applicable
- Use `.sh` extension for shell scripts
- Use `.py` extension for Python scripts

### Script Location
```
scripts/
├── build/
│   ├── pre-build.sh
│   ├── post-build.sh
│   └── parallel-build.sh
├── config/
│   ├── configure-build.sh
│   └── set-env.sh
├── package/
│   ├── create-installer.sh
│   └── sign-packages.sh
├── deploy/
│   ├── deploy.sh
│   └── publish.sh
└── utils/
    ├── clean.sh
    └── status.sh
```

### Script Template
```bash
#!/bin/bash
# Script: <script-name>
# Description: <brief description>
# Author: ECMTCP Team
# Date: YYYY-MM-DD

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Functions
function usage() {
    cat <<EOF
Usage: $(basename "$0") [options]

Options:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output
    -d, --debug     Enable debug output
EOF
}

function log() {
    local level="$1"
    local message="$2"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $message"
}

# Main execution
main() {
    # Parse arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help) usage; exit 0 ;;
            -v|--verbose) VERBOSE=1 ;;
            -d|--debug) DEBUG=1 ;;
            *) echo "Unknown option: $1"; usage; exit 1 ;;
        esac
        shift
    done

    # Script logic here
    log "INFO" "Starting script execution"
    
    # ... script implementation ...
    
    log "INFO" "Script completed successfully"
}

# Run main function
main "$@"
```

## Common Script Patterns

### Environment Validation
```bash
# Check required tools
for tool in albie wpack g++ make; do
    if ! command -v $tool &> /dev/null; then
        echo "Error: $tool is not installed"
        exit 1
    fi
done

# Check environment variables
for var in FLC_ROOT BUILD_DIR; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done
```

### Parallel Execution
```bash
# Parallel build execution
BUILD_JOBS="${BUILD_JOBS:-$(nproc)}"

echo "Building with $BUILD_JOBS parallel jobs"
albie build --jobs $BUILD_JOBS
```

### Error Handling
```bash
# Error handling with trap
function cleanup() {
    echo "Cleaning up on error..."
    # Cleanup operations
}

trap cleanup ERR

# Main execution
set +e
# ... operations that might fail ...
set -e
```

### Logging
```bash
# Logging functions
LOG_FILE="${LOG_FILE:-build.log}"

function log_info() {
    echo "[INFO] $1" | tee -a "$LOG_FILE"
}

function log_error() {
    echo "[ERROR] $1" | tee -a "$LOG_FILE" >&2
}

function log_debug() {
    [ "$DEBUG" = "1" ] && echo "[DEBUG] $1" | tee -a "$LOG_FILE"
}
```

## Integration with Albie and wpack

### Albie Hook Scripts
Scripts that are called by Albie at specific points in the build process.

```yaml
# In albie configuration
hooks:
  pre-build: scripts/build/pre-build.sh
  post-build: scripts/build/post-build.sh
  pre-package: scripts/package/pre-package.sh
  post-package: scripts/package/post-package.sh
```

### wpack Hook Scripts
Scripts that are called by wpack during packaging.

```yaml
# In wpack configuration
hooks:
  pre-package: scripts/package/pre-package.sh
  post-package: scripts/package/post-package.sh
  pre-sign: scripts/package/pre-sign.sh
  post-sign: scripts/package/post-sign.sh
```

## Script Best Practices

### Security
- Validate all inputs
- Sanitize paths and filenames
- Use absolute paths when possible
- Set proper file permissions
- Avoid hardcoded credentials

### Performance
- Use efficient algorithms
- Minimize I/O operations
- Parallelize when possible
- Cache results when appropriate

### Maintainability
- Use consistent style
- Add comprehensive comments
- Document usage
- Handle errors gracefully
- Log important operations

### Portability
- Use portable shell features
- Avoid platform-specific commands
- Check for required tools
- Handle missing dependencies

## Script Examples

### Example: pre-build.sh
```bash
#!/bin/bash
# Script: pre-build.sh
# Description: Pre-build operations for ECMTCP
# Author: ECMTCP Team

set -euo pipefail

# Clean build directory
if [ -d "$BUILD_DIR" ]; then
    echo "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
fi

# Create build directory
mkdir -p "$BUILD_DIR"

# Validate environment
if [ ! -d "$FLC_ROOT" ]; then
    echo "Error: FLC_ROOT directory not found"
    exit 1
fi

# Set environment variables
export ALBIE_CONFIG="$PROJECT_ROOT/config/albie.yaml"
export WPACK_CONFIG="$PROJECT_ROOT/config/wpack.yaml"

echo "Pre-build operations completed successfully"
```

### Example: create-installer.sh
```bash
#!/bin/bash
# Script: create-installer.sh
# Description: Creates platform-specific installers
# Author: ECMTCP Team

set -euo pipefail

PLATFORM="${1:?Platform must be specified}"
VERSION="${2:?Version must be specified}"
OUTPUT_DIR="${3:-dist}"

mkdir -p "$OUTPUT_DIR"

case "$PLATFORM" in
    linux-x86_64)
        wpack package --format rpm --platform linux-x86_64 --version "$VERSION" --output "$OUTPUT_DIR"
        wpack package --format deb --platform linux-x86_64 --version "$VERSION" --output "$OUTPUT_DIR"
        ;;
    windows-x64)
        wpack package --format msi --platform windows-x64 --version "$VERSION" --output "$OUTPUT_DIR"
        ;;
    macos-x64)
        wpack package --format pkg --platform macos-x64 --version "$VERSION" --output "$OUTPUT_DIR"
        ;;
    *)
        echo "Error: Unsupported platform: $PLATFORM"
        exit 1
        ;;
esac

echo "Installer created successfully for $PLATFORM version $VERSION"
```

## Open Questions

- What are the standard practices for script versioning and distribution?
- How are scripts tested and validated before deployment?
- What are the security review processes for build scripts?
- How are script dependencies managed?
- What are the backup and recovery procedures for build scripts?
