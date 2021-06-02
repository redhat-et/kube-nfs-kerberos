# RHEL Client Setup

1. Run the client setup script, this will install the required packages and setup the client 
2. Get your kerberos ticket: `kinit admin`
3. `ipa-client-automount`
4. Add your mount to `/etc/fstab`:

```
nfs.octo-emerging.redhataicoe.com:/data/testnfs /mnt/testnfs nfs4  sec=krb5p,rw
```

5. Create your mount points if they don’t exist
6. Mount the share: `mount /mnt/testnfs`

