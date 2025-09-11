#!/bin/bash
# User-specific aliases
alias vi="vim"
alias reload=". ~/.bashrc"
alias ls="ls -1 --color=auto"
alias la="ls -a"
# JOBID PARTITION NAME STATE TIME TIME_LEFT CPUS NODES MIN_MEM NODELIST(REASON)
sq_fmt="%.10i %.9P %.25j %.2t %.10M %.10L %.6C %.6D %.6m %R"
alias myjobs="squeue --me --format=\"$sq_fmt\""
alias watchjobs="watch -d 'squeue --me --format=\"$sq_fmt\"'"
unset -v sq_fmt
alias getnode="salloc --time=300:00:00 --ntasks=1 --cpus-per-task=12 --mem-per-cpu=10gb"
alias smallnode="salloc --time=05:00:00 --mem=10gb"
alias bignode="salloc --time=01:00:00 --mem=85gb"
alias proj="cd /project/noujdine_61/kdeweese"
alias long="cd /project/noujdine_61/kdeweese/latissima/longreads"
alias geno="cd /project/noujdine_61/kdeweese/latissima/genome_stats"
alias ass="cd /project/noujdine_61/kdeweese/latissima/organelles/org_assembly"
alias pop="cd /project/noujdine_61/kdeweese/latissima/organelles/org_pop_gen"
alias undar="cd /project/noujdine_61/mharden/undaria_variation"
