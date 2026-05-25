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
  type        = string
  description = "Resource Group donde se despliega la DCR"
}

variable "location" {
  type        = string
  description = "Región Azure"
}

# 🔥 PARAMETRIZADO IGUAL QUE EL ANTERIOR
variable "dcr_name" {
  type        = string
  description = "Nombre de la DCR Syslog"
  default     = "syslog-dcr"
}

variable "workspace_resource_id" {
  type        = string
  description = "Resource ID del Log Analytics Workspace"
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
# RESOURCE DCR SYSLOG
# ==============================

resource "azurerm_monitor_data_collection_rule" "syslog_dcr" {
  name                = var.dcr_name
  resource_group_name = var.resource_group_name
  location            = var.location

  kind = "Linux"

  data_collection_endpoint_id = var.data_collection_endpoint_id

  tags = merge(var.tags, {
    createdBy = "Sentinel"
  })

  # ==========================
  # DATA FLOW
  # ==========================
  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["DataCollectionEvent"]
  }

  # ==========================
  # DATA SOURCES
  # ==========================
  data_sources {

    syslog {
      name    = "syslog-security"
      streams = ["Microsoft-Syslog"]

      facility_names = [
        "alert",
        "audit",
        "auth",
        "authpriv",
        "cron",
        "daemon",
        "kern",
        "syslog",
        "user"
      ]

      log_levels = [
        "Notice",
        "Warning",
        "Error",
        "Critical",
        "Alert",
        "Emergency"
      ]
    }

    syslog {
      name    = "syslog-nopri"
      streams = ["Microsoft-Syslog"]

      facility_names = ["nopri"]
      log_levels     = ["Emergency"]
    }
  }

  # ==========================
  # DESTINATIONS
  # ==========================
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
  value = azurerm_monitor_data_collection_rule.syslog_dcr.id
}

output "dcr_name" {
  value = azurerm_monitor_data_collection_rule.syslog_dcr.name
}
