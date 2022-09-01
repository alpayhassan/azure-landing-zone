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
  name                 = "audit_vm_manageddisks"
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
  name                 = "msftdefender_for_cloud"
  policy_definition_id = azurerm_policy_definition.enable_microsoft_defender_for_cloud.id
  management_group_id  = azurerm_management_group.mycompany-grp.id
  description          = "Identifies existing subscriptions that aren't monitored by Microsoft Defender for Cloud and protects them with Defender for Cloud's free features.Subscriptions already monitored will be considered compliant.To register newly created subscriptions, open the compliance tab, select the relevant non-compliant assignment, and create a remediation task."
  display_name         = "Enable Microsoft Defender for Cloud on your subscription"
}

resource "azurerm_policy_definition" "diagnostic_settings_storageaccount_to_loganalyticsworkspace" {
  description  = "Deploys the diagnostic settings for storage accounts to stream resource logs to a Log Analytics workspace when any storage account which is missing this diagnostic settings is created or updated."
    display_name = "Configure diagnostic settings for storage accounts to Log Analytics workspace"

    metadata     = jsonencode(
        {
            category = "Storage"
            version  = "1.3.0"
        }
    )
    mode         = "Indexed"
    name         = "6f8f98a4-f108-47cb-8e98-91a0d85cd474"
    parameters   = jsonencode(
        {
            StorageDelete               = {
                allowedValues = [
                    "True",
                    "False",
                ]
                defaultValue  = "True"
                metadata      = {
                    description = "Whether to stream StorageDelete logs to the Log Analytics workspace - True or False"
                    displayName = "StorageDelete - Enabled"
                }
                type          = "String"
            }
            StorageRead                 = {
                allowedValues = [
                    "True",
                    "False",
                ]
                defaultValue  = "True"
                metadata      = {
                    description = "Whether to stream StorageRead logs to the Log Analytics workspace - True or False"
                    displayName = "StorageRead - Enabled"
                }
                type          = "String"
            }
            StorageWrite                = {
                allowedValues = [
                    "True",
                    "False",
                ]
                defaultValue  = "True"
                metadata      = {
                    description = "Whether to stream StorageWrite logs to the Log Analytics workspace - True or False"
                    displayName = "StorageWrite - Enabled"
                }
                type          = "String"
            }
            Transaction                 = {
                allowedValues = [
                    "True",
                    "False",
                ]
                defaultValue  = "True"
                metadata      = {
                    description = "Whether to stream Transaction logs to the Log Analytics workspace - True or False"
                    displayName = "Transaction - Enabled"
                }
                type          = "String"
            }
            diagnosticsSettingNameToUse = {
                defaultValue = "storageAccountsDiagnosticsLogsToWorkspace"
                metadata     = {
                    description = "Name of the diagnostic settings."
                    displayName = "Setting name"
                }
                type         = "String"
            }
            effect                      = {
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
            logAnalytics                = {
                metadata = {
                    assignPermissions = true
                    description       = "Specify the Log Analytics workspace the storage account should be connected to."
                    displayName       = "Log Analytics workspace"
                    strongType        = "omsWorkspace"
                }
                type     = "String"
            }
            servicesToDeploy            = {
                allowedValues = [
                    "storageAccounts",
                    "blobServices",
                    "fileServices",
                    "tableServices",
                    "queueServices",
                ]
                defaultValue  = [
                    "storageAccounts",
                    "blobServices",
                    "fileServices",
                    "tableServices",
                    "queueServices",
                ]
                metadata      = {
                    description = "List of Storage services to deploy"
                    displayName = "Storage services to deploy"
                }
                type          = "Array"
            }
        }
    )
    policy_rule  = jsonencode(
        {
            if   = {
                equals = "Microsoft.Storage/storageAccounts"
                field  = "type"
            }
            then = {
                details = {
                    deployment         = {
                        properties = {
                            mode       = "incremental"
                            parameters = {
                                StorageDelete               = {
                                    value = "[parameters('StorageDelete')]"
                                }
                                StorageRead                 = {
                                    value = "[parameters('StorageRead')]"
                                }
                                StorageWrite                = {
                                    value = "[parameters('StorageWrite')]"
                                }
                                Transaction                 = {
                                    value = "[parameters('Transaction')]"
                                }
                                diagnosticsSettingNameToUse = {
                                    value = "[parameters('diagnosticsSettingNameToUse')]"
                                }
                                location                    = {
                                    value = "[field('location')]"
                                }
                                logAnalytics                = {
                                    value = "[parameters('logAnalytics')]"
                                }
                                resourceName                = {
                                    value = "[field('name')]"
                                }
                                servicesToDeploy            = {
                                    value = "[parameters('servicesToDeploy')]"
                                }
                            }
                            template   = {
                                "$schema"      = "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#"
                                contentVersion = "1.0.0.0"
                                outputs        = {}
                                parameters     = {
                                    StorageDelete               = {
                                        type = "string"
                                    }
                                    StorageRead                 = {
                                        type = "string"
                                    }
                                    StorageWrite                = {
                                        type = "string"
                                    }
                                    Transaction                 = {
                                        type = "string"
                                    }
                                    diagnosticsSettingNameToUse = {
                                        type = "string"
                                    }
                                    location                    = {
                                        type = "string"
                                    }
                                    logAnalytics                = {
                                        type = "string"
                                    }
                                    resourceName                = {
                                        type = "string"
                                    }
                                    servicesToDeploy            = {
                                        type = "array"
                                    }
                                }
                                resources      = [
                                    {
                                        apiVersion = "2017-05-01-preview"
                                        condition  = "[contains(parameters('servicesToDeploy'), 'blobServices')]"
                                        dependsOn  = []
                                        location   = "[parameters('location')]"
                                        name       = "[concat(parameters('resourceName'), '/default/', 'Microsoft.Insights/', parameters('diagnosticsSettingNameToUse'))]"
                                        properties = {
                                            logs        = [
                                                {
                                                    category = "StorageRead"
                                                    enabled  = "[parameters('StorageRead')]"
                                                },
                                                {
                                                    category = "StorageWrite"
                                                    enabled  = "[parameters('StorageWrite')]"
                                                },
                                                {
                                                    category = "StorageDelete"
                                                    enabled  = "[parameters('StorageDelete')]"
                                                },
                                            ]
                                            metrics     = [
                                                {
                                                    category        = "Transaction"
                                                    enabled         = "[parameters('Transaction')]"
                                                    retentionPolicy = {
                                                        days    = 0
                                                        enabled = false
                                                    }
                                                    timeGrain       = null
                                                },
                                            ]
                                            workspaceId = "[parameters('logAnalytics')]"
                                        }
                                        type       = "Microsoft.Storage/storageAccounts/blobServices/providers/diagnosticSettings"
                                    },
                                    {
                                        apiVersion = "2017-05-01-preview"
                                        condition  = "[contains(parameters('servicesToDeploy'), 'fileServices')]"
                                        dependsOn  = []
                                        location   = "[parameters('location')]"
                                        name       = "[concat(parameters('resourceName'), '/default/', 'Microsoft.Insights/', parameters('diagnosticsSettingNameToUse'))]"
                                        properties = {
                                            logs        = [
                                                {
                                                    category = "StorageRead"
                                                    enabled  = "[parameters('StorageRead')]"
                                                },
                                                {
                                                    category = "StorageWrite"
                                                    enabled  = "[parameters('StorageWrite')]"
                                                },
                                                {
                                                    category = "StorageDelete"
                                                    enabled  = "[parameters('StorageDelete')]"
                                                },
                                            ]
                                            metrics     = [
                                                {
                                                    category        = "Transaction"
                                                    enabled         = "[parameters('Transaction')]"
                                                    retentionPolicy = {
                                                        days    = 0
                                                        enabled = false
                                                    }
                                                    timeGrain       = null
                                                },
                                            ]
                                            workspaceId = "[parameters('logAnalytics')]"
                                        }
                                        type       = "Microsoft.Storage/storageAccounts/fileServices/providers/diagnosticSettings"
                                    },
                                    {
                                        apiVersion = "2017-05-01-preview"
                                        condition  = "[contains(parameters('servicesToDeploy'), 'tableServices')]"
                                        dependsOn  = []
                                        location   = "[parameters('location')]"
                                        name       = "[concat(parameters('resourceName'), '/default/', 'Microsoft.Insights/', parameters('diagnosticsSettingNameToUse'))]"
                                        properties = {
                                            logs        = [
                                                {
                                                    category = "StorageRead"
                                                    enabled  = "[parameters('StorageRead')]"
                                                },
                                                {
                                                    category = "StorageWrite"
                                                    enabled  = "[parameters('StorageWrite')]"
                                                },
                                                {
                                                    category = "StorageDelete"
                                                    enabled  = "[parameters('StorageDelete')]"
                                                },
                                            ]
                                            metrics     = [
                                                {
                                                    category        = "Transaction"
                                                    enabled         = "[parameters('Transaction')]"
                                                    retentionPolicy = {
                                                        days    = 0
                                                        enabled = false
                                                    }
                                                    timeGrain       = null
                                                },
                                            ]
                                            workspaceId = "[parameters('logAnalytics')]"
                                        }
                                        type       = "Microsoft.Storage/storageAccounts/tableServices/providers/diagnosticSettings"
                                    },
                                    {
                                        apiVersion = "2017-05-01-preview"
                                        condition  = "[contains(parameters('servicesToDeploy'), 'queueServices')]"
                                        dependsOn  = []
                                        location   = "[parameters('location')]"
                                        name       = "[concat(parameters('resourceName'), '/default/', 'Microsoft.Insights/', parameters('diagnosticsSettingNameToUse'))]"
                                        properties = {
                                            logs        = [
                                                {
                                                    category = "StorageRead"
                                                    enabled  = "[parameters('StorageRead')]"
                                                },
                                                {
                                                    category = "StorageWrite"
                                                    enabled  = "[parameters('StorageWrite')]"
                                                },
                                                {
                                                    category = "StorageDelete"
                                                    enabled  = "[parameters('StorageDelete')]"
                                                },
                                            ]
                                            metrics     = [
                                                {
                                                    category        = "Transaction"
                                                    enabled         = "[parameters('Transaction')]"
                                                    retentionPolicy = {
                                                        days    = 0
                                                        enabled = false
                                                    }
                                                    timeGrain       = null
                                                },
                                            ]
                                            workspaceId = "[parameters('logAnalytics')]"
                                        }
                                        type       = "Microsoft.Storage/storageAccounts/queueServices/providers/diagnosticSettings"
                                    },
                                    {
                                        apiVersion = "2017-05-01-preview"
                                        condition  = "[contains(parameters('servicesToDeploy'), 'storageAccounts')]"
                                        dependsOn  = []
                                        location   = "[parameters('location')]"
                                        name       = "[concat(parameters('resourceName'), '/', 'Microsoft.Insights/', parameters('diagnosticsSettingNameToUse'))]"
                                        properties = {
                                            metrics     = [
                                                {
                                                    category        = "Transaction"
                                                    enabled         = "[parameters('Transaction')]"
                                                    retentionPolicy = {
                                                        days    = 0
                                                        enabled = false
                                                    }
                                                    timeGrain       = null
                                                },
                                            ]
                                            workspaceId = "[parameters('logAnalytics')]"
                                        }
                                        type       = "Microsoft.Storage/storageAccounts/providers/diagnosticSettings"
                                    },
                                ]
                                variables      = {}
                            }
                        }
                    }
                    existenceCondition = {
                        allOf = [
                            {
                                anyof = [
                                    {
                                        equals = "True"
                                        field  = "Microsoft.Insights/diagnosticSettings/metrics.enabled"
                                    },
                                    {
                                        equals = "True"
                                        field  = "Microsoft.Insights/diagnosticSettings/logs.enabled"
                                    },
                                ]
                            },
                            {
                                equals = "[parameters('logAnalytics')]"
                                field  = "Microsoft.Insights/diagnosticSettings/workspaceId"
                            },
                        ]
                    }
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
    policy_type  = "Custom"

    timeouts {}
}

resource "azurerm_management_group_policy_assignment" "diagnostic_settings_storageaccount_to_loganalyticsworkspace" {
  name                 = "diags_storageacc_to_LAWS"
  policy_definition_id = azurerm_policy_definition.diagnostic_settings_storageaccount_to_loganalyticsworkspace.id
  management_group_id  = azurerm_management_group.mycompany-grp.id
  description          = "Deploys the diagnostic settings for storage accounts to stream resource logs to a Log Analytics workspace when any storage account which is missing this diagnostic settings is created or updated."
  display_name         = "Configure diagnostic settings for storage accounts to Log Analytics workspace"
}

resource "azurerm_policy_definition" "azure_monitor_agent_for_linux_vms" {
  description  = "Linux virtual machines should be monitored and secured through the deployed Azure Monitor Agent. The Azure Monitor Agent collects telemetry data from the guest OS. This policy will audit virtual machines with supported OS images in supported regions. Learn more: https://aka.ms/AMAOverview."
    display_name = "Linux virtual machines should have Azure Monitor Agent installed"

    metadata     = jsonencode(
        {
            category = "Monitoring"
            version  = "2.0.0"
        }
    )
    mode         = "Indexed"
    name         = "1afdc4b6-581a-45fb-b630-f1e6051e3e7a"
    parameters   = jsonencode(
        {
            effect                      = {
                allowedValues = [
                    "AuditIfNotExists",
                    "Disabled",
                ]
                defaultValue  = "AuditIfNotExists"
                metadata      = {
                    description = "Enable or disable the execution of the policy."
                    displayName = "Effect"
                }
                type          = "String"
            }
            listOfLinuxImageIdToInclude = {
                defaultValue = []
                metadata     = {
                    description = "List of virtual machine images that have supported Linux OS to add to scope. Example values: '/subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage'"
                    displayName = "Additional Virtual Machine Images"
                }
                type         = "Array"
            }
        }
    )
    policy_rule  = jsonencode(
        {
            if   = {
                allOf = [
                    {
                        equals = "Microsoft.Compute/virtualMachines"
                        field  = "type"
                    },
                    {
                        field = "location"
                        in    = [
                            "australiacentral",
                            "australiaeast",
                            "australiasoutheast",
                            "brazilsouth",
                            "canadacentral",
                            "canadaeast",
                            "centralindia",
                            "centralus",
                            "eastasia",
                            "eastus2euap",
                            "eastus",
                            "eastus2",
                            "francecentral",
                            "germanywestcentral",
                            "japaneast",
                            "japanwest",
                            "jioindiawest",
                            "koreacentral",
                            "koreasouth",
                            "northcentralus",
                            "northeurope",
                            "norwayeast",
                            "southafricanorth",
                            "southcentralus",
                            "southeastasia",
                            "southindia",
                            "switzerlandnorth",
                            "uaenorth",
                            "uksouth",
                            "ukwest",
                            "westcentralus",
                            "westeurope",
                            "westindia",
                            "westus",
                            "westus2",
                        ]
                    },
                    {
                        anyOf = [
                            {
                                field = "Microsoft.Compute/imageId"
                                in    = "[parameters('listOfLinuxImageIdToInclude')]"
                            },
                            {
                                allOf = [
                                    {
                                        equals = "RedHat"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        field = "Microsoft.Compute/imageOffer"
                                        in    = [
                                            "RHEL",
                                            "RHEL-BYOS",
                                            "RHEL-HA",
                                            "RHEL-SAP",
                                            "RHEL-SAP-APPS",
                                            "RHEL-SAP-HA",
                                        ]
                                    },
                                    {
                                        anyOf = [
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "7*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "8*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "rhel-lvm7*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "rhel-lvm8*"
                                            },
                                        ]
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "SUSE"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        anyOf = [
                                            {
                                                allOf = [
                                                    {
                                                        field = "Microsoft.Compute/imageOffer"
                                                        in    = [
                                                            "SLES",
                                                            "SLES-HPC",
                                                            "SLES-HPC-Priority",
                                                            "SLES-SAP",
                                                            "SLES-SAP-BYOS",
                                                            "SLES-Priority",
                                                            "SLES-BYOS",
                                                            "SLES-SAPCAL",
                                                            "SLES-Standard",
                                                        ]
                                                    },
                                                    {
                                                        anyOf = [
                                                            {
                                                                field = "Microsoft.Compute/imageSku"
                                                                like  = "12*"
                                                            },
                                                            {
                                                                field = "Microsoft.Compute/imageSku"
                                                                like  = "15*"
                                                            },
                                                        ]
                                                    },
                                                ]
                                            },
                                            {
                                                allOf = [
                                                    {
                                                        anyOf = [
                                                            {
                                                                field = "Microsoft.Compute/imageOffer"
                                                                like  = "sles-12*"
                                                            },
                                                            {
                                                                field = "Microsoft.Compute/imageOffer"
                                                                like  = "sles-15*"
                                                            },
                                                        ]
                                                    },
                                                    {
                                                        field = "Microsoft.Compute/imageSku"
                                                        in    = [
                                                            "gen1",
                                                            "gen2",
                                                        ]
                                                    },
                                                ]
                                            },
                                        ]
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "Canonical"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        equals = "UbuntuServer"
                                        field  = "Microsoft.Compute/imageOffer"
                                    },
                                    {
                                        anyOf = [
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                in    = [
                                                    "14.04.0-lts",
                                                    "14.04.1-lts",
                                                    "14.04.2-lts",
                                                    "14.04.3-lts",
                                                    "14.04.4-lts",
                                                    "14.04.5-lts",
                                                ]
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                in    = [
                                                    "16.04-lts",
                                                    "16.04.0-lts",
                                                    "16_04-lts-gen2",
                                                    "16_04_0-lts-gen2",
                                                ]
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                in    = [
                                                    "18.04-lts",
                                                    "18_04-lts-gen2",
                                                ]
                                            },
                                        ]
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "Canonical"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        anyOf = [
                                            {
                                                field = "Microsoft.Compute/imageOffer"
                                                like  = "0001-com-ubuntu-server-*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageOffer"
                                                like  = "0001-com-ubuntu-pro-*"
                                            },
                                        ]
                                    },
                                    {
                                        anyOf = [
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                in    = [
                                                    "pro-16_04-lts",
                                                    "pro-16_04-lts-gen2",
                                                    "pro-18_04-lts",
                                                    "pro-18_04-lts-gen2",
                                                    "20_04-lts",
                                                    "20_04-lts-gen2",
                                                    "pro-20_04-lts",
                                                    "pro-20_04-lts-gen2",
                                                ]
                                            },
                                        ]
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "Oracle"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        equals = "Oracle-Linux"
                                        field  = "Microsoft.Compute/imageOffer"
                                    },
                                    {
                                        anyOf = [
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "7*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "8*"
                                            },
                                        ]
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "OpenLogic"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        field = "Microsoft.Compute/imageOffer"
                                        in    = [
                                            "CentOS",
                                            "Centos-LVM",
                                            "CentOS-SRIOV",
                                        ]
                                    },
                                    {
                                        anyOf = [
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "6*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "7*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "8*"
                                            },
                                        ]
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "cloudera"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        equals = "cloudera-centos-os"
                                        field  = "Microsoft.Compute/imageOffer"
                                    },
                                    {
                                        field = "Microsoft.Compute/imageSku"
                                        like  = "7*"
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "credativ"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        field = "Microsoft.Compute/imageOffer"
                                        in    = [
                                            "Debian",
                                        ]
                                    },
                                    {
                                        equals = "9"
                                        field  = "Microsoft.Compute/imageSku"
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "Debian"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        field = "Microsoft.Compute/imageOffer"
                                        in    = [
                                            "debian-10",
                                        ]
                                    },
                                    {
                                        field = "Microsoft.Compute/imageSku"
                                        in    = [
                                            "10",
                                            "10-gen2",
                                        ]
                                    },
                                ]
                            },
                        ]
                    },
                ]
            }
            then = {
                details = {
                    existenceCondition = {
                        allOf = [
                            {
                                equals = "AzureMonitorLinuxAgent"
                                field  = "Microsoft.Compute/virtualMachines/extensions/type"
                            },
                            {
                                equals = "Microsoft.Azure.Monitor"
                                field  = "Microsoft.Compute/virtualMachines/extensions/publisher"
                            },
                            {
                                equals = "Succeeded"
                                field  = "Microsoft.Compute/virtualMachines/extensions/provisioningState"
                            },
                        ]
                    }
                    type               = "Microsoft.Compute/virtualMachines/extensions"
                }
                effect  = "[parameters('effect')]"
            }
        }
    )
    policy_type  = "BuiltIn"

    timeouts {}
}

