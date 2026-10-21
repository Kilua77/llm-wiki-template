---
type: Bundle Proposal
title: components
description: Composants ECMTCP individuels (GOL, SOL, AVAIL, etc.), interfaces et bases de données.
status: draft
generated: { by: hermes/mistral-medium, at: 2026-10-21T14:00:00Z }
---

## Motivation
La vue haut-niveau de `architecture` ne couvre pas les **détails internes** des composants. Ce bundle permet une documentation **granulaire** par composant.

## Scope
- Fonctionnalités et responsabilités de chaque composant MTCP_*
- Interfaces (GLI, SLI, TL1, SDN, XML)
- Bases de données (ADDR, MAIN, MAINPM, SDNAGENT, TL1AGENT)
- Décisions et contraintes **spécifiques aux composants**

## Out-of-scope
- Architecture globale (→ `architecture`)
- Outils de build (→ `development`)
- Stratégies de test (→ `testing`)

## Tree
```
entities/      # Composants (avail.md, gol.md, sol.md, etc.) et bases de données
concepts/      # Concepts transversaux (ex: couches objets)
decisions/     # Décisions par composant
constraints/   # Contraintes par composant
references/    # Digests des READMEs des composants
raw/           # Sources brutes
```

## Initial pages
1. entities/avail.md
2. entities/gol.md
3. entities/sol.md
4. entities/appserv.md
5. entities/common.md
6. entities/tl1agent.md
7. entities/sdnagent.md
8. entities/irm-16wx.md
9. entities/gliagt.md
10. entities/sli.md
11. entities/addr-db.md
12. entities/main-db.md
13. entities/mainpm-db.md

## Overlaps
- `architecture` : Relations entre composants (ici : détails internes)
- `development` : Processus de build (ici : runtime)
