# dotnet-pipelines/scripts/tasks/push-to-cf

The push-to-cf task is used to push the app to cloud foundry.

The task has the following steps:
- validate that all values were correctly provided
- install the needed cli's cf and artifactory
- download and extract the src archive from artifactory
- login in to cloud foundry and target the desired org & space
- run cf push --no-start to push the app but not start it
- run cf start to start the app about bind the route
- export the newly created route

### Required Values
  PIPELINE_VERSION: 
	ARTIFACTORY_HOST: The URL to access artifactory
	ARTIFACTORY_TOKEN: https://www.jfrog.com/confluence/display/RTF/Access+Tokens#AccessTokens-UsingTokens
	ARTIFACTORY_REPO_ID: The identifying key of the Artifactory repo associated with the solution
	SRC_ARTIFACT_NAME: The artifact name created from running the build-and-upload task
	CF_USERNAME: To login to cf
	CF_PASSWORD: To login to cf
	CF_ORG: Targted org name in cf
	CF_SPACE: Targted space name in cf (this will error if the space doesn't exist)
	CF_API_URL: The cf platform api
	CF_CLI_VERSION: The version of cf cli to use https://github.com/cloudfoundry/cli/releases
	ENVIRONMENT_NAME: stage|prod (provide either value)

### Optional Values
	none

### Output Values
	APP_ROUTES: The route created during the task
	APP_NAME: The generated app name during the task