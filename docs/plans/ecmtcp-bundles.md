# Plan ECMTCP - Création des Bundles

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

## Workflow Standard pour chaque Bundle
1. **Valider la proposition** : Le propriétaire doit dire explicitement "oui".
2. **Créer le bundle** : `tools/new-bundle.sh <nom>`
3. **Mettre à jour CHARTE.md** : Ajouter une ligne dans le tableau §3.
4. **Ingérer les sources** :
   - Convertir les fichiers MkDocs en Markdown (anonymiser !).
   - Placer dans `raw/YYYY-MM-DD-<slug>.md` avec header OKF.
   - Créer les digests dans `references/`.
5. **Créer les pages** : Suivre les templates du plan.
6. **Linter et commiter** :
   ```bash
   python3 tools/lint.py
   tools/commit.sh "wiki(<bundle>): <action> — <object>" "<agent>/<model>"
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
