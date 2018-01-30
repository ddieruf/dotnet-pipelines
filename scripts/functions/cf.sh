#!/bin/bash
#
# Task Description:
#   Functions to run cloud foundry action. By adding this script as a source, the required binaries
#   will automatically be installed
#
#

######################################
# Description:
# 	Install cf cli and all it's dependencies
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: success
#   1: error
#######################################
function install(){
	apt-get update --quiet --assume-yes

  apt-get install --assume-yes --fix-broken --quiet \
		wget \
		apt-transport-https

	#Add the Cloud Foundry Foundation public key and package repository to your system
	wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
	echo "deb http://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list

	apt-get update --quiet --assume-yes
	apt-get install --assume-yes --fix-broken --quiet --allow-unauthenticated cf-cli

	return 0
}
######################################
# Description:
# 	Login to cf environment
#	Globals:
#		None
# Arguments:
#   1 - username: cf login account
#   2 - password: cf login account
#   3 - org: cf org that hold the space
#   4 - space: cf space that will old the app
#   5 - apiUrl: how to interact with cf
# Returns:
#   0: success
#   1: error
#######################################
function logInToPaas() {
	local username="${1}"
	local password="${2}"
	local org="${3}"
	local space="${4}"
	local apiUrl="${5}"

	echo "Logging in to CF to org [${org}], space [${space}]"
	"${CF_BIN}" api --skip-ssl-validation "${apiUrl}"
	ret=$("${CF_BIN}" login -u "${username}" -p "${password}" -o "${org}" -s "${space}")
	#do not echo ${ret}, becuase it has password

	#check if any errors occurred
	if [[ ${ret} =~ "FAILED" ]]; then
		echo "ERROR: cf login"
		return 1
	fi
	
	return 0
}
######################################
# Description:
# 	Deploy an app to cf. Assumptions:
#			- The current directory is the root of the app to publish
#			- The cf manifest is in the current directory, named manifest.yml
#	Globals:
#		- CF_BIN
# Arguments:
#   - appName: the name of the app to deploy
#	Global Returns:
#		- APP_ROUTE: the returned cf app route
#		- APP_URLS: the returned cf app url(s)
# Returns:
#   0: success
#   1: error
#######################################
function deployAppNoStart() {
	local appName="${1}"

	if [ ! -f "manifest.yml" ]; then
		echo "ERROR: The file manifest.yml does not exist"
		return 1
	fi

	echo "Using cf manifest:"
	cat "manifest.yml" || return 1

	echo "Deploying app"
	ret=$("${CF_BIN}" push "${appName}" --no-start)
	echo "${ret}"

	#check if any errors occurred
	if [[ ${ret} =~ "FAILED" ]]; then
		echo "ERROR: cf push"
		return 1
	fi

	export APP_ROUTE=$(grep -i "route:" <<< "${ret}")
	export APP_URLS=$(grep -i "urls:" <<< "${ret}")

	return 0
}
######################################
# Description:
# 	Remove an app from cf, assumes the correct org and space have been targeted
#	Globals:
#		- CF_BIN
# Arguments:
#   - appName: the name of the app to remove
# Returns:
#   0: success
#   1: error
#######################################
function deleteApp() {
	local appName="${1}"

	local lowerCaseAppName
	lowerCaseAppName=$(toLowerCase "${appName}")

	local APP_NAME="${lowerCaseAppName}"

	echo "Deleting application [${APP_NAME}]"
	# Delete app and route
	ret=$("${CF_BIN}" delete -f -r "${APP_NAME}")
	echo "${ret}"
	if [[ ${ret} =~ "FAILED" ]]; then
		echo "ERROR: cf delete"
		return 1
	fi


	return 0
}
######################################
# Description:
# 	Restart an app in cf, assumes the correct org and space have been targeted
#	Globals:
#		- CF_BIN
# Arguments:
#   - appName: the name of the app to restart
# Returns:
#   0: success
#   1: error
#######################################
function restartApp() {
	local appName="${1}"

	echo "Restarting app with name [${appName}]"
	ret=$("${CF_BIN}" restart "${appName}")
	echo "${ret}"
	if [[ ${ret} =~ "FAILED" ]]; then
		echo "ERROR: cf delete"
		return 1
	fi

	#check if the app successfully started
	state=$(grep -i "requested state:" <<< "${ret}")
	if [[ "${state}" =~ "started" ]]; then
		echo "ERROR: cf restart app is not started"
		return 1
	fi

	return 0
}
######################################
# Description:
# 	Deploy an app to cf (assume you are already logged in)
#	Globals:
#		None
# Arguments:
#   1 - AppName: the name to be used during cf push
# Returns:
#   0: success
#   1: error
#######################################
function deploy(){
	local appName="${1}"

	# deploy app
	deployAppNoStart "${appName}"
	if [[ $?==1 ]]; then
		echo "ERROR: deployAppNoStart"
		return 1
	fi

	restartApp "${appName}"
	if [[ $?==1 ]]; then
		echo "ERROR: restartApp"
		return 1
	fi
	
	return 0
}

#INITIALIZE THE LIBRARY
command -v cf >/dev/null 2>&1 || install
export CF_BIN="cf"
"${CF_BIN}" --version