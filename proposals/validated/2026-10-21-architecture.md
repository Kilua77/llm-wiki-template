---
type: Bundle Proposal
title: architecture
description: Architecture globale FLC/ECMTCP, composants, plateformes, acronymes et décisions.
status: draft
generated: { by: hermes/mistral-medium, at: 2026-10-21T14:00:00Z }
---

## Motivation
Aucun bundle existant ne couvre l'architecture globale d'ECMTCP. La connaissance architecturale est **fondamentale** pour tous les autres bundles.

## Scope
- Architecture FLC/ECMTCP : composants, relations, flux de données
- Plateformes embarquées : ESCT2000, EASE2000, ESCT3000, XFLC1000, CFLC(Z)
- **Acronymes** (ASN, FLC, SLTE, SLC, SC, TLC, NE, etc.)
- Décisions d'architecture (ADRs) et contraintes système

## Out-of-scope
- Détails d'implémentation des composants (→ bundle `components`)
- Outils de build (Albie, wpack) (→ bundle `development`)
- Stratégies de test (→ bundle `testing`)

## Tree
```
concepts/      # flc-overview, components, platforms, acronyms
entities/      # databases (ADDR, MAIN, MAINPM, SDNAGENT, TL1AGENT)
decisions/     # ADRs (ex: clearcase-to-git)
constraints/   # Contraintes système (embedded-limits, windriver-lts)
references/    # Digests des sources MkDocs
raw/           # Sources brutes (immutables)
```

## Initial pages
1. concepts/flc-overview.md
2. concepts/components.md
3. concepts/platforms.md
4. concepts/acronyms.md
5. entities/databases.md
6. decisions/clearcase-to-git.md
7. constraints/embedded-limits.md
8. constraints/windriver-lts.md

## Overlaps
- `components` : Détail des composants (ici : vue haut-niveau uniquement)
- `development` : Décisions sur les outils (ici : architecturales uniquement)
