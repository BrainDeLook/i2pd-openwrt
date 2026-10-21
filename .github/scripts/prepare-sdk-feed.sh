#!/usr/bin/env bash
set -euo pipefail

# Release SDKs pin packages.git to the firmware release date. Binary package
# repositories keep moving, including Boost's versioned shared-library ABI.
# Use a current stable packages feed, with our i2pd recipe replacing the stock
# one, so scripts/feeds also resolves i2pd's dependencies from that same feed.
packages_ref="${1:-openwrt-25.12}"
package_dir="${GITHUB_WORKSPACE:-$PWD}/i2pd"
feed_dir="$(mktemp -d "${RUNNER_TEMP:-${TMPDIR:-/tmp}}/i2pd-sdk-feed.XXXXXX")"

test -f "$package_dir/Makefile"
git -C "$feed_dir" init -q
git -C "$feed_dir" remote add origin https://github.com/openwrt/packages.git
git -C "$feed_dir" fetch --depth 1 origin "$packages_ref"
git -C "$feed_dir" checkout -q --detach FETCH_HEAD

# Keep the original outside the feed; its patches must not leak into our build.
mv "$feed_dir/net/i2pd" "${feed_dir}.stock-i2pd"
cp -R "$package_dir" "$feed_dir/net/i2pd"

boost_version="$(sed -n 's/^PKG_VERSION:=//p' "$feed_dir/libs/boost/Makefile")"
test -n "$boost_version"
packages_commit="$(git -C "$feed_dir" rev-parse HEAD)"
echo "OpenWrt packages: $packages_commit"
echo "Boost ABI: $boost_version"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  {
    echo "feed_dir=$feed_dir"
    echo "boost_version=$boost_version"
    echo "packages_commit=$packages_commit"
  } >> "$GITHUB_OUTPUT"
fi
