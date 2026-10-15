# Automatisation-Bash
Liste de script d'automatisation de script bash (pour linux only)

Répartition des tâches : 

Alexandre FA --> Scripts Bash (Linux)
Tristan Roux --> Script PowerShell
Valentin ryckaert (undef)

# Nomenclature branch git

Branche stable : Main
Branche de développement : Develop
Branch de features : feat/<language_nom_de_la_feature>
Branch de documentation : feat/docs 


Pour créer vos branches, pensez bien à respecté la nomenclature : feat/<language_nom_de_votre_features>

ex. feat/Bash_crea_newprojet
ex. feat/c_timer
ex. feat/ps_cration_branch

ps = PowerShell

# Liste des Scripts


- [Script de création de branche](#script-de-création-de-branche)
- [Script création de nouveau projet](#script-création-de-nouveau-projet)
- [Script de backup](#script-de-backup)


## Script de création de branche

Idées:
--> Vérification que d'autres branch ne porte pas le même nom
--> Demande de push automatiquement ou non
--> Verifier si un bon nom de branch à été donner
--> 

## Script création de nouveau projet

--> Créer la base d'un projet (Architecture src, public etc... , gitignore, fichier de démarrage, README, initialisation de git ou pas etc...)
--> push automatiquement le projet sur git
--> Possibilité de créer un Workflow (Github flow, Gitlab flow git flow ou git flow modifier)
--> 

## Script de backup 

--> Paramètre 1 : lien du fichier / dossier que l'on souhaite sauvegarder
--> Paramètre 2 : lien du dossier ou l'on doit sauvegarder
--> possibilité de le mettre dans un cron pour automatiser les tâches de sauvegardes
--> Permet de séléctionner un périphérique de stockage (CLI)

## List todo 

--> Ajouter une entré dans un fichier todo (variable pour le chemin)
--> Afficher la liste (avec un système de notation genre 1. blabla 2. blabla etc...)
--> Supprimer un élément de la todo liste
--> Une todo liste = Un nom, une description et un fichier 