# Documentation de la pipeline CI

Oct 24, 2026 · @Alex

## Vue d'ensemble

La pipeline vérifie automatiquement le C, le Python et le PowerShell du dépôt à chaque push sur la branche principale et à chaque pull request. Une exécution lance 4 jobs indépendants ; un job dont le langage est absent du dépôt passe au vert sans rien faire.

&#91;embedded content: pipeline CI · 3 déclencheurs, 4 jobs\]

Les trois jobs Linux se partagent tes runners Linux, le job PowerShell part sur un runner Windows ; sans variable définie, GitHub fournit les machines. Un job en échec n'arrête pas les autres.

## Déclencheurs et concurrence

La pipeline se lance dans trois cas, définis dans le bloc `on:` du fichier `.github/workflows/ci.yml`.

| Déclencheur | Quand | Pourquoi |
| --- | --- | --- |
| `push` | Un commit est poussé sur `main` ou `master` | Vérifier que la branche principale reste saine |
| `pull_request` | Une PR est ouverte ou mise à jour, quelle que soit la branche | Bloquer le code cassé avant la fusion |
| `workflow_dispatch` | Clic sur **Run workflow** dans l'onglet Actions | Relancer la CI à la main, sans commit |

Un push sur une autre branche que `main`/`master` ne lance rien tant qu'aucune PR n'est ouverte dessus. Pour tout tester, remplacer `branches: [main, master]` par `branches: ['**']`.

**Concurrence.** Le bloc `concurrency` regroupe les exécutions par branche (`ci-${{ github.ref }}`). Avec `cancel-in-progress: true`, un nouveau push annule l'exécution encore en cours sur la même branche. Tes runners ne perdent donc pas de temps sur un commit déjà dépassé.

## Choix des runners

Chaque job choisit sa machine grâce à deux variables de dépôt : sans elles, la CI tourne sur les runners gratuits de GitHub ; avec elles, sur tes runners auto-hébergés. Aucune modification du fichier n'est nécessaire pour basculer.

La ligne qui fait ce choix, dans les jobs C et Python :

```yaml
runs-on: ${{ vars.RUNNER_LINUX && fromJSON(vars.RUNNER_LINUX) || 'ubuntu-latest' }}
```

Elle se lit ainsi : si la variable `RUNNER_LINUX` existe, convertir son contenu JSON en liste de labels ; sinon, utiliser `ubuntu-latest`. Le job PowerShell fait la même chose avec `RUNNER_WINDOWS` et `windows-latest`.

| Variable | Utilisée par | Valeur conseillée | Repli si absente |
| --- | --- | --- | --- |
| `RUNNER_LINUX` | Jobs C (gcc et clang), Python | `["self-hosted", "linux"]` | `ubuntu-latest` |
| `RUNNER_WINDOWS` | Job PowerShell | `["self-hosted", "windows"]` | `windows-latest` |

**Comment GitHub répartit le travail entre plusieurs runners.** Un job part sur le premier runner libre qui porte **tous** les labels demandés. Une exécution crée 4 jobs (C gcc, C clang, Python, PowerShell). Avec trois runners Linux, les trois jobs Linux tournent donc en même temps, chacun sur une machine. Avec un seul runner Linux, ils passent l'un après l'autre. Ajouter un runner ne demande rien d'autre que lui donner les bons labels.

**Cibler une machine précise.** Pour réserver un job à un runner donné (par exemple celui qui a le plus de cœurs pour le C), lui ajouter un label personnalisé comme `gros-build`, puis mettre `["self-hosted", "linux", "gros-build"]` dans la variable.

**Délais.** Chaque job a un `timeout-minutes` (30 pour le C, 20 pour les autres). Un job bloqué libère le runner au lieu de l'occuper jusqu'à la limite de 6 heures par défaut.

## Job C

Le job C compile ton code deux fois, avec **gcc** puis avec **clang**, et le fait analyser par **cppcheck**. Deux compilateurs détectent plus d'erreurs qu'un seul : chacun a ses propres avertissements.

**La matrice.** `matrix: compiler: [gcc, clang]` duplique le job en deux exécutions parallèles, « C (gcc) » et « C (clang) ». La variable `CC` reçoit le nom du compilateur ; CMake et Make la lisent automatiquement. Avec `fail-fast: false`, un échec sous gcc n'annule pas l'exécution clang : tu vois les deux résultats.

