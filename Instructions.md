You’re in a good spot. Your folder structure is already better than most first projects. Now we need to turn it into a clean, resume-worthy infrastructure project instead of a random lab.

# What we are building in simple words

You are building a **mini company-style Azure infrastructure environment**.

Not an app. Not a website. Not a tutorial copy.

You are building a small cloud environment that shows:

* “I know how to organize Azure resources.”
* “I know how to build networking with subnets and NSGs.”
* “I know how to deploy infrastructure using Bicep.”
* “I know how to think about security.”
* “I know how to add monitoring and alerts.”
* “I know how to automate cloud admin work using PowerShell.”
* “I know how to use GitHub Actions for CI/CD.”

This is the kind of project that fits **Cloud Infrastructure Engineer / Azure Administrator / Cloud Operations** roles.

Microsoft’s own Bicep documentation says modules help organize deployments and improve readability by separating complex deployment details into separate files. That is exactly why we are using modules instead of one giant file. ([Microsoft Learn][1])

# First: your current folder structure

Your current structure:

```text
AZURE-INFRA-OPS-PROJECT/
│
├── .github/workflows/
├── diagrams/
├── Infrastructure/
│   ├── main.bicep
│   ├── main.parameters.dev.json
│   └── Modules/
│       ├── compute.bicep
│       ├── network.bicep
│       ├── nsg.bicep
│       ├── rbac.bicep
│       └── resourceGrp.bicep
│
├── screenshots/
├── Scripts/
│   ├── Find-RiskyNsgRules.ps1
│   ├── Get-AzureInfraHealth.ps1
│   └── Start-Stop-VMs.ps1
│
├── testFolder/
└── README.md
```

This is a good start.

## Changes I suggest

Rename these folders to lowercase:

```text
Infrastructure  -> infra
Modules         -> modules
Scripts         -> scripts
```

Why? GitHub Actions runs on Linux by default, and Linux paths are case-sensitive. Lowercase folder names reduce annoying path mistakes later.

Rename:

```text
resourceGrp.bicep -> resourceGroups.bicep
```

Because it creates multiple resource groups, so the name should be plural.

Delete:

```text
testFolder
```

Do not leave random folders in a public GitHub repo. It looks messy.

Add these files:

```text
.gitignore
bicepconfig.json
docs/
```

Your improved structure should become:

```text
azure-infra-ops-project/
│
├── .github/
│   └── workflows/
│       ├── bicep-validate.yml        <-- later
│       └── bicep-deploy-dev.yml      <-- later
│
├── diagrams/
│
├── docs/
│   ├── architecture.md
│   ├── deployment-guide.md
│   ├── cost-control.md
│   └── troubleshooting.md
│
├── infra/
│   ├── main.bicep
│   ├── main.parameters.dev.json
│   └── modules/
│       ├── resourceGroups.bicep
│       ├── network.bicep
│       ├── nsg.bicep
│       ├── compute.bicep
│       ├── monitoring.bicep
│       ├── rbac.bicep
│       └── backup.bicep
│
├── scripts/
│   ├── Find-RiskyNsgRules.ps1
│   ├── Get-AzureInfraHealth.ps1
│   └── Start-Stop-VMs.ps1
│
├── screenshots/
├── .gitignore
├── bicepconfig.json
└── README.md
```

You do **not** need to write all files today. But this is the final structure I want you moving toward.

# Very important: cost control first

Before deploying anything, set a budget alert.

Since you’re using a student/free account, treat the subscription like real money. Microsoft says Azure for Students gives eligible students **$100 credit**, no credit card required, plus selected free services, but the offer is for current full-time students. Since you graduated, your existing student subscription may still exist, but don’t assume it will renew. Check your Azure portal before deploying. ([Microsoft Azure][2])

Create a budget in Azure Cost Management before you deploy VMs. Microsoft’s Cost Management docs explain that budgets can be created at subscription or resource group scope and can send alerts when cost thresholds are reached. ([Microsoft Learn][3])

Use this budget:

