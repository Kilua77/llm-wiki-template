---
type: Reference
title: ADDR Database Purge Script Digest
description: Résumé du script SQL de purge de la base ADDR
status: stable
tags: [addr, database, sql, purge]
generated: { by: opencode/mistral-medium, at: 2026-11-05T10:15:00Z }
sources:
  - id: addr-database-purge
    resource: observation:2026-11
    title: ADDR Database Purge Script
---

Le script de purge de la base de données ADDR supprime toutes les données des tables suivantes :
ADDRDBVER, DCC, IPITEM, LANITEM, MGRADDRSUPP, MGRADDRSUPP_NTP_SERVERDATA, OCS, OSPFAREA, 
OSPFINTERFACE, OSPFROUTER, PORTACCESS, PPP, ROUTITEM, TUNNEL, et UDCCHANNEL.

Ce script est utilisé pour réinitialiser complètement la base de données d'adresses du système ECMTCP.
