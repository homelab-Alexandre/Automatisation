#!/bin/bash

DEFAULT_BRANCH=develop
CURRENT_BRANCH=$(git branch --show-current)

git stash
git switch DEFAULT_BRANCH
git branch "$1"
git switch "$1"
git switch "$CURRENT_BRANCH"
git stash pop
