---
type: Service
title: AVAIL
description: Availability Management - Composant de gestion de la disponibilité des ressources ECMTCP
status: stable
tags: [component, avail, availability, resource-management, ecmtcp]
generated: { by: opencode/mistral-medium, at: 2026-11-05T12:00:00Z }
sources:
  - id: mtcp-avail-readme
    resource: observation:2026-11
    title: MTCP_AVAIL README
---

# AVAIL - Availability Management

Le composant **AVAIL** (Availability Management) est responsable de la gestion de la disponibilité des ressources dans le système ECMTCP. Il assure le suivi de l'état des équipements, la détection des pannes et la gestion des redondances.

## Fonctionnalités

- **Suivi de disponibilité** : Surveillance en temps réel de l'état des ressources réseau
- **Détection des pannes** : Identification rapide des défaillances et indisponibilités
- **Gestion des redondances** : Basculement automatique vers des ressources de secours
- **Rapports d'état** : Génération de rapports de disponibilité pour les opérateurs

## Interfaces

- **GLI** (Generic Logical Interface) : Pour les requêtes d'état des objets
- **SLI** (Service Layer Interface) : Pour les notifications de disponibilité

## Dépendances

- **GOL** : Pour accéder aux informations sur les objets logiques
- **SOL** : Pour coordonner les actions de récupération

## Historique

- Migration depuis ClearCase avec le préfixe de vue `int_avail__v`
- Label racine : LIV_AVAIL__
- Date de migration : 5 octobre 2021
- Export de 4 branches et 62 livraisons

## See Also

- [README Source](../references/mtcp-avail-readme-digest.md)
- [Raw Source](../raw/2026-11-04-mtcp-avail-readme.md)
- [Object Layers Concept](../concepts/object-layers.md)
