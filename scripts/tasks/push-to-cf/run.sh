#!/bin/bash
#
# Task Description:
#   Gien an app artifact saved in artifactory, retrieve it, extract it, and push to cf
# 
# Required Globals:
#   PIPELINE_VERSION
#   SRC_ARTIFACT_NAME
#   CF_USERNAME
#   CF_PASSWORD
#   CF_ORG
#   CF_SPACE
#   CF_API_URL
#   CF_CLI_VERSION
#   ENVIRONMENT_NAME - stage|prod
#   ARTIFACT_LOCATION_TYPE - local|artifactory
#
# Output Globals:
#   APP_ROUTES
#   APP_NAME
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
[[ ! -z "${CF_USERNAME}" ]] || (echo "CF_USERNAME is a required value" && exit 1)
[[ ! -z "${CF_PASSWORD}" ]] || (echo "CF_PASSWORD is a required value" && exit 1)
[[ ! -z "${CF_ORG}" ]] || (echo "CF_ORG is a required value" && exit 1)
[[ ! -z "${CF_SPACE}" ]] || (echo "CF_SPACE is a required value" && exit 1)
[[ ! -z "${CF_API_URL}" ]] || (echo "CF_API_URL is a required value" && exit 1)
[[ ! -z "${PIPELINE_VERSION}" ]] || (echo "PIPELINE_VERSION is a required value" && exit 1)
[[ ! -z "${SRC_ARTIFACT_NAME}" ]] || (echo "SRC_ARTIFACT_NAME is a required value" && exit 1)
[[ ! -z "${CF_CLI_VERSION}" ]] || (echo "CF_CLI_VERSION is a required value" && exit 1)
[[ ! -z "${ENVIRONMENT_NAME}" ]] || (echo "ENVIRONMENT_NAME is a required value" && exit 1)
[[ ! -z "${ARTIFACT_LOCATION_TYPE}" ]] || (echo "ARTIFACT_LOCATION_TYPE is a required value" && exit 1)

case "${ARTIFACT_LOCATION_TYPE}" in
  "local")
    [[ ! -z "${ARTIFACT_FOLDER_PATH}" ]] || (echo "ARTIFACT_FOLDER_PATH is a required value" && exit 1)
    [[ -d "${ARTIFACT_FOLDER_PATH}" ]] || (echo "ARTIFACT_FOLDER_PATH path invalid [${ARTIFACT_FOLDER_PATH}]" && exit 1)
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
source "${THIS_FOLDER}/../../functions/cf.sh" --version ${CF_CLI_VERSION}
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
    cp "${ARTIFACT_FOLDER_PATH}/${SRC_ARTIFACT_NAME}" "${THIS_FOLDER}"
    ;;
  "artifactory")
    #download the zip to PWD
    downloadAppArtifact "${ARTIFACTORY_HOST}" "${ARTIFACTORY_REPO_ID}" "${ARTIFACTORY_TOKEN}" "${SRC_ARTIFACT_NAME}"
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
pushd "${ROOT_FOLDER}/${TEST_EXTRACT}"
  deploy "${ENVIRONMENT_NAME}" "${PIPELINE_VERSION}"
  if [[ $? -eq 1 ]]; then
    echo "ERROR: deploy"
    exit 1
  fi
popd

#######################################
#       Return result
#######################################