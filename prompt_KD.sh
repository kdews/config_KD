#!/bin/bash
# Manage custom BASH prompt
# Set custom emoji
emoj="😔 "
# Only customize prompt if `hostname` command is sourced 
if [[ -n $(command -v hostname) ]]
then
	if [[ $(hostname) =~ "endeavour" ]] || [[ $(hostname) =~ "discovery" ]]
	then
		# If running on head node
		export PS1="$emoj  [\u] \W > "
	else
		# If running in compute node
		export PS1="$emoj  [\u@\h] \W > "
	fi
fi
