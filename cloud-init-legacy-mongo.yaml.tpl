#cloud-config
package_update: false
package_upgrade: false

write_files:
  - path: /opt/setup-legacy-mongo.sh
    permissions: "0755"
    content: |
      #!/bin/bash
      set -eux

      systemctl disable --now unattended-upgrades.service || true
      systemctl disable --now apt-daily.timer apt-daily-upgrade.timer || true

      echo "deb [ arch=amd64 trusted=yes ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/${mongodb_version} multiverse" > /etc/apt/sources.list.d/mongodb-org-${mongodb_version}.list

      apt-get update
      apt-get install -y \
        mongodb-org=${mongodb_full_version} \
        mongodb-org-server=${mongodb_full_version} \
        mongodb-org-shell=${mongodb_full_version} \
        mongodb-org-mongos=${mongodb_full_version} \
        mongodb-org-tools=${mongodb_full_version}
      apt-mark hold mongodb-org mongodb-org-server mongodb-org-shell mongodb-org-mongos mongodb-org-tools

      sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
      systemctl enable --now mongod

runcmd:
  - /opt/setup-legacy-mongo.sh
