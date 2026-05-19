az bicep build --file .\infrastructure\main.bicep

az deployment sub validate `
    --name azurevalidateV2 `
    --location eastus2 `
    --template-file .\infrastructure\main.bicep `
    --parameters "@.\infrastructure\main.parameters.dev.json"

az deployment sub what-if `
  --name phase3-whatif `
  --location eastus2 `
  --template-file .\infrastructure\main.bicep `
  --parameters "@.\infrastructure\main.parameters.dev.json"


az deployment sub create `
  --name deploymentTest `
  --location eastus2 `
  --template-file .\infrastructure\main.bicep `
  --parameters "@.\infrastructure\main.parameters.dev.json"


