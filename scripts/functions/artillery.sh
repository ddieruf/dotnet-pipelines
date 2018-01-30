#!/bin/bash

######################################
# Description:
# 	Install artillery and all it's dependencies
# Globals:
#   None
# Arguments:
#   none
# Returns:
#   0: success
#   1: error
#######################################
function install(){
	apt-get update --quiet --assume-yes
  
  apt-get install --assume-yes --fix-broken --quiet \
		curl
  
  apt-get update --quiet --assume-yes

  curl -sL https://deb.nodesource.com/setup_8.x

  apt-get install --assume-yes --fix-broken --quiet \
    nodejs \
    npm
  
  ln -s /usr/bin/nodejs /usr/bin/node
  
  echo "Node version: $(node -v)"
  echo "NPM version: $(npm -v)"

  echo "Installing artillery for load tests: https://artillery.io/docs/getting-started/"
  npm install -g artillery

	return 0
}
######################################
# Description:
# 	Run an artillery test
# Globals:
#   None
# Arguments:
#   1 - AppUrl: The url to use during artillery test; note this will overwrite any URL provided in artillery manifest
#   2 - EnvironmentName: The environment is use from the artillery manifest
#		3 - ManifestPath: The absolute path to the artillery manifest
#   4 - ReportDir: The directory to temporarily store the json report
# Returns:
#   0: success
#   1: error
#######################################
function runTest(){
	local appUrl="${1}"
	local environmentName="${2}"
	local manifestPath="${3}"
  local reportDir="${4}"
  
  #The --insecure param is because Node keeps a static collection of trusted CAs and it's hit  or miss
  #  if a certain SSL is trusted. Artillery will return an error of UNABLE_TO_VERIFY_LEAF_SIGNATURE
  #  if the cert's CA is not loaded'
  artillery run \
    --quiet \
    --output "${reportDir}/artillery-report.json" \
    --insecure \
    --environment "${environmentName}" \
    --target "${appUrl}" \
    "${manifestPath}"

  cat "${reportDir}/artillery-report.json" || return 1
  #artillery report ./artillery-report

  return 0
}

#INITIALIZE THE LIBRARY - if not installed
command -v artillery >/dev/null 2>&1 || install
echo "artillery version: $(artillery -V)"