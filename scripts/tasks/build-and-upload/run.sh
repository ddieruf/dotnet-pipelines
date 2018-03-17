#!/bin/bash
# 
# Required Globals:
#   APP_SRC_CSPROJ_PATH
#   PIPELINE_VERSION
#   CF_STAGE_MANIFEST_PATH
#   CF_PROD_MANIFEST_PATH
#   DOTNET_VERSION
#   ARTIFACT_LOCATION_TYPE
#
# Optional Globals:
#   APP_UNIT_TEST_CSPROJ_PATH
#   APP_INTEGRATION_TEST_CSPROJ_PATH
#   APP_SMOKE_TEST_CSPROJ_PATH
#   ARTILLERY_MANIFEST_PATH
#   DOTNET_RUNTIME_ID
#   ARTIFACTORY_HOST
#   ARTIFACTORY_TOKEN
#   ARTIFACTORY_REPO_ID
#   ARTIFACT_FOLDER_PATH
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
[[ ! -z "${APP_SRC_CSPROJ_PATH}" ]] || (echo "APP_SRC_CSPROJ_PATH is a required value" && exit 1)
[[ ! -z "${CF_STAGE_MANIFEST_PATH}" ]] || (echo "CF_STAGE_MANIFEST_PATH is a required value" && exit 1)
[[ ! -z "${CF_PROD_MANIFEST_PATH}" ]] || (echo "CF_PROD_MANIFEST_PATH is a required value" && exit 1)
[[ ! -z "${DOTNET_VERSION}" ]] || (echo "DOTNET_VERSION is a required value" && exit 1)
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

[[ -f "${APP_SRC_CSPROJ_PATH}" ]] || (echo "APP_SRC_CSPROJ_PATH path invalid [${APP_SRC_CSPROJ_PATH}]" && exit 1)
[[ -f "${CF_STAGE_MANIFEST_PATH}" ]] || (echo "CF_STAGE_MANIFEST_PATH path invalid [${CF_STAGE_MANIFEST_PATH}]" && exit 1)
[[ -f "${CF_PROD_MANIFEST_PATH}" ]] || (echo "CF_PROD_MANIFEST_PATH path invalid [${CF_PROD_MANIFEST_PATH}]" && exit 1)

if [[ ! -z "${ARTILLERY_MANIFEST_PATH}" ]]; then
  [[ -f "${ARTILLERY_MANIFEST_PATH}" ]] || (echo "ARTILLERY_MANIFEST_PATH path invalid [${ARTILLERY_MANIFEST_PATH}]" && exit 1)
fi
if [[ ! -z "${APP_UNIT_TEST_CSPROJ_PATH}" ]]; then
  [[ -f "${APP_UNIT_TEST_CSPROJ_PATH}" ]] || (echo "APP_UNIT_TEST_CSPROJ_PATH path invalid [${APP_UNIT_TEST_CSPROJ_PATH}]" && exit 1)
fi
if [[ ! -z "${APP_INTEGRATION_TEST_CSPROJ_PATH}" ]]; then
  [[ -f "${APP_INTEGRATION_TEST_CSPROJ_PATH}" ]] || (echo "APP_INTEGRATION_TEST_CSPROJ_PATH path invalid [${APP_INTEGRATION_TEST_CSPROJ_PATH}]" && exit 1)
fi
if [[ ! -z "${APP_SMOKE_TEST_CSPROJ_PATH}" ]]; then
  [[ -f "${APP_SMOKE_TEST_CSPROJ_PATH}" ]] || (echo "APP_SMOKE_TEST_CSPROJ_PATH path invalid [${APP_SMOKE_TEST_CSPROJ_PATH}]" && exit 1)
fi

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
mkdir "${THIS_FOLDER}/${PUBLISH_DIR}" || exit 1
mkdir "${THIS_FOLDER}/${OUTPUT_FOLDER}" || exit 1

