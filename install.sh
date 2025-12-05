#!/usr/bin/env bash

if [ "$(id -u)" != "0" ]; then
  echo "error: install action needs to run as root"
  exit 1
fi

config_file=$(mktemp)
pre_build_hook=$(mktemp)
buildtime_secrets_nix_conf="/etc/nix/nix.buildtime-secrets.conf"

[[ -z "$CI_KEY_FILE" ]] \
  && { echo "No environment variable CI_KEY_FILE"; exit 1; }

[[ -z "$SOPS_FILE" ]] \
  && { echo "No environment variable SOPS_FILE"; exit 1; }

# push and pop to ensure relative paths, if provided, are canonicalized correctly
>/dev/null pushd ..

ci_key_file="$(realpath $CI_KEY_FILE)"
sops_file="$(realpath $SOPS_FILE)"

>/dev/null popd

# buildtime-secrets-nix config file
{
  echo "s:@KEY@:$ci_key_file:g;"
  echo "s:@SOPS_FILE@:$sops_file:g;"
} |> "$config_file" sed -f- templates/config.json


sops=$(
  nix build \
    nixpkgs#sops \
    --print-out-paths \
    -o sops
)

buildtime_secrets_nix=$(
  nix build \
    github:ttrssreal/buildtime-secrets-nix \
    --print-out-paths \
    -o buildtime-secrets-nix
)

# buildtime-secrets-nix config file
{
  echo "s:@SOPS@:$sops:g;"
  echo "s:@CONFIG_FILE@:$config_file:g;"
  echo "s:@BUILDTIME_SECRETS_NIX@:$buildtime_secrets_nix:g;"
} |> "$pre_build_hook" sed -f- templates/pre-build-hook.sh

chmod +x "$pre_build_hook"

{
  default_system_features="kvm nixos-test benchmark big-parallel"
  echo "s:@DEFAULT_SYSTEM_FEATURES@:$default_system_features:g;"
  echo "s:@PRE_BUILD_HOOK@:$pre_build_hook:g;"
} |> $buildtime_secrets_nix_conf sed -f- templates/nix.buildtime-secrets.conf

# link in nix.buildtime-secrets.conf to nix.custom.conf
>>/etc/nix/nix.custom.conf echo '!include' "$buildtime_secrets_nix_conf"

echo "Nix configuration file updated, restarting nix-daemon..."
systemctl restart nix-daemon

echo -e "\033[1;32mSuccessfully installed buildtime-secrets-nix!\033[0m"