```text
Budget name: budget-azure-infra-ops-lab
Amount: $20 CAD or $25 CAD
Alert 1: 50%
Alert 2: 80%
Alert 3: 100%
Email: your email
```

And remember this: when you stop a VM, it must show **Stopped (deallocated)** to stop compute billing. If it only says **Stopped**, you may still be billed for allocated compute. Microsoft’s VM pricing page and VM state docs both explain this distinction. ([Microsoft Learn][4])

# Location to use

Use:

```text
canadacentral
```

That is the best region for you because you are in Canada and it keeps the project regionally realistic.

Fallback:

```text
canadaeast
```

Microsoft says free services can be created in any region where they are available, but quota and availability can vary by subscription. So do not panic if one VM size is unavailable in Canada Central; use Canada East or choose another B-series size. ([Microsoft Learn][5])

# The exact project scope

The full project will have 6 phases.

## Phase 3: Foundation

This is where you are now.

You will build:

```text
Resource groups
VNet
Subnets
NSGs
Tags
```

No VM yet. No monitoring yet. No GitHub Actions yet.

## Phase 4: Compute

You will add:

```text
1 small Linux VM
optional Windows VM later
NIC
temporary public IP only if needed
secure NSG rules
```

## Phase 5: Monitoring

You will add:

```text
Log Analytics Workspace
Azure Monitor alert rules
Action group
Activity log alert for NSG changes
```

## Phase 6: RBAC

You will add:

```text
Azure RBAC role assignments
Reader / Operator / Admin model
```

You do **not** need Entra ID P2 for this. Microsoft Entra ID Free is included with Azure billing accounts and helps manage subscriptions, and Azure RBAC is used to control access to Azure resources through role assignments. ([Microsoft Learn][6])

Avoid P2-only features like:

```text
Privileged Identity Management
Access Reviews
Identity Protection risk-based automation
```

Those are not needed for this project.

## Phase 7: PowerShell automation

You will build:

```text
VM health report
NSG risk scanner
VM start/stop script
```

## Phase 8: CI/CD

You will add GitHub Actions:

```text
validate Bicep
run what-if
manual deploy to dev
```

Microsoft has official guidance for deploying Bicep with GitHub Actions, and GitHub Actions can authenticate to Azure using OpenID Connect instead of storing long-lived secrets. ([Microsoft Learn][7])

# Resources I want you to build

## Resource groups

Create these three:

```text
rg-aiol-network-dev-cc-001
rg-aiol-compute-dev-cc-001
rg-aiol-ops-dev-cc-001
```

Meaning:

```text
aiol = Azure Infrastructure Operations Lab
dev = development environment
cc = Canada Central
001 = first instance
```

Why separate resource groups?

Because real cloud environments separate resources by function:

* networking resources
* compute resources
* operations/monitoring resources

This also helps later with RBAC.

## Tags for every resource

Every resource should have these tags:

```text
Project: AzureInfraOpsLab
Environment: Dev
Owner: Gurdit
ManagedBy: Bicep
CostCenter: Learning
Purpose: CloudInfraPortfolio
```

Why tags matter:

* cost tracking
* governance
* cleanup
* professionalism

This is small but important. Many beginners ignore tags.

# VNet and subnet design

Use this VNet:

```text
VNet name: vnet-aiol-dev-cc-001
Address space: 10.20.0.0/16
Resource group: rg-aiol-network-dev-cc-001
Location: canadacentral
```

Why `10.20.0.0/16`?

Because `10.0.0.0/16` is very common. Using `10.20.0.0/16` looks more intentional and avoids future overlap if you ever connect this lab to other networks.

## Subnets

Create these:

```text
snet-mgmt-dev-cc-001
Address range: 10.20.1.0/24

snet-workload-dev-cc-001
Address range: 10.20.2.0/24

snet-private-dev-cc-001
Address range: 10.20.3.0/24
```

What each subnet means:

## `snet-mgmt-dev-cc-001`

This is for management resources.

Later you can place jumpbox/admin VMs here.

## `snet-workload-dev-cc-001`

This is where normal workload VMs go.

