### `buildtime-secrets-nix` install action
```yaml
- name: Install buildtime-secrets-nix
  uses: ttrssreal/buildtime-secrets-nix-install-action@main
  with:
    ci-key-file: <ssh-key>
    sops-file: <sops-file>
```

### Testing

#### Editing secrets
```console
SOPS_AGE_SSH_PRIVATE_KEY_FILE=test/fixtures/key \
    sops \
    --config \
    test/fixtures/.sops.yaml \
    edit test/fixtures/test.sops.yaml
```
