---
type: Reference
title: ClearCase to Git Migration Study Digest
description: Summary of the ClearCase to Git migration feasibility study.
tags: [reference, migration, clearcase, git, version-control]
status: stable
stale_after: 2027-10-21
generated: { by: hermes/mistral-medium, at: 2026-10-21T17:00:00Z }
sources:
  - id: cc2git
    resource: observation:2026-10
    title: ClearCase to Git Migration Study
---

# ClearCase to Git Migration Study - Digest

This source provides a **detailed feasibility study** for migrating the FLC software components from IBM Rational ClearCase to Git version control system.

## Key Points

### System Comparison

The study includes a **comprehensive comparison** between ClearCase and Git:

| Aspect | ClearCase | Git |
|--------|-----------|-----|
| Repository model | Client-server | Distributed |
| Revision IDs | Branch + number | Global alphanumeric ID (SHA-1) |
| Scope of change | File | Directory tree snapshot |
| Concurrency model | Merge | Merge |
| Storage method | Deltas | Full content |
| Client | CLI, CC client, IDEs | CLI, Git clients/GUIs, IDEs |
| License | Proprietary | GPL |

### Current Organization (ClearCase)

The existing system has:
- **Multiple components** with interdependencies
- Source code **spread across different VOBs** (Versioned Object Bases)
- **Complex branching strategy**:
  - Main branch (never used for direct development)
  - Integration branches created per release
  - Developments merged into integration branches
  - Deliveries identified by unique labels (LIV)
  - Branches merged back to main at release end
  - Start labels applied to main for next integration branch

### Performance Analysis

**ClearCase Issues**:
- View creation and access can be slow
- Network dependencies for distributed development
- Winkin mechanism helps reduce compilation time
- Limited scalability for large teams

**Local Disk Benefits**:
- Faster access (no network latency)
- Full project available locally
- Better performance with SSD storage
- Limited to single machine (but multi-core compilation possible)

**Git Benefits**:
- Very fast for most operations (local repository)
- Clone time depends on history size
- Efficient branching and merging
- Scalable for large teams

### Migration Strategy

**Decision**: Stick with ClearCase organization principle — **1 ClearCase VOB corresponds to 1 Git repository**.

**Rationale**:
- Maintains existing component boundaries
- Allows incremental migration
- Preserves component independence
- Some components are shared with other projects (AVAIL, APPSERV)

**Central Coordination**:
- Need a central Git repository to coordinate all component repositories
- Currently done by ECMTCP delivery labels
- Can be replaced by a Git repository containing descriptor files (version.json, package.des, package.py)

### Git Workflow Options

**Option 1: ClearCase-like Workflow**
- Keep same organization as ClearCase for delivery labels and branches
- Reproduce existing branches with automated migration
- Master branch for main development
- Integration branches for releases

**Option 2: Git-native Workflow**
- Master branch for linear integration
- Feature branches for development, bugfix, and maintenance
- Continuous integration

**Option 3: Hybrid Workflow**
- Master branch for start only
- Cascaded integration branches
- Feature branches for development
- Continuous integration

### Migration Approaches

**Full Move from VOBs to Local Disk**:
- Build chain (Albie) can be copied to local disk
- Albie can run independently from ClearCase
- Most paths are relative to environment variables
- Projects can be copied to local disk and compiled with same build chain

**Full Move from Local Disk to Git**:
1. Create empty bare Git repository
2. Clone empty project
3. Extract all files from ClearCase
4. Add and commit all files to Git
5. Push all files to server
6. Clone project on other machines

### Interworking During Transition

**Partial Migrations**: Some VOBs may be in Git while others remain in ClearCase.

**Solution**: Use symbolic links to connect components across different version control systems.

### Coherency Management

**Challenge**: Although each component has its own deliveries and tags, there is strong coherency between them.

**Coherency Mechanisms**:
- Interfaces are shared internally (GLI, SLI) or externally (XML, TL1, EC-SC)
- Some components are libraries (AVAIL, APPSERV) used by others
- All components are referenced in a FLC global delivery (ECMTCP)

**Solution**: Synchronize **16 repositories**:
- External interfaces: TL1IOM, SYSTLC, INTER
- Components: TL1AGENT, GLIAGT, GOL, SLI, SOL, PLAT-RHEL, COMMON, IRM, CONF
- Dependencies: ALBIE, AVAIL, APPSERV, ORBLIGHT
- Referent: ECMTCP

**Coherency Tools**:
- Generate from ECMTCP config spec
- Git submodules for environment and coherency management

### Automated Migration

An experimental script has been developed to:
- Migrate a single component by creating a Git repository
- Include all deliveries of the component
- Optionally include all branches
- Follow the same organization as ClearCase branches
- Result: Master branch with latest delivery, all deliveries as Git tags

### Open Points

- How to organize Git? (number of repositories, branching strategy)
- How many branches to migrate? (only latest release? all historical?)
- Developers request history of changes
- Maintenance releases: out of scope for initial migration
- Rollback to ClearCase: out of scope

## Conclusion

Migration from ClearCase to Git is **feasible** and offers significant advantages:
- Better performance for most operations
- Improved developer experience
- Modern tooling ecosystem
- Open source license
- Distributed development model

The migration requires **careful planning** to maintain component coherency and preserve development workflows.

## See Also
- [Raw source](../raw/2026-10-21-cc2git.md)
