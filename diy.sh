#!/bin/bash
# diy.sh - 雅典娜 RE-CS-02 NSS 定制脚本
set -e

cd "${0%/*}" || exit 1

echo ">>> [1/5] 设置 LAN IP 为 192.168.68.1"
sed -i 's/192.168.1.1/192.168.68.1/g' package/base-files/files/bin/config_generate

echo ">>> [2/5] 设置主机名为 Athena-NSS"
sed -i "s/hostname='OpenWrt'/hostname='Athena-NSS'/g" package/base-files/files/bin/config_generate

echo ">>> [3/5] 设置默认 root 密码为 athena"
# 占位 hash，编译前请本地生成真 hash 替换：
#   echo -n '你的密码' | openssl passwd -5 -stdin
sed -i 's/root:::0:99999:7:::/root:$5$athena$VXxX8QY8QY8QY8QY8QY8QY8QY8QY8QY8QY8QY8QY8QY8QY.:0:99999:7:::/' package/base-files/files/etc/shadow

echo ">>> [4/5] 关闭 opkg/apk 签名强制"
sed -i 's/check_signature 1/check_signature 0/g' package/system/opkg/Makefile 2>/dev/null || true

echo ">>> [5/5] 重新展开配置 (让 athena-led + 4 插件进最终配置)"
make defconfig V=s

echo ">>> diy.sh 完成 ✓"
