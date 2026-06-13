# Admin notes

Misc admin notes

## Debugging nodes

To launch a shell on a node
```bash
kubectl debug node/talos-w3 -n kube-system -it --image=alpine --profile=sysadmin
```

## Add a talos node

Provision and boot new node.  If using DHCP make sure node is reflecting desired IP address before continuing.


Edit talconfig file, then:

```bash
task talos:generate-config
task talos:add-node IP=10.10.10.XYZ
```

## Convert talos node to secureboot

Make sure node has:
* TPM state drive (no pre-enrolled keys)
* EFI disk and bios UEFI
* Update url in talconfig.yaml to factory.talos.dev/installer-secureboot/HASH and `secureboot: true`
* install `task talos:upgrade-node IP=10.10.10.IP`
* Boot will likely fail
* Mount the secureboot ISO on node
* Reboot to ISO (will enroll keys)
* Reboot to firmware and enable secure boot
* Reboot into talos.  SECUREBOOT should show True

## Storage class migrations

Migrating PVC's from one storage class to another

https://github.com/BeryJu/korb

```bash
brew tap beryju/tap
brew install korb
```

Pause kustomization and scale deployment to 0 first, then proceed

```bash
export NS=portainer

# Check to ensure no pods are using PVC.  May need to evict errored out pods?
kubectl get pods -n $NS -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.volumes[*].persistentVolumeClaim.claimName}{"\n"}{end}'

# Migrate
korb --source-namespace $NS --new-pvc-namespace $NS --new-pvc-storage-class $NEW_SC --strategy copy-twice-name --timeout 360s pvc_claim_name

# If initial migration succeeds but errors after deleting the source, you can save it (look for original-claim-name-copy-123)
korb --source-namespace $NS --new-pvc-namespace $NS --new-pvc-storage-class $NEW_SC --strategy copy-twice-name --timeout 360s --new-pvc-name ORIGINAL_CLAIM_NAME TEMP_CLAIM_NAME
```

Push changes to git, resume kustomization

## CNPG

```bash
kubectl get cluster -n immich immich-database
kubectl-cnpg status -n immich immich-database
```


## Volume commands

```bash
talosctl get mounts
NODE           NAMESPACE   TYPE          ID          VERSION   SOURCE      TARGET          FILESYSTEM TYPE
10.10.10.118   runtime     MountStatus   EPHEMERAL   1         /dev/sda4   /var            xfs
10.10.10.118   runtime     MountStatus   u-data      1         /dev/sdb1   /var/mnt/data   xfs

talosctl get disks -n 10.10.10.118
NODE           NAMESPACE   TYPE   ID        VERSION   SIZE     READ ONLY   TRANSPORT   ROTATIONAL   WWID                                   MODEL           SERIAL                                            
10.10.10.118   runtime     Disk   nvme0n1   2         500 GB   false       nvme                     eui.000000000000000100a0752447507754   CT500P3PSSD8    240547507754

talosctl wipe disk nvme0n1 --drop-partition -n 10.10.10.118 
```

## Check a ceph cluster

```bash
kubectl get cephcluster -n rook-ceph-pve
```