resource "azurerm_management_group_policy_assignment" "azure_monitor_agent_for_linux_vms" {
  name                 = "monitoragent_linuxvms"
  policy_definition_id = azurerm_policy_definition.azure_monitor_agent_for_linux_vms.id
  management_group_id  = azurerm_management_group.mycompany-grp.id
  description          = "Linux virtual machines should be monitored and secured through the deployed Azure Monitor Agent. The Azure Monitor Agent collects telemetry data from the guest OS. This policy will audit virtual machines with supported OS images in supported regions. Learn more: https://aka.ms/AMAOverview"
  display_name         = "Linux virtual machines should have Azure Monitor Agent installed"
}

resource "azurerm_policy_definition" "azure_monitor_agent_for_linux_vm_scalesets" {
  description  = "Linux virtual machine scale sets should be monitored and secured through the deployed Azure Monitor Agent. The Azure Monitor Agent collects telemetry data from the guest OS. This policy will audit virtual machine scale sets with supported OS images in supported regions. Learn more: https://aka.ms/AMAOverview."
    display_name = "Linux virtual machine scale sets should have Azure Monitor Agent installed"

    metadata     = jsonencode(
        {
            category = "Monitoring"
            version  = "2.0.0"
        }
    )
    mode         = "Indexed"
    name         = "32ade945-311e-4249-b8a4-a549924234d7"
    parameters   = jsonencode(
        {
            effect                      = {
                allowedValues = [
                    "AuditIfNotExists",
                    "Disabled",
                ]
                defaultValue  = "AuditIfNotExists"
                metadata      = {
                    description = "Enable or disable the execution of the policy."
                    displayName = "Effect"
                }
                type          = "String"
            }
            listOfLinuxImageIdToInclude = {
                defaultValue = []
                metadata     = {
                    description = "List of virtual machine images that have supported Linux OS to add to scope. Example values: '/subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage'"
                    displayName = "Additional Virtual Machine Images"
                }
                type         = "Array"
            }
        }
    )
    policy_rule  = jsonencode(
        {
            if   = {
                allOf = [
                    {
                        equals = "Microsoft.Compute/virtualMachineScaleSets"
                        field  = "type"
                    },
                    {
                        field = "location"
                        in    = [
                            "australiacentral",
                            "australiaeast",
                            "australiasoutheast",
                            "brazilsouth",
                            "canadacentral",
                            "canadaeast",
                            "centralindia",
                            "centralus",
                            "eastasia",
                            "eastus2euap",
                            "eastus",
                            "eastus2",
                            "francecentral",
                            "germanywestcentral",
                            "japaneast",
                            "japanwest",
                            "jioindiawest",
                            "koreacentral",
                            "koreasouth",
                            "northcentralus",
                            "northeurope",
                            "norwayeast",
                            "southafricanorth",
                            "southcentralus",
                            "southeastasia",
                            "southindia",
                            "switzerlandnorth",
                            "uaenorth",
                            "uksouth",
                            "ukwest",
                            "westcentralus",
                            "westeurope",
                            "westindia",
                            "westus",
                            "westus2",
                        ]
                    },
                    {
                        anyOf = [
                            {
                                field = "Microsoft.Compute/imageId"
                                in    = "[parameters('listOfLinuxImageIdToInclude')]"
                            },
                            {
                                allOf = [
                                    {
                                        equals = "RedHat"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        field = "Microsoft.Compute/imageOffer"
                                        in    = [
                                            "RHEL",
                                            "RHEL-BYOS",
                                            "RHEL-HA",
                                            "RHEL-SAP",
                                            "RHEL-SAP-APPS",
                                            "RHEL-SAP-HA",
                                        ]
                                    },
                                    {
                                        anyOf = [
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "7*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "8*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "rhel-lvm7*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "rhel-lvm8*"
                                            },
                                        ]
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "SUSE"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        anyOf = [
                                            {
                                                allOf = [
                                                    {
                                                        field = "Microsoft.Compute/imageOffer"
                                                        in    = [
                                                            "SLES",
                                                            "SLES-HPC",
                                                            "SLES-HPC-Priority",
                                                            "SLES-SAP",
                                                            "SLES-SAP-BYOS",
                                                            "SLES-Priority",
                                                            "SLES-BYOS",
                                                            "SLES-SAPCAL",
                                                            "SLES-Standard",
                                                        ]
                                                    },
                                                    {
                                                        anyOf = [
                                                            {
                                                                field = "Microsoft.Compute/imageSku"
                                                                like  = "12*"
                                                            },
                                                            {
                                                                field = "Microsoft.Compute/imageSku"
                                                                like  = "15*"
                                                            },
                                                        ]
                                                    },
                                                ]
                                            },
                                            {
                                                allOf = [
                                                    {
                                                        anyOf = [
                                                            {
                                                                field = "Microsoft.Compute/imageOffer"
                                                                like  = "sles-12*"
                                                            },
                                                            {
                                                                field = "Microsoft.Compute/imageOffer"
                                                                like  = "sles-15*"
                                                            },
                                                        ]
                                                    },
                                                    {
                                                        field = "Microsoft.Compute/imageSku"
                                                        in    = [
                                                            "gen1",
                                                            "gen2",
                                                        ]
                                                    },
                                                ]
                                            },
                                        ]
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "Canonical"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        equals = "UbuntuServer"
                                        field  = "Microsoft.Compute/imageOffer"
                                    },
                                    {
                                        anyOf = [
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                in    = [
                                                    "14.04.0-lts",
                                                    "14.04.1-lts",
                                                    "14.04.2-lts",
                                                    "14.04.3-lts",
                                                    "14.04.4-lts",
                                                    "14.04.5-lts",
                                                ]
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                in    = [
                                                    "16.04-lts",
                                                    "16.04.0-lts",
                                                    "16_04-lts-gen2",
                                                    "16_04_0-lts-gen2",
                                                ]
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                in    = [
                                                    "18.04-lts",
                                                    "18_04-lts-gen2",
                                                ]
                                            },
                                        ]
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "Canonical"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        anyOf = [
                                            {
                                                field = "Microsoft.Compute/imageOffer"
                                                like  = "0001-com-ubuntu-server-*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageOffer"
                                                like  = "0001-com-ubuntu-pro-*"
                                            },
                                        ]
                                    },
                                    {
                                        anyOf = [
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                in    = [
                                                    "pro-16_04-lts",
                                                    "pro-16_04-lts-gen2",
                                                    "pro-18_04-lts",
                                                    "pro-18_04-lts-gen2",
                                                    "20_04-lts",
                                                    "20_04-lts-gen2",
                                                    "pro-20_04-lts",
                                                    "pro-20_04-lts-gen2",
                                                ]
                                            },
                                        ]
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "Oracle"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        equals = "Oracle-Linux"
                                        field  = "Microsoft.Compute/imageOffer"
                                    },
                                    {
                                        anyOf = [
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "7*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "8*"
                                            },
                                        ]
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "OpenLogic"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        field = "Microsoft.Compute/imageOffer"
                                        in    = [
                                            "CentOS",
                                            "Centos-LVM",
                                            "CentOS-SRIOV",
                                        ]
                                    },
                                    {
                                        anyOf = [
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "6*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "7*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "8*"
                                            },
                                        ]
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "cloudera"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        equals = "cloudera-centos-os"
                                        field  = "Microsoft.Compute/imageOffer"
                                    },
                                    {
                                        field = "Microsoft.Compute/imageSku"
                                        like  = "7*"
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "credativ"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        field = "Microsoft.Compute/imageOffer"
                                        in    = [
                                            "Debian",
                                        ]
                                    },
                                    {
                                        equals = "9"
                                        field  = "Microsoft.Compute/imageSku"
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "Debian"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        field = "Microsoft.Compute/imageOffer"
                                        in    = [
                                            "debian-10",
                                        ]
                                    },
                                    {
                                        field = "Microsoft.Compute/imageSku"
                                        in    = [
                                            "10",
                                            "10-gen2",
                                        ]
                                    },
                                ]
                            },
                        ]
                    },
                ]
            }
            then = {
                details = {
                    existenceCondition = {
                        allOf = [
                            {
                                equals = "AzureMonitorLinuxAgent"
                                field  = "Microsoft.Compute/virtualMachineScaleSets/extensions/type"
                            },
                            {
                                equals = "Microsoft.Azure.Monitor"
                                field  = "Microsoft.Compute/virtualMachineScaleSets/extensions/publisher"
                            },
                            {
                                equals = "Succeeded"
                                field  = "Microsoft.Compute/virtualMachineScaleSets/extensions/provisioningState"
                            },
                        ]
                    }
                    type               = "Microsoft.Compute/virtualMachineScaleSets/extensions"
                }
                effect  = "[parameters('effect')]"
            }
        }
    )
    policy_type  = "BuiltIn"

    timeouts {}
}

