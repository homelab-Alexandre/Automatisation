#!/bin/bash

# Variables
CHEMIN="/home/killex/Bureau/Mes documents/Mes projets/repo_perso/"
PROJ=(Python Java C React Go Rust )
index=0

# Code

check_type(){
        if [[ "$1" =~ ^-?[0-9]+$ ]]; then
                echo 1 # int
        elif [[ "$1" =~ ^-?[0-9]+\.[0-9]+$ ]]; then
                echo 3 # float
        else
                echo 2 # str
        fi
}

create_python_repo(){
	mkdir "$CHEMIN$2"
	cp -r ../template/Python "$CHEMIN$2"
}

create_java_repo(){
	mkdir "$CHEMIN$2"
	cp -r ../template/Java, "$CHEMIN$2"
}


creer_repo(){

if [[ "$1" -eq 0 ]]; then 
	create_python_repo
elif [[ "$1" -eq 1 ]]; then 
    mkdir "$CHEMIN$2"
	touch "$CHEMIN$2/main.java"
    echo "// fichier main java" > "$CHEMIN$2/main.java"
elif [[ "$1" -eq 2 ]]; then 
    mkdir -p "$CHEMIN$2/src"
	touch "$CHEMIN$2/src/main.c"
    echo "// fichier main C" > "$CHEMIN$2/src/main.c"

else

    echo "Erreur"
    return 1
fi

}


menu(){
	for i in "${PROJ[@]}";
		do echo "Option $index : $i"
		((index++))
	done

	read -p "Votre choix : " choix
	read -p "Le nom de votre dossier / repo : " name_repo
	((index = 0))
	type_repo=$(check_type "$name_repo")
	type_choix=$(check_type "$choix")
	if [[ "$type_choix" -eq 1 && "$type_repo" -eq 2 ]]; then
		choix_str="${PROJ[$choix]}"
		echo "Vous avez choisi :[ $choix_str ] avec le nom de repo : [ $name_repo ] dans le repertoire suivant : repo_perso"
		sleep 2
		creer_repo "$choix" "$name_repo"
	else
		echo "votre nombre n'est pas valide"
		menu
	fi
}


# lancement du script
menu
