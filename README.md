# Phase 3 IaC Deployment Notes

These are my personal notes for deploying the Phase 3 foundation of the Azure Infrastructure Operations project.

The goal of this phase is to deploy the basic Azure foundation using Bicep:

- Resource groups
- Virtual network
- Subnets
- Network security groups
- Subnet-to-NSG associations

This file is only for my own reference. It is not the final project README.

---

## 1. Check if Azure CLI is installed

Open the VS Code terminal and run:

```powershell
az --version
```

If Azure CLI is installed, it will show the installed version.

If the terminal says that `az` is not recognized, install Azure CLI by running:

```powershell
winget install -e --id Microsoft.AzureCLI
```

Another option is to use Azure Cloud Shell from the Azure Portal, but for this project I am running the commands from my local machine.

---

## 2. Check if Bicep is available

After Azure CLI is working, check the Bicep version:

```powershell
az bicep version
```

If Bicep is not installed, install it with:

```powershell
az bicep install
```

If Bicep is already installed but outdated, upgrade it with:

```powershell
az bicep upgrade
```

---

## 3. Build the Bicep file locally

Before talking to Azure, first check if the Bicep file can build locally:

```powershell
az bicep build --file .\infra\main.bicep
```

This checks the Bicep syntax and module references. It does not deploy anything to Azure.

If this step fails, fix the Bicep errors first before moving forward.

---

## 4. Run the Bicep linter

Next, run the linter:

```powershell
az bicep lint --file .\infra\main.bicep
```

This checks for common Bicep issues and best-practice warnings.

Warnings are not always blockers, but errors should be fixed before deployment.

---

## 5. Sign in to Azure

Once the local checks pass, sign in to Azure:

```powershell
az login
```

This opens the browser and lets me sign in to my Azure account.

After login, Azure CLI can deploy resources to my Azure subscription.

---

## 6. Check the active subscription

After signing in, check which subscription is currently active:

```powershell
az account show --output table
```

If I have more than one subscription, I should list them:

```powershell
az account list --output table
```

Then I can select the correct subscription with:

```powershell
az account set --subscription "SUBSCRIPTION-NAME-OR-ID"
```

This is important because I do not want to deploy resources into the wrong subscription.

---

## 7. Validate the deployment with Azure

After confirming the correct subscription, validate the deployment:

```powershell
az deployment sub validate --name aiol-phase3-validate --location eastus2 --template-file .\infra\main.bicep --parameters "@.\infra\main.parameters.dev.json"
```

This sends the deployment to Azure Resource Manager for validation.

It does not create resources.

If there are errors, I need to fix them before moving forward.

If the validation succeeds, I should see JSON output in the terminal.

---

## 8. Run what-if

After validation succeeds, run what-if:

```powershell
az deployment sub what-if --name aiol-phase3-whatif --location eastus2 --template-file .\infra\main.bicep --parameters "@.\infra\main.parameters.dev.json"
```

What-if shows what Azure will create, modify, or delete before I actually deploy.

This is a safety step.

If the output only shows the expected resources, I can continue.

If it shows something unexpected, I should stop and investigate.

---

## 9. Deploy the Phase 3 foundation

After build, lint, validate, and what-if all look good, deploy the resources:

```powershell
az deployment sub create --name aiol-phase3-foundation --location eastus2 --template-file .\infra\main.bicep --parameters "@.\infra\main.parameters.dev.json"
```

This command actually creates the Azure resources.

For this project, the deployment is subscription-scope because the Bicep file creates resource groups.

---

## 10. Verify in Azure Portal

After deployment succeeds, check the Azure Portal.

Expected resources:

- `rg-aiol-network-dev-cc-001`
- `rg-aiol-compute-dev-cc-001`
- `rg-aiol-ops-dev-cc-001`
- `vnet-aiol-dev-cc-001`
- `snet-mgmt-dev-cc-001`
- `snet-workload-dev-cc-001`
- `snet-private-dev-cc-001`
- `nsg-mgmt-dev-cc-001`
- `nsg-workload-dev-cc-001`
- `nsg-private-dev-cc-001`

Also verify that the subnets are associated with the correct NSGs.

---

## 11. Important notes

The parameter file does not connect to the Bicep file by itself.

It is connected during deployment when I pass this part in the command:

```powershell
--parameters "@.\infra\main.parameters.dev.json"
```

The Bicep file defines the infrastructure structure.

The parameter file provides the values.

The Azure CLI deployment command connects both files and sends the deployment to Azure.

---

## 12. Cost note

In Phase 3, I only deployed networking and resource organization resources.

There are no VMs, disks, public IPs, backup vaults, or Log Analytics workspaces yet.

So this phase should not create meaningful cost.

Still, I should check Azure Cost Management regularly.
