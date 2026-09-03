#!/usr/bin/env bash
set -euo pipefail

REPO="WayDroid-ATV/waydroid-androidtv-builds"
MODULE=modules/desktop/waydroidAtv.nix
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
MODULE="$ROOT/$MODULE"

TAG=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
echo "Latest release: $TAG"

system_url=""
vendor_url=""
while read -r u; do
  case "$u" in
    *"GAPPS-waydroid_tv_x86_64-system.zip") system_url=$u ;;
    *"MAINLINE-waydroid_tv_x86_64-vendor.zip") vendor_url=$u ;;
  esac
done < <(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | grep browser_download_url | cut -d'"' -f4)

if [[ -z "$system_url" || -z "$vendor_url" ]]; then
  echo "Could not find system/vendor assets for release $TAG" >&2
  exit 1
fi

echo "Downloading and hashing system image"
system_sha=$(nix hash convert --hash-algo sha256 --to sri "$(curl -fsSL "$system_url" | sha256sum | cut -d' ' -f1)")
echo "Downloading and hashing vendor image"
vendor_sha=$(nix hash convert --hash-algo sha256 --to sri "$(curl -fsSL "$vendor_url" | sha256sum | cut -d' ' -f1)")

sed -i "s|^    systemUrl = .*|    systemUrl = \"$system_url\";|" "$MODULE"
sed -i "s|^    systemSha = .*|    systemSha = \"$system_sha\";|" "$MODULE"
sed -i "s|^    vendorUrl = .*|    vendorUrl = \"$vendor_url\";|" "$MODULE"
sed -i "s|^    vendorSha = .*|    vendorSha = \"$vendor_sha\";|" "$MODULE"
sed -i "s|^      version = .*|      version = \"$TAG\";|" "$MODULE"

echo "Updated $MODULE to $TAG"
echo "Next: rsync the repo to the box, then nixos-rebuild switch --flake .#htpc"