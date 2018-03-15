# dotnet-pipelines/scripts/tasks/load-test

The load-test task uses the [artillery](https://artillery.io/) framework to run configured load tests and prints the results. The tests are provided in the artillery manifest yml. Note that the test output will be in the pipeline logs as JSON. You can use this to run the artillery report function for a presentable html report.

The task has the following steps:
- validate that all values were correctly provided and file/folder locations exist
- install the needed cli's artillery and artifactory
- download and extract the src archive from artifactory, to get the artillery manifest
- run artillery test(s), feeding in the manifest, the manifests environment to use, and the app's staging route

Think about how this test is run! It may not provide real numbers for your needs. It is being run off a pipeline worker who's network may not reflect reality. It is assumed your your cf environment for staging has parity with your production cf environment. If not, then you are not giving the app a chance to perform. Also how many instances of the app are you running? If only 1(one) instance then your load test is a reflection of what the app itself can do. If you have 3(three) instances running then you are testing how the app performs on the platform.

### Required Values
	APP_URL: 
	ARTILLERY_ENVIRONMENT: 
	ARTIFACTORY_HOST: The URL to access artifactory
	ARTIFACTORY_TOKEN: https://www.jfrog.com/confluence/display/RTF/Access+Tokens#AccessTokens-UsingTokens
	ARTIFACTORY_REPO_ID: The identifying key of the Artifactory repo associated with the solution
	SRC_ARTIFACT_NAME: 

### Optional Values
	none

### Output Values
	none