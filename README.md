# i2pd-openwrt 25.12+

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
