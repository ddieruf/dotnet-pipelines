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
		curl

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