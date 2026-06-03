az bicep build --file .\infra\main.bicep

az deployment sub validate `
    --name monitoringValidation3 `
    --location westus2 `
    --template-file .\infra\main.bicep `
    --parameters "@.\infra\main.parameters.dev.json"

az deployment sub what-if `
  --name testingphasewhatif2 `
  --location westus2 `
  --template-file .\infra\main.bicep `
  --parameters "@.\infra\main.parameters.dev.json" `
  --result-format FullResourcePayloads


az deployment sub create `
  --name testingInfraDeploymentV7 `
  --location westus2 `
  --template-file .\infra\main.bicep `
  --parameters "@.\infra\main.parameters.dev.json"


