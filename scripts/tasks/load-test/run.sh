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

urlstatus=$(curl -o /dev/null --silent --head --write-out '%{http_code}' "${APP_URL}" )
if [[ ${urlstatus} -ne 200 ]]; then
  echo "ERROR: App url could not be reached [${APP_URL}][${urlstatus}]"
  exit 1
fi

#######################################
#       Install required programs
#######################################


#######################################
#       Source needed functions
#######################################
source "${THIS_FOLDER}/../../functions/artifactory.sh"
source "${THIS_FOLDER}/../../functions/artillery.sh"

#######################################
#       Setup temporary directories
#######################################
mkdir "${THIS_FOLDER}/${ARTIFACT_EXTRACT}" || exit 1

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