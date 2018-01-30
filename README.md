# dotnet-pipelines

Welcome! This project is aimed at dotnet developers wanting to create an full CI/CD pipline that published to cloud foundry. The idea is to provide a set of tasks (or steps) that make up the pipeline. There are some values that can be provided to the pipeline for customization, but overall your project should hold the pipeline definition and reference this repo & version for the individual steps.

## Getting Started

I have provided example pipelines for certain tools. The folder name will point you in the right direction. The scripts folder is where the magic happens. I suggest referencing these repo, and not copying the entire thing. When more steps are requested or needed they will be added to this folder.

### Design

I have chosen to rely solely on bash scripts for task execution. I had mixed feelings about doing this, but felt it provided the best solution in the long run. An alternative to this would be, in TFS, to build out my sources to project dependencies (Artifactory, Sonar, etc etc) and then build every task individually in my release definition. Yes it's nice to have everything in the UI but you can only do what the given task has options for. And you are now totally reliant on that tool. Not good.

I have chosen to start with a blank canvas (Linux OS) and let the given task build the environment and run it's script. Versatility, portability, and shareability. All things that are my friends. This design should keep quite a few door open to the team
- Maintainability (not tied to a certain project)
- Platform primitives (your admin simply needs to offer the ability for Linux workers)
- Pipeline Versioning (2 years after deployment when you need to build the app but have no clue what it did you are safe to simply run the pipeline)

### Installing

First, you will need to make a decision about where the pipeline scripts and task scripts live. On one hand you can reference this repo's pipeline tasks and scripts with a version number. Good side is when tasks are added you simply add a new step in your pipeline definition and maybe some new params. Bad side is you have tied your solution to this repo - ugh! If you chose to not be tied to this repo I suggest NOT cloning, instead copy the zip/tar and put everything in a local repo that you control. Then you reference that new repo in your pipeline. Do not copy this entire repo and paste it into your existing solution, it is worthly of it's own repo. That is not scalable, is generally a bad practice, and is asking for source code duplication (duplication==bad).

#### Pipeline Scripts

These scripts are used to define a given app's pipeline. In concourse each script would result in a different job. In a TFS release definition* each script would result in a different agent phase. Notice the directories are named for the given CI/CD tool. These tasks could possibly be specific to a given application's build needs and if they needed to live with the application source, it could be justifiable.

*You can not use build definitions with this design. Because you didn't copy and paste the scripts directory in to your existing solution, your pipeline needs to reference multiple repos. Build definitions can only reference one repo.

#### Task Scripts

These scripts are referenced within the calling pipeline script. Most of these scripts use environment variables to "communicate" back to the pipeline script upon successfully completing or erroring out. The intention is for these scripts to live outside any one application's pipeline. They are self-sufficient in that they will install needed dependencies and require/check for needed environment variables. In the case of a task needing to connect to another platform (Artifactory, Sonar, etc) the script will verify access before running.

## Deployment

In the given CI/CD tool folder, you will find specifics about installing (ie if you are using concourse, look in the concourse-tasks/readme.md).

## Versioning

I use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/ddieruf/dotnet-pipelines/tags). 

## Authors

* **David Dieruf** - *Initial work* - [ddieruf](https://github.com/ddieruf)

## License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Thank you to the [spring-cloud-pipelines](https://github.com/spring-cloud/spring-cloud-pipelines) team. They have provided a great deal of inspiration and ideas!



# SCRATCH PAD
the application side. This is a stand-alone VS solution that has certain prerequisites. You can find a list of those pre-req's in the "Prerequisites" area of given tool's readme (ie if you are using concourse, look in the concourse-tasks/readme.md). I have provided an example solution in my repos - [Example Project](https://github.com/ddieruf/log-message). To get thigns going and to understand the pieces your solution needs.