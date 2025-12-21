#!/bin/bash
# User-specific functions

# Function returns path of file in which a given function name is defined
whichfunc () (
  # $1 is function name input or help option
  if (( $# < 1  )) ||  (( $# > 2 )) || [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]]
  then
    echo \
"Function returns path of file in which a given function name is defined

Usage: whichfunc [-h / --help] <function name> 

Options:
-h, --help : Prints this help message"
  else
    shopt -s extdebug
    declare -F "$1"
  fi
)


# Function returns partition names with idle nodes
whosopen () {
  # $1 can be help option
  if [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]]
  then
    echo \
"Function returns names of parititons with currently idle nodes.

Usage: whosopen [-h / --help]

Options:
-h, --help : Prints this help message"
  else
    sinfo | grep "idle" | awk '{print $1}'
  fi
}


# Function to quickly push changes to GitHub from remote git repo
gitpublish () {
  # $1 is the commit message
  # $2 (if given) is /path/to/repo
  # Help message
  if (( $# < 1  )) || (( $# > 2 )) || [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]]
  then
    echo \
"$# options given to gitpublish: $*

Function pushes repository to GitHub with commit message specified by 
<commit_msg>. If target repository is not the current directory, specify 
[/path/to/repo].

Usage: gitpublish <commit_msg> [/path/to/repo]"
  # Run in current directory (./)
  elif (( $# == 1 ))
  then
    git add -v --all
    git commit -m "$1"
    git push -v
  # Handle second positional argument
  elif (( $# == 2 ))
  then
    git -C "$2" add -v --all
    git -C "$2" commit -m "$1"
    git -C "$2" push -v
  fi
}


# Print job scheduler queue in specific format
myjobs () {
  local sq_fmt
  # JOBID PARTITION NAME STATE TIME TIME_LEFT CPUS NODES MIN_MEM NODELIST(REASON)
  sq_fmt="%.17i %.5K %.9P %.17j %.2t %.10M %.10L %.6C %.6D %.6m %R"
  squeue --me --format="$sq_fmt"
}


# Use 'watch' to follow job scheduler queue in real time
watchjobs () {
  local sq_fmt
  # JOBID PARTITION NAME STATE TIME TIME_LEFT CPUS NODES MIN_MEM NODELIST(REASON)
  sq_fmt="%.17i %.9P %.20j %.2t %.10M %.10L %.6C %.6D %.6m %R"
  watch -d "squeue --me --format='$sq_fmt' -t running"
}


# Generate YYYY-MM-DD formatted date from 10 years prior to today
olddate () {
  date -d "10 years ago" +%F
}


# Function to get job info from Slurm "sacct" for a specific
# job name and start date
getjobinfo () {
  # $1 is the job name
  # $2 is the start date 
  # Returns info for all jobs starting after <startdate> (format YYYY-MM-DD)
  # Help message
  local hlp
  hlp="\
Function prints most informative outputs of Slurm 'sacct' for
given job name and start date.

Usage: getjobinfo <job_name> <start_date>

The format of <start_date> must be: YYYY-MM-DD."
  # Format string
  if (( $# < 2 )) || [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]]
  then
    echo "$hlp"
  elif [[ -z "$2" ]]
  then
    echo "Missing <start_date>."
    echo "$hlp"
  else
    local job_name
    local start_date
    local fmt
    job_name="$1"
    start_date="$2"
    fmt="JobID%20,JobName,State%13,ExitCode,Start,End,Elapsed,CPUTime,ReqMem,MaxRSS,NCPUS"
    # Retrieve only completed (CD), out of memory (OOM), or timed out (TO) jobs
    sacct --format="$fmt" \
      --name "$job_name" \
      -s "CD,TO,OOM" \
      -S "$start_date" \
      -E now
  fi
}

# Function to get tab-separated list of job IDs from Slurm from given job name
# Retrieves all IDs (start date arbitrarily set to 10 years ago)
getjobids () {
  local start_date
  local hlp
  start_date="$(olddate)"
  # Help message
  hlp="\
Function to list all job IDs returned by Slurm 'sacct' for a
specific job name. Excludes job IDs ending in '.batch' or '.extern'.

Usage: getjobids <job_name> [date]

Where date is formatted: YYYY_MM_DD
Unless date is given, starts 10 years prior to today's date (e.g., $start_date)."
  if (( $# < 1 )) || [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]]
  then
    echo "$hlp"
  else
    local job_name
    job_name="$1"
    if (( $# == 2 ))
    then
      start_date="$2"
    fi
    # Retrieve only completed (CD), out of memory (OOM), or timed out (TO) jobs
    # Exclude <jobid>.batch/extern/interactive
    sacct --format "JobID%20,State%13" \
      --name "$job_name" \
      -s "CD,TO,OOM" \
      -S "$start_date" \
      -E "now" \
      | grep -v "\." \
      | grep -v "JobID\|-" \
      | awk '{print $1}'
    # # Substitute newlines with commas and trim trailing comma
    # tr -s '\n' ',' | tr -d '[:space:]' | sed 's/\(.*\),/\1/'
  fi
}


# Function to list the max memory usage for each job named <job_name>
jobmem () {
  local start_date
  local hlp
  start_date="$(olddate)"
  # Help message
  hlp="\
Function to list max memory used by each job named <job_name> reported by
USC CARC's 'jobinfo', sorted from least to greatest.

Usage: jobmem <job_name>  [date]

Where date is formatted: YYYY_MM_DD
Unless date is given, starts 10 years prior to today's date (e.g., $start_date)."
  if (( $# < 1 )) || [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]]
  then
    echo "$hlp"
  else
    local job_name
    local ids
    job_name="$1"
    if (( $# == 2 ))
    then
      start_date="$2"
    fi
    mapfile -t ids < <(getjobids "$job_name" "$start_date")
    if [[ "${#ids[@]}" -ne 0 ]]
    then
      local ptn
      ptn="Max memory used"
      printf "%-10s\t%-10s\n" "JobID" "MaxMemoryUsed"
      for (( i=0; i<${#ids[@]}; i++ ))
      do
        local id
        local mem
        id="${ids[i]}"
        # Use capture group to get memory report (e.g., 1.89M)
        mem="$(jobinfo "$id" | grep "$ptn" | sed -E 's/.+\s+([0-9.A-Z]+)\s*.*/\1/g')"
        printf "%-10s\t%-10s\n" "$id" "$mem"
      done | sort -h -k2b
    fi
  fi
}


# Function to list elapsed time in seconds for each job named <job_name>
jobtime () {
  local start_date
  local hlp
  start_date="$(olddate)"
  hlp="\
Function to list elapsed walltime for each job named <job_name> reported by
USC CARC's 'jobinfo', sorted from least to greatest.

Usage: jobtime <job_name> [date]

Where date is formatted: YYYY_MM_DD
Unless date is given, starts 10 years prior to today's date (e.g., $start_date)."
  if (( $# < 1 )) || [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]]
  then
    echo "$hlp"
  else
    local job_name
    local ids
    job_name="$1"
    if (( $# == 2 ))
    then
      start_date="$2"
    fi
    mapfile -t ids < <(getjobids "$job_name" "$start_date")
    if [[ "${#ids[@]}" -ne 0 ]]
    then
      local ptn
      ptn="Elapsed walltime"
      printf "%-10s\t%-10s\n" "JobID" "ElapsedWalltime"
      for (( i=0; i<${#ids[@]}; i++))
      do
        local id
        local t
        id="${ids[i]}"
        # Use capture group to get time report (e.g., 00:00:30)
        t="$(jobinfo "$id" | grep "$ptn" | sed -E 's/.+\s+([0-9:]+)\s*/\1/g')"
        printf "%-10s\t%-10s\n" "$id" "$t"
      done | sort -k2b
    fi
  fi
}

# Function to list the max memory usage (MaxRSS) for each job for 
# a specific job name (can also calculate maximum)
jobmem2 () {
  local start_date
  local hlp
  start_date="$(olddate)"
  # Help message
  hlp="\
Function to list or find the maximum of the max memory usage (MaxRSS) for 
each job listed by Slurm 'sacct' for a specific job name over the last 10 years.

Usage: jobmem2 <option> <job_name> [date]

Where date is formatted: YYYY_MM_DD
Options:
  -m  return only the highest MaxRSS value for jobs with <job_name>
  -l  list MaxRSS values for jobs with <job_name> in human-readable
    format (e.g., KB/MB/GB)

Unless date is given, starts 10 years prior to today's date (e.g., $start_date)."
  if (( $# < 2 )) || [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]]
  then
    echo "$hlp"
  elif [[ "$1" = "-m" ]] || [[ "$1" = "-l" ]]
  then
    local job_name
    local jobs
    local cnt
    local max_m
    job_name="$2"
    if (( $# == 3 ))
    then
      start_date="$3"
    fi
    # Array of info for all jobs named <job_name>
    mapfile -t jobs < \
      <(getjobinfo "$job_name" "$start_date" | grep "batch")
    cnt="${#jobs[@]}"
    max_m=0
    for ((i=0;i<cnt;i++))
    do
      local j
      local rss
      local m
      local m_unit
      j="$(echo "${jobs[i]}" | awk '{print $1}')"
      rss="$(echo "${jobs[i]}" | awk '{print $9}')"
      # Remove unit and decimal numbers (if needed)
      m="${rss//[A-Z]/}"
      m="${m/.*/}"
      # Save unit
      m_unit="${rss//[0-9.]/}"
      if [[ "$1" = "-m" ]]
      then
        [[ $m_unit = "M" ]] && m=$(( m / 1000 ))
        if (( m > max_m ))
        then
          local max_j
          local max_m
          local max_m_unit
          max_j="$j"
          max_m="$m"
          max_m_unit="$m_unit"
        fi
      fi
      if [[ "$max_m" ]] && (( max_m != 0 )) && [[ "$max_m_unit" ]]
      then
        m="$max_m"
        m_unit="$max_m_unit"
      fi
      # Handles input in kilobytes (KB)
      local mem
      if [[ "$m_unit" = "K" ]]
      then
        if (( "$(echo -n "$m" | wc -c)" < 4 ))
        then
          mem="${m}KB"
        elif (( "$(echo -n "$m" | wc -c)" < 7 ))
        then
          mem="$(( m / 1000 ))MB"
        else
          mem="$(( m / 1000000 ))GB"
        fi
      # Handles input in megabytes (MB)
      elif [[ "$m_unit" = "M" ]]
      then
        if (( "$(echo -n "$m" | wc -c)" <= 3 ))
        then
          mem="${m}MB"
        else
          mem="$(( m / 1000 ))GB"
        fi
      # Handles input in gigabytes (GB)
      elif [[ "$m_unit" = "G" ]]
      then
        mem="${m}GB"
      else
        local err
        # Error message
        err="\
Error - unrecognized unit of memory in $rss: $m_unit (jobid: $j)

Check output of 'MaxRSS' column from command 'getjobinfo $job_name $start_date'.
This function only handes K and M unit inputs."
        echo "$err"
        break
      fi
      if [[ "$1" = "-l" ]]
      then
        printf "%s\t%s\n" "${j/.*/}" "$mem"
      fi
    done
    if [[ "$1" = "-m" ]]
    then
      printf "%s\t%s\n" "${max_j/.*/}" "$mem"
    fi
  else
    echo "Error, unrecognized option: $1"
    echo "Run jobmem2 -h/--help for help."
  fi
}


# Function to list elapsed time in seconds for each job listed by 
# Slurm 'sacct' for a specific job name
jobtime2 () {
  local start_date
  local hlp
  start_date="$(olddate)"
  hlp="\
Function to list or find the maximum of elapsed times (Elapsed) for each
job listed by Slurm 'sacct' for a specific job name over the last 10 years.

Usage: jobtime2 [option] <job_name> [date]

Where date is formatted: YYYY_MM_DD
Options:
  -m    return only greatest Elapsed time for jobs with <job_name>
  -l    list all Elapsed time values for jobs with <job_name>

Unless date is given, starts 10 years prior to today's date (e.g., $start_date)."
  if (( $# < 2 )) || [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]]
  then
    echo "$hlp"
  elif [[ "$1" = "-m" ]] || [[ "$1" = "-l" ]]
  then
    local job_name
    local jobs
    local cnt
    local max_t
    job_name="$2"
    if (( $# == 3 ))
    then
      start_date="$3"
    fi
    # Array of info for all jobs named <job_name>
    mapfile -t jobs < \
      <(getjobinfo "$job_name" "$start_date" | grep "batch")
    cnt="${#jobs[@]}"
    max_t=0
    for (( i=0; i<cnt; i++ ))
    do
      local j
      local elapsed
      local t
      # Take JobID and Elapsed columns
      j="$(echo "${jobs[i]}" | awk '{print $1}')"
      elapsed="$(echo "${jobs[i]}" | awk '{print $7}')"
      t="$(echo "$elapsed" | awk -F: '{print ($1 * 3600) + ($2 * 60) + $3}')"
      if [[ "$1" = "-l" ]]
      then
        local read_t
        (( t >= 3600 )) && read_t="($(( t / 3600 )) hours)"
        (( t < 3600 )) && read_t="($(( t / 60 )) minutes)"
        (( t < 60 )) && unset -v read_t
        printf "%s\t%s\n" "${j/.*/}" "$t seconds $read_t"
      elif [[ "$1" = "-m" ]]
      then
        (( t > max_t )) && { max_j="$j"; max_t="$t"; }
      fi
    done
    if [[ "$1" = "-m" ]]
    then
      local max_read_t
      (( max_t >= 3600 )) && max_read_t="($((max_t / 3600)) hours)"
      (( max_t < 3600 )) &&  max_read_t="($((max_t / 60)) minutes)"
      (( max_t < 60 )) && unset -v max_read_t
      printf "%s\t%s\n" "${max_j/.*/}" "$max_t seconds $max_read_t"
    fi
  else
    echo "Error, unrecognized option: $1"
    echo "Run jobtime2 -h/--help for help."
  fi
}

