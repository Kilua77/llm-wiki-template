---
type: Bundle Proposal
title: infrastructure
description: Environnement runtime, déploiement, partages réseau et livraisons pour ECMTCP.
status: draft
generated: { by: hermes/mistral-medium, at: 2026-10-21T14:00:00Z }
---

## Motivation
ECMTCP s'exécute sur des **plateformes embarquées variées** et dépend de **ressources réseau partagées** pour le développement et le déploiement. Cette connaissance est critique mais dispersée.

## Scope
- Environnements runtime : Plateformes embarquées (ESCT2000, XFLC1000, etc.) et leurs configurations
- Infrastructure réseau : Partages (`/doclns`, `/livint`, `/livtools`, etc.), service users
- Déploiement : Processus de livraison (RPMs, wpack), gestion des versions
- Maintenance : SEPS (Submarine Engineering & Product Support), suivi des issues

## Out-of-scope
- Architecture des plateformes (→ `architecture`)
- Outils de développement (→ `development`)
- Environnements de test (→ `testing`)

## Tree
```
tools/       # network-shares.md, service-users.md
practices/   # delivery-process.md, seps-maintenance.md
playbooks/   # mount-shares.md, generate-delivery-notes.md, access-deliveries.md
references/  # Digests des documentations d'infrastructure
raw/         # Sources brutes
```

## Initial pages
1. tools/network-shares.md
2. tools/service-users.md
3. practices/delivery-process.md
4. practices/seps-maintenance.md
5. playbooks/mount-shares.md
6. playbooks/generate-delivery-notes.md
7. playbooks/access-deliveries.md

## Overlaps
- `architecture` : Architectures des plateformes (ici : runtime et déploiement)
- `development` : Outils de build (ici : workflows de déploiement)
