#!/bin/bash

set -o errexit
set -o errtrace

ROOT_FOLDER="$( pwd )"
PIPELINE_RESOURCE=dotnet-pipelines
CONCOURSE_TASKS_RESOURCE="${PIPELINE_RESOURCE}/concourse-tasks"
KEYVAL_RESOURCE=keyval
VERSION_SRC_OUT_RESOURCE=src-version-out
SRC_VERSION_RESOURCE=src-version

#######################################
#       Initialize Task
#######################################
source "${ROOT_FOLDER}/${CONCOURSE_TASKS_RESOURCE}/functions/init-task.sh"

#######################################
#       Run Task
#######################################

cp -R "${ROOT_FOLDER}/${SRC_VERSION_RESOURCE}/." "${ROOT_FOLDER}/${VERSION_SRC_OUT_RESOURCE}/"

pushd "${ROOT_FOLDER}/${VERSION_SRC_OUT_RESOURCE}"
  echo "${PASSED_PIPELINE_VERSION}" > version
popd

#######################################
#       Finalize task
#######################################