---
type: Concept
title: Test Frameworks
description: Testing frameworks and libraries used in ECMTCP for implementing various test types.
tags: [testing, ecmtcp, frameworks, tools, google-test, catch2]
status: draft
stale_after: 2027-11-04
generated: { by: opencode/mistral-medium, at: 2026-11-04T00:00:00Z }
sources:
  - id: google-test-docs
    resource: https://github.com/google/googletest
    title: Google Test documentation
    author: Google
    last_modified: 2026-10-01
  - id: observation
    resource: "observation:2026-11"
    title: Direct observation of ECMTCP test framework usage
--- 

# Test Frameworks

**Test frameworks** provide the infrastructure and utilities for writing, organizing, and executing tests in ECMTCP. This page catalogs the primary frameworks used across the project.

**Related concepts**:
- [Test Strategies](./test-strategies.md) — Testing methodologies that use these frameworks
- [Test Levels](./test-levels.md) — Granularity levels where frameworks are applied
- [Test Best Practices](./test-best-practices.md) — Guidelines for using frameworks effectively
- [Test Tools](../entities/test-tools.md) — Supporting utilities beyond frameworks

## Unit Testing Frameworks

### Google Test (gtest)
- **Type**: Unit testing framework for C++
- **Features**: Rich assertions, death tests, parameterized tests, test fixtures
- **Integration**: Native support in ECMTCP build system
- **Usage**: Primary framework for C++ unit tests
- **Documentation**: [Google Test Documentation](https://github.com/google/googletest)

### Catch2
- **Type**: Multi-paradigm test framework for C++
- **Features**: Header-only, expressive syntax, powerful matchers
- **Integration**: Used for specific test scenarios
- **Usage**: Alternative for certain C++ test cases

## Integration Testing Frameworks

### Custom Test Harnesses
- **Type**: ECMTCP-specific integration test infrastructure
- **Features**: Environment setup, component orchestration, result validation
- **Integration**: Built into the ECMTCP test ecosystem
- **Usage**: System and integration level tests

## Test Framework Comparison

| Framework | Language | Type | Strengths | Weaknesses |
|-----------|----------|------|-----------|------------|
| Google Test | C++ | Unit | Mature, well-documented, feature-rich | Verbose syntax |
| Catch2 | C++ | Unit | Expressive, header-only | Less integration with build system |
| Custom Harness | Multi | Integration | ECMTCP-specific, production-like | Maintenance overhead |

## Framework Selection Guidelines

1. **Use Google Test** for standard C++ unit tests
2. **Use Catch2** when header-only inclusion is required or for rapid prototyping
3. **Use Custom Harnesses** for integration and system tests requiring ECMTCP-specific setup

## Open Questions

- Are there other test frameworks used in ECMTCP (e.g., for other languages)?
- What is the migration strategy when updating framework versions?
- How are framework-specific configurations managed?
