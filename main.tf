terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.66.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# VARIABLES
variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "workspace_resource_id" {
  type = string
}

variable "dcr_name" {
  type    = string
  default = "windowssecurityevent-dcr"
}

variable "data_collection_endpoint_id" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

# DCR
resource "azurerm_monitor_data_collection_rule" "windows_dcr" {
  name                = var.dcr_name
  resource_group_name = var.resource_group_name
  location            = var.location

  kind = "Windows"

  data_collection_endpoint_id = var.data_collection_endpoint_id

  tags = merge(var.tags, {
    createdBy = "Sentinel"
  })

  data_flow {
    streams      = ["Microsoft-SecurityEvent"]
    destinations = ["DataCollectionEvent"]
  }

  data_sources {
    windows_event_log {
      name    = "windows-security-events"
      streams = ["Microsoft-SecurityEvent"]

      x_path_queries = [
        "Security!*"
      ]
    }
  }

  destinations {
    log_analytics {
      name                  = "DataCollectionEvent"
      workspace_resource_id = var.workspace_resource_id
    }
  }
}

output "dcr_id" {
  value = azurerm_monitor_data_collection_rule.windows_dcr.id
}
