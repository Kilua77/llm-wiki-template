---
type: Service
title: SOL
description: Service Order Logic - Composant de logique de service pour la gestion des commandes ECMTCP
status: stable
tags: [component, sol, service-order, command-processing, ecmtcp]
generated: { by: opencode/mistral-medium, at: 2026-11-05T12:00:00Z }
sources:
  - id: mtcp-sol-readme
    resource: observation:2026-11
    title: MTCP_SOL README
---

# SOL - Service Order Logic

Le composant **SOL** (Service Order Logic) est responsable du traitement des commandes et de la logique métier associée dans le système ECMTCP. Il gère l'exécution des opérations de service, la validation des commandes et la coordination avec les autres composants.

## Fonctionnalités

- **Traitement des commandes** : Interprétation et exécution des commandes reçues via les interfaces GLI et SLI
- **Validation des opérations** : Vérification de la validité des commandes avant exécution
- **Coordination inter-composants** : Communication avec GOL, AVAIL et d'autres composants pour l'exécution des services
- **Gestion des performances** : Collecte et stockage des données de performance dans MAIN_PM

## Interfaces

- **GLI** (Generic Logical Interface) : Réception des commandes de gestion d'objets
- **SLI** (Service Layer Interface) : Interface principale pour les opérations de service
- **Base de données** : Accès à MAIN_PM pour les données de performance

## Dépendances

- **GOL** : Pour la gestion des objets logiques sous-jacents
- **AVAIL** : Pour la vérification de disponibilité des ressources
- **TL1AGENT** : Pour l'exécution des commandes TL1

## Configuration

Le composant SOL utilise une architecture modulaire avec les bibliothèques suivantes :
- libSLIgol.so (interface avec GOL)
- libSLIsol.so (logique spécifique SOL)
- libSLImsgcommon.so (messages communs)
- libSLImsgdata.so (gestion des données de message)

## Historique

- Migration depuis ClearCase vers Git avec le préfixe de vue `int_solwdm__v`
- Label racine : LIV_SOLWDM__
- Date de migration : 18 février 2022

## See Also

- [README Source](../references/mtcp-sol-readme-digest.md)
- [Raw Source](../raw/2026-11-04-mtcp-sol-readme.md)
- [SLI Interface Definition](../references/sli-interface-definition-digest.md)
- [SLI Component](./sli.md)
- [Object Layers Concept](../concepts/object-layers.md)
