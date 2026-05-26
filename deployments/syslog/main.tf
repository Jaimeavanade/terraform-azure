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

# ==============================
# RESOURCE
# ==============================

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

    # ✅ AUTH (AUDIT REAL)
    syslog {
      name    = "auth"
      streams = ["Microsoft-Syslog"]
      facility_names = ["auth"]
      log_levels     = ["Notice"]
    }

    syslog {
      name    = "authpriv"
      streams = ["Microsoft-Syslog"]
      facility_names = ["authpriv"]
      log_levels     = ["Notice"]
    }

    syslog {
      name    = "daemon"
      streams = ["Microsoft-Syslog"]
      facility_names = ["daemon"]
      log_levels     = ["Notice"]
    }

    syslog {
      name    = "kern"
      streams = ["Microsoft-Syslog"]
      facility_names = ["kern"]
      log_levels     = ["Notice"]
    }

    syslog {
      name    = "syslog"
      streams = ["Microsoft-Syslog"]
      facility_names = ["syslog"]
      log_levels     = ["Notice"]
    }

    syslog {
      name    = "user"
      streams = ["Microsoft-Syslog"]
      facility_names = ["user"]
      log_levels     = ["Notice"]
    }

    # ✅ LOCALs (muy usados)
    syslog {
      name    = "local0"
      streams = ["Microsoft-Syslog"]
      facility_names = ["local0"]
      log_levels     = ["Notice"]
    }

    syslog {
      name    = "local1"
      streams = ["Microsoft-Syslog"]
      facility_names = ["local1"]
      log_levels     = ["Notice"]
    }

    syslog {
      name    = "local2"
      streams = ["Microsoft-Syslog"]
      facility_names = ["local2"]
      log_levels     = ["Notice"]
    }

    syslog {
      name    = "local3"
      streams = ["Microsoft-Syslog"]
      facility_names = ["local3"]
      log_levels     = ["Notice"]
    }

    syslog {
      name    = "local4"
      streams = ["Microsoft-Syslog"]
      facility_names = ["local4"]
      log_levels     = ["Notice"]
    }

    syslog {
      name    = "local5"
      streams = ["Microsoft-Syslog"]
      facility_names = ["local5"]
      log_levels     = ["Notice"]
    }

    syslog {
      name    = "local6"
      streams = ["Microsoft-Syslog"]
      facility_names = ["local6"]
      log_levels     = ["Notice"]
    }

    syslog {
      name    = "local7"
      streams = ["Microsoft-Syslog"]
      facility_names = ["local7"]
      log_levels     = ["Notice"]
    }

    # ✅ NOPRI → clave para portal
    syslog {
      name    = "nopri"
      streams = ["Microsoft-Syslog"]
      facility_names = ["nopri"]
      log_levels     = ["Notice"]
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
