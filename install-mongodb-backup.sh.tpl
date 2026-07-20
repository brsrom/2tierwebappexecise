#!/bin/bash
set -eux

for i in $(seq 1 30); do
  systemctl is-active --quiet mongod && break
  sleep 2
done

mongo --quiet <<'EOF'
db.getSiblingDB("admin").createUser({
  user: "${admin_username}",
  pwd: "${admin_password}",
  roles: [ { role: "root", db: "admin" } ]
})
EOF

cat >> /etc/mongod.conf <<'CONF'

security:
  authorization: enabled
CONF

systemctl restart mongod
sleep 3

curl -sL https://aka.ms/InstallAzureCLIDeb | bash

cat > /opt/backup-mongo.sh <<'SCRIPT'
#!/bin/bash
set -euo pipefail
DATE=$(date +%F)
ARCHIVE="/tmp/mongodb-backup-$DATE.archive.gz"
mongodump --archive="$ARCHIVE" --gzip --username '${admin_username}' --password '${admin_password}' --authenticationDatabase admin
az login --identity --allow-no-subscriptions
ACCOUNT_KEY=$(az storage account keys list \
  --resource-group ${resource_group_name} \
  --account-name ${storage_account_name} \
  --query '[0].value' -o tsv)
az storage blob upload \
  --account-name ${storage_account_name} \
  --account-key "$ACCOUNT_KEY" \
  --container-name ${container_name} \
  --name "mongodb-backup-$DATE.archive.gz" \
  --file "$ARCHIVE" \
  --overwrite
rm -f "$ARCHIVE"
SCRIPT
chmod 700 /opt/backup-mongo.sh

cat > /etc/systemd/system/mongodb-backup.service <<'UNIT'
[Unit]
Description=Daily MongoDB backup to Azure Blob Storage

[Service]
Type=oneshot
ExecStart=/opt/backup-mongo.sh
UNIT

cat > /etc/systemd/system/mongodb-backup.timer <<'UNIT'
[Unit]
Description=Run MongoDB backup daily

[Timer]
OnCalendar=${backup_schedule}
Persistent=true

[Install]
WantedBy=timers.target
UNIT

systemctl daemon-reload
systemctl enable --now mongodb-backup.timer
