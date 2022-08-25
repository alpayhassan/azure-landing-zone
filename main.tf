terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.16.0"
    }
  }
}

provider "azurerm" {
  features {}
}


# Policies: Company management group level
resource "azurerm_policy_definition" "auditvms" {
  description  = "This policy audits VMs that do not use managed disks"
  display_name = "Audit VMs that do not use managed disks"

  metadata = jsonencode(
    {
      category = "Compute"
      version  = "1.0.0"
    }
  )
  mode = "All"
  name = "06a78e20-9358-41c9-923c-fb736d382a4d"
  policy_rule = jsonencode(
    {
      if = {
        anyOf = [
          {
            allOf = [
              {
                equals = "Microsoft.Compute/virtualMachines"
                field  = "type"
              },
              {
                exists = "True"
                field  = "Microsoft.Compute/virtualMachines/osDisk.uri"
              },
            ]
          },
          {
            allOf = [
              {
                equals = "Microsoft.Compute/VirtualMachineScaleSets"
                field  = "type"
              },
              {
                anyOf = [
                  {
                    exists = "True"
                    field  = "Microsoft.Compute/VirtualMachineScaleSets/osDisk.vhdContainers"
                  },
                  {
                    exists = "True"
                    field  = "Microsoft.Compute/VirtualMachineScaleSets/osdisk.imageUrl"
                  },
                ]
              },
            ]
          },
        ]
      }
      then = {
        effect = "audit"
      }
    }
  )
  policy_type = "BuiltIn"

  timeouts {}
}

resource "azurerm_management_group_policy_assignment" "auditvms" {
  name                 = "audit-vm-manageddisks"
  policy_definition_id = azurerm_policy_definition.auditvms.id
  management_group_id  = azurerm_management_group.mycompany-grp.id
  description          = "Shows all virtual machines not using managed disks"
  display_name         = "Audit VMs without managed disks assignment"
}

resource "azurerm_policy_definition" "enable_microsoft_defender_for_cloud" {
  description  = <<-EOT
        Identifies existing subscriptions that aren't monitored by Microsoft Defender for Cloud and protects them with Defender for Cloud's free features.
        Subscriptions already monitored will be considered compliant.
        To register newly created subscriptions, open the compliance tab, select the relevant non-compliant assignment, and create a remediation task.
    EOT
    display_name = "Enable Microsoft Defender for Cloud on your subscription"
    metadata     = jsonencode(
        {
            category = "Security Center"
            version  = "1.0.1"
        }
    )
    mode         = "All"
    name         = "ac076320-ddcf-4066-b451-6154267e8ad2"
    policy_rule  = jsonencode(
        {
            if   = {
                equals = "Microsoft.Resources/subscriptions"
                field  = "type"
            }
            then = {
                details = {
                    deployment         = {
                        location   = "westeurope"
                        properties = {
                            mode     = "incremental"
                            template = {
                                "$schema"      = "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#"
                                contentVersion = "1.0.0.0"
                                outputs        = {}
                                resources      = [
                                    {
                                        apiVersion = "2018-06-01"
                                        name       = "VirtualMachines"
                                        properties = {
                                            pricingTier = "free"
                                        }
                                        type       = "Microsoft.Security/pricings"
                                    },
                                ]
                                variables      = {}
                            }
                        }
                    }
                    deploymentScope    = "subscription"
                    existenceCondition = {
                        anyof = [
                            {
                                equals = "standard"
                                field  = "microsoft.security/pricings/pricingTier"
                            },
                            {
                                equals = "free"
                                field  = "microsoft.security/pricings/pricingTier"
                            },
                        ]
                    }
                    existenceScope     = "subscription"
                    name               = "VirtualMachines"
                    roleDefinitionIds  = [
                        "/providers/Microsoft.Authorization/roleDefinitions/fb1c8493-542b-48eb-b624-b4c8fea62acd",
                    ]
                    type               = "Microsoft.Security/pricings"
                }
                effect  = "deployIfNotExists"
            }
        }
    )
    policy_type  = "BuiltIn"

    timeouts {}
}

resource "azurerm_management_group_policy_assignment" "enable_microsoft_defender_for_cloud" {
  name                 = "enable-microsoft-defender-for-cloud"
  policy_definition_id = azurerm_policy_definition.enable_microsoft_defender_for_cloud.id
  management_group_id  = azurerm_management_group.mycompany-grp.id
  description          = "Identifies existing subscriptions that aren't monitored by Microsoft Defender for Cloud and protects them with Defender for Cloud's free features.Subscriptions already monitored will be considered compliant.To register newly created subscriptions, open the compliance tab, select the relevant non-compliant assignment, and create a remediation task."
  display_name         = "Enable Microsoft Defender for Cloud on your subscription"
}

