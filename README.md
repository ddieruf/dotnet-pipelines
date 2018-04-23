# dotnet-pipelines

Welcome! This project is aimed at dotnet developers, both core and framework, wanting to create an full CI/CD pipline that is published to cloud foundry. The idea is to provide a set of tasks (or steps) that make up the pipeline. There are some values that can be provided to the pipeline for customization, but overall your project should hold the pipeline definition and reference this repo/version for the individual steps.

## Getting Started

I have provided example pipelines for certain tools. The folder name will point you in the right direction. The 'scripts' folder is where the magic happens. I suggest referencing this repo, and not copying the entire thing. When more steps are requested or needed they will be added to this folder.

I have also created sample solutions that utilize this pipeline. I suggest using these simple apps to understand what is going on and the solution structure. Once you have the pipeline working properly, adapt to your solution.  
[dotnet core](https://github.com/ddieruf/log-message-core20)  
[dotnet framework](https://github.com/ddieruf/log-message-framework45)

Development Versions
VSCode: 1.21.1
Concourse: 3.8
Concourse Fly: 3.8.0
Artifactory OSS: 5.8.1
SonarQube: 6.7
dotnet core runtime: 2.1.4
xUnit: 2.3.1
Artillery: 1.6.0-12
Ubuntu: 16.04
Cloud Foundry cli: 6.33.1

### Design

I have chosen to rely solely on bash scripts for task execution. I had mixed feelings about doing this, but felt it provided the best solution in the long run. An alternative to this would be, in VSTS, to build out my sources to project dependencies (Artifactory, Sonar, etc etc) and then build every task individually in my release definition. Yes it's nice to have everything in the UI but you can only do what the given task has options for. And you are now totally reliant on that tool. Not good.

I have chosen to start with a blank canvas (Linux OS) and let the given task build the environment and run it's script. Versatility, portability, and shareability. All things that are my friends. This design should keep quite a few doors open to the team
- Maintainability (not tied to a certain project)
- Platform primitives (your admin simply needs to offer the ability for Linux workers)
- Pipeline task versioning (2 years after deployment when you need to build the app but have no clue what it did you are safe to simply run the pipeline)

### Installing

First, you will need to make a decision about where the pipeline scripts and task scripts live. On one hand you can reference this repo's pipeline tasks and scripts with a version number. Good side is when tasks are added you simply add a new step in your pipeline definition and maybe some new params. Bad side is you have tied your solution to this repo! If you chose to not be tied to this repo I suggest NOT cloning, instead copy the zip/tar and put everything in a local repo that you control. Then you reference that new repo in your pipeline. Do not copy this entire repo and paste it into your existing solution, it is worthly of it's own repo. That is not scalable, is generally a bad practice, and is asking for source code duplication (duplication==bad).

Note: The master branch is where I am doing development. While I [try] to never push bugs we all know how that goes. Choose a specific versioned branch for the best stability.

#### Pipeline Scripts

These scripts are used to define a given app's pipeline. In concourse each script would result in a different job. In a VSTS release definition* each script would result in a different agent phase. Notice the directories are named for the given CI/CD tool. These tasks could possibly be specific to a given application's build needs and if they needed to live with the application source, it could be justifiable.

*You can not use build definitions with this design. Because you didn't copy and paste the scripts directory in to your existing solution, your pipeline needs to reference multiple repos. Build definitions can only reference one repo.

#### Task Scripts

These scripts are referenced within the calling pipeline script. Most of these scripts use environment variables to "communicate" back to the pipeline script upon successfully completing or erroring out. The intention is for these scripts to live outside any one application's pipeline. They are self-sufficient in that they will install needed dependencies and require/check for needed environment variables. In the case of a task needing to connect to another platform (Artifactory, Sonar, etc) the script will verify access before running.

##### About Each Task
- [generate-version](https://github.com/ddieruf/dotnet-pipelines/tree/master/scripts/tasks/generate-version) - Incrament the build version
- [scan-code-quality](https://github.com/ddieruf/dotnet-pipelines/tree/master/scripts/tasks/scan-code-quality) - Using SonarQube, scan and pass/fail the code quality
- [build-and-upload](https://github.com/ddieruf/dotnet-pipelines/tree/master/scripts/tasks/build-and-upload) - Run dotnet publish on each project, archive[zip] the result and upload to Artifactory repo
- [dotnet-test](https://github.com/ddieruf/dotnet-pipelines/tree/master/scripts/tasks/dotnet-test) - Run unit|integration|smoke tests on the app. (Follow the link to learn more about how each test is defined)
- [push-to-cf](https://github.com/ddieruf/dotnet-pipelines/tree/master/scripts/tasks/push-to-cf) - Push the tested app to a given org/space in Cloud Foundry
- [load-test](https://github.com/ddieruf/dotnet-pipelines/tree/master/scripts/tasks/load-test) - With the app available via HTTP, using Artillery, run load tests

## Deployment

In the given CI/CD tool folder, you will find specifics about installing (ie if you are using concourse, look in the concourse-tasks/readme.md).

## Roadmap

Some features and additions I am working on:
- Windows workers in the pipeline
- Powershell version of all script tasks
- Additional task to do security scan using [Checkmarx](https://www.checkmarx.com/)

## Versioning

I use [SemVer](http://semver.org/) for versioning. For the versions available, see the [branches on this repository](https://github.com/ddieruf/dotnet-pipelines/branches). 

## Authors

* **David Dieruf** - *Initial work* - [ddieruf](https://github.com/ddieruf)

## License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Thank you to the [spring-cloud-pipelines](https://github.com/spring-cloud/spring-cloud-pipelines) team. They have provided a great deal of inspiration and ideas!