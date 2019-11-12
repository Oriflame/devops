# Pipelines

Yaml pipelines can be used in Azure DevOps to standardize the build, test, analyzis and deployment.

## Supported pipelines

### Nuget-Package

This pipeline is suitable for a standalone Nuget module. It will build, test and deploy to nuget repository and set the version according to gitflow strategy.

## How to use


You need to have your CI pipeline (yaml) file in your repository like follows:

```
resources:
  repositories:
    - repository: templates #reference in this pipeline
      type: github
      name: oriflame/devops

#triggers definition etc 

jobs:
- template: pipelines/nuget-package/default-ci-pipeline.yaml@templates
  parameters:
    vmImage: 'windows-2019' # sample parameter
```
