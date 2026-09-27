terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.12.0"
    }
  }
}

resource "talos_machine_secrets" "this" {}

data "talos_image_factory_urls" "nodes" {
  for_each      = var.nodes
  talos_version = var.talos_version
  schematic_id  = coalesce(each.value.schematic_id, var.schematic_id)
  platform      = each.value.platform
}

data "talos_machine_configuration" "nodes" {
  for_each         = var.nodes
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.vip}:6443"
  machine_type     = each.value.controlplane ? "controlplane" : "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches = concat(
    var.global_patches,
    each.value.controlplane ? var.controlplane_patches : var.worker_patches,
    each.value.patches,
  )
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for k, v in var.nodes : k if v.controlplane]
}

resource "talos_machine" "nodes" {
  for_each              = var.nodes
  node                  = each.key
  client_configuration  = talos_machine_secrets.this.client_configuration
  image                 = each.value.secureboot ? data.talos_image_factory_urls.nodes[each.key].urls.installer_secureboot : data.talos_image_factory_urls.nodes[each.key].urls.installer
  kubeconfig            = talos_cluster_kubeconfig.this.kubeconfig_raw
  machine_configuration = data.talos_machine_configuration.nodes[each.key].machine_configuration
}

# resource "talos_machine_configuration_apply" "controlplane" {
#   client_configuration        = talos_machine_secrets.this.client_configuration
#   machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
#   for_each                    = var.node_data.controlplanes
#   node                        = each.key
#   config_patches = [
#     templatefile("${path.module}/templates/node.yaml", {
#       hostname     = each.key
#       install_disk = each.value.install_disk
#     })
#   ]
# }
#
# resource "talos_machine_configuration_apply" "worker" {
#   client_configuration        = talos_machine_secrets.this.client_configuration
#   machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
#   for_each                    = var.node_data.workers
#   node                        = each.key
#   config_patches = [
#     templatefile("${path.module}/templates/install-disk-and-hostname.yaml.tmpl", {
#       hostname     = each.value.hostname == null ? format("%s-worker-%s", var.cluster_name, index(keys(var.node_data.workers), each.key)) : each.value.hostname
#       install_disk = each.value.install_disk
#     })
#   ]
# }

# resource "talos_machine_bootstrap" "this" {
#   depends_on = [talos_machine_configuration_apply.controlplane]
#
#   client_configuration = talos_machine_secrets.this.client_configuration
#   node                 = [for k, v in var.node_data.controlplanes : k][0]
# }

resource "talos_cluster_kubeconfig" "this" {
  # depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  # node                 = [for k, v in var.node_data.controlplanes : k][0]
  node = var.vip
}
