Great. Phase 4 is basically done: VM is deployed, network is working, and the VM is **Stopped (deallocated)**. That is exactly what I wanted to see.

Yes, West US 2 is fine. Just document this clearly later:

> I used West US 2 because my Azure for Students subscription had limited regional VM availability and this region supported a cheaper B-series Linux VM.

Now we move to **Phase 5: Monitoring + Alerting**.

# Phase 5 Goal

In simple words:

> We are going to make your Azure lab observable.

Right now, you can deploy infrastructure. That is good.

But cloud infrastructure work is not just deployment. Real cloud teams also need to know:

* Is the VM healthy?
* Is CPU usage too high?
* Did someone change an NSG?
* Did someone start/stop a VM?
* Who should be notified when something breaks?
* Can we see logs and metrics in one place?

That is what Phase 5 teaches.

Azure Monitor is Microsoft’s platform for collecting and analyzing telemetry so you can improve the performance and availability of cloud and on-prem resources. Log Analytics workspaces are used as a central place to collect and query log data. ([Microsoft Learn][1])

---

# What you will build in Phase 5

You will add these resources:

```text
Log Analytics Workspace
Action Group
VM CPU alert
Activity Log alert for NSG changes
Optional: Azure Monitor Agent + Data Collection Rule
```

Do **not** overbuild this phase. Keep it clean and cheap.

---

# Before you start Phase 5

## 1. Confirm VM is deallocated

You already showed:

```text
Stopped (deallocated)
```

Good.

Keep it deallocated until you need to test alerts.

---

## 2. Fix tags on compute resources

From your screenshot, the VM shows:

```text
Tags: Add tags
```

That means your VM may not have tags applied.

Before Phase 5, make sure these resources have your standard tags:

```text
VM
NIC
Public IP
OS disk if possible
```

Tags should be:

```text
Project: AzureInfraOpsLab
Environment: Dev
Owner: Gurdit
ManagedBy: Bicep
Purpose: CloudInfraPortfolio
```

This matters because later your PowerShell health report can filter resources by tag.

---

## 3. Make sure SSH works

Before monitoring, confirm you can SSH into the VM at least once.

Take a screenshot of:

```text
successful SSH connection
hostname command output
private IP check
```

Then deallocate the VM again.

---

# Files you will touch in Phase 5

## `monitoring.bicep`

This becomes the main file for Phase 5.

It should create:

```text
Log Analytics Workspace
Action Group
Metric alert
Activity log alert
Optional Data Collection Rule
```

This file should be scoped to:

```text
rg-aiol-ops-dev-cc-001
```

Why? Because monitoring/operations resources belong in the ops resource group.

---

## `compute.bicep`

You may need to update this file to output:

```text
Linux VM resource ID
Linux VM name
Linux VM resource group
```

Why?

Because monitoring needs to know which VM to monitor.

Your monitoring module should not guess the VM ID. It should receive it from the compute module.

---

## `main.bicep`

This will connect the monitoring module.

It should pass:

```text
VM resource ID
location
tags
alert names
workspace name
action group email
```

from your main deployment into `monitoring.bicep`.

---

## `main.parameters.dev.json`

Add non-sensitive monitoring values:

```text
log analytics workspace name
action group name
CPU alert name
CPU threshold
alert severity
retention days
```

Be careful with your email address.

Your email is not a password, but it is personal information. If you do not want your email public on GitHub, put the email in:

```text
main.parameters.local.json
```

and keep that file ignored by Git.

---

# Phase 5 resources and what each one does

## 1. Log Analytics Workspace

Name suggestion:

```text
law-aiol-dev-wus2-001
```

Purpose:

```text
Central place to store logs and query monitoring data.
```

This is where VM logs, activity logs, and agent data can go later.

Keep retention low/default for cost control.

Do **not** enable:

```text
Microsoft Sentinel
Defender paid plans
extra solutions
large data collection
```

Those can increase cost.

---

## 2. Action Group

Name suggestion:

```text
ag-aiol-dev-wus2-001
```

Purpose:

```text
Defines who gets notified when an alert fires.
```

For your lab, use email notification only.

Action groups define notification and automation actions for Azure Monitor alerts, such as email, webhook, Azure Functions, and similar actions. ([Microsoft Learn][2])

Use your personal email, but again, use a local parameter file if you don’t want it committed.

---

## 3. CPU Metric Alert

