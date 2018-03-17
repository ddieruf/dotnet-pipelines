# dotnet-pipelines/scripts/tasks/push-to-cf

The push-to-cf task is used to push the app to cloud foundry.

The task has the following steps:
- validate that all values were correctly provided
- install the needed cli's
- retrieve the src artifact
- extract the artifact
- login in to cloud foundry and target the desired org & space
- run cf push --no-start to push the app but not start it
- run cf start to start the app about bind the route
- export the newly created route

### Required Values
  PIPELINE_VERSION: 
	SRC_ARTIFACT_NAME: The artifact name created from running the build-and-upload task
	CF_USERNAME: To login to cf
	CF_PASSWORD: To login to cf
	CF_ORG: Targted org name in cf
	CF_SPACE: Targted space name in cf (this will error if the space doesn't exist)
	CF_API_URL: The cf platform api
	CF_CLI_VERSION: The version of cf cli to use https://github.com/cloudfoundry/cli/releases
	ENVIRONMENT_NAME: Which environment to push, supported values are ```stage``` or ```prod```
	ARTIFACT_LOCATION_TYPE: Where to save the artifacts, supported values are ```local``` or ```artifactory```

### Optional Values
	ARTIFACTORY_HOST: The URL to access artifactory. Required if ```ARTIFACT_LOCATION_TYPE==artifactory```
	ARTIFACTORY_TOKEN: https://www.jfrog.com/confluence/display/RTF/Access+Tokens#AccessTokens-UsingTokens Required if ```ARTIFACT_LOCATION_TYPE==artifactory```
	ARTIFACTORY_REPO_ID: The identifying key of the Artifactory repo associated with the solution. Required if ```ARTIFACT_LOCATION_TYPE==artifactory```
	ARTIFACT_FOLDER_PATH: Where to save the newly created artifact. Required if ```ARTIFACT_LOCATION_TYPE==local```

### Output Values
	APP_ROUTES: The route created during the task
	APP_NAME: The generated app name during the task