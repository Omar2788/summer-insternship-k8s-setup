provider "vsphere" {
  vsphere_server       = var.vsphere_server
  user                 = var.vsphere_user
  password             = var.vsphere_password
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "ha-datacenter"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = "Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "mgmt_lan" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = "localhost.spark.local"
  datacenter_id = data.vsphere_datacenter.dc.id
}

## Remote OVF/OVA Source
data "vsphere_ovf_vm_template" "ovfRemote" {
  name              = "ubuntu-server-cloud-image-01"
  disk_provisioning = "thin"
  resource_pool_id  = data.vsphere_resource_pool.pool.id
  datastore_id      = data.vsphere_datastore.datastore.id
  host_system_id    = data.vsphere_host.host.id
  remote_ovf_url    = "https://cloud-images.ubuntu.com/releases/22.04/release-20230427/ubuntu-22.04-server-cloudimg-amd64.ova"
  ovf_network_map = {
    "VM Network" : data.vsphere_network.mgmt_lan.id
  }
}

resource "vsphere_virtual_machine" "test2" {
  for_each         = var.vms
  name             = each.value.name
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  datacenter_id        = data.vsphere_datacenter.dc.id
  host_system_id   = data.vsphere_host.host.id
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0

  num_cpus = each.value.num_cpus
  memory   = each.value.memory
  memory_hot_add_enabled = true
  guest_id = "ubuntu64Guest"
  nested_hv_enabled = true

  ovf_deploy {
    allow_unverified_ssl_cert = true
    enable_hidden_properties = true
    remote_ovf_url            = data.vsphere_ovf_vm_template.ovfRemote.remote_ovf_url
    disk_provisioning         = data.vsphere_ovf_vm_template.ovfRemote.disk_provisioning
    ip_protocol               = "IPV4"
    ovf_network_map = {
      "Network 1" = data.vsphere_network.mgmt_lan.id
    }
  }

extra_config = {
    "guestinfo.userdata" = base64encode(templatefile("${path.module}/user_data.tpl", {
      hostname    = each.value.name
      username    = "test"
      password    = bcrypt("test")
      ip_address  = each.value.ip_address
      gateway     = "192.168.1.1"
      dns_servers = "8.8.8.8,8.8.4.4"
  
    }))
    "guestinfo.userdata.encoding" = "base64"
  }
 network_interface {
    network_id = data.vsphere_network.mgmt_lan.id
  }

  disk {
    label            = "disk1"
    size             = each.value.disk_size
    eagerly_scrub    = false
    thin_provisioned = true
  }
}
# resource "time_sleep" "wait_for_vm" {
#   depends_on = [vsphere_virtual_machine.test2]

#   create_duration = "90s"
# }
# resource "null_resource" "verify_ssh" {
#   for_each = var.vms

#   provisioner "remote-exec" {
#     inline = [
#       "echo 'SSH access successful'"
#     ]

#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       host        = each.value.ip_address
#       password = "test"  # This should match the password you set in user_data.tpl
#       timeout     = "10m"
#     }
#   }

#   depends_on = [time_sleep.wait_for_vm]
# }