resource "azurerm_management_group_policy_assignment" "azure_monitor_agent_for_linux_vm_scalesets" {
  name                 = "monitoragent_linuxvm_ss"
  policy_definition_id = azurerm_policy_definition.azure_monitor_agent_for_linux_vm_scalesets.id
  management_group_id  = azurerm_management_group.mycompany-grp.id
  description          = "Linux virtual machine scale sets should be monitored and secured through the deployed Azure Monitor Agent. The Azure Monitor Agent collects telemetry data from the guest OS. This policy will audit virtual machine scale sets with supported OS images in supported regions. Learn more: https://aka.ms/AMAOverview."
  display_name         = "Linux virtual machine scale sets should have Azure Monitor Agent installed"
}

resource "azurerm_policy_definition" "azure_monitor_agent_for_linux_arc_enabled_machines" {
  description  = "Linux Arc-enabled machines should be monitored and secured through the deployed Azure Monitor Agent. The Azure Monitor Agent collects telemetry data from the guest OS. This policy will audit Arc-enabled machines in supported regions. Learn more: https://aka.ms/AMAOverview."
    display_name = "Linux Arc-enabled machines should have Azure Monitor Agent installed"

    metadata     = jsonencode(
        {
            category = "Monitoring"
            version  = "1.0.1"
        }
    )
    mode         = "Indexed"
    name         = "f17d891d-ff20-46f2-bad3-9e0a5403a4d3"
    parameters   = jsonencode(
        {
            effect = {
                allowedValues = [
                    "AuditIfNotExists",
                    "Disabled",
                ]
                defaultValue  = "AuditIfNotExists"
                metadata      = {
                    description = "Enable or disable the execution of the policy."
                    displayName = "Effect"
                }
                type          = "String"
            }
        }
    )
    policy_rule  = jsonencode(
        {
            if   = {
                allOf = [
                    {
                        equals = "Microsoft.HybridCompute/machines"
                        field  = "type"
                    },
                    {
                        equals = "linux"
                        field  = "Microsoft.HybridCompute/machines/osName"
                    },
                    {
                        field = "location"
                        in    = [
                            "australiacentral",
                            "australiaeast",
                            "australiasoutheast",
                            "brazilsouth",
                            "canadacentral",
                            "canadaeast",
                            "centralindia",
                            "centralus",
                            "eastasia",
                            "eastus2euap",
                            "eastus",
                            "eastus2",
                            "francecentral",
                            "germanywestcentral",
                            "japaneast",
                            "japanwest",
                            "jioindiawest",
                            "koreacentral",
                            "koreasouth",
                            "northcentralus",
                            "northeurope",
                            "norwayeast",
                            "southafricanorth",
                            "southcentralus",
                            "southeastasia",
                            "southindia",
                            "switzerlandnorth",
                            "uaenorth",
                            "uksouth",
                            "ukwest",
                            "westcentralus",
                            "westeurope",
                            "westindia",
                            "westus",
                            "westus2",
                        ]
                    },
                ]
            }
            then = {
                details = {
                    existenceCondition = {
                        allOf = [
                            {
                                equals = "AzureMonitorLinuxAgent"
                                field  = "Microsoft.HybridCompute/machines/extensions/type"
                            },
                            {
                                equals = "Microsoft.Azure.Monitor"
                                field  = "Microsoft.HybridCompute/machines/extensions/publisher"
                            },
                            {
                                equals = "Succeeded"
                                field  = "Microsoft.HybridCompute/machines/extensions/provisioningState"
                            },
                        ]
                    }
                    type               = "Microsoft.HybridCompute/machines/extensions"
                }
                effect  = "[parameters('effect')]"
            }
        }
    )
    policy_type  = "BuiltIn"

    timeouts {}
}

