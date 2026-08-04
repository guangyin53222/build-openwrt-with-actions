#!/bin/bash

# ============================================================
# diy.sh - iStoreOS / ImmortalWRT 自定义脚本
# 执行时机：在 feeds update 之前
# ============================================================

# ==================== 基础系统定制 ====================

# 修改默认 LAN IP 为 192.168.100.1
sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate

# 修改固件显示名称 ImmortalWrt → agWRT
sed -i 's/ImmortalWrt/agWRT/g' package/base-files/files/bin/config_generate

echo "✅ 基础系统定制完成"

# ==================== 第三方插件克隆 ====================
# ⚠️ 必须在 feeds update 之前 clone 到 package/ 目录下

# 集客 AC 控制器
echo "📦 克隆 luci-app-gecoosac ..."
rm -rf package/luci-app-gecoosac
git clone --depth=1 https://github.com/laipeng668/luci-app-gecoosac package/luci-app-gecoosac

# tcpdump 抓包插件
echo "📦 克隆 luci-app-tcpdump ..."
rm -rf package/luci-app-tcpdump
git clone --depth=1 https://github.com/KFERMercer/luci-app-tcpdump.git package/luci-app-tcpdump

# Harbor File 文件管理器
echo "📦 克隆 luci-app-harbor-file ..."
rm -rf package/luci-app-harbor-file
git clone --depth=1 https://github.com/destan19/luci-app-harbor-file.git package/luci-app-harbor-file

echo "✅ 第三方插件克隆完成"
echo "✅ diy.sh 执行完成"
