#!/bin/bash
# Default value for renewing the TGT ticket
KERBEROS_RENEWAL_TIME=86400 # One day

# Move the keytab into keytabfile
echo  "Generating keytab file"
# cat /vault/secrets/${USERNAME}.keytab  | cut -d' ' -f2 | base64 -d > /etc/${USERNAME}.keytab

# Get the TGT
echo "Loading keytab"
kinit -kt /keytab/keytab ${USERNAME}@${REALM}

# Remove secrets for security reasons
# rm -rf /vault/secrets/*
# rm -rf /etc/${USERNAME}.keytab
# echo "Secrets removed from tmpfs"
while :;
do
  kinit -R -kt /keytab/keytab
  sleep ${KERBEROS_RENEWAL_TIME}
done
