#!/bin/bash

# Print date and time
date

# Source shortcut git function
source_file () {
    if [[ -a $1 ]]
    then
        source "$1"
    else
        echo "Error on source of $1"
        exit 1
    fi
}
config_dir="$HOME/config_KD"
MODS="$config_dir/modules_KD.sh"
FUNCS="$config_dir/functions_KD.sh"
source_file "$MODS"
source_file "$FUNCS"

# Run auto-commit on all repositories containing a .git in ~/scripts
# Only for user set by git config
# REQUIRED: set git user
GIT_USR="$(git config user.name)"
# REQUIRED: set auto-commit message
MESSAGE="Auto-commit: $(date)"
git --version
echo "User: $GIT_USR"
echo "$MESSAGE"
# REQUIRED: set repository path(s)
mapfile -t REPOS < <(grep -l "$GIT_USR" ~/scripts/*/.git/config)
REPOS+=("$config_dir")
for REPO_PATH in "${REPOS[@]}"
do
    REPO_PATH="${REPO_PATH%%\.git*}"
    echo "$REPO_PATH"
    gitpublish "$MESSAGE" "$REPO_PATH"
done
