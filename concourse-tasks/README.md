# dotnet-pipelines/concourse-tasks

So you want to use Concourse, well that is awesome! There is (of course) a prerequisite of a working Concourse install. Keep reading...

## Getting Started

I have created a sample project that has all the fixin's. You can use this to provide your pipeline and all it's prerequisits.  
[dotnet core](https://github.com/ddieruf/log-message-core20)  
[dotnet framework](https://github.com/ddieruf/log-message-framework45)

Development Versions  
VSCode: 1.12.2  
Concourse: 3.8  
Concourse Fly: 3.8.0  
Artifactory OSS: 5.8.1  
SonarQube: 6.7  
dotnet core runtime: 2.0.3  
xUnit: 2.3.1  
Artillery: 1.6.0-12  
Ubuntu: 16.04  
Cloud Foundry cli: 6.33.1

### Prerequisites

[Concourse.io](http://concourse.ci/) - All development was done on a Bosh driven cluster, but you are safe to choose a different flavor.  
[Cloud Foundry](https://www.cloudfoundry.org/) - While you could modify the example piplelines to publish to another platform, why would you? CF is where it's at!  
[Artifactory](https://jfrog.com/artifactory/) - Same as CF, you could build a task to store your artifact else where but I chose Artifactory.

#### Optional tasks
[Sonarqube](https://www.sonarqube.org/) - Scan your code! You may have not even considered this a step, but I do. Don't relay on your own knowledge of best practice, let Sonarqube scan it and test it against the industrie's practices.  
[Artillery](https://artillery.io/) - Load testing can be a very particular thing. To get real results you want to run it in an exact environment/infrastructure as production. Obviously we can't produce that in this example. So the next best thing is to atleast understand how an individual instance of the app performs under load. THis can be the start of understaning how many instances of the app should be running. Artillery is the tool of choice.

### Installing

I am not going to get into install Concourse or any of the other pre-requ's. That is a whole mess of fun in itself. There are a few things needed to use this pipeline:
- Pipeline definition
- Params definition
- Cloud Foundry manifest
- Load test manifest
- A project (with tests) to build

#### Pipeline Definition

The file concourse-pipeline.yml contains an example pipeline that uses all avaiable steps. An example pipeline deployment from the root Project-Name folder, in Concourse:

```
fly -t con set-pipeline \
  --config concourse-pipeline.yml \
  --pipeline my-pipeline-name \
  --load-vars-from concourse-params.yml \
  --var "github-private-key=$(cat ./github-private-key.key)" \
  --var "artifactory-token=XXXXXX" \
  --var "sonar-login-key=XXXXXX" \
  --var "cf-stage-api-url=https://api.system.mydomain.com" \
  --var "cf-stage-username=XXXXXX" \
  --var "cf-stage-password=XXXXXX" \
  --var "cf-prod-api-url=https://api.system.mydomain.com" \
  --var "cf-prod-username=XXXXXX" \
  --var "cf-prod-password=XXXXXX" \
  --var "github-username=XXXXXX" \
  --var "github-password=XXXXXX"

```

#### Params Definition

Refer to the concouse-params.yml exmaple file. Each Paramater and it's possible value are defined in there.

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

### Security

Obviously putting passwords in a plain text yml or upon excuting set-pipeline isn't going to work in the real world. I hope that this design provides an obvious path to utilizing Vault, CredHub, or whatever your chosen method of secret store might be.

[Concourse Credential Management](https://concourse.ci/creds.html)
