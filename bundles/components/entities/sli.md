---
type: Service
title: SLI
description: Service Layer Interface - Interface de couche service pour ECMTCP
status: stable
tags: [interface, sli, service-layer, messaging, ecmtcp]
generated: { by: opencode/mistral-medium, at: 2026-11-05T12:30:00Z }
sources:
  - id: sli-interface-definition
    resource: observation:2026-11
    title: SLI Interface Definition
---

# SLI - Service Layer Interface

L'interface **SLI** (Service Layer Interface) est une interface de couche service dans le système ECMTCP. Elle fournit les mécanismes de messagerie et de communication entre les différents composants.

## Fonctionnalités

- **Messagerie inter-composants** : Échange de messages entre les composants ECMTCP
- **Encapsulation des commandes** : Encapsulation et transport des commandes de service
- **Gestion des sessions** : Maintien des sessions de communication
- **Sérialisation/désérialisation** : Conversion des données en formats adaptés au transport

## Architecture

SLI est implémentée via un ensemble de bibliothèques :

### Bibliothèques principales
- `libSLIgol.so` : Interface avec le composant GOL
- `libSLIsol.so` : Interface avec le composant SOL
- `libSLImsgcommon.so` : Messages communs
- `libSLImsgdata.so` : Gestion des données de message
- `libSLImsgbase.so` : Messages de base
- `libSLImsgsdh.so` : Messages SDH (Synchronous Digital Hierarchy)

## Composants utilisateurs

Les principaux composants utilisant SLI sont :
- **GOL** : Pour la gestion des objets logiques
- **SOL** : Pour le traitement des commandes de service
- **GLIAGT** : Pour l'interface GLI

## Protocoles

SLI supporte plusieurs protocoles de communication :
- Communication inter-processus (IPC)
- Appels de procédure distante (RPC)
- Messagerie asynchrone

## Installation

L'installation de SLI place les bibliothèques dans :
- `/ecmtcp/app/SLI/lib/`

## Historique

- Version : v9-4-0-8-0
- Date de migration : 21 février 2022

## See Also

- [Interface Definition](../references/sli-interface-definition-digest.md)
- [Raw Source](../raw/2026-11-04-sli-interface-definition.md)
- [GOL Component](./gol.md)
- [SOL Component](./sol.md)
- [Object Layers Concept](../concepts/object-layers.md)
