# 请在下方输入自定义命令(一般用来安装第三方插件)(可以留空)

# 编辑默认的lan口ip地址
sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate

# 编辑默认的主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 编辑默认的luci显示的固件名称
#sed -i 's/OpenWrt/ARWRT/g' package/base-files/files/bin/config_generate
sed -i 's/ImmortalWrt/ARWRT/g' package/base-files/files/bin/config_generate

# 添加额外的软件包，echo 方式和git clone 方式二选一即可
#echo 'src-git kenzok8 https://github.com/kenzok8/openwrt-packages' >>feeds.conf.default
#echo 'src-git small https://github.com/kenzok8/small' >>feeds.conf.default
#echo 'src-git UA3F https://github.com/SunBK201/UA3F.git' >>feeds.conf.default
#git clone https://github.com/kenzok8/openwrt-packages.git package/openwrt-packages
#git clone https://github.com/kenzok8/small.git package/small
#git clone https://github.com/SunBK201/UA3F.git package/UA3F
#git clone https://github.com/stevenjoezhang/luci-app-adguardhome.git package/ADGH
git clone https://github.com/destan19/OpenAppFilter package/OpenAppFilter
# istore插件
git clone https://github.com/linkease/istore.git package/luci-app-store
# 克隆gecoosac插件
git clone --depth=1 https://github.com/laipeng668/luci-app-gecoosac package/luci-app-gecoosac
#下载 wan-mac 修改插件
git clone --depth=1 https://github.com/linkease/openwrt-app-actions tmp/openwrt-app-actions
mv tmp/openwrt-app-actions/applications/luci-app-wan-mac package/luci-app-wan-mac
rm -rf tmp/openwrt-app-actions
# Bandix-plus 流量监控：后端核心程序
#git clone --depth=1 https://github.com/timsaya/openwrt-bandix-plus package/openwrt-bandix-plus
# Bandix-plus 流量监控：LuCI前端界面
#git clone --depth=1 https://github.com/timsaya/luci-app-bandix-plus package/luci-app-bandix-plus
