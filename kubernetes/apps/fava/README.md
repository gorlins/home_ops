# Fava (beancount) — read-only

Fava runs with `--read-only` (`FAVA_READ_ONLY=true`), so the web UI can't edit
the ledger. The ledger comes from a private git repo: an init container clones
it, and a git-sync sidecar pulls changes every 60s into an `emptyDir`. Fava
mounts that `emptyDir` read-only. Your git repo stays the source of truth.

The UI is at `https://fava.${SECRET_DOMAIN}`, served by Traefik behind the
`traefik-authentik` forward-auth middleware.

## One-time setup

1. Create a **read-only deploy key** for the ledger repo (Gitea/GitHub → repo
   settings → Deploy keys; leave "write access" unticked):

   ```sh
   ssh-keygen -t ed25519 -N '' -C fava-git-sync -f fava_deploy_key
   ```

2. Grab the SSH host key of the git server:

   ```sh
   ssh-keyscan -t ed25519 github.com > known_hosts   # or your gitea host/port
   ```

3. Write `fava/app/secret.sops.yaml`, then encrypt it:

   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: fava-git
   stringData:
     GITSYNC_REPO: git@github.com:<you>/<ledger-repo>.git
     # GITSYNC_REF: main           # optional, defaults to remote HEAD
     ssh-privatekey: |
       -----BEGIN OPENSSH PRIVATE KEY-----
       ...
     known_hosts: |
       github.com ssh-ed25519 AAAA...
   ```

   ```sh
   sops -e -i kubernetes/apps/fava/fava/app/secret.sops.yaml
   ```

4. Uncomment `./secret.sops.yaml` in `fava/app/kustomization.yaml`.

5. If your main file isn't `main.beancount` at the repo root, change
   `BEANCOUNT_FILE` in `fava/app/helmrelease.yaml`. Paths are relative to
   `/git/current/`.

6. In Authentik, create a proxy provider/application (forward auth, single
   application) for `fava.<domain>` and add it to the embedded outpost.
