---
type: Bundle Proposal
title: development
description: Outils de développement (Albie, wpack, scripts), build, versioning et environnement.
status: draft
generated: { by: hermes/mistral-medium, at: 2026-10-21T14:00:00Z }
---

## Motivation
ECMTCP utilise des **outils internes critiques** (Albie, wpack, scripts Perl/Shell) et un **processus de build complexe** non documenté centralement.

## Scope
- Système de build : Albie, Imakefile, AlbieMakefile
- **Outils internes** : wpack, reportDeliveryPackage.pl, mtcp_magic_delivery.sh, unpackOID.pl, ZIC
- Versioning : scripts `version.sh`, schéma `a.b.c.d.e`
- Environnement de dev : setup Linux, service users, partages réseau
- Migration ClearCase → Git

## Out-of-scope
- Architecture système (→ `architecture`)
- Détails des composants (→ `components`)
- Stratégies de test (→ `testing`)

## Tree
```
tools/       # albie.md, wpack.md, report-delivery-package.md, etc.
practices/   # dev-env-setup.md, git-workflow.md
playbooks/   # build-component.md, create-delivery.md
constraints/ # supported-compilers.md
references/  # Digests des documentations outils
raw/         # Sources brutes
```

## Initial pages
1. tools/albie.md
2. tools/wpack.md
3. tools/report-delivery-package.md
4. tools/mtcp-magic-delivery.md
5. tools/unpack-oid.md
6. tools/zic.md
7. tools/doxygen.md
8. practices/dev-env-setup.md
9. practices/git-workflow.md
10. playbooks/build-component.md
11. playbooks/create-delivery.md
12. constraints/supported-compilers.md

## Overlaps
- `architecture` : Décisions sur les outils (ici : configuration/usage)
- `best-practices` : Pratiques générales (ici : spécifiques aux outils)
