#!/bin/bash
#
# Task Description:
#   A description
# 
# Required Globals:
#   ARTIFACTORY_HOST
#   ARTIFACTORY_TOKEN
#   ARTIFACTORY_REPO_ID
#   APP_SRC_CSPROJ_PATH
#   APP_UNIT_TEST_CSPROJ_PATH
#   APP_INTEGRATION_TEST_CSPROJ_PATH
#   APP_SMOKE_TEST_CSPROJ_PATH
#   PIPELINE_VERSION
#   CF_MANIFEST_PATH
#   ARTILLERY_MANIFEST_PATH
#   DOTNET_VERSION
#   DOTNET_FRAMEWORK
#   DOTNET_RUNTIME_ID
#
# Output Globals:
#   SRC_ARTIFACT_NAME
#   UNIT_TEST_ARTIFACT_NAME
#   INTEGRATION_TEST_ARTIFACT_NAME
#   SMOKE_TEST_ARTIFACT_NAME

set -o errexit
set -o errtrace

export ROOT_FOLDER="$( pwd )"
export THIS_FOLDER="$( dirname "${BASH_SOURCE[0]}" )"
export PUBLISH_DIR="publish"
export OUTPUT_FOLDER="out"

#######################################
#       Validate required globals
#######################################
[[ ! -z "${PIPELINE_VERSION}" ]] || (echo "PIPELINE_VERSION is a required value" && exit 1)
[[ ! -z "${ARTIFACTORY_HOST}" ]] || (echo "ARTIFACTORY_HOST is a required value" && exit 1)
[[ ! -z "${ARTIFACTORY_TOKEN}" ]] || (echo "ARTIFACTORY_TOKEN is a required value" && exit 1)
[[ ! -z "${ARTIFACTORY_REPO_ID}" ]] || (echo "ARTIFACTORY_REPO_ID is a required value" && exit 1)
[[ ! -z "${APP_SRC_CSPROJ_PATH}" ]] || (echo "APP_SRC_CSPROJ_PATH is a required value" && exit 1)
[[ ! -z "${APP_UNIT_TEST_CSPROJ_PATH}" ]] || (echo "APP_UNIT_TEST_CSPROJ_PATH is a required value" && exit 1)
[[ ! -z "${APP_INTEGRATION_TEST_CSPROJ_PATH}" ]] || (echo "APP_INTEGRATION_TEST_CSPROJ_PATH is a required value" && exit 1)
[[ ! -z "${APP_SMOKE_TEST_CSPROJ_PATH}" ]] || (echo "APP_SMOKE_TEST_CSPROJ_PATH is a required value" && exit 1)
[[ ! -z "${CF_MANIFEST_PATH}" ]] || (echo "CF_MANIFEST_PATH is a required value" && exit 1)
[[ ! -z "${ARTILLERY_MANIFEST_PATH}" ]] || (echo "ARTILLERY_MANIFEST_PATH is a required value" && exit 1)
[[ ! -z "${DOTNET_FRAMEWORK}" ]] || (echo "DOTNET_FRAMEWORK is a required value" && exit 1)
[[ ! -z "${DOTNET_RUNTIME_ID}" ]] || (echo "DOTNET_RUNTIME_ID is a required value" && exit 1)

[[ -f "${APP_SRC_CSPROJ_PATH}" ]] || (echo "APP_SRC_CSPROJ_PATH path invalid [${APP_SRC_CSPROJ_PATH}]" && exit 1)
[[ -f "${APP_UNIT_TEST_CSPROJ_PATH}" ]] || (echo "APP_UNIT_TEST_CSPROJ_PATH path invalid [${APP_UNIT_TEST_CSPROJ_PATH}]" && exit 1)
[[ -f "${APP_INTEGRATION_TEST_CSPROJ_PATH}" ]] || (echo "APP_INTEGRATION_TEST_CSPROJ_PATH path invalid [${APP_INTEGRATION_TEST_CSPROJ_PATH}]" && exit 1)
[[ -f "${APP_SMOKE_TEST_CSPROJ_PATH}" ]] || (echo "APP_SMOKE_TEST_CSPROJ_PATH path invalid [${APP_SMOKE_TEST_CSPROJ_PATH}]" && exit 1)
[[ -f "${CF_MANIFEST_PATH}" ]] || (echo "CF_MANIFEST_PATH path invalid [${CF_MANIFEST_PATH}]" && exit 1)
[[ -f "${ARTILLERY_MANIFEST_PATH}" ]] || (echo "ARTILLERY_MANIFEST_PATH path invalid [${ARTILLERY_MANIFEST_PATH}]" && exit 1)

#######################################
#       Install required programs
#######################################