resource "azurerm_management_group_policy_assignment" "azure_monitor_agent_for_linux_arc_enabled_machines" {
  name                 = "monitoragent_linux_arc"
  policy_definition_id = azurerm_policy_definition.azure_monitor_agent_for_linux_arc_enabled_machines.id
  management_group_id  = azurerm_management_group.mycompany-grp.id
  description          = "Linux Arc-enabled machines should be monitored and secured through the deployed Azure Monitor Agent. The Azure Monitor Agent collects telemetry data from the guest OS. This policy will audit Arc-enabled machines in supported regions. Learn more: https://aka.ms/AMAOverview."
  display_name         = "Linux Arc-enabled machines should have Azure Monitor Agent installed"
}

resource "azurerm_policy_definition" "azure_monitor_agent_for_windows_vms" {
  description  = "Windows virtual machines should be monitored and secured through the deployed Azure Monitor Agent. The Azure Monitor Agent collects telemetry data from the guest OS. Windows virtual machines with supported OS and in supported regions are monitored for Azure Monitor Agent deployment. Learn more: https://aka.ms/AMAOverview."
    display_name = "Windows virtual machines should have Azure Monitor Agent installed"

    metadata     = jsonencode(
        {
            category = "Monitoring"
            version  = "3.0.0"
        }
    )
    mode         = "Indexed"
    name         = "c02729e5-e5e7-4458-97fa-2b5ad0661f28"
    parameters   = jsonencode(
        {
            effect                        = {
                allowedValues = [
                    "AuditIfNotExists",
                    "Disabled",
                ]
                defaultValue  = "AuditIfNotExists"
                metadata      = {
                    description = "Enable or disable the execution of the policy."
                    displayName = "Effect"
                }
                type          = "String"
            }
            listOfWindowsImageIdToInclude = {
                defaultValue = []
                metadata     = {
                    description = "List of virtual machine images that have supported Windows OS to add to scope. Example values: '/subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage'"
                    displayName = "Additional Virtual Machine Images"
                }
                type         = "Array"
            }
        }
    )
    policy_rule  = jsonencode(
        {
            if   = {
                allOf = [
                    {
                        equals = "Microsoft.Compute/virtualMachines"
                        field  = "type"
                    },
                    {
                        field = "location"
                        in    = [
                            "australiacentral",
                            "australiaeast",
                            "australiasoutheast",
                            "brazilsouth",
                            "canadacentral",
                            "canadaeast",
                            "centralindia",
                            "centralus",
                            "eastasia",
                            "eastus2euap",
                            "eastus",
                            "eastus2",
                            "francecentral",
                            "germanywestcentral",
                            "japaneast",
                            "japanwest",
                            "jioindiawest",
                            "koreacentral",
                            "koreasouth",
                            "northcentralus",
                            "northeurope",
                            "norwayeast",
                            "southafricanorth",
                            "southcentralus",
                            "southeastasia",
                            "southindia",
                            "switzerlandnorth",
                            "uaenorth",
                            "uksouth",
                            "ukwest",
                            "westcentralus",
                            "westeurope",
                            "westindia",
                            "westus",
                            "westus2",
                        ]
                    },
                    {
                        anyOf = [
                            {
                                field = "Microsoft.Compute/imageId"
                                in    = "[parameters('listOfWindowsImageIdToInclude')]"
                            },
                            {
                                allOf = [
                                    {
                                        equals = "MicrosoftWindowsServer"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        equals = "WindowsServer"
                                        field  = "Microsoft.Compute/imageOffer"
                                    },
                                    {
                                        anyOf = [
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "2008-R2-SP1*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "2012-*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "2016-*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "2019-*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "2022-*"
                                            },
                                        ]
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "MicrosoftWindowsServer"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        equals = "WindowsServerSemiAnnual"
                                        field  = "Microsoft.Compute/imageOffer"
                                    },
                                    {
                                        field = "Microsoft.Compute/imageSKU"
                                        in    = [
                                            "Datacenter-Core-1709-smalldisk",
                                            "Datacenter-Core-1709-with-Containers-smalldisk",
                                            "Datacenter-Core-1803-with-Containers-smalldisk",
                                        ]
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "MicrosoftWindowsServerHPCPack"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        equals = "WindowsServerHPCPack"
                                        field  = "Microsoft.Compute/imageOffer"
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "MicrosoftSQLServer"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        anyOf = [
                                            {
                                                field = "Microsoft.Compute/imageOffer"
                                                like  = "*-WS2022"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageOffer"
                                                like  = "*-WS2022-BYOL"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageOffer"
                                                like  = "*-WS2019"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageOffer"
                                                like  = "*-WS2019-BYOL"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageOffer"
                                                like  = "*-WS2016"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageOffer"
                                                like  = "*-WS2016-BYOL"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageOffer"
                                                like  = "*-WS2012R2"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageOffer"
                                                like  = "*-WS2012R2-BYOL"
                                            },
                                        ]
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "MicrosoftRServer"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        equals = "MLServer-WS2016"
                                        field  = "Microsoft.Compute/imageOffer"
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "MicrosoftVisualStudio"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        field = "Microsoft.Compute/imageOffer"
                                        in    = [
                                            "VisualStudio",
                                            "Windows",
                                        ]
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "MicrosoftDynamicsAX"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        equals = "Dynamics"
                                        field  = "Microsoft.Compute/imageOffer"
                                    },
                                    {
                                        equals = "Pre-Req-AX7-Onebox-U8"
                                        field  = "Microsoft.Compute/imageSKU"
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "microsoft-ads"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        equals = "windows-data-science-vm"
                                        field  = "Microsoft.Compute/imageOffer"
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "MicrosoftWindowsDesktop"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        equals = "Windows-10"
                                        field  = "Microsoft.Compute/imageOffer"
                                    },
                                ]
                            },
                        ]
                    },
                ]
            }
            then = {
                details = {
                    existenceCondition = {
                        allOf = [
                            {
                                equals = "AzureMonitorWindowsAgent"
                                field  = "Microsoft.Compute/virtualMachines/extensions/type"
                            },
                            {
                                equals = "Microsoft.Azure.Monitor"
                                field  = "Microsoft.Compute/virtualMachines/extensions/publisher"
                            },
                            {
                                equals = "Succeeded"
                                field  = "Microsoft.Compute/virtualMachines/extensions/provisioningState"
                            },
                        ]
                    }
                    type               = "Microsoft.Compute/virtualMachines/extensions"
                }
                effect  = "[parameters('effect')]"
            }
        }
    )
    policy_type  = "BuiltIn"

    timeouts {}
}

