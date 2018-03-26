#!/bin/bash

set -o errexit
set -o errtrace


#git clone "${BUILD_SOURCESDIRECTORY}" "${AGENT_WORKFOLDER}/src-and-test"
pushd "${BUILD_SOURCESDIRECTORY}"
  git config --local user.email "my@email.com"
  git config --local user.name "My Name"

  touch version
  echo "123asd" > version

  git add version
  git commit -m "Commit this file"
popd

ls -l "${BUILD_SOURCESDIRECTORY}"