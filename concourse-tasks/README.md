# dotnet-pipelines/concourse-tasks

So you want to use Concourse, well that is awesome! There is (of course) a prerequisite of a working Concourse install. Keep reading...

## Getting Started

I have created a sample project that has all the fixin's. You can use this to provide your pipeline and a;; it's prerequisits.
[Example Project](https://github.com/ddieruf/log-message)

Development Versions:
VSCode
Concourse
Concourse Fly
Artifactory
SonarQube
dotnet core runtime: 2.0.0
Artillery
Ubuntu: 16.04

### Prerequisites

[Concourse.io](http://concourse.ci/) - All development was done on a Bosh driven cluster, but you are safe to choose a different flavor.
[Cloud Foundry](https://www.cloudfoundry.org/) - While you could modify the example piplelines to publish to another platform, why would you? CF is where it's at!
[Artifactory](https://jfrog.com/artifactory/) - Same as CF, you could build a task to store your artifact else where but I chose Artifactory.
[Sonarqube](https://www.sonarqube.org/) - Scan your code! You may have not even considered this a step but I do. Don't relay on your own knowledge of best practice, let Sonarqube scan it and test it against the industrie's practices.
[Artillery](https://artillery.io/) - Load testing can be a very particular thing. To get real results you want to run it in an exact environment/infrastructure as production. Obviously we can't produce that in this example. So the next best thing is to atleast understand how an individual instance of the app performs under load. THis can be the start of understaning how many instances of the app should be running. Artillery is the tool of choice.

### Installing

I am not going to get into install Concourse or any of the other pre-requ's. That is a whole mess of fun in itself. There are a few things needed to use this pipeline:
- Pipeline definition
- Params definition
- Cloud Foundry manifest
- Load test manifest
- A project (with tests) to build

#### Pipeline Definition

#### Params Definition

#### Cloud Foundry manifest

#### Load test manifest

#### A project
Refer to the example project linked above. There is a directory structure that is suggested to hold the different solution pieces, but the available customizations in params should let you arrange the solution otherwise.

Project-Name/
  - MySolution.sln
  Ci/
    - artillery.yml
    - pipeline.yml
    - params.yml
    - manifest.yml
  Src/
    Project-Name/
      - MyProject.csproj
      Other-Stuff/
  Test/
    Project-Name-Unit-Test/
      - MyProject-Unit-Test.csproj
      Other-Stuff/
    Project-Name-Integration-Test/
      - MyProject-Integration-Test.csproj
      Other-Stuff/
    Project-Name-Smoke-Test/
      - MyProject-Smoke-Test.csproj
      Other-Stuff/

### Security

Obviously putting passwords in a plain text yml isn't going to work in the real world. I hope that this design provides an obvious path to utilizing Vault, or CredHub, or whatever your chosen method of password security might be.

[Concourse Credential Management](https://concourse.ci/creds.html)

## Deployment

An example pipeline deployment from the root Project-Name folder, in Concourse:

```
fly -t env set-pipeline \
  --pipeline Project-Name \
  --config Ci/pipeline.yml \
  --load-vars-from Ci/params.yml
```