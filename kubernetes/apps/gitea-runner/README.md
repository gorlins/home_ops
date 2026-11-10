# gitea-runner

Gitea Actions runner (`act_runner`) with a privileged `docker:dind` sidecar.

- Namespace `gitea-runner` is labelled `pod-security.kubernetes.io/enforce: privileged`
  (Talos enforces `baseline` by default); only the dind sidecar is privileged.
- dockerd listens only on a unix socket shared between the two containers.
- `/data` (registration state + actions/cache) is a Longhorn PVC; the docker
  image cache is an emptyDir (50Gi limit) on the node.

## One-time setup: registration token

1. In Gitea: **Site Administration → Actions → Runners → Create new runner**
   (or at org/user level to scope the runner) and copy the token.
2. Create and encrypt the secret:

   ```bash
   cat > kubernetes/apps/gitea-runner/runner/app/secret.sops.yaml <<'YAML'
   apiVersion: v1
   kind: Secret
   metadata:
     name: gitea-runner-token
   type: Opaque
   stringData:
     token: PASTE_TOKEN_HERE
   YAML
   sops -e -i kubernetes/apps/gitea-runner/runner/app/secret.sops.yaml
   ```

3. Uncomment `./secret.sops.yaml` in `runner/app/kustomization.yaml` and push.

The token is only used on first registration; the result is stored in
`/data/.runner`. To re-register, delete the `data-gitea-runner-0` PVC.

## Notes

- Workflows' `actions/checkout` clones from Gitea's `ROOT_URL`
  (`https://git.${SECRET_DOMAIN}`), so that name must resolve and be reachable
  from pods.
- Security: anything a workflow runs can reach the privileged dind daemon,
  i.e. root on the node. Only run trusted repos on this runner.
