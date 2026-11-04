---
type: Reference
title: MAIN_PM Database Schema Digest
description: Résumé du schéma de la base de données MAIN_PM
status: stable
tags: [mainpm, database, sql, schema]
generated: { by: opencode/mistral-medium, at: 2026-11-05T10:15:00Z }
sources:
  - id: mainpm-database-schema
    resource: observation:2026-11
    title: MAIN_PM Database Schema
---

Le schéma de la base de données MAIN_PM (Persistent Maintenance) définit les tables pour la gestion 
des performances dans le système ECMTCP.

La table principale PmSolItem contient les éléments de performance avec un identifiant unique (pmItemOid_) 
et un intervalle de suppression (numSuppressionInterval_).

La table PmSolHistoryCollection stocke l'historique des collections de performances avec des champs 
pour l'identifiant, le temps écoulé, la fin de période, les indicateurs de suppression, et les données de compteurs.
