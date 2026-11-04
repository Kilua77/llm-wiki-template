---
type: Service
title: MAIN Database
description: MAIN Database - Base de données principale pour le système ECMTCP
status: stable
tags: [database, main, primary, configuration, ecmtcp]
generated: { by: opencode/mistral-medium, at: 2026-11-05T12:30:00Z }
sources:
  - id: observation
    resource: observation:2026-11
    title: MAIN Database Analysis
---

# MAIN Database

La base de données **MAIN** est la base de données principale du système ECMTCP. Elle stocke la majorité des données de configuration et d'état des objets réseau gérés par le système.

## Fonctionnalités

- **Stockage des objets** : Persistance des objets logiques gérés par GOL
- **Configuration des services** : Stockage des configurations de service
- **Historique des opérations** : Enregistrement des opérations effectuées
- **Gestion des alarmes** : Stockage des alarmes et événements

## Structure

La base MAIN contient de nombreuses tables organisées par domaines fonctionnels :

### Domaine GOL
- Tables pour la gestion des objets logiques
- Tables de synchronisation
- Tables de persistance

### Domaine SOL
- Tables de suivi des commandes
- Tables de performance (liées à MAIN_PM)

### Domaine COMMON
- Tables partagées entre plusieurs composants
- Tables de configuration système

## Utilisation

La base MAIN est utilisée par tous les composants principaux :
- **GOL** : Stockage principal des objets logiques
- **SOL** : Persistance des commandes et de leur état
- **AVAIL** : Suivi de la disponibilité des ressources
- **APPSERV** : Configuration des services

## Relation avec MAIN_PM

La base MAIN travaille en étroite collaboration avec la base **MAIN_PM** (Persistent Maintenance) pour :
- Le stockage des données de performance
- L'historique des opérations
- Les données de maintenance persistantes

## See Also

- [GOL Component](./gol.md)
- [SOL Component](./sol.md)
- [MAIN_PM Database](./mainpm-db.md)
- [ADDR Database](./addr-db.md)
- [Object Layers Concept](../concepts/object-layers.md)
