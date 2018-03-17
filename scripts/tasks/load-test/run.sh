#!/bin/bash
#
# Task Description:
#   Retrieve artifacts and run unit tests on app
# 
# Required Globals:
#   APP_URL
#   ARTILLERY_ENVIRONMENT
#   SRC_ARTIFACT_NAME
#   ARTIFACT_LOCATION_TYPE
# 
# Optional Globals:
#   ARTIFACTORY_HOST
#   ARTIFACTORY_TOKEN
#   ARTIFACTORY_REPO_ID
#   ARTIFACT_FOLDER_PATH
#

set -o errexit
set -o errtrace

export ROOT_FOLDER="$( pwd )"
export THIS_FOLDER="$( dirname "${BASH_SOURCE[0]}" )"
export ARTIFACT_EXTRACT="artifact-extract"

#######################################
#       Validate required globals
#######################################
[[ ! -z "${APP_URL}" ]] || (echo "APP_URL is a required value" && exit 1)
[[ ! -z "${ARTILLERY_ENVIRONMENT}" ]] || (echo "ARTILLERY_ENVIRONMENT is a required value" && exit 1)
[[ ! -z "${SRC_ARTIFACT_NAME}" ]] || (echo "SRC_ARTIFACT_NAME is a required value" && exit 1)
[[ ! -z "${ARTIFACT_LOCATION_TYPE}" ]] || (echo "ARTIFACT_LOCATION_TYPE is a required value" && exit 1)

case "${ARTIFACT_LOCATION_TYPE}" in
  "local")
    [[ ! -z "${ARTIFACT_FOLDER_PATH}" ]] || (echo "ARTIFACT_FOLDER_PATH is a required value" && exit 1)
    [[ -f "${ARTIFACT_FOLDER_PATH}" ]] || (echo "ARTIFACT_FOLDER_PATH path invalid [${ARTIFACT_FOLDER_PATH}]" && exit 1)
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
source "${THIS_FOLDER}/../../functions/artillery.sh"
source "${THIS_FOLDER}/../../functions/zip.sh"

if [[ "${ARTIFACT_LOCATION_TYPE}" == "artifactory" ]]; then
  source "${THIS_FOLDER}/../../functions/artifactory.sh"
fi

#######################################
#       Setup temporary directories
#######################################
mkdir "${ROOT_FOLDER}/${ARTIFACT_EXTRACT}" || exit 1

#######################################
#       Begin task
#######################################
set -x #echo all commands

case "${ARTIFACT_LOCATION_TYPE}" in
  "local")
    #copy the zip to PWD
    cp "${ARTIFACT_FOLDER_PATH}/${SRC_ARTIFACT_NAME}" "${ROOT_FOLDER}"
    ;;
  "artifactory")
    #download the zip to PWD
    downloadAppArtifact "${ARTIFACTORY_HOST}" "${ARTIFACTORY_TOKEN}" "${ARTIFACTORY_REPO_ID}" "${SRC_ARTIFACT_NAME}"
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
extractAppArtifact "zip" "${ROOT_FOLDER}/${SRC_ARTIFACT_NAME}" "${ROOT_FOLDER}/${ARTIFACT_EXTRACT}"
if [[ $? -eq 1 ]]; then
  echo "ERROR: extractAppArtifact"
  exit 1
fi

if [ ! -f "${ROOT_FOLDER}/${ARTIFACT_EXTRACT}/artillery.yml" ]; then
  echo "ERROR: Artillery manifest doesn't exist [${ROOT_FOLDER}/${ARTIFACT_EXTRACT}/artillery.yml]"
  exit 1
fi

echo "Running artillery load tests on ${APP_URL} ..."
runTest \
  "${APP_URL}" \
  "${ARTILLERY_ENVIRONMENT}" \
  "${ROOT_FOLDER}/${ARTIFACT_EXTRACT}/artillery.yml" \
  "${ROOT_FOLDER}"
if [[ $? -eq 1 ]]; then
  echo "ERROR: runTest"
  exit 1
fi

#######################################
#       Return result
#######################################