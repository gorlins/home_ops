#
# resource "talos_image_factory_schematic" "this" {
#   for_each  = toset(["proxmox_vm", "opti"])
#   schematic = file("./talos/schematics/${each.value}.yaml")
# }
#
# # terraform import 'module.talos.talos_machine.nodes["10.10.10.X"]' 10.10.10.X
# module "talos" {
#   source       = "./modules/talos_cluster"
#   cluster_name = "kubernetes"
#   vip          = "10.10.10.8"
#
#   schematic_id = talos_image_factory_schematic.this["proxmox_vm"].id
#
#   global_patches = [
#     file("./talos/patches/global/cilium.yaml"),
#     file("./talos/patches/global/cluster.yaml"),
#     file("./talos/patches/global/machine-files.yaml"),
#     file("./talos/patches/global/machine-kernel.yaml"),
#     file("./talos/patches/global/machine-kubelet.yaml"),
#     file("./talos/patches/global/machine-network.yaml"),
#   ]
#   controlplane_patches = [
#     file("./talos/patches/controller/cluster.yaml")
#   ]
#   worker_patches = [
#     file("./talos/patches/worker/machine-kubelet.yaml")
#   ]
#
#   nodes = {
#     "10.10.10.106" = {
#       hostname     = "talos-c1"
#       controlplane = true
#     }
#   }
# }
#
# output "kubeconfig" {
#   value     = module.talos.kubeconfig
#   sensitive = true
# }
#
# output "talosconfig" {
#   value     = module.talos.talosconfig
#   sensitive = true
# }
# # data "talos_client_configuration" "this" {
# #   cluster_name         = var.cluster_name
# #   client_configuration = talos_machine_secrets.this.client_configuration
# #   endpoints            = [for k, v in var.node_data.controlplanes : k]
# # }
# #
# # resource "talos_machine_configuration_apply" "controlplane" {
# #   client_configuration        = talos_machine_secrets.this.client_configuration
# #   machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
# #   for_each                    = var.node_data.controlplanes
# #   node                        = each.key
# #   config_patches = [
# #     templatefile("./templates/install-disk-and-hostname.yaml.tmpl", {
# #       hostname     = each.value.hostname == null ? format("%s-cp-%s", var.cluster_name, index(keys(var.node_data.controlplanes), each.key)) : each.value.hostname
# #       install_disk = each.value.install_disk
# #     }),
# #     file("./files/cp-scheduling.yaml"),
# #   ]
# # }
# #
# # resource "talos_machine_configuration_apply" "worker" {
# #   client_configuration        = talos_machine_secrets.this.client_configuration
# #   machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
# #   for_each                    = var.node_data.workers
# #   node                        = each.key
# #   config_patches = [
# #     templatefile("./templates/install-disk-and-hostname.yaml", {
# #       hostname     = each.value.hostname == null ? format("%s-worker-%s", var.cluster_name, index(keys(var.node_data.workers), each.key)) : each.value.hostname
# #       install_disk = each.value.install_disk
# #     })
# #   ]
# # }
# #
# # resource "talos_machine_bootstrap" "this" {
# #   depends_on = [talos_machine_configuration_apply.controlplane]
# #
# #   client_configuration = talos_machine_secrets.this.client_configuration
# #   node                 = [for k, v in var.node_data.controlplanes : k][0]
# # }
# #
# # resource "talos_cluster_kubeconfig" "this" {
# #   depends_on           = [talos_machine_bootstrap.this]
# #   client_configuration = talos_machine_secrets.this.client_configuration
# #   node                 = [for k, v in var.node_data.controlplanes : k][0]
# # }
