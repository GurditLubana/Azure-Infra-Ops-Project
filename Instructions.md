
# Where you are right now

You have completed **Phase 3: Foundation**.

You now have:

```text
Resource groups
VNet
Subnets
NSGs
Subnet-to-NSG associations
Bicep modules
Parameter file
Successful subscription-scope deployment
```

That is a proper first IaC milestone.

Now we move into:

# Phase 4: Compute + Secure Access

This phase adds your first real workload:

```text
One Linux VM
One NIC
One temporary public IP
SSH key authentication
Secure NSG access from only your IP
Cost-control habit
Basic VM screenshots
```

Do **not** add Windows VM yet. Linux first.

Windows costs more, takes more resources, and adds more complexity. We’ll add it later only if it improves the project.

---

# Phase 4 goal in simple words

You are now going to place a small Linux server inside your Azure network.

This will prove that your network is not just decoration. It actually supports compute.

You will learn:

* how VMs connect to subnets
* how NICs work
* how public IPs work
* how SSH access works
* how NSGs protect admin access
* how Bicep modules pass outputs/IDs
* how to avoid unnecessary cloud cost

Microsoft describes Bicep as a declarative language for deploying Azure resources repeatedly and consistently, and modules are specifically meant to organize Bicep deployments into cleaner separate files. That is exactly what you are practicing now. ([Microsoft Learn][1])

---

# Before Phase 4: small cleanup

## 1. Delete or ignore `main.json`

In your tree, I saw:

```text
infra/main.json
```

That file was probably generated when you ran:

```powershell
az bicep build
```

You usually do **not** need to commit generated ARM JSON if your source is Bicep.

Add this to `.gitignore`:

```text
infra/main.json
```

Keep:

```text
infra/main.parameters.dev.json
```

Do **not** ignore your parameter file.

## 2. Make sure your folders are lowercase

You already renamed folders. Good.

Final structure should look like:

```text
.github/
diagrams/
docs/
infra/
  main.bicep
  main.parameters.dev.json
  modules/
scripts/
screenshots/
README.md
Instructions.md or docs/
```

## 3. Commit Phase 3 before moving on

Before changing anything, commit your working Phase 3.

Suggested commit message:

```text
infra: deploy phase 3 foundation with bicep
```

Why? Because this gives you a clean checkpoint. If Phase 4 breaks something, you can compare or roll back.

---

# Phase 4 design

## VM choice

Use:

```text
VM name: vm-aiol-linux-dev-cc-001
OS: Ubuntu Server 22.04 LTS
Size: Standard_B1s
Authentication: SSH key
Subnet: snet-workload-dev-cc-001
Resource group: rg-aiol-compute-dev-cc-001
Region: eastus2
```

If `Standard_B1s` is not available in your student subscription, try another small B-series size available to you. B-series VMs are designed for smaller/general-purpose workloads and use a CPU credit model, which makes them a reasonable fit for learning and dev/test scenarios. ([Microsoft Learn][2])

Do **not** use expensive VM sizes.

Avoid:

```text
D-series
E-series
F-series
GPU VMs
Premium SSD
large Windows VMs
```

---

# Resource design for Phase 4

You will add these resources:

```text
Public IP
Network Interface Card
Linux Virtual Machine
```

## 1. Public IP

Purpose:

```text
Allows you to SSH into the VM from your laptop.
```

Keep it temporary.

A public IP is convenient for learning, but it should be protected by NSG rules.

## 2. NIC

Purpose:

```text
Connects the VM to the subnet.
```

A VM does not directly attach to a subnet. The NIC does.

The flow is:

```text
VM -> NIC -> Subnet -> VNet
```

## 3. Linux VM

Purpose:

```text
This is your first compute workload inside your Azure infrastructure.
```

Use SSH key authentication, not password authentication.

---

# Important security change before creating the VM

Right now, your management NSG has SSH and RDP rules from your admin IP. That is not terrible, but I want you to improve the design.

For this phase:

## Workload subnet should allow SSH

Because the Linux VM will live in:

```text
snet-workload-dev-cc-001
```

The SSH rule should belong to:

```text
nsg-workload-dev-cc-001
```

So update your NSG thinking:

```text
nsg-workload-dev-cc-001
  Allow SSH from your public IP only

nsg-mgmt-dev-cc-001
  Keep RDP closed for now
  Later use it for Windows VM if needed

nsg-private-dev-cc-001
  No inbound public access
```

Best practice: only open access where it is actually needed.

Do not allow:

```text
SSH from 0.0.0.0/0
RDP from 0.0.0.0/0
Any source *
```

