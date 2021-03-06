# kube-nfs-kerberos

This repo is an example for client access to NFS volumes with Kerberos security in Kubernetes.

### Related work

Kubernetes:
1. [Allow NFS to accept a Secret for authentication · Issue #13136 · kubernetes/kubernetes](https://github.com/kubernetes/kubernetes/issues/13136)
1. [Kubernetes NFS encrypted communication: Kubernetes pod applications (as NFS client) and Linux based machine (as NFS server) – secure traffic using Tunnel Over SSH](http://www.zerogbram.com/2019/10/kubernetes-nfs-encrypted-communication.html)
1. [Stackoverflow How to mount kerberised NFS on kubernetes?](https://stackoverflow.com/questions/64574328/how-to-mount-kerberised-nfs-on-kubernetes)

Openshift:
1. [OCP 3 Kerberised NFS volumes with OpenShift (not resolved)](https://access.redhat.com/solutions/3255971)
1. [Kerberos Sidecar Container](https://www.openshift.com/blog/kerberos-sidecar-container)

RHEL8 - Configuring and managing Identity Management
1. [RHEL8 - Chapter 6. Logging in to IdM in the Web UI: Using a Kerberos ticket Red Hat Enterprise Linux 8](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_identity_management/logging-in-to-ipa-in-the-web-ui-using-a-kerberos-ticket_configuring-and-managing-idm)
1. [RHEL8 - Chapter 83. Setting up a Kerberos-aware NFS server/client Red Hat Enterprise Linux 8](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_identity_management/using-automount_configuring-and-managing-idm)

Spark
1. [Spark 3.1.1 - Documentation - Security - Kerberos](https://spark.apache.org/docs/latest/security.html#kerberos)

## Adcli CoreOs setup

```bash
domain=corp.octo-emerging.redhataicoe.com
realm=CORP.OCTO-EMERGING.REDHATAICOE.COM

oc apply -f machineconfig/machineconfig.yaml
# updates krb5.conf, nfs.conf, idmapd.conf

sudo adcli join --verbose --domain $domain --domain-realm $realm --domain-controller $domain --login-type user --login-user Admin

systemctl enable nfs-client.target

systemctl restart nfs-client.target

systemctl restart nfs-idmapd.service

mkdir -p /mnt/test

# validate that NFS mount works
mount -t nfs4 nfs.octo-emerging.redhataicoe.com:/export /mnt/test -o sec=krb5,rw
```

## Kerberized NFS setup (Active Directory)

```bash
$ yum install adcli nfs-utils
$ adcli join --verbose --domain $domain --domain-realm $realm --domain-controller $domain --login-type user --login-user Admin --service-name="host" --service-name="nfs"
$ kinit Admin
# setup /etc/krb5.conf
# setup /etc/idmapd.conf
$ echo "/export  *(rw,root_squash,sec=krb5)" > /etc/exports # export shares in /etc/exports
$ firewall-cmd --zone=public --add-service=nfs --permanent
$ firewall-cmd --permanent --add-service=mountd --permanent
$ firewall-cmd --permanent --add-service=rpc-bind --permanent
$ systemctl restart nfs-idmapd.service
$ systemctl restart nfs-server
$ exportfs -var
# ensure user, group, selinux permissions correct for share
```

## Questions

- Can we use adcli (or something similar) within the context of a MachineConfig?
  - [https://github.com/coreos/bugs/issues/968](https://github.com/coreos/bugs/issues/968)
