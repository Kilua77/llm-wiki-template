---
type: Service
title: GLIAGT
description: GLI Agent - Agent d'interface Generic Logical Interface
status: stable
tags: [component, gli, gliagt, logical-interface, agent, ecmtcp]
generated: { by: opencode/mistral-medium, at: 2026-11-05T12:15:00Z }
sources:
  - id: observation
    resource: observation:2026-11
    title: GLI Agent Analysis
---

# GLIAGT - GLI Agent

L'agent **GLIAGT** (Generic Logical Interface Agent) est le composant qui implémente l'interface GLI (Generic Logical Interface) dans le système ECMTCP. GLI est l'interface principale pour la manipulation des objets logiques.

## Fonctionnalités

- **Gestion des objets** : Création, lecture, mise à jour et suppression des objets logiques
- **Traduction des commandes** : Conversion des commandes GLI en actions sur les objets
- **Validation** : Vérification de la validité des opérations demandées
- **Synchronisation** : Maintien de la cohérence entre les différents composants

## Architecture

GLIAGT agit comme un intermédiaire entre :
- Les interfaces utilisateur (CLI, API, etc.)
- Les composants de gestion (GOL, SOL, AVAIL)
- Les bases de données (MAIN, MAINPM)

## Interfaces

- **GLI** : Interface principale (Generic Logical Interface)
- **SLI** : Interface de service (Service Layer Interface)
- **TL1** : Interface de télécommunication (via TL1AGENT)
- **SDN** : Interface réseau défini par logiciel (via SDNAGENT)

## Composants associés

GLIAGT travaille en étroite collaboration avec :
- **GOL** : Pour la gestion des objets logiques
- **SOL** : Pour le traitement des commandes de service
- **TL1AGENT** : Pour l'exécution des commandes TL1
- **SDNAGENT** : Pour les opérations SDN

## Historique

- Composant dédié à l'interface GLI
- Utilisé par tous les autres composants pour les opérations sur les objets

## See Also

- [GOL Component](./gol.md)
- [SOL Component](./sol.md)
- [TL1AGENT Component](./tl1agent.md)
- [SDNAGENT Component](./sdnagent.md)
- [Object Layers Concept](../concepts/object-layers.md)
