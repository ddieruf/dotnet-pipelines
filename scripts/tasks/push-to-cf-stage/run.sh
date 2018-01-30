#!/bin/bash
#
# Task Description:
#   Gien an app artifact saved in artifactory, retrieve it, extract it, and push to cf
# 
# Required Globals:
#   APP_NAME - 
#   PIPELINE_VERSION - 
#   ARTIFACTORY_HOST
#   ARTIFACTORY_TOKEN
#   ARTIFACTORY_REPO_ID
#   SRC_ARTIFACT_NAME
#   CF_USERNAME
#   CF_PASSWORD
#   CF_ORG
#   CF_SPACE
#   CF_API_URL
#
# Output Globals:
#   APP_ROUTE - 
#   APP_URLS - 

set -o errexit
set -o errtrace

export ROOT_FOLDER="$( pwd )"
export THIS_FOLDER="$( dirname "${BASH_SOURCE[0]}" )"
export ARTIFACT_EXTRACT="artifact-extract"

#######################################
#       Validate required globals
#######################################
[[ ! -z "${APP_NAME}" ]] || (echo "APP_NAME is a required value" && exit 1)
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

#######################################
#       Install required programs
#######################################

#######################################
#       Source needed functions
#######################################
source "${THIS_FOLDER}/../../functions/cf.sh"
source "${THIS_FOLDER}/../../functions/artifactory.sh"

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

appName="${APP_NAME}-${PIPELINE_VERSION}"

echo "Retrieving and extracting artifact"
downloadAndExtractZipArtifact "${ARTIFACTORY_HOST}" "${ARTIFACTORY_REPO_ID}" "${ARTIFACTORY_TOKEN}" "${SRC_ARTIFACT_NAME}" "${THIS_FOLDER}/${ARTIFACT_EXTRACT}"

echo "Logging into cloud foundry"
logInToPaas \
  "${CF_USERNAME}" \
  "${CF_PASSWORD}" \
  "${CF_ORG}" \
  "${CF_SPACE}" \
  "${CF_API_URL}"
if [[ $?==1 ]]; then
  echo "ERROR: logInToPaas"
  exit 1
fi

echo "Pushing app to cloud foundry"
cd "${THIS_FOLDER}/${ARTIFACT_EXTRACT}" || exit

deploy "${appName}"
if [[ $?==1 ]]; then
  echo "ERROR: deploy"
  exit 1
fi

cd "${ROOT_FOLDER}" || exit

#######################################
#       Return result
#######################################