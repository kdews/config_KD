#!/bin/bash
# User-specific aliases
alias vi="vim"
alias reload=". ~/.bash_profile"
alias ls="ls -1 --color=auto"
alias la="ls -a"
alias getnode="salloc --time=300:00:00 --ntasks=1 --cpus-per-task=12 --mem-per-cpu=10gb"
alias smallnode="salloc --time=05:00:00 --mem=10gb"
alias bignode="salloc --time=01:00:00 --mem=85gb"
alias proj="cd /project2/noujdine_61/kdeweese"