This will also help your future PowerShell script `Find-RiskyNsgRules.ps1`, because that script will later check for exactly these risky rules.

---

# Files you will touch in Phase 4

## 1. `compute.bicep`

This module should create compute-related resources.

It should eventually create:

```text
Public IP
NIC
Linux VM
```

It should receive values from `main.bicep`, not hardcode everything.

This file should **not** create the VNet or subnet. Those already exist in `network.bicep`.

The compute module should take the workload subnet ID as input.

### What you learn from this

You learn how compute depends on networking.

You also learn how one module can use information from another module.

This is a real IaC skill.

---

## 2. `network.bicep`

You may need to update this file to output subnet IDs.

At minimum, it should output:

```text
workload subnet resource ID
management subnet resource ID
private subnet resource ID
```

Why?

Because `compute.bicep` needs the workload subnet ID to attach the NIC.

The compute module should not guess where the subnet is. It should be passed the subnet ID cleanly.

### What you learn from this

You learn module outputs.

This is important because real projects often have modules like:

```text
network module outputs subnet IDs
compute module consumes subnet IDs
monitoring module consumes VM IDs
backup module consumes VM IDs
```

---

## 3. `main.bicep`

This is where you connect the compute module.

Your `main.bicep` should:

```text
Deploy resource groups
Deploy NSGs
Deploy network
Deploy compute after network exists
Pass workload subnet ID into compute module
```

The compute module should depend on the network deployment.

Do not deploy compute before networking exists.

### What you learn from this

You learn deployment order and dependency thinking.

---

## 4. `main.parameters.dev.json`

Add VM-related values here.

Add values like:

```text
linuxVmName
linuxVmSize
adminUsername
adminPublicKey
publicIpName
nicName
osDiskType
```

Do not put private keys in this file.

The public key is safe to store, but the private key is not.

Never commit:

```text
private key
password
client secret
.pfx file
.pem private key
```

---

# SSH key setup

For Linux VM access, use SSH key authentication.

You need:

```text
Private key: stays on your laptop
Public key: goes into Azure VM configuration
```

Think of it like this:

```text
Azure VM stores your public key.
Your laptop keeps the private key.
When you connect, Azure checks if both match.
```

Do not paste your private key into GitHub.

Do not upload your private key.

Do not put your private key in Bicep.

Only the public key goes into the deployment.

---

# Phase 4 step-by-step instructions

## Step 1: Create a new branch

Do this before Phase 4 changes.

Branch idea:

```text
feature/phase-4-linux-vm
```

Why?

Because now you are adding compute. If you break something, your Phase 3 main branch stays clean.

What you learn:

```text
Basic Git workflow
Safe infrastructure change process
```

---

## Step 2: Update your NSG design

Move SSH access to the workload NSG.

Your final Phase 4 NSG design should be:

```text
nsg-workload-dev-cc-001
  Allow SSH from your IP only

nsg-mgmt-dev-cc-001
  No public inbound access for now
  RDP rule can be added later only when Windows VM exists

nsg-private-dev-cc-001
  No public inbound access
```

Keep the source as your current public IP with `/32`.

Example concept:

```text
source = your-ip/32
destination port = 22
protocol = TCP
access = Allow
direction = Inbound
```

Do not copy this as code. Just use the concept in your Bicep/parameter structure.

What you learn:

```text
Least privilege access
Subnet-specific NSG design
Cloud security basics
```

Time:

```text
30–60 minutes
```

---

## Step 3: Add subnet outputs in `network.bicep`

You need the workload subnet ID.

Your network module should output:

```text
workload subnet ID
management subnet ID
private subnet ID
```

Since your subnets are inside an array, this may take some thinking.

You can approach it in either of these ways:

## Option A: Simple approach

Output the VNet name and rebuild the subnet resource ID in `main.bicep`.

This is easier but less clean.

## Option B: Better approach

Output the actual subnet IDs from `network.bicep`.

This is cleaner and more professional.

I recommend Option B.

What you learn:

```text
How Bicep modules share data
How subnet IDs are passed into other modules
```

Time:

```text
1–2 hours
```

---

## Step 4: Plan `compute.bicep`

Before writing the file, write comments or notes inside it.

List what the module will create:

```text
1. Public IP
2. NIC
3. Linux VM
```

Also list what values it needs:

```text
location
tags
vm name
vm size
admin username
admin public key
subnet ID
public IP name
NIC name
OS disk type
```

Do not start coding until this is clear.

What you learn:

