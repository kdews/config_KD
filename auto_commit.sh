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
MODS=~/config_KD/modules_KD
FUNCS=~/config_KD/functions_KD
source_file "$MODS"
source_file "$FUNCS"

# Run auto-commit on all repositories containing a .git in ~/scripts
# Only for user set by git config
# REQUIRED: set git user
GIT_USR=$(git config user.name)
# REQUIRED: set auto-commit message
MESSAGE="Auto-commit: $(date)"
echo "$(git --version)
User: $GIT_USR 
$MESSAGE"
# REQUIRED: set repository path(s)
for REPO_PATH in $(grep -l "$GIT_USR" ~/scripts/*/.git/config | sed "s/\\/\\.git.*//g")
do
	echo "$REPO_PATH"
	cd "$REPO_PATH"
	gitpublish "$MESSAGE"
done

