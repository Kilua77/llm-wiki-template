---
type: Service
title: ADDR Database
description: ADDR Database - Base de données d'adresses pour le système ECMTCP
status: stable
tags: [database, addr, addresses, network-configuration, ecmtcp]
generated: { by: opencode/mistral-medium, at: 2026-11-05T12:30:00Z }
sources:
  - id: addr-database-purge
    resource: observation:2026-11
    title: ADDR Database Purge Script
---

# ADDR Database

La base de données **ADDR** (Address Database) est la base de données principale pour la gestion des adresses et de la configuration réseau dans le système ECMTCP. Elle stocke toutes les informations liées aux adresses IP, aux routes, aux interfaces réseau, etc.

## Structure

La base ADDR contient les tables suivantes :

### Configuration de base
- **ADDRDBVER** : Version de la base de données ADDR

### Adresses et interfaces
- **IPITEM** : Éléments d'adresse IP
- **LANITEM** : Éléments de réseau local
- **PORTACCESS** : Accès aux ports
- **PPP** : Connexions PPP (Point-to-Point Protocol)

### Routage
- **ROUTITEM** : Entrées de table de routage
- **TUNNEL** : Configurations de tunnel
- **UDCCHANNEL** : Canaux UDC

### Protocoles de routage
- **OCS** : Configuration OCS
- **OSPFAREA** : Zones OSPF
- **OSPFINTERFACE** : Interfaces OSPF
- **OSPFROUTER** : Routeurs OSPF

### Gestion
- **DCC** : Configurations DCC
- **MGRADDRSUPP** : Support des adresses gérées
- **MGRADDRSUPP_NTP_SERVERDATA** : Données de serveur NTP pour le support des adresses gérées

## Fonctionnalités

- **Gestion des adresses IP** : Stockage et récupération des configurations d'adresse
- **Configuration de routage** : Maintien des tables de routage
- **Gestion des interfaces** : Suivi de l'état et de la configuration des interfaces
- **Support des protocoles** : Configuration des protocoles de routage (OSPF, etc.)

## Utilisation

La base ADDR est principalement utilisée par :
- **GOL** : Pour la gestion des objets réseau avec leurs adresses
- **SOL** : Pour l'exécution des commandes affectant les adresses
- **APPSERV** : Pour les services nécessitant des informations d'adresse

## Maintenance

Un script de purge (`purgeADDR.sql`) est disponible pour réinitialiser complètement la base de données ADDR.

## See Also

- [Purge Script](../references/addr-database-purge-digest.md)
- [Raw Source](../raw/2026-11-05-addr-database-purge.md)
- [GOL Component](./gol.md)
- [SOL Component](./sol.md)
- [MAIN Database](./main-db.md)
- [MAIN_PM Database](./mainpm-db.md)
- [Object Layers Concept](../concepts/object-layers.md)