Your Linux VM should go here.

## `snet-private-dev-cc-001`

This is reserved for future private endpoints.

You may not use it immediately, but having it shows planning.

# NSG design

Create these NSGs:

```text
nsg-mgmt-dev-cc-001
nsg-workload-dev-cc-001
nsg-private-dev-cc-001
```

Attach them like this:

```text
nsg-mgmt-dev-cc-001      -> snet-mgmt-dev-cc-001
nsg-workload-dev-cc-001  -> snet-workload-dev-cc-001
nsg-private-dev-cc-001   -> snet-private-dev-cc-001
```

## For Phase 3, keep NSG rules simple

Do not create too many rules yet.

Your goal right now is:

```text
No open RDP from internet
No open SSH from internet
No wide-open inbound rules
Allow default VNet communication
```

Azure already includes default NSG rules. You do not need to manually create a “deny all inbound” rule because Azure NSGs already include default deny inbound behavior.

Later, when you create a VM, add one allow rule:

```text
Allow SSH from your public IP only
Port: 22
Source: your current public IP
Destination: workload subnet
```

For Windows later:

```text
Allow RDP from your public IP only
Port: 3389
Source: your current public IP
Destination: management subnet
```

Do **not** allow this:

```text
Source: 0.0.0.0/0
Port: 22
Port: 3389
```

That would weaken the project.

# What each Bicep file should do

## `main.bicep`

This is the boss file.

It should not contain all resource definitions.

It should:

* define high-level parameters
* call modules
* pass values to modules
* control deployment order
* output important values like VNet name, subnet IDs, resource group names

Think of `main.bicep` like the project manager.

It says:

```text
Create resource groups.
Then create network resources inside the network resource group.
Then later create compute resources inside the compute resource group.
Then later create monitoring resources inside the ops resource group.
```

Important detail: because you are creating resource groups, your `main.bicep` should be a **subscription-scope deployment**.

That means the first deployment is not deployed into an existing resource group. It is deployed at the subscription level because it creates the resource groups.

## `main.parameters.dev.json`

This is the dev environment configuration.

It should contain values like:

```text
location
project prefix
environment name
resource group names
VNet address space
subnet address ranges
your public IP address
admin username later
```

The Bicep files should contain structure and logic. The parameters file should contain environment-specific values.

Example idea:

```text
location = canadacentral
environment = dev
projectPrefix = aiol
vnetAddressSpace = 10.20.0.0/16
```

Do not put secrets in this file.

Never commit:

```text
passwords
client secrets
private keys
```

## `resourceGroups.bicep`

This creates your three resource groups:

```text
rg-aiol-network-dev-cc-001
rg-aiol-compute-dev-cc-001
rg-aiol-ops-dev-cc-001
```

It should apply your standard tags to all three.

It should output the resource group names so other modules can use them.

This file belongs at subscription scope because resource groups exist at subscription level.

## `network.bicep`

This creates:

```text
VNet
subnets
subnet-to-NSG associations
```

It should receive:

```text
location
vnet name
address space
subnet names
subnet ranges
NSG IDs from nsg.bicep
tags
```

Why subnet-to-NSG association should probably live here:

Because subnet association is part of network design. The NSG itself can be created separately, but attaching it to a subnet is a network responsibility.

## `nsg.bicep`

This creates:

```text
management NSG
workload NSG
private NSG
basic security rules
```

For now, the rules should be minimal.

Later, when compute exists, this file will include:

```text
Allow SSH from your IP only
Allow RDP from your IP only
```

It should output the NSG resource IDs so `network.bicep` can attach them to subnets.

## `compute.bicep`

Do not build this yet.

Later, this file will create:

```text
Linux VM
NIC
optional public IP
optional Windows VM
OS disk settings
VM extensions
```

For the first VM, I recommend:

```text
VM name: vm-aiol-linux-dev-cc-001
OS: Ubuntu 22.04 LTS
Size: Standard_B1s
Authentication: SSH key
Subnet: snet-workload-dev-cc-001
Disk: Standard SSD LRS or Standard HDD LRS
```

