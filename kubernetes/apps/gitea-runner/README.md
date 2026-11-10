# gitea-runner

Gitea Actions runner deployed with the official `actions` Helm chart
(<https://gitea.com/gitea/helm-actions>): a `gitea/runner` container plus a
privileged `docker:dind` native sidecar.

- Namespace `gitea-runner` is labelled `pod-security.kubernetes.io/enforce: privileged`
  (Talos enforces `baseline` by default); only the dind sidecar is privileged.
- dockerd listens only on a unix socket shared with the runner container (no TCP).
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
`/data/.runner`. To re-register, delete the `data-runner-gitea-runner-runner-0` PVC.

## Notes

- Workflows' `actions/checkout` clones from Gitea's `ROOT_URL`
  (`https://git.${SECRET_DOMAIN}`), so that name must resolve and be reachable
  from pods.
- Security: anything a workflow runs can reach the privileged dind daemon,
  i.e. root on the node. Only run trusted repos on this runner.
- `gitea/runner` 5.x also supports a `kubernetes://` label that runs each job
  as a pod with no Docker daemon (and no privileged pod). The Helm chart doesn't
  deploy that mode yet; see the runner repo's `docs/kubernetes.md`.
