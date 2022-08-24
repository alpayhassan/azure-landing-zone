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

# Policy Assignment
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
