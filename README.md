# i2pd-openwrt 25.12+

### Building and testing

Release SDKs pin dependency feeds to older commits, while OpenWrt's binary
package repositories continue to receive updates. CI overlays this i2pd recipe
on the current `openwrt-25.12` packages feed so Boost headers and libraries match
the stable package feed, rather than the SDK's old Boost ABI. Each release build
checks the APK's linked Boost version before publishing it.

Pull requests build `aarch64_generic` and run `i2pd --version` in an OpenWrt
25.12.5 container with dependencies installed from the official repositories.
This checks the dynamic loader; router networking and tunnels still need testing
on a device. The test workflow publishes an APK artifact without deployment keys.

Increment `PKG_RELEASE` when changing the package without changing the upstream
version. Release detection checks that revision's APK assets; `force_rebuild`
also permits an explicit rebuild of an existing revision.

### Install trust key once

```sh
wget -qO "/etc/apk/keys/i2pd-feed.pem" "https://makishimuakuma.github.io/i2pd-openwrt/25.12/$(cat /etc/apk/arch)/i2pd-feed.pub.pem"
```

### Add repository

```sh
echo "https://makishimuakuma.github.io/i2pd-openwrt/25.12/$(cat /etc/apk/arch)/packages.adb" > "/etc/apk/repositories.d/i2pd.list"
apk update
apk add i2pd
```

### Update i2pd

```sh
apk update
apk upgrade i2pd
```
