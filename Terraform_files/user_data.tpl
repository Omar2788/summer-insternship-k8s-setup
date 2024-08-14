#cloud-config
hostname: ${hostname}
users:
  - name: ${username}
    passwd: ${password}
    lock_passwd: false
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/bash
    
write_files:
  - path: /etc/netplan/50-cloud-init.yaml
    content: |
      network:
        version: 2
        ethernets:
          ens192:
            dhcp4: no
            addresses: [${ip_address}/24]
            gateway4: ${gateway}
            nameservers:
              addresses: [${dns_servers}]

runcmd:
  - netplan apply
  - sed -i 's/^#\?PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
  - systemctl restart ssh