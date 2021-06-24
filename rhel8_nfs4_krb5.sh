#!/bin/bash
#
# This script is setting up NFS4 + KRB5 on RHEL-8
# See https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_identity_management/using-automount_configuring-and-managing-idm#setting-up-a-kerberos-aware-nfs-server_using-automount

##########
# CONFIG #
##########

IP=$(ip route get 1 | head -1 | cut -d' ' -f7)
SERVER="server"
DOMAIN="kube-nfs-kerberos.redhat-et"
REALM="KUBE-NFS-KERBEROS.REDHAT-ET"

IPA_DS_PASSWORD="12345678"
IPA_ADMIN_PASSWORD="12345678"

############
# PACKAGES #
############

subscription-manager repos --enable=rhel-8-for-x86_64-baseos-rpms
subscription-manager repos --enable=rhel-8-for-x86_64-appstream-rpms

yum update -y
yum install -y bind bind-utils nfs-utils
yum module -y enable idm:DL1
yum distro-sync -y
yum module -y install idm:DL1/{client,server,dns}

##################
# KRB5 (IDM/IPA) #
##################


ipa-server-install \
    --unattended \
    --skip-mem-check \
    --ntp-pool=pool.ntp.org \
    --setup-dns \
    --auto-reverse \
    --auto-forwarders \
    --realm=$REALM \
    --domain=$DOMAIN \
    --hostname=${SERVER}.${DOMAIN} \
    --ip-address=$IP \
    --ds-password=$IPA_DS_PASSWORD \
    --admin-password=$IPA_ADMIN_PASSWORD

firewall-cmd --permanent --add-service={freeipa-ldap,freeipa-ldaps,dns}
firewall-cmd --permanent --add-port={80/tcp,443/tcp,389/tcp,636/tcp,88/tcp,88/udp,464/tcp,464/udp,53/tcp,53/udp,123/udp}
firewall-cmd --reload

kinit -l $((24*365*100)) admin

ipa service-add nfs/${SERVER}.${DOMAIN}
ipa-getkeytab -s ${SERVER}.${DOMAIN} -p nfs/${SERVER}.${DOMAIN} -k /etc/krb5.keytab
ipa service-show nfs/${SERVER}.${DOMAIN}

ipa-client-automount

#######
# NFS #
#######

systemctl start nfs-server
systemctl enable nfs-server

mkdir -p /share1 /mnt/share1
chmod 777 /share1 /mnt/share1

cat >>/etc/exports <<EOF
/share1 *(rw,sec=krb5)
EOF
cat >>/etc/fstab <<EOF
$SERVER.$DOMAIN:/share1 /mnt/share1 nfs4 rw,sec=krb5 0 0
EOF

exportfs -rav
systemctl reload nfs-server
systemctl restart nfs-server

# mount -t nfs4 -o rw,sec=krb5 $SERVER.$DOMAIN:/share1 /mnt/share1
# (or)
mount /mnt/share1

echo hi > /mnt/share1/lala
cat /mnt/share1/lala
ls -l /mnt/share1



# hostname ${SERVER}.${DOMAIN}

# systemctl restart nfs-client.target
# systemctl enable nfs-client.target

# systemctl start krb5kdc
# systemctl reload krb5kdc
# systemctl restart krb5kdc
# systemctl enable krb5kdc

# klist -k
# klist -A
# kdestroy -A # clear credentials cache
# ipa user-add user1

# umount /mnt/share

# rpcdebug -m nfs -s all
# less /var/log/messages
