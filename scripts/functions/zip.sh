#!/bin/bash

######################################
# Description:
# 	Install all required programs and dependencies to create artifact
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
		zip \
		unzip \
		tar

	return 0
}
######################################
# Description:
# 	Given a directory of files, compress them into a single artifact
# Globals:
#   None
# Arguments:
#   1 - ArtifactType: zip|tar
#		2 - AppSrcPath: The absolute path to directory holding files to compress
#		3 - ArtifactPath: The absolute path (including file name) to where the artifact will be temporarity held. ie: /root-folder/artifact/my-app.zip
# Returns:
#   0: success
#   1: error
#######################################
function createAppArtifact(){
	local artifactType="${1}"
	local appSrcPath="${2}"
	local artifactPath="${3}"
	local currentDir=$( pwd )

	cd "${appSrcPath}" #drop the directory structure

	echo "Creating app artifact [${artifactPath}] in [${appSrcPath}]"
	case "$artifactType" in
    "zip")
			zip --recurse-paths "${artifactPath}" "."
		;;
    "tar")
			tar -zcf "${artifactPath}" "."
		;;
    *)
			echo "Unknown artifact type"
			return 1
		;;
  esac

	cd "${currentDir}"

	return 0
}
######################################
# Description:
# 	Extract a compressed artifact
# Globals:
#   None
# Arguments:
#   1 - ArtifactType: zip|tar
#		2 - ArtifactPath: The absolute path to the artifact file
#		3 - DestinationPath: The absolute path of where to extract artifact
# Returns:
#   0: success
#   1: error
#######################################
function extractAppArtifact(){
	local artifactType="${1}"
	local artifactPath="${2}"
	local destinationPath="${3}"
	
	echo "Using app artifact [${artifactPath}] at [${destinationPath}]"

	case "$artifactType" in
    "zip")
			unzip "${artifactPath}" -d "${destinationPath}"
		;;
    "tar")
			tar -xzf "${artifactPath}" -C "${destinationPath}"
		;;
    *)
			echo "Unknown artifact type"
			return 1
		;;
  esac

	return 0
}

#When this file is sourced, automatically install everything
install