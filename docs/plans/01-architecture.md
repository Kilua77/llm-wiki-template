# Plan ECMTCP - Bundle Architecture

---

## 📌 Consignes Globales

1. **Diagrammes** : Utiliser **uniquement Mermaid** pour tous les graphiques (flowcharts, sequence diagrams, etc.).
2. **Anonymisation** : Voir [CHARTE §2](../CHARTE.md#2-publishability-and-anonymization).
3. **Frontmatter** : Toujours valider avec `python3 tools/lint.py` avant commit.

---

## 🎯 Objectif

Documenter l'**architecture globale** FLC/ECMTCP, incluant les composants, plateformes, acronymes, décisions (ADRs) et contraintes système.

## 📋 Scope

- Architecture globale FLC/ECMTCP
- Composants principaux et leurs relations
- Plateformes supportées
- Acronymes et terminologie
- Décisions architecturales (ADRs)
- Contraintes système

## 🚫 Out-of-scope

- Détails internes des composants (→ `components`)
- Outils de build (→ `development`)
- Stratégies de test (→ `testing`)
- Environnement runtime (→ `infrastructure`)

---

## 📁 Structure du Bundle

```
architecture/
├── index.md          # Généré automatiquement
├── log.md            # Historique des actions
├── CHARTE.md         # Copie de la charte avec ligne d'inventaire
├── concepts/         # Concepts architecturaux
│   ├── flc-overview.md
│   ├── components.md
│   ├── platforms.md
│   └── acronyms.md
├── entities/         # Entités principales
│   └── databases.md
├── decisions/        # Décisions architecturales (ADRs)
│   └── clearcase-to-git.md
├── constraints/      # Contraintes système
│   ├── embedded-limits.md
│   ├── windriver-lts-versions.md
│   └── windriver-lts-operations.md
├── references/       # Digests des sources MkDocs
│   ├── flc-intro-digest.md
│   ├── flc-components-digest.md
│   ├── acronyms-digest.md
│   ├── target-env-digest.md
│   └── cc2git-digest.md
└── raw/              # Sources brutes (immutables)
    ├── 2026-10-21-flc-intro.md
    ├── 2026-10-21-flc-components.md
    ├── 2026-10-21-acronyms.md
    ├── 2026-10-21-target-env.md
    └── 2026-10-21-cc2git.md
```

---

## 📝 Pages Créées

### Concepts
1. **flc-overview.md** - Vue d'ensemble de l'architecture FLC/ECMTCP
2. **components.md** - Composants principaux et leurs relations
3. **platforms.md** - Plateformes supportées (ESCT2000, EASE2000, ESCT3000, XFLC1000)
4. **acronyms.md** - Liste complète des acronymes

### Entités
5. **databases.md** - Bases de données (ADDR, MAIN, MAINPM, SDNAGENT, TL1AGENT)

### Décisions
6. **clearcase-to-git.md** - Migration de ClearCase vers Git

### Contraintes
7. **embedded-limits.md** - Limites des ressources sur les plateformes embarquées
8. **windriver-lts-versions.md** - Versions WRL LTS, kernel, toolchain, packages
9. **windriver-lts-operations.md** - Sécurité, mises à jour, monitoring

---

## 🔗 Overlaps avec d'autres Bundles

| Bundle | Relation | Ce bundle couvre... | Autre bundle couvre... |
|--------|----------|---------------------|------------------------|
| components | Enfant | Architecture globale | Détails internes |
| development | Complémentaire | Plateformes, contraintes | Outils de build |
| testing | Complémentaire | Architecture | Stratégies de test |
| infrastructure | Complémentaire | Contraintes système | Runtime, déploiement |

---

## 📚 Sources Ingerées

| Source | Fichier | raw/ | references/ | Pages créées |
|--------|---------|------|-------------|--------------|
| FLC Documentation Index | `/local/ECMTCP_MEL/mkdocsFLC/docs/index.md` | ✅ 2026-10-21-flc-intro.md | ✅ flc-intro-digest.md | flc-overview.md |
| FLC Components | `/local/ECMTCP_MEL/mkdocsFLC/docs/flc_components.md` | ✅ 2026-10-21-flc-components.md | ✅ flc-components-digest.md | components.md, platforms.md, databases.md |
| Acronyms | `/local/ECMTCP_MEL/mkdocsFLC/docs/acronyms.md` | ✅ 2026-10-21-acronyms.md | ✅ acronyms-digest.md | acronyms.md |
| Target Environment | `/local/ECMTCP_MEL/mkdocsFLC/docs/target_environment.md` | ✅ 2026-10-21-target-env.md | ✅ target-env-digest.md | embedded-limits.md, windriver-lts-*.md |
| ClearCase to Git | `/local/ECMTCP_MEL/mkdocsFLC/docs/cc2git.md` | ✅ 2026-10-21-cc2git.md | ✅ cc2git-digest.md | clearcase-to-git.md |

---

## 🎯 Workflow OBLIGATOIRE

### Étape 1 : Validation
- **Prérequis** : Le propriétaire doit dire **explicitement** "oui" à la proposition.
- **Silence = Refus** (CHARTE §10).

### Étape 2 : Création du Bundle
```bash
tools/new-bundle.sh architecture
```

### Étape 3 : Mise à jour de CHARTE.md
Ajouter dans le tableau §3 :
```markdown
| architecture | Architecture globale FLC/ECMTCP, composants, plateformes, acronymes et décisions | Détails internes des composants, outils de build | Active (validated 2026-10-21) |
```

### Étape 4 : Ingestion des Sources
Pour chaque source MkDocs :

1. **Anonymiser** le contenu :
   - `/local/ECMTCP_MEL` → "le dépôt ECMTCP"
   - `vxl15038` → "un serveur de développement"
   - `/doclns` → "un partage réseau"
   - `omcap` → "un utilisateur système"

2. **Convertir** (déjà en Markdown, donc copier directement)

3. **Calculer le sha256** :
   ```bash
   sha256sum /tmp/fichier.md
   ```

4. **Créer le fichier raw/** :
   - Format : `bundles/architecture/raw/YYYY-MM-DD-<slug>.md`
   - Contenu : Source brute anonymisée avec header OKF

5. **Créer le digest references/** :
   - Format : `bundles/architecture/references/<slug>-digest.md`
   - Contenu : Résumé de la source (2-5 phrases max)

### Étape 5 : Création des Pages de Connaissance
Pour chaque concept/entité/décision/contrainte :
1. Créer le fichier dans le bon sous-dossier
2. Utiliser le template OKF v0.2
3. Lier vers les sources (digest et raw)

### Étape 6 : Mise à jour du log.md
```markdown
## YYYY-MM-DD
* **Ingest**: [Titre](references/<slug>.md) — Résumé. (<AGENT>/<MODEL>)
* **Creation**: [Page](concepts/<page>.md) — Description. (<AGENT>/<MODEL>)
```

### Étape 7 : Lint et Commit
```bash
# 1. Générer les index
python3 tools/gen-index.py

# 2. Linter (DOIT PASSER SANS ERREUR)
python3 tools/lint.py

# 3. Commiter
tools/commit.sh "wiki(architecture): <action> — <object>" "<AGENT>/<MODEL>"
```

---

## ✅ Statut Actuel

- **Bundle créé** : ✅ 2026-10-21
- **Proposition validée** : ✅ 2026-10-21
- **Sources ingérées** : ✅ 5/5 (100%)
- **Pages créées** : ✅ 9/9 (100%)
- **Lint** : ✅ 0 error(s)
- **Commit final** : ✅ 6c56481

---

## ⚠️ Règles Critiques

1. **Anonymisation** (CHARTE §2) : TOUT le contenu doit être anonymisé avant ingestion.
2. **Pas de création sans validation** (CHARTE §10) : Silence = Refus.
3. **Lint obligatoire** avant chaque commit.
4. **Log.md** : Toute action doit être loguée.
5. **Mermaid uniquement** pour tous les diagrammes.

---

## 📅 Historique

| Date | Action | Commit | Agent |
|------|--------|--------|-------|
| 2026-10-21 | Proposition formalisée | - | hermes/mistral-medium |
| 2026-10-21 | Bundle créé, sources ingérées | fb8577e | hermes/mistral-medium |
| 2026-10-21 | Corrections (split windriver-lts, clearcase-to-git) | 3c218c0 | hermes/mistral-medium |
| 2026-10-22 | Conversion diagrammes → Mermaid | 6c56481 | hermes/mistral-medium |
