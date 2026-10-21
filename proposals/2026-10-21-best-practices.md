---
type: Bundle Proposal
title: best-practices
description: Bonnes pratiques transversales (revue de code, legacy, sécurité, performance).
status: draft
generated: { by: hermes/mistral-medium, at: 2026-10-21T14:00:00Z }
---

## Motivation
Codebase **20 ans, 2M lignes C++** → besoin de standardiser les pratiques pour maintenir la qualité et faciliter l'onboarding.

## Scope
- Revue de code et standards de documentation
- Gestion du code legacy (quand refactorer ? quand remplacer ?)
- Sécurité (AAA, gestion des secrets, accès contrôle)
- Performance (optimisation embarquée : mémoire, CPU, I/O)
- Collaboration (workflows d'équipe, partage de connaissance)

## Out-of-scope
- Outils spécifiques (→ `development`)
- Détails des composants (→ `components`)
- Stratégies de test (→ `testing`)
- Architecture (→ `architecture`)

## Tree
```
practices/    # code-review.md, doc-standards.md, legacy-code.md, security.md, performance.md
playbooks/    # onboarding.md
constraints/  # Contraintes transversales (ex: politiques de sécurité)
references/   # Digests des documentations de bonnes pratiques
raw/          # Sources brutes
```

## Initial pages
1. practices/code-review.md
2. practices/doc-standards.md
3. practices/git-workflow.md
4. practices/security.md
5. practices/performance.md
6. practices/legacy-code.md
7. practices/onboarding.md
8. constraints/security-policies.md

## Overlaps
- `development` : Pratiques liées aux outils (ici : principes généraux)
- `architecture` : Contraintes architecturales (ici : développement)
