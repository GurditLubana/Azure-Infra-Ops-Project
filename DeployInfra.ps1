az bicep build --file .\infra\main.bicep

az deployment sub validate `
    --name validation4 `
    --location westus2 `
    --template-file .\infra\main.bicep `
    --parameters "@.\infra\main.parameters.dev.json"

az deployment sub what-if `
  --name testingphasewhatif `
  --location westus2 `
  --template-file .\infra\main.bicep `
  --parameters "@.\infra\main.parameters.dev.json" `
  --result-format FullResourcePayloads


az deployment sub create `
  --name testingInfraDeploymentV6 `
  --location westus2 `
  --template-file .\infra\main.bicep `
  --parameters "@.\infra\main.parameters.dev.json"


