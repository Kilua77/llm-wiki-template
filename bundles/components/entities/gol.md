---
type: Service
title: GOL
description: Gestion des Objets Logiques - Composant central pour la gestion des objets réseau dans ECMTCP
status: stable
tags: [component, gol, logical-objects, network-management, ecmtcp]
generated: { by: opencode/mistral-medium, at: 2026-11-05T12:00:00Z }
sources:
  - id: mtcp-gol-readme
    resource: observation:2026-11
    title: MTCP_GOL README
---

# GOL - Gestion des Objets Logiques

Le composant **GOL** (Gestion des Objets Logiques) est le composant central du système ECMTCP responsable de la gestion des objets réseau. Il assure la synchronisation entre la base de données et les équipements physiques, ainsi que la persistance des données de configuration.

## Fonctionnalités

- **Gestion des objets réseau** : Création, modification, suppression et consultation des objets logiques représentant les équipements et ressources du réseau
- **Synchronisation avec les équipements** : Maintien de la cohérence entre la configuration logique et l'état physique des équipements
- **Persistance des données** : Stockage durable des configurations dans les bases de données MAIN et MAINPM
- **Gestion des alarmes et défauts** : Détection et signalement des anomalies sur les objets gérés

## Interfaces

- **GLI** (Generic Logical Interface) : Interface principale pour la manipulation des objets logiques
- **SLI** (Service Layer Interface) : Interface pour les opérations de service
- **Base de données** : Accès aux bases MAIN et MAINPM pour la persistance

## Dépendances

- **SOL** : Pour la logique de service et la gestion des commandes
- **AVAIL** : Pour la gestion de la disponibilité des ressources
- **COMMON** : Pour les fonctionnalités communes partagées entre composants

## Configuration

Le composant GOL est configuré via des fichiers de configuration spécifiques et utilise les bibliothèques suivantes :
- libSoftmgtKeystore.so (pour la gestion des certificats)
- libSoftmgtCommon.so (fonctions communes)
- libSoftmgtFault.so (gestion des défauts)

## Historique

- Migration depuis ClearCase vers Git avec le préfixe de vue `int_gol__v`
- Label racine : LIV_GOLWDM__
- Date de migration : 21 février 2022

## See Also

- [README Source](../references/mtcp-gol-readme-digest.md)
- [Raw Source](../raw/2026-11-04-mtcp-gol-readme.md)
- [COMMON Component](./common.md)
- [Object Layers Concept](../concepts/object-layers.md)
