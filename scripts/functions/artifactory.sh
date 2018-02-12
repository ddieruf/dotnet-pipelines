#!/bin/bash

######################################
# Description:
# 	Install all required programs and dependencies for artifactory to run
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
		curl \
		tar

	return 0
}
######################################
# Description:
# 	Given an artifact saved in Artifactory, download it.
#		THIS WILL DOWNLOAD TO THE CURRENT DIR!!!
# Globals:
#   None
# Arguments:
#		1 - ArtifactoryHost: URL to server ie: http://artifactory.domain.com:8081/artifactory
#		2 - ArtifactoryRepoName: Name of the Artifactory repo created to hold everything
#		3 - ArifactoryApiKey: Credentials to use for interacting with Artifactory host
#		4 - ArtifactFileName: The file name of the saved artifact in artifactory
# Returns:
#   0: success
#   1: error
#######################################
function downloadAppArtifact() {
	local artifactoryHost="${1}"
	local artifactoryRepoName="${2}"
	local artifactoryApiKey="${3}"
	local artifactFileName="${4}"

	testHost "${artifactoryHost}"
	if [[ $? -eq 1 ]]; then
		echo "ERROR: testHost"
		return 1
	fi
	
	local targetFolderUrl="${artifactoryHost}/${artifactoryRepoName}"

	(curl \
		-H "X-JFrog-Art-Api: ${artifactoryApiKey}" \
		-O "${targetFolderUrl}/${artifactFileName}") || (echo "Failed downloading artifact." && exit 1)

	return 0
}
######################################
# Description:
# 	Given a compressed artifact, upload it to Artifactory host
# Globals:
#   None
# Arguments:
#		1 - ArtifactPath: The absolute path (including file name) to file. ie: /root-folder/artifact/my-app.zip
#		2 - ArtifactoryHost: URL to server ie: http://artifactory.domain.com:8081/artifactory
#		3 - ArtifactoryRepoName: Name of the Artifactory repo created to hold everything
#		4 - ArtifactoryApiKey: Credentials to use for interacting with Artifactory host
# Returns:
#   0: success
#   1: error
#######################################
function uploadAppArtifact() {
	local artifactPath="${1}"
	local artifactoryHost="${2}"
	local artifactoryRepoName="${3}"
	local artifactoryAPIKey="${4}"

	testHost "${artifactoryHost}"
	if [[ $? -eq 1 ]]; then
		echo "ERROR: testHost"
		return 1
	fi

	local targetFolderUrl="${artifactoryHost}/${artifactoryRepoName}"
	echo "Validating archive to artifactory"

	if [ ! -f "${artifactPath}" ]; then
			echo "ERROR: Artifact ${artifactPath} does not exist"
			return 1
	fi

	md5Value="`md5sum "${artifactPath}"`"
	md5Value="${md5Value:0:32}"
	sha1Value="`sha1sum "${artifactPath}"`"
	sha1Value="${sha1Value:0:40}"
	fileName="`basename "${artifactPath}"`"

	#echo $md5Value $sha1Value $artifactPath

	(curl -i -X PUT \
		-H "X-Checksum-Md5: ${md5Value}" \
		-H "X-Checksum-Sha1: ${sha1Value}" \
		-H "X-JFrog-Art-Api: ${artifactoryAPIKey}" \
		-T "${artifactPath}" \
		"${targetFolderUrl}/${fileName}") || (echo "Failed uploading artifact." && exit 1)
	
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
######################################
# Description:
# 	Given an artifact saved in Artifactory, download it and extract to a temporary place
# Globals:
#   None
# Arguments:
#		1 - ArtifactoryHost: URL to server ie: http://artifactory.domain.com:8081/artifactory
#		2 - ArtifactoryRepoId: Name of the Artifactory repo created to hold everything
#		3 - ArifactoryApiKey: Credentials to use for interacting with Artifactory host
#		4 - ArtifactFileName: The file name of the saved artifact in artifactory
#		5 - ExtractToDirPath: Where to extract the downloaded artifact to
# Returns:
#   0: success
#   1: error
#######################################
function downloadAndExtractZipArtifact(){
	local artifactoryHost="${1}"
	local artifactoryRepoId="${2}"
	local artifactoryAPIKey="${3}"
	local artifactFileName="${4}"
	local extractToDirPath="${5}"
	
	testHost "${artifactoryHost}"
	if [[ $? -eq 1 ]]; then
		echo "ERROR: testHost"
		return 1
	fi
	
	#download the zip to PWD
	downloadAppArtifact "${artifactoryHost}" "${artifactoryAPIKey}" "${artifactoryRepoId}" "${artifactFileName}"
	if [[ $? -eq 1 ]]; then
		echo "ERROR: downloadAppArtifact"
		return 1
	fi

	#extract the zip
	extractAppArtifact "zip" "${artifactFileName}" "${extractToDirPath}"
	if [[ $? -eq 1 ]]; then
		echo "ERROR: extractAppArtifact"
		return 1
	fi

	return 0
}
######################################
# Description:
# 	Compress files that are a part of an given artifact and upload upload the result to Artifactory repo
# Globals:
#   None
# Arguments:
#   1 - ArtifactType: zip|tar
#		2 - AppSrcPath: The absolute path to directory holding files to compress
#		3 - ArtifactPath: The absolute path (including file name) to where the artifact will be temporarity held. ie: /root-folder/artifact/my-app.zip
#		4 - ArtifactoryHost: URL to server ie: http://artifactory.domain.com:8081/artifactory
#		5 - ArtifactoryRepoId: Name of the Artifactory repo created to hold everything
#		6 - ArifactoryApiKey: Credentials to use for interacting with Artifactory host
# Returns:
#   0: success
#   1: error
#######################################
function createAndUploadAppArtifact(){
	local artifactType="${1}"
	local appSrcPath="${2}"
	local artifactPath="${3}"
	local artifactoryHost="${4}"
	local artifactoryRepoId="${5}"
	local artifactoryAPIKey="${6}"

	testHost "${artifactoryHost}"
	if [[ $? -eq 1 ]]; then
		echo "ERROR: testHost"
		return 1
	fi

	createAppArtifact "${artifactType}" "${appSrcPath}" "${artifactPath}"
	if [[ $? -eq 1 ]]; then
		echo "ERROR: createAppArtifact $?"
		return 1
	fi

	uploadAppArtifact "${artifactPath}" "${artifactoryHost}" "${artifactoryRepoId}" "${artifactoryAPIKey}"
	if [[ $? -eq 1 ]]; then
		echo "ERROR: uploadAppArtifact"
		return 1
	fi

	return 0
}

######################################
# Description:
# 	Confirm the provided host URL is reachable
# Globals:
#   None
# Arguments:
#		1 - ArtifactoryHost: URL to server ie: http://artifactory.domain.com:8081/artifactory
# Returns:
#   0: success
#   1: error
#######################################
function testHost(){
	local artifactoryHost="${1}"

	#now that the required dependencies are installed
	urlstatus=$(curl -o /dev/null --silent --head --write-out '%{http_code}' "${artifactoryHost}" )
	#allow 302 becuase of the redirect artifactory could do
	if [[ ${urlstatus} -ne 200 && ${urlstatus} -ne 302 ]]; then
		echo "ERROR: Artifactory host could not be reached [${artifactoryHost}][${urlstatus}]"
		return 1
	fi

	return 0
}

#When this file is sourced, automatically install everything
install