| Étape | Se lance si | Ce qu'elle fait |
| --- | --- | --- |
| Récupération du code | Toujours | `actions/checkout@v5` clone le dépôt dans le dossier de travail du runner |
| Installer les outils manquants | Toujours | Vérifie gcc, clang, make, cmake et cppcheck. N'installe rien s'ils sont tous là. Sinon, utilise `apt-get` (avec `sudo` si le runner ne tourne pas en root). Sans `apt-get`, l'étape échoue et liste les outils à installer à la main |
| Compiler avec CMake | Un `CMakeLists.txt` existe | Configure en mode Debug dans `build/` avec `-Wall -Wextra`, puis compile en parallèle |
| Compiler avec Make | Pas de CMake, mais un `Makefile` existe | Lance `make` dans le dossier du premier `Makefile` trouvé, en lui passant le compilateur |
| Vérifier chaque fichier .c | Ni CMake ni Makefile | Passe chaque `.c` au compilateur en C11 avec `-Wall -Wextra -fsyntax-only` : vérification de syntaxe et de types, sans édition de liens. Les dossiers `include/` sont ajoutés aux chemins d'en-têtes. Tous les fichiers sont vérifiés avant que l'étape échoue |
| Analyse statique (cppcheck) | Exécution gcc uniquement, et des `.c` existent | Cherche les bugs que le compilateur ne voit pas : fuites mémoire, dépassements de tableau, variables non initialisées, problèmes de portabilité. Échoue au premier problème trouvé. Ignore `build/` |

Les trois étapes de compilation s'excluent : une seule tourne, selon ce que contient le dépôt. cppcheck ne tourne que sur l'exécution gcc pour ne pas faire deux fois la même analyse.

**Ignorer un avertissement cppcheck volontaire** : ajouter `// cppcheck-suppress <identifiant>` sur la ligne au-dessus, grâce à l'option `--inline-suppr`.

## Job Python

Le job Python vérifie le style et les erreurs courantes avec **ruff**, puis lance les tests avec **pytest**. S'il n'y a aucun fichier `.py`, toutes ses étapes sont sautées et le job passe au vert.

| Étape | Se lance si | Ce qu'elle fait |
| --- | --- | --- |
| Récupération du code | Toujours | Clone le dépôt |
| Installer Python | Des `.py` existent | `actions/setup-python@v6` installe Python 3.12 |
| Installer les dépendances | Des `.py` existent | Met à jour pip, installe ruff et pytest, puis `requirements.txt` s'il est à la racine |
| Lint (ruff) | Des `.py` existent | `ruff check .` signale les imports inutilisés, variables non définies, erreurs de syntaxe, etc. |
| Tests (pytest) | Des fichiers `test_*.py` ou `*_test.py` existent | `pytest -v` lance les tests et affiche chacun avec son résultat |

Pour changer de version de Python, modifier `python-version`. Pour régler ruff (règles, longueur de ligne, dossiers exclus), ajouter une section `[tool.ruff]` dans un `pyproject.toml` à la racine.

## Job PowerShell

Le job PowerShell analyse tes scripts avec **PSScriptAnalyzer** et lance les tests **Pester** s'il y en a. Il tourne sur Windows, et toutes ses commandes passent par `pwsh` (PowerShell 7).

| Étape | Se lance si | Ce qu'elle fait |
| --- | --- | --- |
| Récupération du code | Toujours | Clone le dépôt |
| Analyse des scripts | Des `.ps1` ou `.psm1` existent | Installe PSScriptAnalyzer s'il manque, analyse tout le dépôt et affiche un tableau des avertissements et erreurs. **Seules les erreurs font échouer le job** ; les avertissements sont affichés mais tolérés |
| Tests (Pester) | Des fichiers `*.Tests.ps1` existent | Installe Pester et lance `Invoke-Pester -CI`, qui fait échouer le job si un test échoue |

Pour rendre l'analyse plus stricte, faire échouer aussi sur les avertissements en remplaçant `Where-Object Severity -eq 'Error'` par `$results.Count -gt 0`.

## Ajouter tes runners auto-hébergés

Un runner s'ajoute en trois temps : l'enregistrer sur GitHub, vérifier ses labels, puis renseigner les variables une seule fois. Les runners suivants n'ont besoin que des deux premiers temps.

### 1. Enregistrer un nouveau runner

1. Sur GitHub, ouvrir le dépôt, puis **Settings > Actions > Runners > New self-hosted runner**.
2. Choisir le système (Linux ou Windows) et l'architecture. GitHub affiche les commandes à copier, avec un jeton d'enregistrement valable une heure.
3. Sur la machine, exécuter les commandes de téléchargement, puis la configuration. Sous Linux, ajouter les labels voulus dès cette étape :

```bash
./config.sh --url https://github.com/<ton-compte>/<ton-depot> --token <JETON> --labels linux
```

4. Installer le runner comme service, pour qu'il redémarre avec la machine :

```bash
sudo ./svc.sh install
sudo ./svc.sh start
```

Sous Windows, la commande est `config.cmd`, et l'assistant propose de l'installer comme service à la fin. Le runner apparaît ensuite en **Idle** dans la liste.

### 2. Vérifier les labels de chaque runner

GitHub donne automatiquement les labels `self-hosted`, le système (`Linux` ou `Windows`) et l'architecture (`X64`, `ARM64`). Les labels ne tiennent pas compte de la casse, donc `linux` correspond à `Linux`. Pour ton runner déjà installé, ouvrir sa fiche dans **Settings > Actions > Runners** : ses labels y sont listés et l'icône d'engrenage permet d'en ajouter.

