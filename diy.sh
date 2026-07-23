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
rm -rf feeds/tcpdump
echo "src-git tcpdump https://github.com/KFERMercer/luci-app-tcpdump.git" >> feeds.conf.default

# 更新并安装全部插件
./scripts/feeds update -a
./scripts/feeds install -a
