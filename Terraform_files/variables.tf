variable "vsphere_server" {}
variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_datastore" {
  default = "datastore1"

}
variable "ssh_private_key" {
  description = "the ssh public key to be used for the VMs"
  type = string
  sensitive = true
  
}

variable "datacenter" {
  default = "ha-datacenter"

}
variable "vm_template_name" {
  default = "spark-remote"
}
variable "vms" {
  type = map(object({
    name       = string
    ip_address = string
    num_cpus   = number
    memory     = number
    disk_size  = number
  }))
  default = {
    "vm1" = { name = "ubuntu-vm1", ip_address = "192.168.1.100", num_cpus = 2, memory = 3048, disk_size = 25 }
    "vm2" = { name = "ubuntu-vm2", ip_address = "192.168.1.101", num_cpus = 2, memory = 1048, disk_size = 25 }
    #"vm3" = { name = "ubuntu-vm3", ip_address = "192.168.1.102", num_cpus = 4, memory = 8192, disk_size = 19 }

  }
}
