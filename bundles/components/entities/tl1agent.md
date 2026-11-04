---
type: Service
title: TL1AGENT
description: TL1 Agent - Agent d'exécution des commandes Telecommunication Language One
status: stable
tags: [component, tl1, tl1agent, telecommunication, command-execution, ecmtcp]
generated: { by: opencode/mistral-medium, at: 2026-11-05T12:15:00Z }
sources:
  - id: tl1agent-interface-definition
    resource: observation:2026-11
    title: TL1 Agent Interface Definition
---

# TL1AGENT - TL1 Agent

L'agent **TL1AGENT** est responsable de l'exécution des commandes au format TL1 (Telecommunication Language One) dans le système ECMTCP. TL1 est un protocole standard de l'industrie des télécommunications pour la gestion des équipements réseau.

## Fonctionnalités

- **Interprétation TL1** : Analyse et interprétation des commandes TL1 reçues
- **Exécution des commandes** : Traduction et exécution des commandes sur les équipements cibles
- **Gestion des réponses** : Génération des réponses TL1 appropriées
- **Journalisation** : Enregistrement des commandes exécutées et de leurs résultats

## Architecture

Le composant TL1AGENT est structuré autour des éléments suivants :

### Fichiers binaires
- `bin*` : Exécutables principaux de l'agent

### Bibliothèques
- `libTL1*` : Bibliothèques spécifiques TL1
- `libAGTGLI*` : Bibliothèques d'interface avec GLI
- `libMtcpSecurity.so` : Gestion de la sécurité

### Fichiers de configuration
- `*.ini` : Fichiers de configuration INIT
- `*.txt` : Fichiers texte de configuration
- `*.conf` : Fichiers de configuration
- `*.cfg` : Fichiers de configuration CFG
- `*.xml` : Fichiers XML de configuration

### Base de données
- `tl1agent.sql` : Script SQL pour la base de données TL1AGENT

## Interfaces

- **TL1** : Interface principale pour les commandes TL1
- **GLI** : Interface avec le système de gestion logique
- **Base de données** : Accès à la base TL1AGENT pour la persistance

## Installation

L'installation RPM crée la structure suivante :
- `/ecmtcp/app/AOL/TL1/bin/` : Binaires
- `/ecmtcp/app/AOL/TL1/lib/` : Bibliothèques
- `/ecmtcp/app/AOL/TL1/DMO/` : Données de gestion
- `/ecmtcp/app/AOL/TL1/conf/` : Configuration
- `/ecmtcp/app/etc/MYSQL_scripts/` : Scripts SQL

## Historique

- Version : v9-4-0-23-0
- Migration depuis ClearCase
- Date de migration : 23 octobre 2022 (implicite)

## See Also

- [Interface Definition](../references/tl1agent-interface-definition-digest.md)
- [Raw Source](../raw/2026-11-04-tl1agent-interface-definition.md)
- [TL1 XML Schema](../references/tl1-xml-schema-digest.md)
- [GLIAGT Component](./gliagt.md)
- [Object Layers Concept](../concepts/object-layers.md)
