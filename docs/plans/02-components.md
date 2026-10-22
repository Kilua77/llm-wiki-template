# Plan ECMTCP - Bundle Components

---

## 📌 Consignes Globales

1. **Diagrammes** : Utiliser **uniquement Mermaid** pour tous les graphiques (flowcharts, sequence diagrams, etc.).
2. **Anonymisation** : Voir [CHARTE §2](../CHARTE.md#2-publishability-and-anonymization).
3. **Frontmatter** : Toujours valider avec `python3 tools/lint.py` avant commit.

---

## 🎯 Objectif

Documenter les **composants ECMTCP individuels** (GOL, SOL, AVAIL, etc.), leurs interfaces et leurs bases de données associées.

## 📋 Scope

- Fonctionnalités et responsabilités de chaque composant MTCP_*
- Interfaces (GLI, SLI, TL1, SDN, XML)
- Bases de données (ADDR, MAIN, MAINPM, SDNAGENT, TL1AGENT)
- Décisions et contraintes **spécifiques aux composants**

## 🚫 Out-of-scope

- Architecture globale (→ `architecture`)
- Outils de build (→ `development`)
- Stratégies de test (→ `testing`)

---

## 📁 Structure du Bundle

```
components/
├── index.md          # Généré automatiquement
├── log.md            # Historique des actions
├── concepts/         # Concepts transversaux
│   └── object-layers.md
├── entities/         # Composants et bases de données
│   ├── avail.md
│   ├── gol.md
│   ├── sol.md
│   ├── appserv.md
│   ├── common.md
│   ├── tl1agent.md
│   ├── sdnagent.md
│   ├── irm-16wx.md
│   ├── gliagt.md
│   ├── sli.md
│   ├── addr-db.md
│   ├── main-db.md
│   └── mainpm-db.md
├── decisions/        # Décisions spécifiques aux composants
├── constraints/      # Contraintes spécifiques aux composants
├── references/       # Digests des sources
└── raw/              # Sources brutes (immutables)
```

---

## 📝 Pages Initiales à Créer

### Entités (entities/)
1. **avail.md** - Composant AVAIL (disponibilité)
2. **gol.md** - Composant GOL (Gestion des Objets Logiques)
3. **sol.md** - Composant SOL (Service Order Logic)
4. **appserv.md** - Composant APPSERV (Application Server)
5. **common.md** - Code et fonctionnalités communes
6. **tl1agent.md** - Agent TL1 (Telecommunication Language One)
7. **sdnagent.md** - Agent SDN (Software Defined Network)
8. **irm-16wx.md** - Interface IRM pour 16WX
9. **gliagt.md** - Agent GLI (Generic Logical Interface)
10. **sli.md** - Interface SLI (Service Layer Interface)

### Bases de données
11. **addr-db.md** - Base de données ADDR (Adresses)
12. **main-db.md** - Base de données MAIN (principale)
13. **mainpm-db.md** - Base de données MAINPM (Persistent Maintenance)

---

## 🔗 Overlaps avec d'autres Bundles

| Bundle | Relation | Ce bundle couvre... | `architecture` couvre... |
|--------|----------|---------------------|--------------------------|
| architecture | Parent | Détails internes des composants | Relations entre composants |
| development | Complémentaire | Runtime des composants | Processus de build |
| testing | Complémentaire | Comportement des composants | Stratégies de test |

---

## 📚 Sources à Ingerer (Priorité)

### Niveau 1 - Documentation Principale
1. **README des composants** : `/local/ECMTCP_MEL/MTCP_*/README`
   - MTCP_GOL/README
   - MTCP_SOL/README
   - MTCP_AVAIL/README
   - MTCP_APPSERV/README
   - etc.

2. **Documentation des interfaces** :
   - GLI (Generic Logical Interface)
   - SLI (Service Layer Interface)
   - TL1 (Telecommunication Language One)
   - SDN (Software Defined Network)
   - XML schemas

3. **Documentation des bases de données** :
   - Schémas ADDR, MAIN, MAINPM
   - Modèles de données
   - Relations entre tables

### Niveau 2 - Code Source (si nécessaire)
4. **Fichiers headers** : `/local/ECMTCP_MEL/MTCP_*/include/*.h`
   - Définitions des interfaces
   - Structures de données
   - Constantes

5. **Fichiers de configuration** : `/local/ECMTCP_MEL/MTCP_*/config/*`

---

## 🎯 Workflow OBLIGATOIRE

### Étape 1 : Validation
- **Prérequis** : Le propriétaire doit dire **explicitement** "oui" à la proposition.
- **Silence = Refus** (CHARTE §10).

### Étape 2 : Création du Bundle
```bash
tools/new-bundle.sh components
```

### Étape 3 : Mise à jour de CHARTE.md
Ajouter dans le tableau §3 :
```markdown
| components | Composants ECMTCP individuels (GOL, SOL, AVAIL) et leurs interfaces | Architecture globale, outils de build, stratégies de test | Active (validated YYYY-MM-DD) |
```

### Étape 4 : Ingestion des Sources
Pour chaque source (fichier README, documentation, etc.) :

1. **Anonymiser** le contenu :
   - `/local/ECMTCP_MEL` → "le dépôt ECMTCP"
   - `vxl15038` → "un serveur de développement"
   - `/doclns` → "un partage réseau"
   - `omcap` → "un utilisateur système"

2. **Convertir** si nécessaire (DOCX/PDF → Markdown)

3. **Calculer le sha256** :
   ```bash
   sha256sum /tmp/fichier.md
   ```

4. **Créer le fichier raw/** :
   - Format : `bundles/components/raw/YYYY-MM-DD-<slug>.md`
   - Contenu : Source brute anonymisée avec header OKF

5. **Créer le digest references/** :
   - Format : `bundles/components/references/<slug>-digest.md`
   - Contenu : Résumé de la source (2-5 phrases max)

### Étape 5 : Création des Pages de Connaissance
Pour chaque composant identifié :
1. Créer le fichier dans `entities/`
2. Utiliser le template **Tool** ou **Service** selon le cas
3. Lier vers les sources (digest et raw)
4. Documenter :
   - Fonctionnalités
   - Responsabilités
   - Interfaces
   - Dépendances
   - Configuration

### Étape 6 : Mise à jour du log.md
```markdown
## YYYY-MM-DD
* **Ingest**: [Titre](references/<slug>.md) — Résumé. (<AGENT>/<MODEL>)
* **Creation**: [Page](entities/<page>.md) — Description. (<AGENT>/<MODEL>)
```

### Étape 7 : Lint et Commit
```bash
# 1. Générer les index
python3 tools/gen-index.py

# 2. Linter (DOIT PASSER SANS ERREUR)
python3 tools/lint.py

# 3. Commiter
tools/commit.sh "wiki(components): <action> — <object>" "<AGENT>/<MODEL>"
```

---

## 📊 Exemple de Page (Entity)

```markdown
---
type: Service
title: GOL
description: Gestion des Objets Logiques - Composant central pour la gestion des objets réseau.
tags: [component, gol, logical-objects, network-management]
status: stable
stale_after: 2027-10-22
generated: { by: <AGENT>/<MODEL>, at: YYYY-MM-DDTHH:MM:SSZ }
code_refs:
  - repo: MTCP_GOL
    commit: a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0
    path: README
    note: Documentation principale
sources:
  - id: gol-readme
    resource: observation:2026-10
    title: GOL README
---

# GOL - Gestion des Objets Logiques

## Fonctionnalités
- Gestion des objets réseau
- Synchronisation avec les équipements
- Persistance des données

## Interfaces
- **GLI** : Interface principale
- **SLI** : Interface de service
- **Base de données** : MAIN, MAINPM

## Dépendances
- SOL (pour la logique de service)
- AVAIL (pour la disponibilité)

## Configuration
[Détails de configuration...]

## See Also
- [README Source](../references/gol-readme-digest.md)
- [Raw Source](../raw/2026-10-22-gol-readme.md)
```

---

## ⚠️ Règles Critiques

1. **Anonymisation** (CHARTE §2) : TOUT le contenu doit être anonymisé avant ingestion.
2. **Pas de création sans validation** (CHARTE §10) : Silence = Refus.
3. **Lint obligatoire** avant chaque commit.
4. **Log.md** : Toute action doit être loguée.
5. **Mermaid uniquement** pour tous les diagrammes.

---

## 📅 Planning Prévisionnel

| Étape | Date Cible | Statut |
|-------|------------|--------|
| Validation proposition | 2026-10-22 | ⏳ En attente |
| Création bundle | 2026-10-22 | ⏳ |
| Ingestion READMEs | 2026-10-23 | ⏳ |
| Création pages entités | 2026-10-24 | ⏳ |
| Ingestion interfaces | 2026-10-25 | ⏳ |
| Création pages concepts | 2026-10-26 | ⏳ |
| Lint final | 2026-10-27 | ⏳ |
| Commit final | 2026-10-27 | ⏳ |
