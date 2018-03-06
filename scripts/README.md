# dotnet-pipelines/scripts/tasks

This is where the magic happens...

## Getting Started

The scripts area is where the work of each task can be found. Within this folder you have two subfolders:

#### /functions

This folder holds specific functions to a given technology. An example is the cf.sh file. This is a collection of functions 
used for interacting with the Cloud Foundry platform.

#### /tasks

This folder holds a subfolder for each pipeline task. Within that child folder a single run.sh script can be found. This is 
the task script to be executed. Each task script documents the assumed globals that should be established before running, as well as globals that are set during the tasks execution that will be relavant in other tasks.

## About Each Task

#### [generate-version](https://github.com/ddieruf/dotnet-pipelines/scripts/tasks/generate-version/README.md)
#### [scan-code-quality](https://github.com/ddieruf/dotnet-pipelines/scripts/tasks/scan-code-quality/README.md)
#### [build-and-upload](https://github.com/ddieruf/dotnet-pipelines/scripts/tasks/build-and-upload/README.md)
#### [unit-test](https://github.com/ddieruf/dotnet-pipelines/scripts/tasks/unit-test/README.md)
#### [integration-test](https://github.com/ddieruf/dotnet-pipelines/scripts/tasks/integration-test/README.md)
#### [push-to-cf](https://github.com/ddieruf/dotnet-pipelines/scripts/tasks/push-to-cf/README.md)
#### [smoke-test](https://github.com/ddieruf/dotnet-pipelines/scripts/tasks/smoke-test/README.md)
#### [load-test](https://github.com/ddieruf/dotnet-pipelines/scripts/tasks/load-test/README.md)