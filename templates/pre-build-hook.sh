#!/usr/bin/env bash
export RUST_LOG=debug
export PATH="@SOPS@/bin"
export LOG_FILE=/var/log/buildtime-secrets/log
export CONFIG_FILE="@CONFIG_FILE@"
"@BUILDTIME_SECRETS_NIX@/bin/buildtime-secrets-nix" "$@"
