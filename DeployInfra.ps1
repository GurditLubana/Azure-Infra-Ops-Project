az bicep build --file .\infra\main.bicep

az deployment sub validate `
    --name azurevalidateV3 `
    --location westus2 `
    --template-file .\infra\main.bicep `
    --parameters "@.\infra\main.parameters.dev.json"

az deployment sub what-if `
  --name azphase4-whatif `
  --location westus2  `
  --template-file .\infra\main.bicep `
  --parameters "@.\infra\main.parameters.dev.json"


az deployment sub create `
  --name infraDeploymentV3 `
  --location westus2 `
  --template-file .\infra\main.bicep `
  --parameters "@.\infra\main.parameters.dev.json"


