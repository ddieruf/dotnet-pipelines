#!/bin/bash

set -o errexit
set -o errtrace

ls

ROOT_FOLDER="${SYSTEM_DEFAULTWORKINGDIRECTORY}"
ARTIFACT_ROOT="${SYSTEM_ARTIFACTSDIRECTORY}"
PIPELINE_RESOURCE="dotnet-pipelines"
TASK_SCRIPTS_RESOURCE="${PIPELINE_RESOURCE}/scripts"
SRC_AND_TEST_RESOURCE="Test-Pipelines"


git clone "${BUILD_SOURCESDIRECTORY}" "${AGENT_WORKFOLDER}"
pushd "${AGENT_WORKFOLDER}"
  git config --local user.email "my@email.com"
  git config --local user.name "My Name"

  touch version
  echo "123asd" > version

  git add version
  git commit -m "Commit this file"
popd

ls -l "${AGENT_WORKFOLDER}"