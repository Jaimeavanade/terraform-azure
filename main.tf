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

# ==============================
# VARIABLES
# ==============================

variable "resource_group_name" {
  description = "RG donde se despliega"
  type        = string
}

variable "location" {
  description = "Región Azure"
  type        = string
}

variable "workspace_resource_id" {
  description = "Resource ID del LAW"
  type        = string
}

# 🔥 NUEVO: nombre parametrizable
variable "dcr_name" {
  description = "Nombre de la DCR"
  type        = string
  default     = "windowssecurityevent-dcr"
}

variable "data_collection_endpoint_id" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

# ==============================
# RESOURCE DCR WINDOWS
# ==============================

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
        "Security!*",
        "Microsoft-Windows-AppLocker/EXE and DLL!*",
        "Microsoft-Windows-AppLocker/MSI and Script!*"
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

# ==============================
# OUTPUTS
# ==============================

output "dcr_id" {
  value = azurerm_monitor_data_collection_rule.windows_dcr.id
}

output "dcr_name" {
  value = azurerm_monitor_data_collection_rule.windows_dcr.name
}