| Runner | Labels minimum | Jobs qu'il peut prendre |
| --- | --- | --- |
| Linux | `self-hosted`, `linux` | C (gcc), C (clang), Python |
| Windows | `self-hosted`, `windows` | PowerShell |

### 3. Créer les variables (une seule fois)

Dans **Settings > Secrets and variables > Actions**, onglet **Variables**, bouton **New repository variable** :

- `RUNNER_LINUX` = `["self-hosted", "linux"]`
- `RUNNER_WINDOWS` = `["self-hosted", "windows"]`

Si tu n'as pas de runner Windows, ne crée pas `RUNNER_WINDOWS` : le job PowerShell restera sur `windows-latest`, hébergé par GitHub. Sans runner correspondant, un job attendrait indéfiniment dans la file.

### Prérequis par machine

| Runner | À installer | Remarque |
| --- | --- | --- |
| Linux (Debian/Ubuntu) | `git` ; idéalement gcc, clang, make, cmake, cppcheck | L'étape d'installation ajoute les outils manquants via `apt-get`. Le compte du runner doit être root ou avoir `sudo` sans mot de passe |
| Linux (autre distribution) | `git`, gcc, clang, make, cmake, cppcheck, Python 3 | Sans `apt-get`, l'étape échoue et liste ce qui manque. `setup-python` est surtout prévu pour Ubuntu |
| Windows | `git`, PowerShell 7 (`winget install Microsoft.PowerShell`) | Les étapes utilisent `pwsh` ; Windows PowerShell 5.1 seul ne suffit pas. PSScriptAnalyzer et Pester s'installent automatiquement |

### Sécurité

Si le dépôt est **public**, n'importe qui peut ouvrir une pull request depuis un fork, et son code s'exécuterait sur tes machines. Dans **Settings > Actions > General**, exiger l'approbation des workflows de PR venant de contributeurs extérieurs. Pour un dépôt privé, le risque se limite aux personnes qui y ont accès.

## Installation, résultats et dépannage

### Installer la pipeline

Le fichier doit être à `.github/workflows/ci.yml`, à la racine du dépôt Git (au même niveau que le dossier `.git`). Le dossier s'écrit `workflows`, au pluriel : avec `workflow`, GitHub ignore le fichier.

```bash
mkdir -p .github/workflows
mv ci.yml .github/workflows/ci.yml
git add .github/workflows/ci.yml
git commit -m "Ajout de la pipeline CI"
git push
```

### Lire les résultats

- **Onglet Actions** du dépôt : une ligne par exécution, avec son déclencheur et son statut.
- En cliquant sur une exécution, les 4 jobs apparaissent ; chaque étape se déplie pour montrer son journal. Les fichiers C vérifiés un par un sont regroupés en sections repliables.
- Une étape sautée (condition non remplie) apparaît grisée : ce n'est pas une erreur.
- Sur une pull request, le statut de chaque job s'affiche en bas de la PR.

### Problèmes fréquents

| Symptôme | Cause probable | Solution |
| --- | --- | --- |
| Aucune exécution dans Actions | Dossier `workflow` au singulier, ou `.github` pas à la racine du dépôt | Renommer en `workflows` ; déplacer `.github` à la racine |
| Job bloqué sur « Waiting for a runner » | Aucun runner en ligne avec les labels demandés | Vérifier que le runner est **Idle** et porte tous les labels de la variable ; sinon supprimer la variable pour revenir aux runners GitHub |
| « Installe à la main sur ce runner » | Runner Linux sans `apt-get` | Installer les outils listés avec le gestionnaire de paquets de la machine |
| `sudo: a password is required` | Le compte du runner n'a pas `sudo` sans mot de passe | Installer les outils une fois à la main ; l'étape n'utilisera plus `sudo` |
| `pwsh: command not found` | PowerShell 7 absent du runner Windows | `winget install Microsoft.PowerShell`, puis redémarrer le service du runner |
| cppcheck ou ruff échoue au premier lancement | Problèmes déjà présents dans le code | Corriger, ou supprimer l'avertissement (`// cppcheck-suppress`, `# noqa`) quand il est voulu |
| Make échoue alors qu'il y a plusieurs Makefile | Seul le premier `Makefile` trouvé est utilisé | Remplacer la commande par `make -C <dossier>` pour viser le bon |

### Personnaliser

- **Ajouter un compilateur ou une version** : compléter `compiler: [gcc, clang]`, par exemple `[gcc, clang, gcc-13]` si ce paquet est installé sur le runner.
- **Compiler aussi sous Windows** : ajouter une dimension `os` à la matrice du job C.
- **Lancer la CI sur toutes les branches** : `branches: ['**']` sous `push`.
- **Durcir les règles** : retirer `fail-fast: false`, ou ajouter `style` à `--enable` de cppcheck.
