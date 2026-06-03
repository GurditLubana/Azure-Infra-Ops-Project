param location string
param targetVMid string
param alertName string
param workspaceName string
param actionGroupEmail string
param actionGroupName string
param alertMetricName string
param altertMetricOperator string
param altertMetricThreshold int
param activityLogAlertName string
param nsgAlertRGname string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}


resource actionGroup 'Microsoft.Insights/actionGroups@2019-06-01' = {
  name: actionGroupName
  location: 'global'
  properties: {
    groupShortName: 'aiol-ops'
    enabled: true
    emailReceivers: [
      {
        name: 'AdminEmail'
        emailAddress: actionGroupEmail
      }
    ]
  }
}
  


resource metricalertsAlert 'Microsoft.Insights/metricalerts@2018-03-01' = {
  name: alertName
  location: 'global'
  properties: {
    description: 'Alert for CPU usage'
    severity: 3
    enabled: true
    scopes: [
      targetVMid
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          name: 'HighPercentageMemory'
          metricName: alertMetricName
          metricNamespace: 'Microsoft.Compute/virtualMachines'
          operator: altertMetricOperator
          threshold: altertMetricThreshold
          timeAggregation: 'Average'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}




resource activityLogAlert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {

  name: activityLogAlertName
  location: 'global'
  properties: {
    description: 'Alert for NSG rule changes'
    enabled: true
    scopes: [
      resourceId('Microsoft.Resources/resourceGroups', nsgAlertRGname)
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'Administrative'
        }
        {
          anyOf: [
            {
              field: 'operationName'
              equals: 'Microsoft.Network/networkSecurityGroups/securityRules/write'
            }
            {
              field: 'operationName'
              equals: 'Microsoft.Network/networkSecurityGroups/securityRules/delete'
            }
          ]
        }
      ]
    }
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroup.id
        }
      ]
    }
  }
}
