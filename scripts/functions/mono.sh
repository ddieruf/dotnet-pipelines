#!/bin/bash

function install(){
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF

  echo "deb http://download.mono-project.com/repo/ubuntu xenial main" | tee /etc/apt/sources.list.d/mono-official.list

  apt-get update --quiet --assume-yes
  apt-get install --assume-yes --fix-broken --quiet --allow-unauthenticated \
    mono-complete \
    ca-certificates-mono \
    referenceassemblies-pcl \
    mono-xsp4
  
	return 0
}

command -v mono >/dev/null 2>&1 || install
echo "mono version: $(mono --version)"