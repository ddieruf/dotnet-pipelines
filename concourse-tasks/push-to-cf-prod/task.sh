#!/bin/bash

set -o errexit
set -o errtrace

ROOT_FOLDER="$( pwd )"
PIPELINE_RESOURCE=dotnet-pipelines
TASK_SCRIPTS_RESOURCE="${PIPELINE_RESOURCE}/scripts"
CONCOURSE_TASKS_RESOURCE="${PIPELINE_RESOURCE}/concourse-tasks"
KEYVAL_RESOURCE=keyval
KEYVALOUTPUT_RESOURCE=keyvalout

#######################################
#       Initialize Task
#######################################
source "${ROOT_FOLDER}/${CONCOURSE_TASKS_RESOURCE}/functions/init-task.sh"

#######################################
#       Run Task
#######################################
#ARTIFACTORY_HOST
#ARTIFACTORY_TOKEN
#ARTIFACTORY_REPO_ID
#CF_CLI_VERSION
export PIPELINE_VERSION="${PASSED_PIPELINE_VERSION}"
export SRC_ARTIFACT_NAME="${PASSED_SRC_ARTIFACT_NAME}"
export CF_USERNAME="${CF_PROD_USERNAME}"
export CF_PASSWORD="${CF_PROD_PASSWORD}"
export CF_ORG="${CF_PROD_ORG}"
export CF_SPACE="${CF_PROD_SPACE}"
export CF_API_URL="${CF_PROD_API_URL}"
export ENVIRONMENT_NAME="prod"

source "${ROOT_FOLDER}/${TASK_SCRIPTS_RESOURCE}/tasks/push-to-cf/run.sh"

export PASSED_PROD_APP_ROUTE="http://${APP_ROUTES}"
export PASSED_PROD_APP_NAME="${APP_NAME}"

#######################################
#       Finalize task
#######################################
source "${ROOT_FOLDER}/${CONCOURSE_TASKS_RESOURCE}/functions/finish-task.sh"
