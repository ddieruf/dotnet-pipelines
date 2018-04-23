# dotnet-pipelines/vsts-tasks

And away we go! Visual Studio Team Services is a powerful tool for managing code, a team's backlog, as well build pipelines.

## Getting Started

I have created a sample project that has all the fixin's. You can use this to provide your pipeline and all it's prerequisits.  
[dotnet core](https://github.com/ddieruf/log-message-core20)  
[dotnet framework](https://github.com/ddieruf/log-message-framework45)

Development Versions  
- VSCode: 1.12.2  
- VSTS  
- SonarQube: 6.7  
- dotnet core runtime: 2.0.3  
- xUnit: 2.3.1  
- Artillery: 1.6.0-12  
- Ubuntu: 16.04  

### Prerequisites

[visualstudio.com](http://visualstudio.com/) - Where everything gets done. 

### Installing

Once logged in to your VSTS account and you have your app's source code saved, it's now time to hook up a build definition and a release definition. The build definition is meant to create the artifact. This in turn should hands off to the release definition that runs tests and pushes to Cloud Foundry. You'll find the json for importing the definitions in the /vsts_definitions folder.

#### Pipeline Definition

The intention is to create a seperate task group that could possibly be managed by your team or another. It is seperate to your build pipeline are reuseable in many other pipelines. The /task-group folder holds the definitions for each step in the task group while the app-build.json and app-release.json assumes these task groups have been created.

#### Params Definition

There are a few places that you need to establish param values for the pipeline. Once the task groups are established, the build definition will want the location of each csproj file. And the release definiton will want a list of variables attached within the defintion.

#### Cloud Foundry manifest

You'll need two manifests, one for staging deployment and another for production deployment.

Example staging manifest:
```
---
applications:
- name: log-message
  host: logmessage-stage
  instances: 1
  memory: 512M
  disk_quota: 512M
  buildpack: https://github.com/cloudfoundry/dotnet-core-buildpack.git#v2.0.1
  stack: cflinuxfs2
  health-check-type: http
  health-check-http-endpoint: /health
```

Example production manifest:
```
---
applications:
- name: log-message
  host: logmessage-stage
  instances: 1
  memory: 512M
  disk_quota: 512M
  buildpack: https://github.com/cloudfoundry/dotnet-core-buildpack.git#v2.0.1
  stack: cflinuxfs2
  health-check-type: http
  health-check-http-endpoint: /health
```

#### Load test manifest

Declare a single load test:

```
config:
  environments:
    testing:
      phases:
        - duration: 5
          arrivalRate: 1
    qa:
      phases: #Ramp up arrival rate from 10 to 50 over 2 minutes, followed by 10 minutes at 50 arrivals per second
        - duration: 120
          arrivalRate: 10
          rampTo: 50
          name: "Warm up the application"
        - duration: 600
          arrivalRate: 50
          name: "Sustained max load"
scenarios:
  - flow:
    - get:
        url: "/"
```

#### A project

Refer to the example project linked above. There is a directory structure that is suggested to hold the different solution pieces, but the available customizations in params should let you arrange the solution otherwise.
```
Project-Name/  
  |-MySolution.sln  
  |-Ci/  
    |-artillery.yml  
    |-pipeline.yml  
    |-params.yml  
    |-cf-stage.yml  
    |-cf-prod.yml  
  |-Src/  
    |-Project-Name/  
      |-MyProject.csproj  
      |-Other-Stuff/  
  |-Test/  
    |-Project-Name-Unit-Test/  
      |-MyProject-Unit-Test.csproj  
      |-Other-Stuff/  
    |-Project-Name-Integration-Test/  
      |-MyProject-Integration-Test.csproj  
      |-Other-Stuff/  
    |-Project-Name-Smoke-Test/  
      |-MyProject-Smoke-Test.csproj  
      |-Other-Stuff/
```

### Security

Fortunatly with VSTS you have the buildin secrets capability. Use it wisely.