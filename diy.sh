#!/bin/bash
# ============================================================
# diy.sh for qosmio/openwrt-ipq (qualcommax-6.x-nss-wifi)
# JDCloud RE-CS-02 + NSS + athena-led + 插件
# ============================================================
set -e
cd "${0%/*}" || exit 1

echo ">>> 雅典娜 RE-CS-02 NSS + 插件 diy.sh"

# 1. LAN IP → 192.168.68.1（和原厂一致，方便过渡）
sed -i 's/192.168.1.1/192.168.68.1/g' package/base-files/files/bin/config_generate

# 2. 主机名
sed -i "s/hostname='OpenWrt'/hostname='Athena-NSS'/g" package/base-files/files/bin/config_generate

# 3. 默认 root 密码 athena（⚠️ 占位 hash，请本地生成真 hash 替换）
#    生成命令: echo -n '你的密码' | openssl passwd -5 -stdin
sed -i 's/root:::0:99999:7:::/root:$5$athena$xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:\n/' package/base-files/files/etc/shadow

# 4. 关 opkg/apk 签名强制（snapshot 源常无签名）
sed -i 's/check_signature 1/check_signature 0/g' package/system/opkg/Makefile

# 5. 设置 Argon 为默认 LuCI 主题
if [ -f feeds/luci/modules/luci-base/root/etc/config/luci ]; then
  sed -i 's/option mediaurlbase.*/option mediaurlbase \/luci-static\/argon/g' feeds/luci/modules/luci-base/root/etc/config/luci
fi

# 6. 重新展开配置（athena-led + 4 个插件已进 package 树，必须再 defconfig）
make defconfig V=s

echo ">>> diy.sh done"