resource "azurerm_management_group_policy_assignment" "azure_monitor_agent_for_windows_vms" {
  name                 = "monitoragent_windowsvms"
  policy_definition_id = azurerm_policy_definition.azure_monitor_agent_for_windows_vms.id
  management_group_id  = azurerm_management_group.mycompany-grp.id
  description          = "Windows virtual machines should be monitored and secured through the deployed Azure Monitor Agent. The Azure Monitor Agent collects telemetry data from the guest OS. Windows virtual machines with supported OS and in supported regions are monitored for Azure Monitor Agent deployment. Learn more: https://aka.ms/AMAOverview."
  display_name         = "Windows virtual machines should have Azure Monitor Agent installed"
}

resource "azurerm_policy_definition" "azure_monitor_agent_for_windows_vm_scale_sets" {
  description  = "Windows virtual machine scale sets should be monitored and secured through the deployed Azure Monitor Agent. The Azure Monitor Agent collects telemetry data from the guest OS. Virtual machine scale sets with supported OS and in supported regions are monitored for Azure Monitor Agent deployment. Learn more: https://aka.ms/AMAOverview."
    display_name = "Windows virtual machine scale sets should have Azure Monitor Agent installed"

    metadata     = jsonencode(
        {
            category = "Monitoring"
            version  = "3.0.0"
        }
    )
    mode         = "Indexed"
    name         = "3672e6f7-a74d-4763-b138-fcf332042f8f"
    parameters   = jsonencode(
        {
            effect                        = {
                allowedValues = [
                    "AuditIfNotExists",
                    "Disabled",
                ]
                defaultValue  = "AuditIfNotExists"
                metadata      = {
                    description = "Enable or disable the execution of the policy."
                    displayName = "Effect"
                }
                type          = "String"
            }
            listOfWindowsImageIdToInclude = {
                defaultValue = []
                metadata     = {
                    description = "List of virtual machine images that have supported Windows OS to add to scope. Example values: '/subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage'"
                    displayName = "Additional Virtual Machine Images"
                }
                type         = "Array"
            }
        }
    )
    policy_rule  = jsonencode(
        {
            if   = {
                allOf = [
                    {
                        equals = "Microsoft.Compute/virtualMachineScaleSets"
                        field  = "type"
                    },
                    {
                        field = "location"
                        in    = [
                            "australiacentral",
                            "australiaeast",
                            "australiasoutheast",
                            "brazilsouth",
                            "canadacentral",
                            "canadaeast",
                            "centralindia",
                            "centralus",
                            "eastasia",
                            "eastus2euap",
                            "eastus",
                            "eastus2",
                            "francecentral",
                            "germanywestcentral",
                            "japaneast",
                            "japanwest",
                            "jioindiawest",
                            "koreacentral",
                            "koreasouth",
                            "northcentralus",
                            "northeurope",
                            "norwayeast",
                            "southafricanorth",
                            "southcentralus",
                            "southeastasia",
                            "southindia",
                            "switzerlandnorth",
                            "uaenorth",
                            "uksouth",
                            "ukwest",
                            "westcentralus",
                            "westeurope",
                            "westindia",
                            "westus",
                            "westus2",
                        ]
                    },
                    {
                        anyOf = [
                            {
                                field = "Microsoft.Compute/imageId"
                                in    = "[parameters('listOfWindowsImageIdToInclude')]"
                            },
                            {
                                allOf = [
                                    {
                                        equals = "MicrosoftWindowsServer"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        equals = "WindowsServer"
                                        field  = "Microsoft.Compute/imageOffer"
                                    },
                                    {
                                        anyOf = [
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "2008-R2-SP1*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "2012-*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "2016-*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "2019-*"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageSku"
                                                like  = "2022-*"
                                            },
                                        ]
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "MicrosoftWindowsServer"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        equals = "WindowsServerSemiAnnual"
                                        field  = "Microsoft.Compute/imageOffer"
                                    },
                                    {
                                        field = "Microsoft.Compute/imageSKU"
                                        in    = [
                                            "Datacenter-Core-1709-smalldisk",
                                            "Datacenter-Core-1709-with-Containers-smalldisk",
                                            "Datacenter-Core-1803-with-Containers-smalldisk",
                                        ]
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "MicrosoftWindowsServerHPCPack"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        equals = "WindowsServerHPCPack"
                                        field  = "Microsoft.Compute/imageOffer"
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "MicrosoftSQLServer"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        anyOf = [
                                            {
                                                field = "Microsoft.Compute/imageOffer"
                                                like  = "*-WS2022"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageOffer"
                                                like  = "*-WS2022-BYOL"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageOffer"
                                                like  = "*-WS2019"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageOffer"
                                                like  = "*-WS2019-BYOL"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageOffer"
                                                like  = "*-WS2016"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageOffer"
                                                like  = "*-WS2016-BYOL"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageOffer"
                                                like  = "*-WS2012R2"
                                            },
                                            {
                                                field = "Microsoft.Compute/imageOffer"
                                                like  = "*-WS2012R2-BYOL"
                                            },
                                        ]
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "MicrosoftRServer"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        equals = "MLServer-WS2016"
                                        field  = "Microsoft.Compute/imageOffer"
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "MicrosoftVisualStudio"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        field = "Microsoft.Compute/imageOffer"
                                        in    = [
                                            "VisualStudio",
                                            "Windows",
                                        ]
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "MicrosoftDynamicsAX"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        equals = "Dynamics"
                                        field  = "Microsoft.Compute/imageOffer"
                                    },
                                    {
                                        equals = "Pre-Req-AX7-Onebox-U8"
                                        field  = "Microsoft.Compute/imageSKU"
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "microsoft-ads"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        equals = "windows-data-science-vm"
                                        field  = "Microsoft.Compute/imageOffer"
                                    },
                                ]
                            },
                            {
                                allOf = [
                                    {
                                        equals = "MicrosoftWindowsDesktop"
                                        field  = "Microsoft.Compute/imagePublisher"
                                    },
                                    {
                                        equals = "Windows-10"
                                        field  = "Microsoft.Compute/imageOffer"
                                    },
                                ]
                            },
                        ]
                    },
                ]
            }
            then = {
                details = {
                    existenceCondition = {
                        allOf = [
                            {
                                equals = "AzureMonitorWindowsAgent"
                                field  = "Microsoft.Compute/virtualMachineScaleSets/extensions/type"
                            },
                            {
                                equals = "Microsoft.Azure.Monitor"
                                field  = "Microsoft.Compute/virtualMachineScaleSets/extensions/publisher"
                            },
                            {
                                equals = "Succeeded"
                                field  = "Microsoft.Compute/virtualMachineScaleSets/extensions/provisioningState"
                            },
                        ]
                    }
                    type               = "Microsoft.Compute/virtualMachineScaleSets/extensions"
                }
                effect  = "[parameters('effect')]"
            }
        }
    )
    policy_type  = "BuiltIn"

    timeouts {}
}