Name suggestion:

```text
alert-aiol-linux-highcpu-dev-wus2-001
```

Purpose:

```text
Trigger alert when Linux VM CPU goes above a threshold.
```

For real-world style:

```text
Threshold: 80%
Window: 5 minutes
Severity: 3
Target: Linux VM
Action: email action group
```

For testing, you can temporarily lower the threshold to something like 5% or 10% so it triggers quickly. After testing, set it back to 80%.

---

## 4. Activity Log Alert for NSG Changes

Name suggestion:

```text
alert-aiol-nsg-change-dev-wus2-001
```

Purpose:

```text
Trigger alert when someone modifies or deletes an NSG.
```

Why this is good:

NSGs control network access. If someone changes an NSG, that can be a security issue.

This is a very strong project detail because it shows security awareness.

Monitor for operations like:

```text
Network Security Group write
Network Security Group delete
Security rule write
Security rule delete
```

Target scope:

```text
rg-aiol-network-dev-cc-001
```

Action:

```text
Send email through action group
```

---

## 5. Optional: Azure Monitor Agent + Data Collection Rule

This is useful, but do not rush it.

Azure automatically collects host metrics and activity logs from Azure VMs, but guest OS logs require extra collection setup using Azure Monitor Agent and Data Collection Rules. ([Microsoft Learn][3])

So divide it like this:

## Phase 5A: Required

```text
Log Analytics Workspace
Action Group
CPU alert
NSG change alert
```

## Phase 5B: Optional after 5A works

```text
Azure Monitor Agent
Data Collection Rule
Linux syslog collection
DCR association to VM
```

I suggest doing **5A first**. Then we can decide if you want 5B.

---

# Step-by-step plan

## Step 1: Create a Phase 5 branch

Use a new branch:

```text
feature/phase-5-monitoring
```

Why?

You now have working Phase 4 infra. Don’t break it directly.

Time: 5 minutes.

---

## Step 2: Update parameters

Add monitoring-related values to your dev parameter file.

Add things like:

```text
workspace name
action group name
CPU alert name
NSG alert name
CPU threshold
alert severity
retention setting
```

If using your email, put it in a local-only parameter file.

Time: 30 minutes.

---

## Step 3: Add outputs from compute module

Your compute module should output the Linux VM resource ID.

The monitoring module needs that VM ID.

Expected concept:

```text
compute module creates VM
compute module outputs VM ID
main.bicep passes VM ID to monitoring module
monitoring module creates alert against VM ID
```

Time: 30–60 minutes.

---

## Step 4: Build Log Analytics Workspace

In `monitoring.bicep`, create the Log Analytics Workspace inside the ops resource group.

Keep it simple.

Do not add advanced solutions yet.

Expected result:

```text
rg-aiol-ops-dev-cc-001
  law-aiol-dev-wus2-001
```

Time: 1 hour.

---

## Step 5: Build Action Group

Create one action group that sends alert emails to you.

Expected result:

```text
ag-aiol-dev-wus2-001
```

This will be used by both CPU alert and NSG change alert.

Time: 1 hour.

---

## Step 6: Build CPU alert

Create a metric alert for the Linux VM.

Target:

```text
vm-aiol-linux-dev-cc-001
```

Condition:

```text
CPU percentage greater than threshold
```

Action:

```text
send email using action group
```

Expected result:

```text
Alert rule exists under Azure Monitor
Alert targets your Linux VM
Alert uses your action group
```

Time: 1–2 hours.

---

## Step 7: Build NSG change alert

Create an activity log alert for NSG changes.

Scope:

```text
rg-aiol-network-dev-cc-001
```

Condition:

```text
NSG write/delete or security rule write/delete
```

Action:

```text
send email using same action group
```

Expected result:

```text
If someone changes an NSG rule, alert notification is sent.
```

Time: 1–2 hours.

---

## Step 8: Validate and deploy

Run your normal process:

```text
bicep build
bicep lint
deployment validate
what-if if useful
deployment create
```

Since you now have nested modules, what-if may still show some limitations. If validate passes and the changes look expected, that is okay.

Expected created/updated resources:

```text
Log Analytics Workspace
Action Group
Metric Alert
Activity Log Alert
Possibly updated VM outputs or tags
```

Time: 30 minutes to 2 hours depending on errors.

---

## Step 9: Test CPU alert

Start the VM only for testing.

Then either:

