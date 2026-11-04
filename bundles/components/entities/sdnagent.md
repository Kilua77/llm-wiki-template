---
type: Service
title: SDNAGENT
description: SDN Agent - Agent de gestion Software Defined Network pour ECMTCP
status: stable
tags: [component, sdn, sdnagent, software-defined-network, yang, ecmtcp]
generated: { by: opencode/mistral-medium, at: 2026-11-05T12:15:00Z }
sources:
  - id: sdnagent-interface-definition
    resource: observation:2026-11
    title: SDN Agent Interface Definition
---

# SDNAGENT - SDN Agent

L'agent **SDNAGENT** (Software Defined Network Agent) implémente les fonctionnalités de réseau défini par logiciel (SDN) dans le système ECMTCP. Il permet une gestion réseau plus flexible et programmable.

## Fonctionnalités

- **Gestion des modèles YANG** : Support des modèles de données standardisés
- **Configuration dynamique** : Application de configurations réseau de manière programmatique
- **Notifications** : Génération et gestion des notifications réseau
- **Services réseau** : Fourniture de services réseau avancés

## Architecture

Le composant SDNAGENT comprend les éléments suivants :

### Binaires et exécutables
- `SdnAgent` : Binaire principal de l'agent
- `YangModelFile` : Fichiers de modèles YANG

### Bibliothèques de services
- `libGliService.so` : Service GLI
- `libGliYangMapperService.so` : Mappage YANG-GLI
- `libModelUpdaters.so` : Mise à jour des modèles
- `libNotificationService.so` : Service de notifications
- `libSDNAGENT.so` : Bibliothèque principale SDN
- `libYangModelService.so` : Service de modèles YANG
- `libAaaService.so` : Service AAA (Authentication, Authorization, Accounting)
- `libDatabaseService.so` : Service de base de données

### Configuration
- `sdnAgent_ComponentData.cfg` : Configuration des composants
- `sdnAgent_DataEng` : Données d'ingénierie
- `sdn_trace.cfg` : Configuration des traces (niveau normal)
- `sdn_trace_min.cfg` : Configuration des traces (niveau minimal)
- `sdn_trace_max.cfg` : Configuration des traces (niveau maximal)
- `sdnagent.sql` : Script SQL pour la base SDNAGENT

## Interfaces

- **SDN** : Interface principale pour la gestion SDN
- **GLI** : Interface avec le système de gestion logique
- **YANG** : Support des modèles YANG

## Installation

L'installation RPM crée la structure suivante :
- `/ecmtcp/app/AOL/SDN/bin/` : Binaires
- `/ecmtcp/app/AOL/SDN/lib/` : Bibliothèques
- `/ecmtcp/app/AOL/SDN/conf/` : Configuration
- `/ecmtcp/app/AOL/SDN/de/` : Données d'ingénierie
- `/ecmtcp/app/AOL/SDN/traces/` : Fichiers de trace
- `/ecmtcp/app/etc/MYSQL_scripts/` : Scripts SQL

## Historique

- Version : v9-4-0-20-0
- Migration depuis ClearCase
- Date de migration : 20 octobre 2022 (implicite)

## See Also

- [Interface Definition](../references/sdnagent-interface-definition-digest.md)
- [Raw Source](../raw/2026-11-04-sdnagent-interface-definition.md)
- [GLIAGT Component](./gliagt.md)
- [Object Layers Concept](../concepts/object-layers.md)
