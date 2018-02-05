#!/bin/bash
#
# Task Description:
#   Retrieve artifacts from Artifactory and run unit tests on app
# 
# Required Globals:
#   ARTIFACTORY_HOST
#   ARTIFACTORY_TOKEN
#   ARTIFACTORY_REPO_ID
#   INTEGRATION_TEST_ARTIFACT_NAME - the name of the artifact containing the compiled test
#   INTEGRATION_TEST_DLL_NAME - the resulting dll file name of the project
#   DOTNET_VERSION
#   DOTNET_FRAMEWORK
#   DOTNET_PLATFORM
#   DOTNET_TEST_LOGGER

set -o errexit
set -o errtrace

export ROOT_FOLDER="$( pwd )"
export THIS_FOLDER="$( dirname "${BASH_SOURCE[0]}" )"
export ARTIFACT_EXTRACT="artifact-extract"
export TEST_EXTRACT="test-extract"

#######################################
#       Validate required globals
#######################################
[[ ! -z "${ARTIFACTORY_HOST}" ]] || (echo "ARTIFACTORY_HOST is a required value" && exit 1)
[[ ! -z "${ARTIFACTORY_TOKEN}" ]] || (echo "ARTIFACTORY_TOKEN is a required value" && exit 1)
[[ ! -z "${ARTIFACTORY_REPO_ID}" ]] || (echo "ARTIFACTORY_REPO_ID is a required value" && exit 1)
[[ ! -z "${INTEGRATION_TEST_ARTIFACT_NAME}" ]] || (echo "INTEGRATION_TEST_ARTIFACT_NAME is a required value" && exit 1)
[[ ! -z "${INTEGRATION_TEST_DLL_NAME}" ]] || (echo "INTEGRATION_TEST_DLL_NAME is a required value" && exit 1)
[[ ! -z "${DOTNET_VERSION}" ]] || (echo "DOTNET_VERSION is a required value" && exit 1)
[[ ! -z "${DOTNET_FRAMEWORK}" ]] || (echo "DOTNET_FRAMEWORK is a required value" && exit 1)
[[ ! -z "${DOTNET_PLATFORM}" ]] || (echo "DOTNET_PLATFORM is a required value" && exit 1)
[[ ! -z "${DOTNET_TEST_LOGGER}" ]] || (echo "DOTNET_TEST_LOGGER is a required value" && exit 1)

#######################################
#       Install required programs
#######################################

#######################################
#       Source needed functions
#######################################
source "${THIS_FOLDER}/../../functions/dotnet.sh" --version ${DOTNET_VERSION}
source "${THIS_FOLDER}/../../functions/mono.sh"
source "${THIS_FOLDER}/../../functions/artifactory.sh"

#######################################
#       Setup temporary directories
#######################################
mkdir "${THIS_FOLDER}/${ARTIFACT_EXTRACT}" || exit 1
mkdir "${THIS_FOLDER}/${TEST_EXTRACT}" || exit 1

#######################################
#       Begin task
#######################################
#now that the required dependencies are installed, one last test
urlstatus=$(curl -o /dev/null --silent --head --write-out '%{http_code}' "${ARTIFACTORY_HOST}" )
#allow 302 becuase of the redirect artifactory could do
if [[ ${urlstatus} -ne 200 && ${urlstatus} -ne 302 ]]; then
  echo "ERROR: Artifactory host could not be reached [${ARTIFACTORY_HOST}][${urlstatus}]"
  exit 1
fi

echo "Retrieving and extracting test artifact"
downloadAndExtractZipArtifact "${ARTIFACTORY_HOST}" "${ARTIFACTORY_TOKEN}" "${ARTIFACTORY_REPO_ID}" "${INTEGRATION_TEST_ARTIFACT_NAME}" "${THIS_FOLDER}/${TEST_EXTRACT}"

echo "Running unit tests"
testProject \
  "${THIS_FOLDER}/${TEST_EXTRACT}/${INTEGRATION_TEST_DLL_NAME}" \
  "${DOTNET_PLATFORM}" \
  "${DOTNET_FRAMEWORK}" \
  "${DOTNET_TEST_LOGGER}"

#######################################
#       Return result
#######################################