---
type: Service
title: COMMON
description: Common Components - Bibliothèques et fonctionnalités partagées entre les composants ECMTCP
status: stable
tags: [component, common, shared-libraries, utilities, ecmtcp]
generated: { by: opencode/mistral-medium, at: 2026-11-05T12:15:00Z }
sources:
  - id: observation
    resource: observation:2026-11
    title: Common Components Analysis
---

# COMMON - Common Components

Le composant **COMMON** regroupe les bibliothèques et fonctionnalités partagées utilisées par plusieurs composants du système ECMTCP. Ces composants communs fournissent des services génériques et des utilitaires réutilisables.

## Fonctionnalités

- **Bibliothèques partagées** : Fourniture de code commun à plusieurs composants
- **Utilitaires système** : Fonctions utilitaires pour la gestion des fichiers, logs, etc.
- **Gestion des erreurs** : Mécanismes standardisés de gestion et de signalement des erreurs
- **Communication** : Protocoles et outils de communication inter-composants

## Sous-composants

### GOL-COMMON
Partie commune du composant GOL avec les bibliothèques :
- libSoftmgtCommon.so
- libSoftmgtFault.so
- libSoftmgtKeystore.so

### Autres bibliothèques communes
- libMtcpSecurity.so : Sécurité et authentification
- libMtcpCommon.so : Fonctions communes de base

## Interfaces

Les composants COMMON sont utilisés indirectement via les interfaces des autres composants.

## Dépendances

Aucune dépendance externe - ces composants sont conçus pour être autonomes et réutilisables.

## See Also

- [GOL Component](./gol.md)
- [SOL Component](./sol.md)
- [APPSERV Component](./appserv.md)
