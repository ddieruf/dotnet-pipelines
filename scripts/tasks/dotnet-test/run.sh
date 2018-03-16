#!/bin/bash
#
# Task Description:
#   Retrieve artifacts from Artifactory and run tests on app
# 
# Required Globals:
#   ARTIFACTORY_HOST
#   ARTIFACTORY_TOKEN
#   ARTIFACTORY_REPO_ID
#   TEST_ARTIFACT_NAME - the name of the artifact containing the compiled test
#   TEST_DLL_NAME - the resulting dll file name of the project
#   DOTNET_VERSION
# 
# Optional Globals:
#   APP_URL - the url to run smoke tests against
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
[[ ! -z "${TEST_ARTIFACT_NAME}" ]] || (echo "TEST_ARTIFACT_NAME is a required value" && exit 1)
[[ ! -z "${TEST_DLL_NAME}" ]] || (echo "TEST_DLL_NAME is a required value" && exit 1)
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
downloadAndExtractZipArtifact "${ARTIFACTORY_HOST}" "${ARTIFACTORY_TOKEN}" "${ARTIFACTORY_REPO_ID}" "${TEST_ARTIFACT_NAME}" "${THIS_FOLDER}/${TEST_EXTRACT}"
if [[ $? -eq 1 ]]; then
  echo "ERROR: downloadAndExtractZipArtifact"
  exit 1
fi

echo "Running test"
testProject "${THIS_FOLDER}/${TEST_EXTRACT}/${TEST_DLL_NAME}"
if [[ $? -eq 1 ]]; then
  echo "ERROR: testProject"
  exit 1
fi

#######################################
#       Return result
#######################################