#!/bin/bash

set -o errexit
set -o errtrace

ROOT_FOLDER="${AGENT_RELEASEDIRECTORY}"
TASK_SCRIPTS_RESOURCE="task-scripts"

#######################################
#       Initialize Task
#######################################

#######################################
#       Run Task
#######################################
#ARTIFACTORY_HOST
#ARTIFACTORY_TOKEN
#ARTIFACTORY_REPO_ID
export PIPELINE_VERSION="${PIPELINE_VERSION}"
export SRC_ARTIFACT_NAME="${SRC_ARTIFACT_NAME}"
export APP_NAME="${CF_PROD_APP_NAME}"
export CF_USERNAME="${CF_PROD_USERNAME}"
export CF_PASSWORD="${CF_PROD_PASSWORD}"
export CF_ORG="${CF_PROD_ORG}"
export CF_SPACE="${CF_PROD_SPACE}"
export CF_API_URL="${CF_PROD_API_URL}"

source "${ROOT_FOLDER}/${TASK_SCRIPTS_RESOURCE}/tasks/push-to-cf-prod/run.sh"

export PROD_APP_ROUTE="${APP_ROUTE}"
export PROD_APP_URLS="${APP_URLS}"

#######################################
#       Finalize task
#######################################