```text
Infrastructure planning before coding
Module input design
```

Time:

```text
30 minutes
```

---

## Step 5: Build the public IP resource

Purpose:

```text
The public IP gives your VM an internet-reachable address for SSH.
```

But it is only safe because your NSG allows SSH only from your IP.

For this project, use:

```text
Public IP name: pip-aiol-linux-dev-cc-001
SKU: Standard
Allocation: Static
```

Why static?

Standard public IPs are static by default and work cleanly with NSG-secured access.

Important: public IPs can create small charges depending on SKU and usage. Do not leave unused public IPs around forever. Once the project is done, we can either keep it for screenshots or remove it and document why.

What you learn:

```text
Public access design
Azure networking dependencies
Cost awareness
```

Time:

```text
30–60 minutes
```

---

## Step 6: Build the NIC resource

Purpose:

```text
The NIC connects the VM to the workload subnet.
```

The NIC should use:

```text
Subnet: snet-workload-dev-cc-001
Public IP: pip-aiol-linux-dev-cc-001
Private IP: dynamic
```

Do not manually set a private IP yet. Let Azure assign it.

What you learn:

```text
How VMs connect to Azure networks
NIC-to-subnet relationship
Public/private IP relationship
```

Time:

```text
30–60 minutes
```

---

## Step 7: Build the Linux VM resource

Use:

```text
VM name: vm-aiol-linux-dev-cc-001
Size: Standard_B1s
OS: Ubuntu Server 22.04 LTS
Authentication: SSH key
Disk: Standard SSD LRS or Standard HDD LRS
Admin username: choose a simple non-root name
```

Do not use password authentication.

Do not use username:

```text
admin
root
test
azureuser if you want to be more professional
```

Use something like:

```text
cloudadmin
```

What you learn:

```text
Azure VM configuration
OS images
SSH authentication
Disk selection
Cost-aware sizing
```

Time:

```text
2–3 hours
```

---

## Step 8: Connect compute module in `main.bicep`

Your `main.bicep` now needs to call:

```text
compute.bicep
```

The compute module should be scoped to:

```text
rg-aiol-compute-dev-cc-001
```

It should receive:

```text
workload subnet ID
location
tags
VM settings
```

It should depend on the network deployment.

What you learn:

```text
Cross-resource-group deployment
Module dependency flow
Subscription-scope orchestration
```

Time:

```text
1 hour
```

---

## Step 9: Validate locally

Run your usual local checks:

```text
Bicep build
Bicep lint
```

Expected result:

```text
No syntax errors
No missing module paths
No missing parameters
```

If the build generates `main.json`, do not commit it unless you intentionally want to.

What you learn:

```text
Local IaC validation
Debugging before deployment
```

Time:

```text
30 minutes to 2 hours depending on errors
```

---

## Step 10: Run Azure validate and what-if

Run:

```text
Azure deployment validate
Azure deployment what-if
```

Do not deploy yet.

Read the what-if output carefully.

Expected new resources:

```text
Public IP
NIC
Linux VM
Possible NSG rule update
```

You should not see:

```text
Delete VNet
Delete NSGs
Delete resource groups
Modify random resources
Create expensive services
```

What you learn:

```text
Safe deployment workflow
Change review before deployment
```

Time:

```text
30 minutes
```

---

## Step 11: Deploy Phase 4

After what-if looks clean, deploy.

Expected result:

```text
VM created
NIC created
Public IP created
NSG updated
```

What you learn:

```text
Real Azure compute deployment using IaC
```

Time:

```text
15–30 minutes deployment
More time if debugging
```

---

## Step 12: Connect to the VM using SSH

After deployment:

1. Go to the VM in Azure Portal.
2. Copy the public IP.
3. Use your private key from your laptop.
4. SSH into the VM.

If SSH fails, check:

```text
Is the VM running?
Is public IP attached?
Is NIC in the workload subnet?
Is workload NSG allowing port 22 from your IP?
Did your public IP change?
Is the private key correct?
Is the username correct?
```

What you learn:

```text
Cloud troubleshooting
Networking path validation
SSH authentication troubleshooting
```

Time:

```text
1–2 hours if this is your first time
```

---

## Step 13: Run a few Linux checks

After SSH works, run simple checks inside the VM:

```text
hostname
IP address
disk usage
memory usage
running services
package update check
```

Do not install random software yet.

Just prove that the VM is reachable and healthy.

What you learn:

```text
Basic Linux VM admin
Operational validation
```

Time:

```text
30 minutes
```

---

## Step 14: Deallocate the VM

This is very important.

