# Fava (beancount) — read-only

Fava runs with `--read-only` (`FAVA_READ_ONLY=true`), so the web UI can't edit
the ledger. The ledger comes from a private git repo: an init container clones
it, and a git-sync sidecar pulls changes every 10s (git-sync default) into an `emptyDir`. Fava
reads from that `emptyDir`. Your git repo stays the source of truth.

The UI is at `https://fava.${SECRET_DOMAIN}` via an HTTPRoute on the `cilium`
Gateway (`websecure` listener, LAN address 10.10.10.160).

> **No authentication yet.** The k3s cluster has no forward-auth in front of the
> gateway, so anyone on the LAN who can reach the gateway can view the ledger.
> Plan: oauth2-proxy backed by the existing Dex instance.

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

3. Write `clusters/apps/fava/secret.sops.yaml`, then encrypt it:

   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: fava-git
   stringData:
     GITSYNC_REPO: git@github.com:<you>/<ledger-repo>.git
     # GITSYNC_REF: main           # optional, defaults to remote HEAD
     ssh: |
       -----BEGIN OPENSSH PRIVATE KEY-----
       ...
     known_hosts: |
       github.com ssh-ed25519 AAAA...
   ```

   ```sh
   sops -e -i clusters/apps/fava/secret.sops.yaml
   ```

4. Uncomment `./secret.sops.yaml` in `clusters/apps/fava/kustomization.yaml`.

5. If your main file isn't `main.beancount` at the repo root, change
   `BEANCOUNT_FILE` in `clusters/apps/fava/app.yaml`. Paths are relative to
   `/git/current/`.
