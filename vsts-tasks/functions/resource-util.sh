#!/bin/bash

# Reads all key-value pairs in keyval.properties input file and exports them as env vars
function exportKeyValProperties() {
	local keyvalDirPath="${1}"
	props="${keyvalDirPath}/keyval.properties"
	echo "Props are in [${props}]"
	if [ -f "${props}" ]
	then
	  #echo "Reading passed key values"
	  while IFS= read -r var
	  do
	    if [ ! -z "${var}" ]
	    then
	      echo "Adding: ${var}"
	      export "$var"
	    fi
	  done < "${props}"
	fi
}

# Writes all env vars that begin with PASSED_ to the OUTPUT variable, so values are passed between jobs & phases
function assoc2json() {
    declare -n v=$1
    printf '%s\0' "${!v[@]}" "${v[@]}" |
    jq -Rs 'split("\u0000") | . as $v | (length / 2) as $n | reduce range($n) as $idx ({}; .[$v[$idx]]=$v[$idx+$n])'
}
function passKeyValProperties() {
	declare -A dict=()

	while IFS='=' read -r name value ; do
		if [[ "${name}" == 'PASSED_'* ]]; then
			#echo "Adding: ${name}=${value}"
			dict[${name}]="${value}"
		fi
	done < <(env)
	#local ret=$(assoc2json ${dict})
	local ret=$( IFS=$'\n'; echo "${dict[*]}" )
	echo "##vso[task.setvariable variable=JSON;isSecret=false;isOutput=true;]${ret}"
}