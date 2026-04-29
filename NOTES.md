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

# Check to ensure no pods are using PVC
kubectl get pods -n $NS -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.volumes[*].persistentVolumeClaim.claimName}{"\n"}{end}'

# Migrate
korb --source-namespace $NS --new-pvc-namespace $NS --new-pvc-storage-class $NEW_SC --strategy copy-twice-name --timeout 360s pvc_claim_name

# If initial migration succeeds but errors after deleting the source, you can save it (look for original-claim-name-copy-123)
korb --source-namespace $NS --new-pvc-namespace $NS --new-pvc-storage-class $NEW_SC --strategy copy-twice-name --timeout 360s --new-pvc-name ORIGINAL_CLAIM_NAME TEMP_CLAIM_NAME
```

Push changes to git, resume kustomization
