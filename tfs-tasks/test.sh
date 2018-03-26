#!/bin/bash

set -o errexit
set -o errtrace

ls

ROOT_FOLDER="${SYSTEM_DEFAULTWORKINGDIRECTORY}"
ARTIFACT_ROOT="${SYSTEM_ARTIFACTSDIRECTORY}"
PIPELINE_RESOURCE="dotnet-pipelines"
TASK_SCRIPTS_RESOURCE="${PIPELINE_RESOURCE}/scripts"
SRC_AND_TEST_RESOURCE="Test-Pipelines"


git clone "${ARTIFACT_ROOT}/${SRC_AND_TEST_RESOURCE}" "${ARTIFACT_ROOT}/updated-version"
pushd "${ARTIFACT_ROOT}/updated-version"
  git config --local user.email "my@emai.com"
  git config --local user.name "My Name"

  touch version
  echo "123asd" > version

  git add version
  git commit -m "Commit this file"
popd

ls -l "${ARTIFACT_ROOT}/updated-version"