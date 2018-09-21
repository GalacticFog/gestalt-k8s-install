#!/bin/bash

############################################
# Utilities: Index
############################################

# exit_with_error - Prints passed message with [Error] prefix and exits with error code 1
# exit_on_error - If current status is non-0, prints passed message with [Error] prefix and exits with error code 1

# check_for_required_variables - Validates whether passed array each element is defined as variable

# Global variable ${logging_lvl} is used for logging level. Currently supported: debug, info, error(default)

# log_debug - If global variable ${logging_lvl} set up to debug, log passed message with [Debug] prefix
# log_info - If global variable ${logging_lvl} set at least to info, log passed message with [Info] prefix
# log_debug - If global variable ${logging_lvl} set at least to error(default), log passed message with [Error] prefix
# log_set_logging_lvl - If not defined, set ${logging_lvl}=error
# logging_lvl_validate - Validate if set loging level is suported.

# get_my_os - Set's variable ${os_current} to lowercase uname result

# file_to_generate_from='./gestalt-installer-image/scripts/utility-bash.sh'
# grep '() {' ${file_to_generate_from} | awk -F '(' '{print $1}'

#exit_with_error
#exit_on_error
#log_debug 
#log_info 
#log_error 
#log_set_logging_lvl 
#logging_lvl_validate 
#run
#check_for_required_variables
#check_for_optional_variables
#check_for_required_files
#source_required_files
#source_all_files 
#check_if_installed
#validate_json 
#convert_json_to_env_variables
#print_env_variables 
#get_my_os


############################################
# Utilities: START
############################################

### Error Handling

exit_with_error() {
  echo
  echo "[Error] $@"
  exit 1
}

exit_on_error() {
  if [ $? -ne 0 ]; then
    echo
    echo "[Error] $@"
    exit 1
  fi
}

### Logging

log_debug () {
  if [ "${logging_lvl}" == "debug" ]; then echo "[Debug] $@"; fi
}

log_info () {
  if [[ "${logging_lvl}" =~ (debug|info) ]]; then echo "[Info] $@"; fi
}

log_error () {
  if [[ "${logging_lvl}" =~ (debug|info|error) ]]; then echo && echo "[Error] $@"; fi
}

log_set_logging_lvl () {
  if [ -z ${logging_lvl} ]; then
    logging_lvl="error"
    echo "[Info] Logging level not set, defaulting to 'error'."
  fi
}

logging_lvl_validate () {
  if [[ "${logging_lvl}" =~ (debug|info|error) ]]; then
    log_debug " [Validation Passed] logging_lvl = '${logging_lvl}'"
  else
    exit_with_error " [Validation Failed] Unsupported logging level '${logging_lvl}'. Supported loggin levels are 'debug|info|error'."
  fi  
}

# Function wrapper for friendly logging and basic timing
run() {
  SECONDS=0
  echo "[Running '$@']"
  $@
  echo "['$@' finished in $SECONDS seconds]"
  echo ""
}


### Validations

check_for_required_variables() {
  retval=0

  for e in $@; do
    if [ -z "${!e}" ]; then
      echo "Required variable \"$e\" not defined."
      retval=1
    fi
  done

  if [ $retval -ne 0 ]; then
    echo "One or more required variables not defined, aborting."
    exit 1
  else
    echo "All required variables: [$@] found."
  fi
}

check_for_optional_variables() {
  for e in $@; do
    if [ -z "${!e}" ]; then
      echo "Optional variable \"$e\" not defined."
    fi
  done
}

check_for_required_files() {
  retval=0

  for e in $@; do
    log_debug "Looking up file '$e'"
    if [ ! -f "${e}" ]; then
      echo "Required file \"$e\" not present."
      retval=1
    fi
  done

  if [ $retval -ne 0 ]; then
    echo "One or more required files not present, aborting."
    exit 1
  else
    log_debug "All required files found."
  fi
}

source_required_files() {
  check_for_required_files $@

  for tmp_file in $@; do
    log_debug "Next will source: '${tmp_file}'"
    . ${tmp_file}
    exit_on_error "Unable source required file: '${tmp_file}', aborting."
    log_debug echo "Sourced file: '${tmp_file}'"
  done
}

source_all_files () {
  check_for_required_files "$@"

  for tmp_file in $@; do
    log_debug "Looking up file '${tmp_file}'"
    if [ ! -f "${tmp_file}" ]; then
      log_error "Required file \"${tmp_file}\" not present."
      retval=1
    else
      source "${tmp_file}"
      exit_on_error "Unable source required file '${curr_file}', aborting."
      log_error "[Debug] Sourced file '${curr_file}'"
    fi
  done

  if [ $retval -ne 0 ]; then
    log_error "One or more required files not present, aborting."
    exit 1
  else
    log_debug "All required files found."
  fi
}


check_if_installed() {
    for curr_tool in "$@"; do
        if ! which $curr_tool &> /dev/null; then
            exit_with_error "Unable locate $curr_tool"
        fi
    done
}

validate_json () {
  json_file_to_process=$1
  log_debug "Checking for valid JSON in '${json_file_to_process}'"
  check_for_required_files ${json_file_to_process}
  log_debug "File Content: `cat ${json_file_to_process}`"
  cat ${json_file_to_process} | jq empty
  exit_on_error "Invalid JSON document: '${json_file_to_process}', aborting"
}

### Manipulations
convert_json_to_env_variables() {
  json_file_to_process=$1
  log_debug "Will be checking and converting '${json_file_to_process}'"
  check_for_required_files ${json_file_to_process}
  
  all_var_array=$(cat ${json_file_to_process} | awk -F'"' '{print $2}' | grep -v '^$')
  for curr_variable in ${all_var_array[@]}; do
    curr_variable_name=`echo ${curr_variable} | tr '[a-z]' '[A-Z]' | sed 's|-|_|g'` #Make all upper-case and change dashes to underscores
    curr_variable_value=`jq -r '.["'${curr_variable}'"]' ${json_file_to_process}`
    log_debug "Setting: export eval ${curr_variable_name}=${curr_variable_value}"
    export eval ${curr_variable_name}=${curr_variable_value}
  done

  log_debug "[${FUNCNAME[0]}][After processing ${json_file_to_process}] All environment variables: [`env | sort`]"
}

print_env_variables () {
  echo "All environment variables:"
  env | sort
  echo ""
}

### OS

get_my_os () {
  cmd="uname | tr '[A-Z]' '[a-z]'"
  os_current=`eval ${cmd}`
  exit_on_error "Unable determine current OS: ${cmd}"
  log_debug " [${FUNCNAME[0]}] os_current = '${os_current}'"
}

############################################
# Utilities: END
############################################