Why Linux first?

It is usually lighter and cheaper than Windows. It lets you test networking, monitoring, SSH, and automation without wasting budget.

Optional Windows VM later:

```text
VM name: vm-aiol-win-dev-cc-001
OS: Windows Server 2022
Size: Standard_B1s or Standard_B2s
Subnet: snet-mgmt-dev-cc-001
```

If Windows B1s is too slow, use B2s briefly, take screenshots, then deallocate or delete it. The goal is not to run a permanent server.

## `monitoring.bicep`

Add this file, but do not build it yet.

Later it will create:

```text
Log Analytics Workspace
Action Group
Metric alert for high CPU
Activity log alert for NSG changes
```

Why this matters:

Cloud infrastructure roles are not only about creating resources. They are about operating and monitoring resources.

## `rbac.bicep`

Build this later.

This file will create Azure RBAC role assignments.

You can create Entra ID security groups manually in the portal first:

```text
AZ-AIOL-Readers
AZ-AIOL-Operators
AZ-AIOL-Admins
```

Then pass their object IDs into Bicep.

Role assignments:

```text
AZ-AIOL-Readers   -> Reader
AZ-AIOL-Operators -> Virtual Machine Contributor
AZ-AIOL-Admins    -> Contributor
```

You do not need Entra ID P2 for basic groups and Azure RBAC role assignments. Azure RBAC controls access to Azure resources using role assignments, and Microsoft’s RBAC Bicep guidance says role assignments can grant access to users, groups, service principals, or managed identities. ([Microsoft Learn][8])

## `backup.bicep`

Add later.

This will create:

```text
Recovery Services Vault
Backup policy
VM backup assignment
```

But do not start backup yet. Backup can add cost. We will only test it briefly.

# What each PowerShell script should do

Do not write these yet. Keep placeholders for now.

## `Find-RiskyNsgRules.ps1`

Purpose:

Scan all NSGs in your lab and find dangerous rules.

It should detect:

```text
SSH open to internet
RDP open to internet
Any inbound rule from 0.0.0.0/0
Any inbound rule from *
Any rule allowing all ports
Any rule allowing all protocols
```

Output should be:

```text
console summary
CSV report
Markdown report
```

Example final output idea:

```text
NSG Name              Risk Type              Rule Name
nsg-workload-dev      SSH open to internet   Allow-SSH-Any
nsg-mgmt-dev          RDP open to internet   Allow-RDP-Any
```

Why this is valuable:

It shows you can automate security checks using PowerShell. This is very relevant to cloud ops.

## `Get-AzureInfraHealth.ps1`

Purpose:

Generate a health report for your lab.

It should check:

```text
resource groups exist
VNet exists
subnets exist
NSGs attached
VM power state
public IP attached yes/no
Log Analytics exists
alerts configured yes/no
backup configured yes/no
```

Output should be:

```text
infra-health-report.csv
infra-health-report.md
```

Example final report sections:

```text
Resource Summary
Network Summary
VM Summary
Security Findings
Monitoring Status
Cost-Control Notes
```

Why this is strong:

It connects your IT support troubleshooting mindset with cloud infrastructure operations.

## `Start-Stop-VMs.ps1`

Purpose:

Start, stop, and check status of lab VMs.

It should support:

```text
Start
Stop
Status
```

Important: when stopping VMs, it must deallocate them, not just shut them down. Otherwise you can still be billed for compute. ([Microsoft Learn][4])

Use tags to find lab VMs:

```text
Project = AzureInfraOpsLab
Environment = Dev
```

Why this is good:

It proves you understand cost control and cloud operations.

# What to do next: your exact next steps

Do not jump to VMs yet.

Your next task is **Phase 3 only**.

## Step 1: Clean the repo names

Rename:

```text
Infrastructure -> infra
Modules -> modules
Scripts -> scripts
resourceGrp.bicep -> resourceGroups.bicep
```

Delete:

```text
testFolder
```

Add:

```text
bicepconfig.json
.gitignore
docs/
```

Your `.gitignore` should block:

