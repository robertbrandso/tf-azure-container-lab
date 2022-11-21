# ---------
# PROVIDERS
# ---------

# AzureRM
provider "azurerm" {
  features {}
}

# Random
provider "random" {}


# ------
# RANDOM
# ------

# Create random string for use in resource names
resource "random_string" "resource_names" {
  length  = 5
  special = false
  numeric = false
  upper   = false
}

# ------
# LOCALS
# ------

locals {
  location           = "norwayeast"
  image_name_and_tag = "lab:latest"
}

# ---------------
# AZURE RESOURCES
# ---------------

# Create resource group
resource "azurerm_resource_group" "main" {
  name     = "rg-${random_string.resource_names.result}-lab"
  location = local.location

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# Create Container registry
resource "azurerm_container_registry" "main" {
  name                = "cr${random_string.resource_names.result}lab"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku           = "Basic"
  admin_enabled = true

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# Create container registry task
resource "azurerm_container_registry_task" "git" {
  name                  = "git-01"
  container_registry_id = azurerm_container_registry.main.id

  platform {
    os = "Linux"
  }
  source_trigger {
    name           = "gitcommit"
    events         = ["commit"]
    repository_url = "https://github.com/robertbrandso/tf-azure-container-lab#main"
    source_type    = "Github"
    branch         = "main"
    authentication {
      token_type = "PAT"
      token      = var.git_access_token
    }
  }
  docker_step {
    dockerfile_path      = "docker/cr-task-git/Dockerfile"
    context_path         = "https://github.com/robertbrandso/tf-azure-container-lab#main"
    context_access_token = var.git_access_token
    image_names          = [local.image_name_and_tag]
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# Build container image now
resource "azurerm_container_registry_task_schedule_run_now" "main" {
  container_registry_task_id = azurerm_container_registry_task.git.id
}

# Create container instance
resource "azurerm_container_group" "main" {
  name                = "ci-${random_string.resource_names.result}-lab"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  os_type        = "Linux"
  dns_name_label = random_string.resource_names.result

  image_registry_credential {
    server   = azurerm_container_registry.main.login_server
    username = azurerm_container_registry.main.admin_username
    password = azurerm_container_registry.main.admin_password
  }

  container {
    name  = random_string.resource_names.result
    image = "${azurerm_container_registry.main.login_server}/${local.image_name_and_tag}"

    cpu    = 1
    memory = 1

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  depends_on = [
    azurerm_container_registry_task_schedule_run_now.main
  ]
}