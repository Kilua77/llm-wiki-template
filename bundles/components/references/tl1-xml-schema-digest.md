---
type: Reference
title: TL1 XML Schema Digest
description: Résumé du schéma XML pour TL1
status: stable
tags: [tl1, xml-schema, xsd]
generated: { by: opencode/mistral-medium, at: 2026-11-05T10:15:00Z }
sources:
  - id: tl1-xml-schema
    resource: observation:2026-11
    title: TL1 XML Schema
---

Le schéma XML TL1 définit la structure des documents XML utilisés par l'interface TL1.

Il comprend les éléments racines suivants : index (avec attribut release), module (avec attribut name), 
et INTRODUCTION (avec attributs release, PROJECT, VIEW). Le schéma permet la validation des documents TL1 
contenant des commandes, des pages de commandes, et des informations d'introduction structurées.
