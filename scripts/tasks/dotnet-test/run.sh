#!/bin/bash
#
# Task Description:
#   Retrieve artifacts and run tests on app
# 
# Required Globals:
#   TEST_ARTIFACT_NAME - the name of the artifact containing the compiled test
#   TEST_DLL_NAME - the resulting dll file name of the project
#   DOTNET_VERSION
#   ARTIFACT_LOCATION_TYPE
# 
# Optional Globals:
#   APP_URL - the url to run smoke tests against
#   ARTIFACTORY_HOST
#   ARTIFACTORY_TOKEN
#   ARTIFACTORY_REPO_ID
#   ARTIFACT_FOLDER_PATH
#

set -o errexit
set -o errtrace

export ROOT_FOLDER="$( pwd )"
export THIS_FOLDER="$( dirname "${BASH_SOURCE[0]}" )"
export TEST_EXTRACT="test-extract"

#######################################
#       Validate required globals
#######################################
[[ ! -z "${TEST_ARTIFACT_NAME}" ]] || (echo "TEST_ARTIFACT_NAME is a required value" && exit 1)
[[ ! -z "${TEST_DLL_NAME}" ]] || (echo "TEST_DLL_NAME is a required value" && exit 1)
[[ ! -z "${DOTNET_VERSION}" ]] || (echo "DOTNET_VERSION is a required value" && exit 1)
[[ ! -z "${ARTIFACT_LOCATION_TYPE}" ]] || (echo "ARTIFACT_LOCATION_TYPE is a required value" && exit 1)

case "${ARTIFACT_LOCATION_TYPE}" in
  "local")
    [[ ! -z "${ARTIFACT_FOLDER_PATH}" ]] || (echo "ARTIFACT_FOLDER_PATH is a required value" && exit 1)
    [[ -d "${ARTIFACT_FOLDER_PATH}" ]] || (echo "ARTIFACT_FOLDER_PATH path invalid [${ARTIFACT_FOLDER_PATH}]" && exit 1)
    [[ -f "${ARTIFACT_FOLDER_PATH}/${TEST_ARTIFACT_NAME}" ]] || (echo "Artifact not found [${ARTIFACT_FOLDER_PATH}/${TEST_ARTIFACT_NAME}]" && exit 1)
    ;;
  "artifactory")
    [[ ! -z "${ARTIFACTORY_HOST}" ]] || (echo "ARTIFACTORY_HOST is a required value" && exit 1)
    [[ ! -z "${ARTIFACTORY_TOKEN}" ]] || (echo "ARTIFACTORY_TOKEN is a required value" && exit 1)
    [[ ! -z "${ARTIFACTORY_REPO_ID}" ]] || (echo "ARTIFACTORY_REPO_ID is a required value" && exit 1)
    ;;
  *)
    echo "Unknown artifact location type [${ARTIFACT_LOCATION_TYPE}]" && exit 1
    ;;
esac

#######################################
#       Source needed functions
#######################################
source "${THIS_FOLDER}/../../functions/dotnet.sh" --version ${DOTNET_VERSION}
source "${THIS_FOLDER}/../../functions/mono.sh"
source "${THIS_FOLDER}/../../functions/zip.sh"

if [[ "${ARTIFACT_LOCATION_TYPE}" == "artifactory" ]]; then
  source "${THIS_FOLDER}/../../functions/artifactory.sh"
fi

#######################################
#       Setup temporary directories
#######################################
mkdir "${ROOT_FOLDER}/${TEST_EXTRACT}" || exit 1

#######################################
#       Begin task
#######################################
set -x #echo all commands

case "${ARTIFACT_LOCATION_TYPE}" in
  "local")
    #copy the zip to PWD
    cp "${ARTIFACT_FOLDER_PATH}/${TEST_ARTIFACT_NAME}" "${THIS_FOLDER}"
    ;;
  "artifactory")
    #download the zip to PWD
    downloadAppArtifact "${ARTIFACTORY_HOST}" "${ARTIFACTORY_REPO_ID}" "${ARTIFACTORY_TOKEN}" "${TEST_ARTIFACT_NAME}" "${THIS_FOLDER}"
    if [[ $? -eq 1 ]]; then
      echo "ERROR: downloadAppArtifact"
      exit 1
    fi
    ;;
  *)
    echo "Unknown artifact location type [${ARTIFACT_LOCATION_TYPE}]" && exit 1
    ;;
esac

echo "Extracting artifact"
extractAppArtifact "zip" "${THIS_FOLDER}/${TEST_ARTIFACT_NAME}" "${ROOT_FOLDER}/${TEST_EXTRACT}"
if [[ $? -eq 1 ]]; then
  echo "ERROR: extractAppArtifact"
  exit 1
fi

echo "Running test"
testProject "${ROOT_FOLDER}/${TEST_EXTRACT}/${TEST_DLL_NAME}"
if [[ $? -eq 1 ]]; then
  echo "ERROR: testProject"
  exit 1
fi

#######################################
#       Return result
#######################################