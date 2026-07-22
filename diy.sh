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

# ===================== Tailscale v1.98.9 自定义 =====================
rm -rf package/feeds/tailscale package/custom_tailscale
git clone --depth 1 https://github.com/tailscale/tailscale-openwrt.git package/custom_tailscale

sed -i 's/^PKG_VERSION:=.*/PKG_VERSION:=1.98.9/' package/custom_tailscale/Makefile
sed -i 's/^PKG_SOURCE:=.*/PKG_SOURCE:=v1.98.9.tar.gz/' package/custom_tailscale/Makefile
sed -i 's|^PKG_SOURCE_URL:=.*|PKG_SOURCE_URL:=https://github.com/tailscale/tailscale/archive/refs/tags|' package/custom_tailscale/Makefile

sed -i '/EXTRA_GOFLAGS/d' package/custom_tailscale/Makefile
echo 'EXTRA_GOFLAGS += -tags=ts_no_metrics' >> package/custom_tailscale/Makefile

sed -i '/tailscale up /c\tailscale up \\\n--advertise-routes=192.168.100.0/24 \\\n--accept-routes \\\n--accept-dns=false \\\n--snat-subnet-routes=false \\\n--netfilter-mode=off' package/custom_tailscale/files/tailscale.init

echo 'src-link tailscale $(TOPDIR)/package/custom_tailscale' >> feeds.conf.default
rm -rf dl/tailscale* build_dir/go bin/packages/*/tailscale

# 更新并安装全部插件
./scripts/feeds update -a
./scripts/feeds install -a
