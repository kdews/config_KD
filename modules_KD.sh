#!/bin/bash
# User-specific module environment

# Clear loaded modules
# module purge >/dev/null 2>&1
# Load data compression library (in USC default now)
# module load zlib >/dev/null 2>&1
# Load most recent Vim version
module --latest load vim >/dev/null 2>&1
# Load most recent git version 
module --latest load git >/dev/null 2>&1
# Load most recent R version
# module load r >/dev/null 2>&1
# # Load most recent screen version
# export HOSTNAME=$(hostname) # patch for screen module
module --latest load screen >/dev/null 2>&1
