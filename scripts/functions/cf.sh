#!/bin/bash
#
# Task Description:
#   Functions to run cloud foundry action. By adding this script as a source, the required binaries
#   will automatically be installed
#
#

exec 5>&1

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
	wget --no-check-certificate -qO - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
	echo "deb http://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list

	apt-get update --quiet --assume-yes
	apt-get install --assume-yes --fix-broken --quiet --allow-unauthenticated cf-cli=${version}

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
	ret=$("${CF_BIN}" login -u "${username}" -p "${password}" -o "${org}" -s "${space}"|tee >(cat - >&5))

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
function pushAppNoStart() {
	local appName="${1}"
	local manifestFileName="${2}"

	echo "Using cf manifest:"
	cat "${manifestFileName}" || return 1

	echo "Deploying app"
	ret=$("${CF_BIN}" push -f "${manifestFileName}" "${appName}" --no-start|tee >(cat - >&5))

	#check if any errors occurred
	if [[ ${ret} =~ "FAILED" ]]; then
		echo "ERROR: cf push"
		return 1
	fi

	export APP_ROUTES=$(grep -i "routes:" <<< "${ret}" | sed 's/^.*: //' | tr -d '[:space:]')
	echo "Parsed app route: ${APP_ROUTES}"
	export APP_NAME="${appName}"

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
	ret=$("${CF_BIN}" delete -f -r "${APP_NAME}"|tee >(cat - >&5))
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
	ret=$("${CF_BIN}" restart "${appName}"|tee >(cat - >&5))
	if [[ ${ret} =~ "FAILED" ]]; then
		echo "ERROR: cf restart"
		return 1
	fi

	#check if the app successfully started
	state=$(grep -i "requested state:" <<< "${ret}" | sed 's/^.*: //')
	if [[ "${state}" != *"started"* ]]; then
		echo "ERROR: cf restart app is not started"
		return 1
	fi
	
	export APP_ROUTES=$(grep -i "routes:" <<< "${ret}" | sed 's/^.*: //' | tr -d '[:space:]')
	echo "Parsed app route: ${APP_ROUTES}"
	export APP_NAME="${appName}"
	return 0
}
######################################
# Description:
# 	Deploy an app to cf (assume you are already logged-in and PWD has the manifest)
#	Globals:
#		None
# Arguments:
#   1 - EnvironmentName: decide which manifest to use
#   2 - VersionNumber: to append on the end of the app name in manifest
# Returns:
#   0: success
#   1: error
#######################################
function deploy(){
	local environmentName="${1}"
	local versionNumber="${2}"
	local appName=""
	local manifestFileName=""

	#depending on environment, get correct manifest
	case "${environmentName}" in
		"stage")
				manifestFileName="cf-stage-manifest.yml"
				;;
		"prod")
				manifestFileName="cf-prod-manifest.yml"
				;;
		*)
				echo "Unknown environment [${environmentName}]"
				return 1
				;;
	esac

	if [ ! -f "${manifestFileName}" ]; then
		echo "ERROR: The manifest file could not be found [${manifestFileName}]"
		return 1
	fi

	#parse app name from manifest
	appName=$(grep -i "name:" "${manifestFileName}" | sed 's/^.*: //' | tr -d '[:space:]')
	if [[ -z "${appName}" ]]; then
		echo "App name could not be found in manifest [${manifestFileName}]"
		return 1
	fi

	appName+="-${versionNumber}"

	# deploy app
	pushAppNoStart "${appName}" "${manifestFileName}"
	if [[ $? -eq 1 ]]; then
		echo "ERROR: pushApp"
		return 1
	fi

	restartApp "${appName}"
	if [[ $? -eq 1 ]]; then
		echo "ERROR: restartApp"
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
function stopApp() {
	local appName="${1}"

	echo "Stopping app with name [${appName}]"
	ret=$("${CF_BIN}" stop "${appName}"|tee >(cat - >&5))
	if [[ ${ret} =~ "FAILED" ]]; then
		echo "ERROR: cf restart"
		return 1
	fi

	return 0
}

version=""

while [ $# -ne 0 ]
do
	name="$1"
	case "$name" in
		-v|--version|-[Vv]ersion)
				shift
				version="$1"
				;;
	esac

	shift
done

#INITIALIZE THE LIBRARY
command -v cf >/dev/null 2>&1 || install
export CF_BIN="cf"
"${CF_BIN}" --version