resource "azurerm_management_group_policy_assignment" "azure_monitor_agent_for_windows_vm_scale_sets" {
  name                 = "monitoragent_wndwsvm_ss"
  policy_definition_id = azurerm_policy_definition.azure_monitor_agent_for_windows_vm_scale_sets.id
  management_group_id  = azurerm_management_group.mycompany-grp.id
  description          = "Windows virtual machine scale sets should be monitored and secured through the deployed Azure Monitor Agent. The Azure Monitor Agent collects telemetry data from the guest OS. Virtual machine scale sets with supported OS and in supported regions are monitored for Azure Monitor Agent deployment. Learn more: https://aka.ms/AMAOverview."
  display_name         = "Windows virtual machine scale sets should have Azure Monitor Agent installed"
}

resource "azurerm_policy_definition" "azure_monitor_agent_for_windows_arc_enabled_machines" {
  description  = "Windows Arc-enabled machines should be monitored and secured through the deployed Azure Monitor Agent. The Azure Monitor Agent collects telemetry data from the guest OS. Windows Arc-enabled machines in supported regions are monitored for Azure Monitor Agent deployment. Learn more: https://aka.ms/AMAOverview."
    display_name = "Windows Arc-enabled machines should have Azure Monitor Agent installed"

    metadata     = jsonencode(
        {
            category = "Monitoring"
            version  = "1.0.1"
        }
    )
    mode         = "Indexed"
    name         = "ec621e21-8b48-403d-a549-fc9023d4747f"
    parameters   = jsonencode(
        {
            effect = {
                allowedValues = [
                    "AuditIfNotExists",
                    "Disabled",
                ]
                defaultValue  = "AuditIfNotExists"
                metadata      = {
                    description = "Enable or disable the execution of the policy."
                    displayName = "Effect"
                }
                type          = "String"
            }
        }
    )
    policy_rule  = jsonencode(
        {
            if   = {
                allOf = [
                    {
                        equals = "Microsoft.HybridCompute/machines"
                        field  = "type"
                    },
                    {
                        equals = "Windows"
                        field  = "Microsoft.HybridCompute/machines/osName"
                    },
                    {
                        field = "location"
                        in    = [
                            "australiacentral",
                            "australiaeast",
                            "australiasoutheast",
                            "brazilsouth",
                            "canadacentral",
                            "canadaeast",
                            "centralindia",
                            "centralus",
                            "eastasia",
                            "eastus2euap",
                            "eastus",
                            "eastus2",
                            "francecentral",
                            "germanywestcentral",
                            "japaneast",
                            "japanwest",
                            "jioindiawest",
                            "koreacentral",
                            "koreasouth",
                            "northcentralus",
                            "northeurope",
                            "norwayeast",
                            "southafricanorth",
                            "southcentralus",
                            "southeastasia",
                            "southindia",
                            "switzerlandnorth",
                            "uaenorth",
                            "uksouth",
                            "ukwest",
                            "westcentralus",
                            "westeurope",
                            "westindia",
                            "westus",
                            "westus2",
                        ]
                    },
                ]
            }
            then = {
                details = {
                    existenceCondition = {
                        allOf = [
                            {
                                equals = "AzureMonitorWindowsAgent"
                                field  = "Microsoft.HybridCompute/machines/extensions/type"
                            },
                            {
                                equals = "Microsoft.Azure.Monitor"
                                field  = "Microsoft.HybridCompute/machines/extensions/publisher"
                            },
                            {
                                equals = "Succeeded"
                                field  = "Microsoft.HybridCompute/machines/extensions/provisioningState"
                            },
                        ]
                    }
                    type               = "Microsoft.HybridCompute/machines/extensions"
                }
                effect  = "[parameters('effect')]"
            }
        }
    )
    policy_type  = "BuiltIn"

    timeouts {}
}