After testing, stop/deallocate the VM from Azure.

Do not just shut it down from inside Linux.

Microsoft explains that VM billing depends on VM power state. Stopped/deallocated is different from just stopped, and deallocation is what stops compute billing. Storage may still cost money because disks remain allocated. ([Microsoft Learn][3])

What you learn:

```text
Cost control
Cloud operations discipline
```

Time:

```text
5 minutes
```

---

## Step 15: Take screenshots

Create:

```text
screenshots/phase-04-compute/
```

Take screenshots of:

```text
01-vm-overview.png
02-vm-networking.png
03-nic-overview.png
04-public-ip.png
05-workload-nsg-ssh-rule.png
06-successful-ssh-session.png
07-vm-stopped-deallocated.png
```

These screenshots will make your final project documentation much stronger.

---

## Step 16: Update your personal notes

Add what you learned:

```text
I learned how a VM connects to a subnet through a NIC.
I learned how public IP + NSG + SSH key access work together.
I learned why source IP restriction matters.
I learned how to deallocate VMs to reduce compute cost.
I learned how compute modules depend on networking modules.
```

This is for your own learning.

Later we will turn this into a professional README.

---

## Step 17: Commit Phase 4

Suggested commit messages:

```text
infra: add linux vm compute module
infra: add secure ssh access for workload subnet
docs: add phase 4 compute screenshots
```

Do not make one giant commit if you can avoid it.

---

# How much time should you spend on Phase 4?

For your first time, give yourself:

```text
2 to 4 days
```

or roughly:

```text
6 to 10 focused hours
```

Do not rush. This phase teaches real cloud infrastructure fundamentals.

A good pace:

```text
Day 1: NSG cleanup + subnet outputs
Day 2: compute module planning + VM Bicep
Day 3: validate, what-if, deploy
Day 4: SSH test, screenshots, notes, commit
```

If it takes a week, that is still fine.

---

# What not to do yet

Do not add:

```text
Windows VM
Backup
Log Analytics
Azure Monitor Agent
GitHub Actions deployment
Terraform
Kubernetes
Bastion
Azure Firewall
NAT Gateway
Load Balancer
Private Endpoints
```

Not yet.

Build cleanly, one phase at a time.

---

# What we will do after Phase 4

After your Linux VM is deployed and tested, we move to:

# Phase 5: Monitoring and Alerting

You will add:

```text
Log Analytics Workspace
Azure Monitor Agent
Data Collection Rule
VM metrics/log collection
CPU alert
VM stopped/deallocated alert
Action group email notification
```

Azure Monitor automatically collects host metrics and activity logs for Azure VMs, but guest OS logs require Azure Monitor Agent and data collection rules. ([Microsoft Learn][4])

That phase will make your project look much closer to real cloud operations.

After that:

# Phase 6: PowerShell Automation

You will build:

```text
Get-AzureInfraHealth.ps1
Find-RiskyNsgRules.ps1
Start-Stop-VMs.ps1
```

This is where your project becomes personal to your background, because you already like PowerShell automation.

After that:

# Phase 7: CI/CD

You will add GitHub Actions:

```text
Bicep build
Bicep lint
what-if on pull request
manual deployment workflow
```

We will not auto-deploy expensive resources on every push. We’ll make deployment manual and controlled.

After that:

# Phase 8: Final Documentation

We will write the real polished README:

```text
Architecture
Project goal
Screenshots
Deployment steps
Security decisions
Cost-control decisions
Lessons learned
Resume bullet points
Interview explanation
```

That final README will be the version hiring managers see.

---

# My honest take

You are doing this correctly.

You are not rushing into “cool” cloud services. You are learning the foundation:

```text
IaC
resource groups
networking
NSGs
VMs
secure access
cost control
documentation
```

That is exactly the base you need for cloud infrastructure roles.

Your next real challenge is this:

> Can you deploy one Linux VM into your existing network securely, using Bicep, without opening SSH to the whole internet?

That is your Phase 4 mission.

[1]: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?utm_source=chatgpt.com "What is Bicep? - Azure Resource Manager | Microsoft Learn"
[2]: https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/b-family?utm_source=chatgpt.com "B family VM size series - Azure Virtual Machines"
[3]: https://learn.microsoft.com/en-us/azure/virtual-machines/states-billing?utm_source=chatgpt.com "States and billing status of Azure Virtual Machines"
[4]: https://learn.microsoft.com/en-us/azure/azure-monitor/vm/data-collection?utm_source=chatgpt.com "Collect guest log data from virtual machines with Azure Monitor"
