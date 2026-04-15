# Admin notes

Misc admin notes

## Debugging nodes

To launch a shell on a node
```bash
kubectl debug node/talos-w3 -n kube-system -it --image=alpine --profile=sysadmin
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
korb --source-namespace $NS --new-pvc-namespace $NS --new-pvc-storage-class longhorn --strategy copy-twice-name portainer
```

Push changes to git, resume kustomization