resource "azurerm_management_group_policy_assignment" "azure_monitor_agent_for_windows_arc_enabled_machines" {
  name                 = "monitoragent_windows_arc"
  policy_definition_id = azurerm_policy_definition.azure_monitor_agent_for_windows_arc_enabled_machines.id
  management_group_id  = azurerm_management_group.mycompany-grp.id
  description          = "Windows Arc-enabled machines should be monitored and secured through the deployed Azure Monitor Agent. The Azure Monitor Agent collects telemetry data from the guest OS. Windows Arc-enabled machines in supported regions are monitored for Azure Monitor Agent deployment. Learn more: https://aka.ms/AMAOverview."
  display_name         = "Windows Arc-enabled machines should have Azure Monitor Agent installed"
}

# Policies: Landing Zones management group level
resource "azurerm_policy_definition" "IP_forwarding_on_vms_disabled" {
  description  = "Enabling IP forwarding on a virtual machine's NIC allows the machine to receive traffic addressed to other destinations. IP forwarding is rarely required (e.g., when using the VM as a network virtual appliance), and therefore, this should be reviewed by the network security team."
    display_name = "IP Forwarding on your virtual machine should be disabled"

    metadata     = jsonencode(
        {
            category = "Security Center"
            version  = "3.0.0"
        }
    )
    mode         = "All"
    name         = "bd352bd5-2853-4985-bf0d-73806b4a5744"
    parameters   = jsonencode(
        {
            effect = {
                allowedValues = [
                    "AuditIfNotExists",
                    "Disabled",
                ]
                defaultValue  = "AuditIfNotExists"
                metadata      = {
                    description = "Enable or disable the execution of the policy"
                    displayName = "Effect"
                }
                type          = "String"
            }
        }
    )
    policy_rule  = jsonencode(
        {
            if   = {
                field = "type"
                in    = [
                    "Microsoft.Compute/virtualMachines",
                    "Microsoft.ClassicCompute/virtualMachines",
                ]
            }
            then = {
                details = {
                    existenceCondition = {
                        field = "Microsoft.Security/assessments/status.code"
                        in    = [
                            "NotApplicable",
                            "Healthy",
                        ]
                    }
                    name               = "c3b51c94-588b-426b-a892-24696f9e54cc"
                    type               = "Microsoft.Security/assessments"
                }
                effect  = "[parameters('effect')]"
            }
        }
    )
    policy_type  = "BuiltIn"

    timeouts {}
}

resource "azurerm_management_group_policy_assignment" "IP_forwarding_on_vms_disabled" {
  name                 = "IP_forwarding_disabled"
  policy_definition_id = azurerm_policy_definition.IP_forwarding_on_vms_disabled.id
  management_group_id      = azurerm_management_group.lz-grp.id
  description          = "Enabling IP forwarding on a virtual machine's NIC allows the machine to receive traffic addressed to other destinations. IP forwarding is rarely required (e.g., when using the VM as a network virtual appliance), and therefore, this should be reviewed by the network security team."
  display_name         = "IP Forwarding on your virtual machine should be disabled"
}
