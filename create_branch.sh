#!/bin/bash

DEFAULT_BRANCH=develop

git switch DEFAULT_BRANCH
git branch "$1"
git switch "$1"

read -p "Voulez vous push directement votre nouvelle branch "$1" (y/N) : " choix

if [[ "$choix" -eq y ]]; then 
    git commit -m "init new branch"
    git push --set-upstream origin "$1"
fi