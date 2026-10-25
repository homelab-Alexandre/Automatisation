# Automatisation-Bash
Liste de script d'automatisation de script bash (pour linux/WINDOWS only)


## Repartition des tâches

Répartition des tâches : 

Alexandre FA --> Scripts Bash (Linux)

Tristan Roux --> Script PowerShell

Valentin ryckaert (undef)


## Dossier template

Ce dossier contient tout ce qui est nécessaire au bon foncitonnement du logiciel

# Nomenclature branch git

Branche stable : Main

Branche de développement (Version stable) : Develop

Branch de features : feat/<language_nom_de_la_feature>

Branch de documentation : feat/docs 


Pour créer vos branches, pensez bien à respecté la nomenclature : feat/<language_nom_de_votre_features>



ex. feat/Bash_crea_newprojet

ex. feat/c_timer

ex. feat/PS_cration_branch

PS = PowerShell


ATTENTION : NE PAS MERGE TOUT DE SUITE, FAIRE UNE PULL REQUEST
# Liste des Scripts


- [Automatisation-Bash](#automatisation-bash)
- [Nomenclature branch git](#nomenclature-branch-git)
- [Liste des Scripts](#liste-des-scripts)
  - [Script de création de branche](#script-de-création-de-branche)
  - [Script création de nouveau projet](#script-création-de-nouveau-projet)
  - [Script de backup](#script-de-backup)
  - [List todo](#list-todo)


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

## Mini application de gestion de laptop (raccourcis et automatisation)

Détails : 
- Globalement, une sorte d'interface global qui reprend tout les projets ci dessus avec une interface graphique pour pouvoirs les utiliser

Fonctionnalités : 

--> Ajout d'une section automatique pour centraliser les documents et création d'une fonctionnalité de pouvoirs ajouter des repertoires (fiche de paie, Certifications, documentation administratif etc...)

--> Possibilité de lancement de l'application reminder

--> Connexion au VPN

--> Lancement de scripts (Création d'un nouveau projet github/gitlab, modification du fichier config dans le dossier ssh et modification de ce dernier)

--> Création de clé ssh

--> Automatisation de Backup (pré-séléction de dossier à l'avance ou choix en directe + pareil pour la destination + intégration du VPN (stockage sur le NAS))

--> Lancement de créatino d'un nouveau projet

--> Lancement d'un script pour voir les stats de son pc (cpu, ram, stockage max et utiliser / restant, état de la batterie etc...)
