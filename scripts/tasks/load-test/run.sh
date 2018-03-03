#!/bin/bash
#
# Task Description:
#   Retrieve artifacts from Artifactory and run unit tests on app
# 
# Required Globals:
#   APP_URL
#   ARTILLERY_ENVIRONMENT
#   ARTIFACTORY_HOST
#   ARTIFACTORY_TOKEN
#   ARTIFACTORY_REPO_ID
#   SRC_ARTIFACT_NAME

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
[[ ! -z "${ARTIFACTORY_HOST}" ]] || (echo "ARTIFACTORY_HOST is a required value" && exit 1)
[[ ! -z "${ARTIFACTORY_TOKEN}" ]] || (echo "ARTIFACTORY_TOKEN is a required value" && exit 1)
[[ ! -z "${ARTIFACTORY_REPO_ID}" ]] || (echo "ARTIFACTORY_REPO_ID is a required value" && exit 1)
[[ ! -z "${SRC_ARTIFACT_NAME}" ]] || (echo "SRC_ARTIFACT_NAME is a required value" && exit 1)

#######################################
#       Source needed functions
#######################################
source "${THIS_FOLDER}/../../functions/artillery.sh"
source "${THIS_FOLDER}/../../functions/artifactory.sh"

#######################################
#       Setup temporary directories
#######################################
mkdir "${THIS_FOLDER}/${ARTIFACT_EXTRACT}" || exit 1

#######################################
#       Begin task
#######################################
set -x #echo all commands
echo "Retrieving and extracting src artifact"
downloadAndExtractZipArtifact "${ARTIFACTORY_HOST}" "${ARTIFACTORY_TOKEN}" "${ARTIFACTORY_REPO_ID}" "${SRC_ARTIFACT_NAME}" "${THIS_FOLDER}/${ARTIFACT_EXTRACT}"

if [ ! -f "${THIS_FOLDER}/${ARTIFACT_EXTRACT}/artillery.yml" ]; then
  echo "ERROR: Artillery manifest doesn't exist [${THIS_FOLDER}/${ARTIFACT_EXTRACT}/artillery.yml]"
  exit 1
fi

echo "Running artillery load tests on ${APP_URL} ..."
runTest \
  "${APP_URL}" \
  "${ARTILLERY_ENVIRONMENT}" \
  "${THIS_FOLDER}/${ARTIFACT_EXTRACT}/artillery.yml" \
  "${THIS_FOLDER}"

#######################################
#       Return result
#######################################