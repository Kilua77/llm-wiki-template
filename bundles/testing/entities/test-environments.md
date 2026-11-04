---
type: Tool
title: Test Environments
description: Test environments used in ECMTCP for executing tests at different levels and stages.
tags: [testing, ecmtcp, environments, ci-cd, infrastructure]
status: draft
stale_after: 2027-11-04
generated: { by: opencode/mistral-medium, at: 2026-11-04T00:00:00Z }
sources:
  - id: observation
    resource: "observation:2026-11"
    title: Direct observation of ECMTCP test infrastructure
--- 

# Test Environments

**Test environments** are the controlled execution contexts in which ECMTCP tests are run, each configured to support specific testing needs and validation objectives.

**Related concepts**:
- [Test Levels](../concepts/test-levels.md) — Test granularity levels and their environment requirements
- [Test Strategies](../concepts/test-strategies.md) — Testing approaches that use these environments
- [Test Tools](./test-tools.md) — Tools for managing and using environments
- [Test Reports](./test-reports.md) — Outputs generated from environment-based testing

## Environment Types

### Development Environment
- **Purpose**: Local testing during development
- **Characteristics**: 
  - Developer workstation or container
  - Fast feedback loop
  - May have mocked dependencies
  - Limited resource isolation
- **Test Levels**: Unit, some module tests
- **Execution**: Manual or IDE-integrated

### Integration Environment
- **Purpose**: Testing interactions between components
- **Characteristics**:
  - Shared or dedicated infrastructure
  - Real dependencies where possible
  - Controlled configuration
  - Moderate resource allocation
- **Test Levels**: Module, integration tests
- **Execution**: CI/CD pipeline or manual trigger

### Staging Environment
- **Purpose**: Pre-production validation
- **Characteristics**:
  - Production-like configuration
  - Full dependency stack
  - Scaled resources
  - Isolated from production
- **Test Levels**: Integration, system, acceptance tests
- **Execution**: Automated or scheduled

### Production Environment
- **Purpose**: Final validation in live setting
- **Characteristics**:
  - Full production configuration
  - Real user data (anonymized)
  - Limited test execution window
  - Monitoring and rollback capabilities
- **Test Levels**: Acceptance, smoke tests
- **Execution**: Controlled, time-boxed

## Environment Comparison

| Environment | Isolation | Configuration | Data | Execution Frequency |
|-------------|-----------|---------------|------|---------------------|
| Development | Low | Developer-specific | Mock/Synthetic | Continuous |
| Integration | Medium | Standardized | Synthetic | Per-commit/merge |
| Staging | High | Production-like | Synthetic/Anonymized | Per-release |
| Production | High | Production | Real (anonymized) | Limited |

## Environment Provisioning

### Infrastructure as Code
- Environment configurations defined as code
- Version controlled alongside test code
- Reproducible and auditable

### Containerization
- Use of containers for environment consistency
- Docker or similar technologies
- Lightweight and portable

### Virtual Machines
- Full OS-level isolation
- Resource-intensive
- Used for complex dependencies

## Environment Management

### Lifecycle
1. **Provisioning**: Automated setup from configuration
2. **Configuration**: Environment-specific settings applied
3. **Validation**: Health checks and readiness verification
4. **Execution**: Test suite execution
5. **Cleanup**: Environment teardown and resource release

### Access Control
- Restricted access based on environment sensitivity
- Audit logging of all environment access
- Role-based permissions

## Open Questions

- How are environment configurations versioned and managed?
- What is the process for environment refresh or rotation?
- How are environment-specific issues tracked and resolved?
