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
  default = "syslog-dcr"
}

variable "tags" {
  type    = map(string)
  default = {}
}

# RESOURCE

resource "azurerm_monitor_data_collection_rule" "syslog_dcr" {
  name                = var.dcr_name
  resource_group_name = var.resource_group_name
  location            = var.location

  kind = "Linux"

  tags = merge(var.tags, {
    createdBy = "Sentinel"
  })

  lifecycle {
    create_before_destroy = true
  }

  # DATA FLOW
  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["DataCollectionEvent"]
  }

  # DATA SOURCES
  data_sources {

    # ✅ ÚNICO BLOQUE SYSLOG (forma correcta)
    syslog {
      name    = "syslog-main"
      streams = ["Microsoft-Syslog"]

      facility_names = [
        "auth",
        "authpriv",
        "daemon",
        "kern",
        "syslog",
        "user",
        "local0",
        "local1",
        "local2",
        "local3",
        "local4",
        "local5",
        "local6",
        "local7",
        "nopri"
      ]

      log_levels = [
        "Notice"
      ]
    }
  }

  # DESTINATION
  destinations {
    log_analytics {
      name                  = "DataCollectionEvent"
      workspace_resource_id = var.workspace_resource_id
    }
  }
}

# OUTPUTS

output "dcr_id" {
  value = azurerm_monitor_data_collection_rule.syslog_dcr.id
}

output "dcr_name" {
  value = azurerm_monitor_data_collection_rule.syslog_dcr.name
}