```text
*.env
*.secret
*.key
*.pem
*.pfx
*.publishsettings
infra/*.json.backup
reports/
```

You can also ignore generated report files later.

## Step 2: Decide your naming standard

Use this naming pattern:

```text
<resource-type>-<project>-<workload>-<environment>-<region>-<instance>
```

For this project:

```text
project = aiol
environment = dev
region = cc
instance = 001
```

Examples:

```text
rg-aiol-network-dev-cc-001
vnet-aiol-dev-cc-001
snet-workload-dev-cc-001
nsg-workload-dev-cc-001
```

Write this naming standard in your README.

## Step 3: Fill `main.parameters.dev.json`

Add only non-secret values.

Include:

```text
location
project name
environment
tags
resource group names
VNet name
VNet address space
subnet names
subnet prefixes
NSG names
your public IP placeholder
```

Do not include admin passwords or secrets.

## Step 4: Build `resourceGroups.bicep`

This file should create the three resource groups.

Expected output after deployment:

```text
rg-aiol-network-dev-cc-001
rg-aiol-compute-dev-cc-001
rg-aiol-ops-dev-cc-001
```

Check in Azure Portal:

```text
Portal -> Resource groups -> search aiol
```

You should see all three.

## Step 5: Build `nsg.bicep`

This file should create the three NSGs.

Expected output:

```text
nsg-mgmt-dev-cc-001
nsg-workload-dev-cc-001
nsg-private-dev-cc-001
```

At this stage, the NSGs can have minimal rules.

Do not add public RDP/SSH yet.

## Step 6: Build `network.bicep`

This file should create:

```text
vnet-aiol-dev-cc-001
snet-mgmt-dev-cc-001
snet-workload-dev-cc-001
snet-private-dev-cc-001
```

It should attach:

```text
management subnet -> management NSG
workload subnet -> workload NSG
private subnet -> private NSG
```

Expected result:

In Azure Portal:

```text
Virtual networks -> vnet-aiol-dev-cc-001 -> Subnets
```

You should see:

```text
snet-mgmt-dev-cc-001       attached to nsg-mgmt-dev-cc-001
snet-workload-dev-cc-001   attached to nsg-workload-dev-cc-001
snet-private-dev-cc-001    attached to nsg-private-dev-cc-001
```

## Step 7: Connect the modules in `main.bicep`

Your `main.bicep` should:

1. create resource groups
2. deploy NSGs into the network resource group
3. deploy VNet/subnets into the network resource group
4. pass NSG IDs into the network module
5. output VNet name and subnet IDs

The big concept:

```text
main.bicep controls the deployment.
modules create the actual resources.
```

## Step 8: Validate locally

Before deploying:

Run Bicep build/validation locally.

You want to catch:

```text
wrong module paths
wrong API versions
missing parameters
typos
scope mistakes
```

Then run `what-if` before actual deployment. Microsoft says Bicep what-if previews the changes that would happen before deployment, which is exactly the kind of safe deployment habit you want to show. ([Microsoft Learn][9])

## Step 9: Deploy Phase 3

Because you are creating resource groups, this is a subscription-level deployment.

Use Azure CLI deployment at subscription scope.

After deployment, check:

```text
Resource groups
VNet
Subnets
NSGs
Subnet-to-NSG associations
Tags
```

Do not move forward until this is clean.

# What screenshots to take after Phase 3

Create a folder:

```text
screenshots/phase-03-foundation/
```

Add screenshots of:

```text
1-resource-groups.png
2-vnet-overview.png
3-subnets.png
4-nsg-list.png
5-subnet-nsg-association.png
6-tags.png
```

These screenshots will make your README much more convincing.

# What to write in README after Phase 3

Add these sections:

```text
## Project Goal
## Architecture
## Phase 3: Foundation
## Resource Groups
## Network Design
## NSG Design
## Tags and Governance
## Deployment Steps
## Screenshots
## What I Learned
## Next Phase
```

For “What I Learned,” write in your own words:

