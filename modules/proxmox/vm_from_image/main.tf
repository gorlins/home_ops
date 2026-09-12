terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.53.1"
    }
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  node_name   = var.node_name
  vm_id       = var.vm_id
  name        = var.name
  description = var.description
  tags        = var.tags
  migrate     = var.migrate
  template    = var.template
  started     = var.template ? false : var.started

  # Machine config
  bios          = var.bios
  machine       = var.machine
  scsi_hardware = var.scsi_hardware

  operating_system {
    type = var.operating_system
  }

  cpu {
    sockets = var.cpu_sockets
    cores   = var.cpu_cores
    type    = var.cpu_type
  }

  memory {
    dedicated = var.memory
    floating  = var.memory_floating
  }

  rng {
    source = var.rng_source
  }

  tpm_state {
    datastore_id = var.datastore_id
  }

  # Boot disk
  dynamic "efi_disk" {
    for_each = (var.bios == "ovmf" ? [1] : [])
    content {
      datastore_id      = var.datastore_id
      type              = "4m"
      pre_enrolled_keys = true
    }
  }
  disk {
    import_from  = var.import_from
    datastore_id = var.datastore_id

    interface = var.boot_disk.interface
    size      = var.boot_disk.size
    cache     = var.boot_disk.cache
    iothread  = var.boot_disk.iothread
    ssd       = var.boot_disk.ssd
    discard   = var.boot_disk.discard
  }

  # Other disks
  dynamic "disk" {
    for_each = var.additional_disks
    iterator = disk
    content {
      datastore_id = var.datastore_id
      interface    = disk.value.interface
      size         = disk.value.size
      cache        = disk.value.cache
      iothread     = disk.value.iothread
      ssd          = disk.value.ssd
      discard      = disk.value.discard
    }
  }

  dynamic "network_device" {
    for_each = var.network_devices
    iterator = nic
    content {
      bridge  = nic.value.bridge
      model   = nic.value.model
      mtu     = nic.value.mtu
      vlan_id = nic.value.vlan_id
    }
  }

  # VM config
  agent {
    enabled = var.agent
    # trim    = true
    # type    = "virtio"

    wait_for_ip {
      disabled = true
    }
  }
  on_boot = var.on_boot

  # cloud-init config
  initialization {
    datastore_id = var.datastore_id
    interface    = "scsi30"

    vendor_data_file_id = var.vendor_data_file_id

    user_account {
      username = var.user_account.username
      password = var.user_account.password
      keys     = var.user_account.keys
    }

    # dns { # Issues with reapplying empty strings
    #   domain  = var.ci_dns_domain
    #   servers = var.ci_dns_servers
    # }

    ip_config {
      dynamic "ipv4" {
        for_each = var.network_devices
        iterator = nic
        content {
          address = nic.value.address
        }
      }
    }
  }

  timeout_clone       = var.timeout_clone
  timeout_create      = var.timeout_create
  timeout_migrate     = var.timeout_migrate
  timeout_reboot      = var.timeout_reboot
  timeout_shutdown_vm = var.timeout_shutdown_vm
  timeout_start_vm    = var.timeout_start_vm
  timeout_stop_vm     = var.timeout_stop_vm

  lifecycle {
    ignore_changes = [
      node_name, # Required to allow for migration w/o destroying
      # initialization["user_account"] # Prevent destroying when credentials change
    ]
  }
}