# Policies: Management subscription
resource "azurerm_policy_definition" "activitylogs_sent_to_loganalyticsworkspace" {
  description  = "Deploys the diagnostic settings for Azure Activity to stream subscriptions audit logs to a Log Analytics workspace to monitor subscription-level events"
    display_name = "Configure Azure Activity logs to stream to specified Log Analytics workspace"
    metadata     = jsonencode(
        {
            category = "Monitoring"
            version  = "1.0.0"
        }
    )
    mode         = "All"
    name         = "2465583e-4e78-4c15-b6be-a36cbc7c8b0f"
    parameters   = jsonencode(
        {
            effect       = {
                allowedValues = [
                    "DeployIfNotExists",
                    "Disabled",
                ]
                defaultValue  = "DeployIfNotExists"
                metadata      = {
                    description = "Enable or disable the execution of the policy"
                    displayName = "Effect"
                }
                type          = "String"
            }
            logAnalytics = {
                metadata = {
                    assignPermissions = true
                    description       = "If this workspace is outside of the scope of the assignment you must manually grant 'Log Analytics Contributor' permissions (or similar) to the policy assignment's principal ID."
                    displayName       = "Primary Log Analytics workspace"
                    strongType        = "omsWorkspace"
                }
                type     = "String"
            }
            logsEnabled  = {
                allowedValues = [
                    "True",
                    "False",
                ]
                defaultValue  = "True"
                metadata      = {
                    description = "Whether to enable logs stream to the Log Analytics workspace - True or False"
                    displayName = "Enable logs"
                }
                type          = "String"
            }
        }
    )
    policy_rule  = jsonencode(
        {
            if   = {
                equals = "Microsoft.Resources/subscriptions"
                field  = "type"
            }
            then = {
                details = {
                    deployment         = {
                        location   = "northeurope"
                        properties = {
                            mode       = "incremental"
                            parameters = {
                                logAnalytics = {
                                    value = "[parameters('logAnalytics')]"
                                }
                                logsEnabled  = {
                                    value = "[parameters('logsEnabled')]"
                                }
                            }
                            template   = {
                                "$schema"      = "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#"
                                contentVersion = "1.0.0.0"
                                outputs        = {}
                                parameters     = {
                                    logAnalytics = {
                                        type = "string"
                                    }
                                    logsEnabled  = {
                                        type = "string"
                                    }
                                }
                                resources      = [
                                    {
                                        apiVersion = "2017-05-01-preview"
                                        location   = "Global"
                                        name       = "subscriptionToLa"
                                        properties = {
                                            logs        = [
                                                {
                                                    category = "Administrative"
                                                    enabled  = "[parameters('logsEnabled')]"
                                                },
                                                {
                                                    category = "Security"
                                                    enabled  = "[parameters('logsEnabled')]"
                                                },
                                                {
                                                    category = "ServiceHealth"
                                                    enabled  = "[parameters('logsEnabled')]"
                                                },
                                                {
                                                    category = "Alert"
                                                    enabled  = "[parameters('logsEnabled')]"
                                                },
                                                {
                                                    category = "Recommendation"
                                                    enabled  = "[parameters('logsEnabled')]"
                                                },
                                                {
                                                    category = "Policy"
                                                    enabled  = "[parameters('logsEnabled')]"
                                                },
                                                {
                                                    category = "Autoscale"
                                                    enabled  = "[parameters('logsEnabled')]"
                                                },
                                                {
                                                    category = "ResourceHealth"
                                                    enabled  = "[parameters('logsEnabled')]"
                                                },
                                            ]
                                            workspaceId = "[parameters('logAnalytics')]"
                                        }
                                        type       = "Microsoft.Insights/diagnosticSettings"
                                    },
                                ]
                                variables      = {}
                            }
                        }
                    }
                    deploymentScope    = "Subscription"
                    existenceCondition = {
                        allOf = [
                            {
                                equals = "[parameters('logsEnabled')]"
                                field  = "Microsoft.Insights/diagnosticSettings/logs.enabled"
                            },
                            {
                                equals = "[parameters('logAnalytics')]"
                                field  = "Microsoft.Insights/diagnosticSettings/workspaceId"
                            },
                        ]
                    }
                    existenceScope     = "Subscription"
                    roleDefinitionIds  = [
                        "/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa",
                        "/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293",
                    ]
                    type               = "Microsoft.Insights/diagnosticSettings"
                }
                effect  = "[parameters('effect')]"
            }
        }
    )
    policy_type  = "BuiltIn"

    timeouts {}
}

resource "azurerm_subscription_policy_assignment" "activitylogs_sent_to_loganalyticsworkspace" {
  name                 = "activitylogs-sent-to-loganalyticsworkspace"
  policy_definition_id = azurerm_policy_definition.activitylogs_sent_to_loganalyticsworkspace.id
  subscription_id      = data.azurerm_subscription.mgmt-sub.subscription_id
}
# 
