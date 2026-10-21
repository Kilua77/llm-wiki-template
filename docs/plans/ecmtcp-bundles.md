# Plan ECMTCP - Création des Bundles

---

## 📌 Consignes Globales (À RESPECTER ABSOLUMENT)

1. **Diagrammes** : Utiliser **uniquement Mermaid** pour tous les graphiques (flowcharts, sequence diagrams, etc.).
   - Exemple :
     ```mermaid
     flowchart TD
       A[FLC] --> B[GOL]
       A --> C[SOL]
     ```
   - **Interdit** : Images, SVG, ou autres formats.

2. **Anonymisation** : Voir [CHARTE §2](../CHARTE.md#2-publishability-and-anonymization).

3. **Frontmatter** : Toujours valider avec `python3 tools/lint.py` avant commit.

---

## Ordre de création
1. **architecture** → Fondation (composants, plateformes, acronymes)
2. **components** → Détail des composants (GOL, SOL, AVAIL, etc.)
3. **development** → Outils (Albie, wpack, scripts)
4. **best-practices** → Bonnes pratiques transversales
5. **testing** → Tests et diagnostics
6. **infrastructure** → Environnement runtime et déploiement
7. **meetings** → Ingestion des ZIPs de réunions

## Lien vers les propositions
- [architecture](../proposals/2026-10-21-architecture.md)
- [components](../proposals/2026-10-21-components.md)
- [development](../proposals/2026-10-21-development.md)
- [best-practices](../proposals/2026-10-21-best-practices.md)
- [testing](../proposals/2026-10-21-testing.md)
- [infrastructure](../proposals/2026-10-21-infrastructure.md)
- [meetings](../proposals/2026-10-21-meetings.md)

---

## Détails par Bundle

### 📦 1. architecture
**Statut** : Proposition formalisée
**Objectif** : Architecture globale FLC/ECMTCP, composants, plateformes, acronymes, décisions (ADRs), contraintes système.
**Structure** :
```
concepts/      # flc-overview, components, platforms, acronyms
entities/      # databases (ADDR, MAIN, MAINPM, SDNAGENT, TL1AGENT)
decisions/     # ADRs (ex: clearcase-to-git)
constraints/   # Contraintes système (embedded-limits, windriver-lts)
references/    # Digests des sources MkDocs
raw/           # Sources brutes (immutables)
```
**Pages initiales** : flc-overview.md, components.md, platforms.md, acronyms.md, databases.md, clearcase-to-git.md, embedded-limits.md, windriver-lts.md

### 📦 2. components
**Statut** : Proposition à formaliser
**Objectif** : Détail des composants individuels (GOL, SOL, AVAIL, etc.), interfaces, bases de données.
**Structure** :
```
entities/      # avail.md, gol.md, sol.md, appserv.md, tl1agent.md, sdnagent.md, addr-db.md, etc.
decisions/     # Décisions par composant
constraints/   # Contraintes par composant
references/    # Digests des READMEs des composants
raw/           # Sources brutes
```

### 📦 3. development
**Statut** : Proposition à formaliser
**Objectif** : Outils internes (Albie, wpack, reportDeliveryPackage.pl, etc.), build, versioning, environnement de dev.
**Structure** :
```
tools/       # albie.md, wpack.md, report-delivery-package.md, etc.
practices/   # dev-env-setup.md, git-workflow.md
playbooks/   # build-component.md, create-delivery.md
constraints/ # supported-compilers.md
```

### 📦 4. best-practices
**Statut** : Proposition à formaliser
**Objectif** : Bonnes pratiques transversales (revue de code, legacy, sécurité, performance).
**Structure** :
```
practices/    # code-review.md, doc-standards.md, legacy-code.md, security.md, performance.md
playbooks/    # onboarding.md
```

### 📦 5. testing
**Statut** : Proposition à formaliser
**Objectif** : Stratégies de test (Fastchecker, COTDR, cppcheck), diagnostics.
**Structure** :
```
tools/       # fastchecker.md, cotdr.md, trace-mgt.md
practices/   # unit-testing.md, integration-testing.md
playbooks/   # reproduce-bug.md, analyze-trace.md
```

### 📦 6. infrastructure
**Statut** : Proposition à formaliser
**Objectif** : Environnement runtime, déploiement, partages réseau.
**Structure** :
```
tools/       # network-shares.md, service-users.md
practices/   # delivery-process.md, seps-maintenance.md
playbooks/   # mount-shares.md, generate-delivery-notes.md
```

### 📦 7. meetings
**Statut** : Proposition à formaliser
**Objectif** : Ingestion des ZIPs de réunions (`/home/melouarr/Documents/Reunions`).
**Structure** :
```
concepts/      # Résumés de réunions
decisions/     # Décisions extraites
constraints/   # Contraintes extraites
references/    # Digests des notes de réunion
raw/           # Fichiers sources (convertis depuis ZIPs)
```

---

## Workflow OBLIGATOIRE pour chaque Bundle (à suivre à la lettre)

### 🔹 Étape 1 : Validation
- **Prérequis** : Le propriétaire doit dire **explicitement** "oui" à la proposition.
- **Silence = Refus** (CHARTE §10).

### 🔹 Étape 2 : Création du Bundle
```bash
tools/new-bundle.sh <nom>
```
**Vérification** :
```bash
ls bundles/<nom>/
# Doit afficher : index.md, log.md, concepts/, entities/, decisions/, constraints/, references/, raw/
```

### 🔹 Étape 3 : Mise à jour de CHARTE.md
- **Fichier** : `CHARTE.md`
- **Action** : Ajouter **une ligne** dans le tableau §3 (entre `<!-- inventory:start -->` et `<!-- inventory:end -->`) :
  ```markdown
  | `<nom>` | <Scope en une phrase> | <Out-of-scope en une phrase> | Active (validated YYYY-MM-DD) |
  ```

### 🔹 Étape 4 : INGESTION DES SOURCES (OBLIGATOIRE)
> **⚠️ C'EST ICI QUE L'AGENT A ÉCHOUÉ POUR `architecture`**

Pour **chaque source** (fichier MkDocs ou ZIP) :

#### 4.1. Préparation
- **Anonymiser** le contenu **AVANT** conversion :
  - `/local/ECMTCP_MEL` → `"le dépôt ECMTCP"`
  - `vxl15038` → `"un serveur de développement"`
  - `/doclns` → `"un partage réseau"`
  - `omcap` → `"un utilisateur système"`
  - **Conserver** : ASN, Wind River, Yocto, RHEL, etc.

#### 4.2. Conversion
- **DOCX → Markdown** :
  ```bash
  pandoc /chemin/vers/fichier.docx -f docx -t gfm --wrap=none -o /tmp/fichier.md
  ```
- **PDF → Markdown** :
  ```bash
  pdftotext -layout -enc UTF-8 /chemin/vers/fichier.pdf /tmp/fichier.md
  ```
- **Markdown existant** : Copier directement (après anonymisation).

#### 4.3. Calcul du sha256
```bash
sha256sum /tmp/fichier.md
# → Copier le hash pour content_sha256
```

#### 4.4. Création du fichier `raw/`
**Format** : `bundles/<nom>/raw/YYYY-MM-DD-<slug>.md`
**Contenu** :
```markdown
---
type: Raw Source
title: <Titre original>
description: Raw capture of <source>, ingested YYYY-MM-DD. Immutable.
tags: [raw, <tag1>, <tag2>]
status: stable
content_sha256: <HASH_CALCULÉ_ICI>
generated: { by: <AGENT>/<MODEL>, at: YYYY-MM-DDTHH:MM:SSZ }
sources:
  - id: origin
    resource: "observation:YYYY-MM"
    title: <Titre de la source>
---

<Contenu brut anonymisé, SANS MODIFICATION>
```

#### 4.5. Création du digest `references/`
**Format** : `bundles/<nom>/references/<slug>.md`
**Contenu** :
```markdown
---
type: Reference
title: <Titre> Digest
description: Summary of <source>.
tags: [<tag1>, <tag2>, reference]
status: stable
stale_after: YYYY-MM-DD
generated: { by: <AGENT>/<MODEL>, at: YYYY-MM-DDTHH:MM:SSZ }
sources:
  - id: <slug>
    resource: "observation:YYYY-MM"
    title: <Titre de la source>
---

# <Titre> - Digest

[Résumé du contenu, en 2-5 phrases. Une page de digest ne contient PAS de connaissance dérivée, seulement ce que la source dit.]

## Key Points
- Point 1
- Point 2

## See Also
- [Raw source](../raw/YYYY-MM-DD-<slug>.md)
```

### 🔹 Étape 5 : Création des Pages de Connaissance
Pour chaque concept/entité/décision/contrainte identifié dans la proposition :
1. **Créer le fichier** dans le bon sous-dossier (`concepts/`, `entities/`, etc.).
2. **Utiliser le template** correspondant au type (Concept, Tool, Service, Decision, Constraint).
3. **Lier vers les sources** :
   - Dans `sources:` : Référencer le digest (`id: <slug>`).
   - Dans le corps : Lier vers le digest et le raw (`[Source](../references/<slug>.md)`, `[Raw](../raw/YYYY-MM-DD-<slug>.md)`).

### 🔹 Étape 6 : Mise à jour du log.md
**Fichier** : `bundles/<nom>/log.md`
**Format** :
```markdown
# Log

## YYYY-MM-DD
* **Ingest**: [Titre de la source](references/<slug>.md) — Résumé en une ligne. (<AGENT>/<MODEL>)
* **Creation**: [Titre de la page](concepts/<page>.md) — Description de la création. (<AGENT>/<MODEL>)
```

### 🔹 Étape 7 : Lint et Commit
```bash
# 1. Générer les index
python3 tools/gen-index.py

# 2. Linter (DOIT PASSER SANS ERREUR)
python3 tools/lint.py

# 3. Commiter (UN COMMIT PAR LOT LOGIQUE)
tools/commit.sh "wiki(<nom>): <action> — <object>" "<AGENT>/<MODEL>"
```

---

## Exemple Complet pour `architecture`

### Sources à ingérer (priorité) :
1. `/local/ECMTCP_MEL/mkdocsFLC/docs/index.md` → `raw/2026-10-21-flc-intro.md` + `references/flc-intro-digest.md`
2. `/local/ECMTCP_MEL/mkdocsFLC/docs/flc_components.md` → `raw/2026-10-21-flc-components.md` + `references/flc-components-digest.md`
3. `/local/ECMTCP_MEL/mkdocsFLC/docs/acronyms.md` → `raw/2026-10-21-acronyms.md` + `references/acronyms-digest.md`
4. `/local/ECMTCP_MEL/mkdocsFLC/docs/target_environment.md` → `raw/2026-10-21-target-env.md` + `references/target-env-digest.md`
5. `/local/ECMTCP_MEL/mkdocsFLC/docs/cc2git.md` → `raw/2026-10-21-cc2git.md` + `references/cc2git-digest.md`

### Pages à créer après ingestion :
- `concepts/flc-overview.md` (source: index.md)
- `concepts/components.md` (source: flc_components.md)
- `concepts/platforms.md` (source: flc_components.md)
- `concepts/acronyms.md` (source: acronyms.md)
- `entities/databases.md` (source: flc_components.md)
- `decisions/clearcase-to-git.md` (source: cc2git.md)
- `constraints/embedded-limits.md` (source: target_environment.md)
- `constraints/windriver-lts.md` (source: flc_components.md)

### Commandes pour `architecture` :
```bash
# Ingestion de flc_components.md
pandoc /local/ECMTCP_MEL/mkdocsFLC/docs/flc_components.md -f markdown -t gfm --wrap=none -o /tmp/flc_components.md
sha256sum /tmp/flc_components.md
# → Copier le hash
cp /tmp/flc_components.md bundles/architecture/raw/2026-10-21-flc-components.md
# Ajouter le header OKF à raw/2026-10-21-flc-components.md
```

---

## Règles Critiques (à respecter ABSOLUMENT)
1. **Anonymisation** (CHARTE §2) :
   - `/local/ECMTCP_MEL` → "le dépôt ECMTCP"
   - `vxl15038` → "un serveur de développement"
   - `/doclns` → "un partage réseau"
2. **Pas de création sans validation** (CHARTE §10).
3. **Lint obligatoire** avant chaque commit.
4. **Log.md** : Toute action doit être loguée.
