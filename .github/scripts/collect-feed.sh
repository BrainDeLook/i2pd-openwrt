#!/usr/bin/env bash
set -euo pipefail

apk="$(realpath "$1")"
destination="$2"
private_key="$(realpath "$3")"
public_key="$(realpath "$4")"

mkdir -p "$destination"
destination="$(realpath "$destination")"
cp "$apk" "$destination/$(basename "$apk")"
cp "$public_key" "$destination/i2pd-feed.pub.pem"

# The dependency overlay also builds official packages. Index only i2pd, so
# this repository does not advertise/re-distribute its rebuilt dependencies.
# Keep the SDK's sha256-160 format for OpenWrt 25.12 apk-tools compatibility.
docker run --rm --user "$(id -u):$(id -g)" \
  -v "$destination:/feed" \
  -v "$private_key:/signing-key.pem:ro" \
  alpine:3.23 \
  apk mkndx --allow-untrusted --hash sha256-160 --compression deflate:9 \
    --sign-key /signing-key.pem --output /feed/packages.adb \
    "/feed/$(basename "$apk")"

test -s "$destination/packages.adb"