```text
temporarily lower CPU threshold
```

or run a temporary CPU-heavy command inside the Linux VM.

The safer beginner method:

```text
Lower threshold temporarily
Wait for alert
Confirm email arrives
Set threshold back to normal
```

After testing:

```text
deallocate the VM again
```

Time: 30–60 minutes.

---

## Step 10: Test NSG change alert

Make a harmless NSG rule change.

Example:

```text
change description
add/remove a test rule
```

Then wait for email alert.

After test, revert the change through Bicep, not manually.

Important: If you manually change something in the portal, your IaC becomes out of sync. That is called drift.

This is a good chance to learn infrastructure drift.

Time: 30–60 minutes.

---

## Step 11: Take screenshots

Create:

```text
screenshots/phase-05-monitoring/
```

Take screenshots of:

```text
01-log-analytics-workspace.png
02-action-group.png
03-cpu-alert-rule.png
04-nsg-change-alert-rule.png
05-alert-email-received.png
06-monitor-alerts-overview.png
07-vm-metrics.png
```

If you add Azure Monitor Agent later:

```text
08-data-collection-rule.png
09-vm-agent-extension.png
10-log-query-result.png
```

---

## Step 12: Update your notes

In your personal notes, write what you learned.

Add simple notes like:

```text
I learned that Azure Monitor can collect VM platform metrics without guest agent setup.
I learned that Log Analytics Workspace stores log data for querying.
I learned that action groups define who gets notified when alerts fire.
I learned how to create a CPU metric alert for a VM.
I learned how to create an Activity Log alert for NSG changes.
I learned the difference between metric alerts and activity log alerts.
```

---

## Step 13: Commit Phase 5

Suggested commits:

```text
infra: add log analytics workspace
infra: add action group for alert notifications
infra: add vm cpu metric alert
infra: add nsg activity log alert
docs: add phase 5 monitoring screenshots
```

---

# How long should Phase 5 take?

Realistic time:

```text
1 to 3 days
```

If you are learning slowly and carefully:

```text
5 to 8 focused hours
```

Don’t rush it.

This phase is not hard, but alerts can take time to test because Azure Monitor is not always instant.

---

# Cost warning

This phase can create small costs if you collect logs heavily.

To stay safe:

```text
keep VM deallocated when not testing
do not enable Sentinel
do not enable Defender paid features
do not collect all syslog/debug logs
do not leave CPU stress running
keep Log Analytics usage low
```

Phase 5A should be low-cost.

Phase 5B with guest logs can cost more if you collect too much data.

---

# What Phase 5 teaches you

This phase teaches:

```text
Cloud monitoring
Alerting
Operational visibility
Action groups
Metrics vs logs
Activity log monitoring
Basic incident detection
Cost-aware monitoring
```

This is very relevant for:

```text
Cloud Support Engineer
Azure Administrator
Cloud Operations Analyst
Infrastructure Support Analyst
Junior Cloud Infrastructure Engineer
```

---

# What we do after Phase 5

After monitoring is done, we move to:

# Phase 6: PowerShell Automation

You will finally build your scripts:

```text
Get-AzureInfraHealth.ps1
Find-RiskyNsgRules.ps1
Start-Stop-VMs.ps1
```

This will connect directly to your strength: PowerShell automation.

After that:

# Phase 7: GitHub Actions CI/CD

You will add:

```text
Bicep validation workflow
Bicep lint workflow
what-if workflow
manual deployment workflow
```

After that:

# Phase 8: Final README + Resume Bullets

We will turn the project into something polished for GitHub and your resume.

---

# My recommendation for you right now

Do **Phase 5A only** first:

```text
Log Analytics Workspace
Action Group
CPU alert
NSG change alert
```

Do not add Azure Monitor Agent or DCR yet.

Once 5A works, we decide if 5B is worth it.

That keeps the project clean, cost-safe, and still very resume-friendly.

[1]: https://learn.microsoft.com/en-us/azure/azure-monitor/?utm_source=chatgpt.com "Azure Monitor documentation - Azure Monitor | Microsoft Learn"
[2]: https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/action-groups?utm_source=chatgpt.com "Create and manage action groups in Azure Monitor - Azure Monitor"
[3]: https://learn.microsoft.com/en-us/azure/azure-monitor/vm/data-collection?utm_source=chatgpt.com "Collect guest log data from virtual machines with Azure Monitor"
