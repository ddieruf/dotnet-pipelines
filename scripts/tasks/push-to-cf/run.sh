#!/bin/bash
#
# Task Description:
#   Gien an app artifact saved in artifactory, retrieve it, extract it, and push to cf
# 
# Required Globals:
#   PIPELINE_VERSION
#   ARTIFACTORY_HOST
#   ARTIFACTORY_TOKEN
#   ARTIFACTORY_REPO_ID
#   SRC_ARTIFACT_NAME
#   CF_USERNAME
#   CF_PASSWORD
#   CF_ORG
#   CF_SPACE
#   CF_API_URL
#   CF_CLI_VERSION
#   ENVIRONMENT_NAME - stage|prod
#
# Output Globals:
#   APP_ROUTES
#   APP_NAME

set -o errexit
set -o errtrace

export ROOT_FOLDER="$( pwd )"
export THIS_FOLDER="$( dirname "${BASH_SOURCE[0]}" )"
export TEST_EXTRACT="test-extract"

#######################################
#       Validate required globals
#######################################
[[ ! -z "${CF_USERNAME}" ]] || (echo "CF_USERNAME is a required value" && exit 1)
[[ ! -z "${CF_PASSWORD}" ]] || (echo "CF_PASSWORD is a required value" && exit 1)
[[ ! -z "${CF_ORG}" ]] || (echo "CF_ORG is a required value" && exit 1)
[[ ! -z "${CF_SPACE}" ]] || (echo "CF_SPACE is a required value" && exit 1)
[[ ! -z "${CF_API_URL}" ]] || (echo "CF_API_URL is a required value" && exit 1)
[[ ! -z "${PIPELINE_VERSION}" ]] || (echo "PIPELINE_VERSION is a required value" && exit 1)
[[ ! -z "${ARTIFACTORY_HOST}" ]] || (echo "ARTIFACTORY_HOST is a required value" && exit 1)
[[ ! -z "${ARTIFACTORY_TOKEN}" ]] || (echo "ARTIFACTORY_TOKEN is a required value" && exit 1)
[[ ! -z "${ARTIFACTORY_REPO_ID}" ]] || (echo "ARTIFACTORY_REPO_ID is a required value" && exit 1)
[[ ! -z "${SRC_ARTIFACT_NAME}" ]] || (echo "SRC_ARTIFACT_NAME is a required value" && exit 1)
[[ ! -z "${CF_CLI_VERSION}" ]] || (echo "CF_CLI_VERSION is a required value" && exit 1)
[[ ! -z "${ENVIRONMENT_NAME}" ]] || (echo "ENVIRONMENT_NAME is a required value" && exit 1)

#######################################
#       Source needed functions
#######################################
source "${THIS_FOLDER}/../../functions/artifactory.sh"
source "${THIS_FOLDER}/../../functions/cf.sh" --version ${CF_CLI_VERSION}

#######################################
#       Setup temporary directories
#######################################
mkdir "${THIS_FOLDER}/${TEST_EXTRACT}" || exit 1

#######################################
#       Begin task
#######################################
echo "Retrieving and extracting src artifact"
downloadAndExtractZipArtifact "${ARTIFACTORY_HOST}" "${ARTIFACTORY_TOKEN}" "${ARTIFACTORY_REPO_ID}" "${SRC_ARTIFACT_NAME}" "${THIS_FOLDER}/${TEST_EXTRACT}"
if [[ $? -eq 1 ]]; then
  echo "ERROR: downloadAndExtractZipArtifact"
  exit 1
fi

echo "Logging into cloud foundry"
logInToPaas \
  "${CF_USERNAME}" \
  "${CF_PASSWORD}" \
  "${CF_ORG}" \
  "${CF_SPACE}" \
  "${CF_API_URL}"
if [[ $? -eq 1 ]]; then
  echo "ERROR: logInToPaas"
  exit 1
fi

echo "Pushing app to cloud foundry"
cd "${THIS_FOLDER}/${TEST_EXTRACT}" || exit

deploy "${ENVIRONMENT_NAME}" "${PIPELINE_VERSION}"
if [[ $? -eq 1 ]]; then
  echo "ERROR: deploy"
  exit 1
fi

cd "${ROOT_FOLDER}" || exit

#######################################
#       Return result
#######################################