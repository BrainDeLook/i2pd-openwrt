#!/usr/bin/env bash
set -euo pipefail

apk="$(realpath "$1")"
boost_version="$2"
output="$(mktemp -d "${RUNNER_TEMP:-${TMPDIR:-/tmp}}/i2pd-abi.XXXXXX")"

# OpenWrt APK v3 uses ADB, not a gzip-compressed tar archive. Extract it with
# apk-tools v3, without installing the package or resolving its dependencies.
docker run --rm \
  -v "$(dirname "$apk"):/packages:ro" \
  -v "$output:/output" \
  alpine:3.23 \
  apk extract --allow-untrusted --destination /output "/packages/$(basename "$apk")"

needed="$(readelf -d "$output/usr/bin/i2pd" | sed -n 's/.*Shared library: \[\(.*\)\]/\1/p')"
printf '%s\n' "$needed"

expected="libboost_program_options.so.${boost_version}"
if ! grep -Fxq "$expected" <<< "$needed"; then
  echo "ERROR: i2pd must link against $expected" >&2
  exit 1
fi

while IFS= read -r library; do
  if [[ "$library" == libboost_*.so.* && "$library" != *.so."$boost_version" ]]; then
    echo "ERROR: Mixed Boost ABIs: $library (expected $boost_version)" >&2
    exit 1
  fi
done <<< "$needed"
