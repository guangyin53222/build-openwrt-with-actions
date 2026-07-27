# ===================== 基础系统修改 =====================
sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
sed -i 's/ImmortalWrt/ARWRT/g' package/base-files/files/bin/config_generate

# ===================== 第三方插件统一拉取（先删旧残留） =====================
rm -rf package/OpenAppFilter
git clone --depth 1 -b v6.1.8 https://github.com/destan19/OpenAppFilter package/OpenAppFilter
rm -rf package/luci-app-store
git clone --depth=1 https://github.com/linkease/istore.git package/luci-app-store
rm -rf package/luci-app-gecoosac
git clone --depth=1 https://github.com/laipeng668/luci-app-gecoosac package/luci-app-gecoosac
rm -rf tmp/openwrt-app-actions package/luci-app-wan-mac
git clone --depth=1 https://github.com/linkease/openwrt-app-actions tmp/openwrt-app-actions
mv tmp/openwrt-app-actions/applications/luci-app-wan-mac package/luci-app-wan-mac
rm -rf tmp/openwrt-app-actions
# 添加 luci-app-tcpdump 抓包插件
git clone https://github.com/KFERMercer/luci-app-tcpdump.git ./package/luci-app-tcpdump

# ===================== KSMBD升级3.5.4 同步源码 =====================
# 修改官方ksmbd内核模块为3.5.4版本
sed -i 's|PKG_VERSION:=.*|PKG_VERSION:=3.5.4|' package/kernel/ksmbd/Makefile
sed -i 's|PKG_SOURCE_URL:=.*|PKG_SOURCE_URL:=https://github.com/cifsd-team/ksmbd/archive/refs/tags/3.5.4.tar.gz|' package/kernel/ksmbd/Makefile
sed -i 's|PKG_HASH:=.*|PKG_HASH:=613c832d4f7e9878d7e87a0d6b4e8d962262985f34f10612f3b07d72f3d81420|' package/kernel/ksmbd/Makefile
# 同步同版本ksmbd-tools
rm -rf feeds/packages/net/ksmbd-tools
git clone --depth 1 -b 3.5.4 https://github.com/cifsd-team/ksmbd-tools feeds/packages/net/ksmbd-tools

# ===================== 强制全部组件内置=y =====================
cat >> .config <<EOF
# 压缩工具
CONFIG_xz-utils=y
# 文件传输curl
CONFIG_curl=y
# 应用商店
CONFIG_PACKAGE_luci-app-store=y
# KSMBD全套强制内置
CONFIG_PACKAGE_kmod-fs-ksmbd=y
CONFIG_PACKAGE_ksmbd-server=y
CONFIG_PACKAGE_ksmbd-utils=y
CONFIG_PACKAGE_luci-app-ksmbd=y
EOF

# 更新并安装全部插件
./scripts/feeds update -a
./scripts/feeds install -a