#######################################
#       Source needed functions
#######################################
source "${THIS_FOLDER}/../../functions/dotnet.sh --version ${DOTNET_VERSION}"
source "${THIS_FOLDER}/../../functions/mono.sh"
source "${THIS_FOLDER}/../../functions/artifactory.sh"

#######################################
#       Setup temporary directories
#######################################
mkdir "${THIS_FOLDER}/${PUBLISH_DIR}" || exit 1
mkdir "${THIS_FOLDER}/${OUTPUT_FOLDER}" || exit 1

#######################################
#       Begin task
#######################################
export FrameworkPathOverride=/usr/lib/mono/4.5/

function buildAndUpload(){
  local csprojPath="${1}"
  local pipelineVersion="${2}"
  local artifactNameSuffix="${3}"

  local artifactName="${pipelineVersion//./_}-${artifactNameSuffix}.zip"

  publishProject \
    "release" \
    "${DOTNET_FRAMEWORK}" \
    "${THIS_FOLDER}/${PUBLISH_DIR}" \
    "${DOTNET_RUNTIME_ID}" \
    "${csprojPath}"

  #include files in the publish result, so it will be a part of artifact
  for i in "${fileArray[@]}"; do
    #echo "$i >-> ${THIS_FOLDER}/${PUBLISH_DIR}"
    cp "${i}" "${THIS_FOLDER}/${PUBLISH_DIR}" || return 1
  done

  createAndUploadAppArtifact \
    "zip" \
    "${THIS_FOLDER}/${PUBLISH_DIR}" \
    "${THIS_FOLDER}/${OUTPUT_FOLDER}/${artifactName}" \
    "${ARTIFACTORY_HOST}" \
    "${ARTIFACTORY_REPO_ID}" \
    "${ARTIFACTORY_TOKEN}"

  export ARTIFACT_NAME="${artifactName}"
  return 0
}

#now that the required dependencies are installed, one last test
urlstatus=$(curl -o /dev/null --silent --head --write-out '%{http_code}' "${ARTIFACTORY_HOST}" )
#allow 302 becuase of the redirect artifactory could do
if [[ ${urlstatus} -ne 200 && ${urlstatus} -ne 302 ]]; then
  echo "ERROR: Artifactory host could not be reached [${ARTIFACTORY_HOST}][${urlstatus}]"
  exit 1
fi

echo "Build and upload the project src"
echo "--------------------------------------------------------"
fileArray=("${CF_MANIFEST_PATH}" "${ARTILLERY_MANIFEST_PATH}")
buildAndUpload "${APP_SRC_CSPROJ_PATH}" "${PIPELINE_VERSION}" "src"
if [[ $? -eq 1 ]]; then
  echo "ERROR: buildAndUpload src:\n${ret}"
  exit 1
else
  export SRC_ARTIFACT_NAME="${ARTIFACT_NAME}"
  unset ARTIFACT_NAME
  echo "Successfully created artifact ${SRC_ARTIFACT_NAME}"
fi

echo "Build and upload the project unit-test"
echo "--------------------------------------------------------"
fileArray=()
buildAndUpload "${APP_UNIT_TEST_CSPROJ_PATH}" "${PIPELINE_VERSION}" "unit-test"
if [[ $? -eq 1 ]]; then
  echo "ERROR: buildAndUpload unit-test:\n${ret}"
  exit 1
else
  export UNIT_TEST_ARTIFACT_NAME="${ARTIFACT_NAME}"
  unset ARTIFACT_NAME
  echo "Successfully created artifact ${UNIT_TEST_ARTIFACT_NAME}"
fi

echo "Build and upload the project integration-test"
echo "--------------------------------------------------------"
fileArray=()
buildAndUpload "${APP_INTEGRATION_TEST_CSPROJ_PATH}" "${PIPELINE_VERSION}" "integration-test"
if [[ $? -eq 1 ]]; then
  echo "ERROR: buildAndUpload integration-test:\n${ret}"
  exit 1
else
  export INTEGRATION_TEST_ARTIFACT_NAME="${ARTIFACT_NAME}"
  unset ARTIFACT_NAME
  echo "Successfully created artifact ${INTEGRATION_TEST_ARTIFACT_NAME}"
fi

echo "Build and upload the project smoke-test"
echo "--------------------------------------------------------"
fileArray=()
buildAndUpload "${APP_SMOKE_TEST_CSPROJ_PATH}" "${PIPELINE_VERSION}" "smoke-test"
if [[ $? -eq 1 ]]; then
  echo "ERROR: buildAndUpload smoke-test:\n${ret}"
  exit 1
else
  export SMOKE_TEST_ARTIFACT_NAME="${ARTIFACT_NAME}"
  unset ARTIFACT_NAME
  echo "Successfully created artifact ${SMOKE_TEST_ARTIFACT_NAME}"
fi

#######################################
#       Return result
#######################################