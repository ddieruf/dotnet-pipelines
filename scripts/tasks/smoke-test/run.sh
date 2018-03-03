#!/bin/bash
#
# Task Description:
#   Retrieve artifacts from Artifactory and run unit tests on app
# 
# Required Globals:
#   ARTIFACTORY_HOST
#   ARTIFACTORY_TOKEN
#   ARTIFACTORY_REPO_ID
#   SMOKE_TEST_ARTIFACT_NAME - the name of the artifact containing the compiled test
#   SMOKE_TEST_DLL_NAME - the resulting dll file name of the project
#   APP_URL - the url to run smoke tests against
#   DOTNET_FRAMEWORK
#   DOTNET_PLATFORM
#   DOTNET_TEST_LOGGER
#   DOTNET_VERSION
#

set -o errexit
set -o errtrace

export ROOT_FOLDER="$( pwd )"
export THIS_FOLDER="$( dirname "${BASH_SOURCE[0]}" )"
export TEST_EXTRACT="test-extract"

#######################################
#       Validate required globals
#######################################
[[ ! -z "${ARTIFACTORY_HOST}" ]] || (echo "ARTIFACTORY_HOST is a required value" && exit 1)
[[ ! -z "${ARTIFACTORY_TOKEN}" ]] || (echo "ARTIFACTORY_TOKEN is a required value" && exit 1)
[[ ! -z "${ARTIFACTORY_REPO_ID}" ]] || (echo "ARTIFACTORY_REPO_ID is a required value" && exit 1)
[[ ! -z "${SMOKE_TEST_ARTIFACT_NAME}" ]] || (echo "SMOKE_TEST_ARTIFACT_NAME is a required value" && exit 1)
[[ ! -z "${SMOKE_TEST_DLL_NAME}" ]] || (echo "SMOKE_TEST_DLL_NAME is a required value" && exit 1)
[[ ! -z "${APP_URL}" ]] || (echo "APP_URL is a required value" && exit 1)
[[ ! -z "${DOTNET_FRAMEWORK}" ]] || (echo "DOTNET_FRAMEWORK is a required value" && exit 1)
[[ ! -z "${DOTNET_PLATFORM}" ]] || (echo "DOTNET_PLATFORM is a required value" && exit 1)
[[ ! -z "${DOTNET_VERSION}" ]] || (echo "DOTNET_VERSION is a required value" && exit 1)

#######################################
#       Source needed functions
#######################################
source "${THIS_FOLDER}/../../functions/dotnet.sh" --version ${DOTNET_VERSION}
source "${THIS_FOLDER}/../../functions/mono.sh"
source "${THIS_FOLDER}/../../functions/artifactory.sh"

#######################################
#       Setup temporary directories
#######################################
mkdir "${THIS_FOLDER}/${TEST_EXTRACT}" || exit 1

#######################################
#       Begin task
#######################################
set -x #echo all commands
echo "Retrieving and extracting test artifact"
downloadAndExtractZipArtifact "${ARTIFACTORY_HOST}" "${ARTIFACTORY_TOKEN}" "${ARTIFACTORY_REPO_ID}" "${SMOKE_TEST_ARTIFACT_NAME}" "${THIS_FOLDER}/${TEST_EXTRACT}"
if [[ $? -eq 1 ]]; then
  echo "ERROR: downloadAndExtractZipArtifact"
  exit 1
fi

echo "Running smoke tests"
testProject \
  "${THIS_FOLDER}/${TEST_EXTRACT}/${SMOKE_TEST_DLL_NAME}" \
  "${DOTNET_PLATFORM}" \
  "${DOTNET_FRAMEWORK}" \
  "${DOTNET_TEST_LOGGER}"
if [[ $? -eq 1 ]]; then
  echo "ERROR: testProject"
  exit 1
fi

#######################################
#       Return result
#######################################