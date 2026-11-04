---
type: Service
title: IRM-16WX
description: Interface IRM pour 16WX - Interface de gestion des ressources pour la plateforme 16WX
status: stable
tags: [component, irm, 16wx, resource-management, interface, ecmtcp]
generated: { by: opencode/mistral-medium, at: 2026-11-05T12:15:00Z }
sources:
  - id: observation
    resource: observation:2026-11
    title: IRM-16WX Interface Analysis
---

# IRM-16WX - IRM Interface for 16WX

L'interface **IRM-16WX** (Interface de Gestion des Ressources pour 16WX) est une interface spécifique à la plateforme 16WX du système ECMTCP. Elle permet la gestion des ressources propres à cette plateforme matérielle.

## Fonctionnalités

- **Gestion des ressources 16WX** : Contrôle des ressources spécifiques à la plateforme 16WX
- **Intégration plateforme** : Interface entre le système ECMTCP et le matériel 16WX
- **Adaptation des commandes** : Traduction des commandes ECMTCP pour la plateforme 16WX

## Architecture

L'interface IRM-16WX fait partie du composant MTCP_16WX et utilise les fonctionnalités des autres composants :
- **GOL** : Pour la gestion des objets logiques
- **SOL** : Pour l'exécution des commandes
- **AVAIL** : Pour la gestion de la disponibilité

## Interfaces

- **IRM** : Interface principale de gestion des ressources
- **GLI** : Interface avec le système de gestion logique

## Configuration

L'interface utilise les configurations standard ECMTCP adaptées pour la plateforme 16WX.

## Historique

- Fait partie du composant MTCP_16WX
- Plateforme cible : 16WX

## See Also

- [GOL Component](./gol.md)
- [SOL Component](./sol.md)
- [AVAIL Component](./avail.md)
