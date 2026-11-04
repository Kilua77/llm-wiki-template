---
type: Service
title: MAIN_PM Database
description: MAIN_PM Database - Base de données de maintenance persistante pour ECMTCP
status: stable
tags: [database, mainpm, persistent-maintenance, performance, ecmtcp]
generated: { by: opencode/mistral-medium, at: 2026-11-05T12:30:00Z }
sources:
  - id: mainpm-database-schema
    resource: observation:2026-11
    title: MAIN_PM Database Schema
---

# MAIN_PM Database

La base de données **MAIN_PM** (Persistent Maintenance) est dédiée au stockage des données de performance et de maintenance persistante dans le système ECMTCP. Elle travaille en complément de la base MAIN principale.

## Fonctionnalités

- **Stockage des données de performance** : Enregistrement des métriques et indicateurs de performance
- **Historique des collections** : Maintien de l'historique des données collectées
- **Gestion des intervalles** : Suivi des intervalles de suppression et de collecte
- **Persistance des compteurs** : Stockage des compteurs de performance

## Structure

### Tables principales

#### PmSolItem
Table des éléments de performance pour SOL :
- `pmItemOid_` : BIGINT UNSIGNED NOT NULL (Clé primaire)
  - Identifiant unique de l'élément de performance
- `numSuppressionInterval_` : INTEGER UNSIGNED
  - Nombre d'intervalles avant suppression

#### PmSolHistoryCollection
Table de l'historique des collections de performance :
- `id_` : SMALLINT UNSIGNED NOT NULL
  - Identifiant de la collection
- `pmItemOid_` : BIGINT UNSIGNED NOT NULL
  - Référence à l'élément de performance
- `ellapsedTime_` : INTEGER UNSIGNED
  - Temps écoulé depuis le début de la collecte
- `periodeEndTime_` : INTEGER UNSIGNED
  - Heure de fin de la période de collecte
- `suspectIntervalFlag_` : TINYINT(1)
  - Indicateur d'intervalle suspect
- `isSuppressed_` : TINYINT(1)
  - Indicateur de suppression
- `counterList_` : BLOB
  - Liste des compteurs (données binaires)
- `collectedFlag_` : TINYINT(1)
  - Indicateur de collecte effectuée

### Tables associées (commentées dans le schéma)

#### PmSolCounter (commentée)
Table des compteurs de performance :
- `id_` : SMALLINT UNSIGNED NOT NULL
- `pmId_` : BIGINT UNSIGNED NOT NULL
- `counterType_` : SMALLINT UNSIGNED
- `value_` : INTEGER UNSIGNED

## Moteur de base de données

Les tables utilisent le moteur **INNODB** pour :
- La gestion des transactions
- L'intégrité référentielle
- Les performances optimisées

## Utilisation

La base MAIN_PM est principalement utilisée par :
- **SOL** : Pour le stockage des données de performance des services
- **GOL** : Pour les métriques liées aux objets logiques
- **APPSERV** : Pour les données de performance des applications

## Relation avec MAIN

MAIN_PM travaille en étroite collaboration avec la base **MAIN** :
- MAIN stocke les configurations et états actuels
- MAIN_PM stocke l'historique et les données de performance

## See Also

- [Database Schema](../references/mainpm-database-schema-digest.md)
- [Raw Source](../raw/2026-11-05-mainpm-database-schema.md)
- [MAIN Database](./main-db.md)
- [SOL Component](./sol.md)
- [ADDR Database](./addr-db.md)
- [Object Layers Concept](../concepts/object-layers.md)