#######################################
#       Begin task
#######################################
function buildAndUpload(){
  local csprojPath="${1}"
  local pipelineVersion="${2}"
  local artifactNameSuffix="${3}"
  local artifactLocationType="${4}"
  
  local artifactName="${pipelineVersion//./_}-${artifactNameSuffix}.zip"

  publishProject \
    "${THIS_FOLDER}/${PUBLISH_DIR}" \
    "${csprojPath}"
	if [[ $? -eq 1 ]]; then
		echo "ERROR: publishProject $?"
		return 1
	fi

  createAppArtifact "zip" "${THIS_FOLDER}/${PUBLISH_DIR}" "${THIS_FOLDER}/${OUTPUT_FOLDER}/${artifactName}"
	if [[ $? -eq 1 ]]; then
		echo "ERROR: createAppArtifact $?"
		return 1
	fi

  case "${artifactLocationType}" in
    "local")
      cp "${THIS_FOLDER}/${OUTPUT_FOLDER}/${artifactName}" "${ARTIFACT_FOLDER_PATH}"
      ;;
    "artifactory")
      uploadAppArtifact "${THIS_FOLDER}/${OUTPUT_FOLDER}/${artifactName}" "${ARTIFACTORY_HOST}" "${ARTIFACTORY_REPO_ID}" "${ARTIFACTORY_TOKEN}"
      if [[ $? -eq 1 ]]; then
        echo "ERROR: uploadAppArtifact"
        return 1
      fi
      ;;
    *)
      echo "Unknown artifact location type [${ARTIFACT_LOCATION_TYPE}]" && exit 1
      ;;
  esac

  export ARTIFACT_NAME="${artifactName}"

  return 0
}

set -x #echo all commands

echo "Build and upload the project src"
echo "--------------------------------------------------------"
cp "${CF_STAGE_MANIFEST_PATH}" "${THIS_FOLDER}/${PUBLISH_DIR}/cf-stage-manifest.yml" || exit 1
cp "${CF_PROD_MANIFEST_PATH}" "${THIS_FOLDER}/${PUBLISH_DIR}/cf-prod-manifest.yml" || exit 1
if [[ ! -z "${ARTILLERY_MANIFEST_PATH}" ]]; then
  cp "${ARTILLERY_MANIFEST_PATH}" "${THIS_FOLDER}/${PUBLISH_DIR}" || exit 1
fi

buildAndUpload "${APP_SRC_CSPROJ_PATH}" "${PIPELINE_VERSION}" "src" "${ARTIFACT_LOCATION_TYPE}"
if [[ $? -eq 1 ]]; then
  echo "ERROR: buildAndUpload src:\n${ret}"
  exit 1
else
  export SRC_ARTIFACT_NAME="${ARTIFACT_NAME}"
  unset ARTIFACT_NAME
  echo "Successfully created artifact ${SRC_ARTIFACT_NAME}"
fi

VAL=${APP_UNIT_TEST_CSPROJ_PATH:-} #an optional value
if [[ ! -z "${VAL}" ]]; then
  echo "Build and upload the project unit-test"
  echo "--------------------------------------------------------"
  buildAndUpload "${VAL}" "${PIPELINE_VERSION}" "unit-test" "${ARTIFACT_LOCATION_TYPE}"
  if [[ $? -eq 1 ]]; then
    echo "ERROR: buildAndUpload unit-test:\n${ret}"
    exit 1
  else
    export UNIT_TEST_ARTIFACT_NAME="${ARTIFACT_NAME}"
    unset ARTIFACT_NAME
    echo "Successfully created artifact ${UNIT_TEST_ARTIFACT_NAME}"
  fi
fi

VAL=${APP_INTEGRATION_TEST_CSPROJ_PATH:-} #an optional value
if [[ ! -z "${VAL}" ]]; then
  echo "Build and upload the project integration-test"
  echo "--------------------------------------------------------"
  buildAndUpload "${VAL}" "${PIPELINE_VERSION}" "integration-test" "${ARTIFACT_LOCATION_TYPE}"
  if [[ $? -eq 1 ]]; then
    echo "ERROR: buildAndUpload integration-test:\n${ret}"
    exit 1
  else
    export INTEGRATION_TEST_ARTIFACT_NAME="${ARTIFACT_NAME}"
    unset ARTIFACT_NAME
    echo "Successfully created artifact ${INTEGRATION_TEST_ARTIFACT_NAME}"
  fi
fi

VAL=${APP_SMOKE_TEST_CSPROJ_PATH:-} #an optional value
if [[ ! -z "${VAL}" ]]; then
  echo "Build and upload the project smoke-test"
  echo "--------------------------------------------------------"
  buildAndUpload "${VAL}" "${PIPELINE_VERSION}" "smoke-test" "${ARTIFACT_LOCATION_TYPE}"
  if [[ $? -eq 1 ]]; then
    echo "ERROR: buildAndUpload smoke-test:\n${ret}"
    exit 1
  else
    export SMOKE_TEST_ARTIFACT_NAME="${ARTIFACT_NAME}"
    unset ARTIFACT_NAME
    echo "Successfully created artifact ${SMOKE_TEST_ARTIFACT_NAME}"
  fi
fi

#######################################
#       Return result
#######################################