---
type: Service
title: APPSERV
description: Application Server - Composant serveur d'applications pour ECMTCP
status: stable
tags: [component, appserv, application-server, service-hosting, ecmtcp]
generated: { by: opencode/mistral-medium, at: 2026-11-05T12:00:00Z }
sources:
  - id: mtcp-appserv-readme
    resource: observation:2026-11
    title: MTCP_APPSERV README
---

# APPSERV - Application Server

Le composant **APPSERV** (Application Server) est le serveur d'applications principal du système ECMTCP. Il héberge les services et applications nécessaires au fonctionnement du système de gestion de réseau.

## Fonctionnalités

- **Hébergement d'applications** : Exécution des composants logiciels ECMTCP
- **Gestion des services** : Supervision et contrôle des services en cours d'exécution
- **Communication inter-processus** : Facilitation de la communication entre les différents composants
- **Gestion des ressources** : Allocation et suivi des ressources système

## Interfaces

- **GLI** (Generic Logical Interface) : Pour les interactions avec les objets logiques
- **SDN** (Software Defined Network) : Pour la configuration réseau programmable
- **TL1** (Telecommunication Language One) : Pour les commandes de télécommunication

## Dépendances

- **GOL** : Pour la gestion des objets réseau
- **SOL** : Pour le traitement des commandes de service
- **AVAIL** : Pour la gestion de la disponibilité
- **SDNAGENT** : Pour les fonctionnalités de réseau défini par logiciel
- **TL1AGENT** : Pour l'exécution des commandes TL1

## Historique

- Migration depuis ClearCase vers Git avec le préfixe de vue `int_appserv__v`
- Label racine : LIV_APPSERV__
- Date de migration : 29 novembre 2021
- Export de 6 branches et 128 livraisons

## See Also

- [README Source](../references/mtcp-appserv-readme-digest.md)
- [Raw Source](../raw/2026-11-04-mtcp-appserv-readme.md)
- [ADDR Database](./addr-db.md)
- [MAIN Database](./main-db.md)
- [MAIN_PM Database](./mainpm-db.md)
- [Object Layers Concept](../concepts/object-layers.md)