```text
I learned how to structure Azure infrastructure using Bicep modules, separate subscription-scope and resource-group-scope deployments, design a VNet with multiple subnets, attach NSGs, and use tags for governance and cost tracking.
```

That is a strong learning statement.

# What the final Phase 3 result should look like

At the end of Phase 3, you should have:

```text
3 resource groups
1 VNet
3 subnets
3 NSGs
subnets associated with NSGs
tags on all resources
Bicep modules working
parameter file working
README updated
screenshots added
```

You should **not** have:

```text
VMs
public IPs
backup
monitoring
GitHub Actions deployment
```

Those come later.

# What you are learning in Phase 3

This phase teaches:

## Azure structure

You learn how to organize resources across resource groups.

## Azure networking

You learn VNet, CIDR ranges, subnets, and NSGs.

## Security thinking

You learn that “it works” is not enough. It must be secure.

## Infrastructure as Code

You learn how to create repeatable infrastructure using Bicep.

## Modular design

You learn how real infrastructure code is broken into files.

## Cost control

You learn not to deploy expensive resources too early.

# One warning: do not overbuild

Right now, your temptation will be to add everything.

Do not.

A good cloud engineer builds in phases.

Bad approach:

```text
Build VMs, monitoring, backup, RBAC, GitHub Actions, PowerShell all in one day.
```

Good approach:

```text
Build foundation.
Test.
Document.
Commit.
Then move to compute.
```

# Git commit plan

Use clean commits.

After repo cleanup:

```text
chore: organize project folder structure
```

After parameters file:

```text
infra: add dev parameter file
```

After resource groups:

```text
infra: add resource group module
```

After network and NSGs:

```text
infra: add vnet subnets and nsg modules
```

After README update:

```text
docs: document phase 3 foundation deployment
```

This makes your GitHub history look professional.

# Your immediate next checklist

Do these in order:

```text
1. Rename folders to lowercase
2. Delete testFolder
3. Rename resourceGrp.bicep to resourceGroups.bicep
4. Add monitoring.bicep and backup.bicep placeholders
5. Add .gitignore
6. Add bicepconfig.json
7. Fill main.parameters.dev.json with non-secret values
8. Build resourceGroups.bicep
9. Build nsg.bicep
10. Build network.bicep
11. Connect modules in main.bicep
12. Run validation
13. Run what-if
14. Deploy Phase 3
15. Take screenshots
16. Update README
17. Commit changes
```

Do not touch compute yet.

# My honest review of your current setup

You are on the right track.

The main thing I would fix is naming consistency. Your structure is good, but capitalized folder names and `testFolder` make it look less polished. Clean that up now before writing more code.

After that, focus only on Phase 3 foundation. Once you get the VNet/subnets/NSGs deployed cleanly with Bicep, you will have built the base for the whole project. That base matters more than rushing into VMs.

[1]: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/modules?utm_source=chatgpt.com "Bicep modules - Azure Resource Manager | Microsoft Learn"
[2]: https://azure.microsoft.com/en-us/free/students?utm_source=chatgpt.com "Azure for Students | Microsoft Azure"
[3]: https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/tutorial-acm-create-budgets?utm_source=chatgpt.com "Tutorial - Create and manage budgets - Microsoft Cost Management"
[4]: https://learn.microsoft.com/en-us/azure/virtual-machines/states-billing?utm_source=chatgpt.com "States and billing status - Azure Virtual Machines | Microsoft Learn"
[5]: https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/create-free-services?utm_source=chatgpt.com "Create free services with Azure free account - Microsoft Cost ..."
[6]: https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/microsoft-entra-id-free?utm_source=chatgpt.com "Microsoft Entra ID Free - Microsoft Cost Management"
[7]: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-github-actions?utm_source=chatgpt.com "Quickstart: Deploy Bicep files by using GitHub Actions"
[8]: https://learn.microsoft.com/en-us/azure/role-based-access-control/overview?utm_source=chatgpt.com "What is Azure role-based access control (Azure RBAC)?"
[9]: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-what-if?utm_source=chatgpt.com "Bicep What-If: Preview Changes Before Deployment"
