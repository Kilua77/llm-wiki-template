---
type: Decision
title: Migration from ClearCase to Git
description: Decision to migrate ECMTCP versioning from ClearCase to Git, including rationale, process, and consequences.
tags: [architecture, decision, migration, versioning, clearcase, git]
status: stable
stale_after: 2027-10-21
generated: { by: hermes/mistral-medium, at: 2026-10-21T18:00:00Z }
code_refs:
  - repo: MTCP_16WX
    commit: a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0
    path: EC/README
    note: ClearCase migration reference in README
applies_to:
  - /concepts/flc-overview.md
sources:
  - id: cc2git
    resource: observation:2026-10
    title: ClearCase to Git migration documentation
---

# Migration from ClearCase to Git

## Context

The ECMTCP project historically used **IBM Rational ClearCase** for version control. Over time, several limitations became apparent:

- **Complexity**: View management in ClearCase was increasingly complex, especially with multiple branches and deliveries.
- **Performance**: ClearCase showed poor performance with large repositories and many files.
- **Cost**: ClearCase is a proprietary and expensive solution, requiring dedicated licensing.
- **Tooling**: Modern CI/CD pipelines and development tools have better integration with Git.
- **Industry Standard**: Git has become the de facto standard for version control in software development.

## Decision

**Migrate all ECMTCP components from ClearCase to Git.**

This migration was approved by the architecture team in 2021 and has been executed incrementally across all components.

## Consequences

### Positive

1. **Improved Collaboration**:
   - Easier branching, merging, and code review workflows.
   - Better support for distributed teams.
   - Standardized tooling across the industry.

2. **Cost Reduction**:
   - Elimination of ClearCase license costs.
   - Reduced infrastructure requirements.

3. **Modern Tooling**:
   - Integration with CI/CD pipelines (Jenkins, GitLab CI, etc.).
   - Better support for automated testing and deployment.
   - Access to modern development tools and plugins.

4. **Performance**:
   - Faster operations (clone, commit, push, pull).
   - Better handling of large repositories.
   - Improved scalability.

### Negative

1. **Learning Curve**:
   - Team required training on Git workflows.
   - Adaptation period for developers accustomed to ClearCase.

2. **Migration Effort**:
   - Manual conversion of history for some components.
   - Verification of migrated repositories.
   - Potential for lost history or metadata.

3. **Tooling Adjustments**:
   - Adaptation of build scripts (Albie) to work with Git.
   - Updates to release and delivery processes.
   - Modifications to existing workflows.

## Implementation

### Migration Process

1. **Component-by-Component**: Components were migrated incrementally, starting with the most actively developed:
   - MTCP_GOL (2021-11)
   - MTCP_AVAIL (2021-12)
   - MTCP_APPSERV (2022-01)
   - Other components followed in subsequent months

2. **History Preservation**:
   - Full commit history was preserved where possible.
   - Custom scripts (`cc2git`) were used for history conversion.
   - Tags and branches were mapped to Git equivalents.

3. **Verification**:
   - Each migrated component was verified for completeness.
   - Build tests were run on migrated repositories.
   - History continuity was checked.

### Timeline

- **Start**: Q4 2021
- **Major Components**: Migrated by Q2 2022
- **Legacy Branches**: Ongoing migration for historical branches
- **Completion**: Expected Q1 2023

## Open Questions

- How to handle legacy ClearCase views that were not fully migrated?
- What is the long-term strategy for components that cannot be migrated due to dependencies?

## See Also

- [FLC Overview](/concepts/flc-overview.md) — System architecture
- [Component Details](../../components/) — Individual component documentation