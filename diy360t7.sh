#!/bin/bash
# ============================================================
# 360T7 专用 diy.sh（合并版）
# 基于 padavanonly/immortalwrt-mt798x-6.6 (openwrt-24.10-6.6)
# 合并了原 diy.sh + diy-part2.sh，单文件直接可用
# ============================================================

echo "=========================================="
echo "  开始 360T7 自定义配置"
echo "=========================================="

# ========== 1. 加载 360T7 基础配置 ==========
if [ -f "defconfig/mt7981-ax3000.config" ]; then
    echo ">>> 使用 mt7981-ax3000.config（360T7 108M）..."
    cp defconfig/mt7981-ax3000.config .config

    # 关闭其他 mt7981 设备
    for dev in huasifei_wh3000-emmc abt_asr3000 cetron_ct3003 cmcc_a10 \
               cmcc_rax3000m cmcc_rax3000m-emmc cmcc_xr30-stock \
               h3c_nx30pro imou_lc-hx3001 jcg_q30 konka_komi-a31 \
               livinet_zr-3020 mt7981-clt-r30b1 mt7981-clt-r30b1-112M \
               xiaomi_mi-router-ax3000t xiaomi_mi-router-ax3000t-stock \
               xiaomi_mi-router-wr30u-112m xiaomi_mi-router-wr30u-stock; do
        sed -i "s/^CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_${dev}=y/# CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_${dev} is not set/" .config
    done

    # 强制开启 360T7
    sed -i 's/^# CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_mt7981-360-t7-108M is not set/CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_mt7981-360-t7-108M=y/' .config
fi

# ========== 2. LAN IP ==========
echo ">>> 设置 LAN IP 为 192.168.100.1..."
sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.6.1/192.168.100.1/g' package/base-files/files/bin/config_generate

# ========== 3. 主机名 & 固件名称 ==========
echo ">>> 设置主机名为 360t7..."
sed -i "s/hostname='ImmortalWrt'/hostname='360t7'/g" package/base-files/files/bin/config_generate
sed -i "s/DISTRIB_DESCRIPTION='ImmortalWrt'/DISTRIB_DESCRIPTION='360T7-WRT 24.10'/g" package/base-files/files/etc/openwrt_release

# ========== 4. Argon 主题 ==========
echo ">>> 设置 Argon 为默认主题..."
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# ========== 6. 克隆第三方插件 ==========
echo ">>> 克隆第三方插件..."
# store
rm -rf package/luci-app-store
git clone --depth=1 https://github.com/linkease/istore.git package/luci-app-store

# OpenAppFilter（锁 v6.1.8 tag）
rm -rf package/OpenAppFilter
git clone --depth 1 --branch v6.1.8 https://github.com/destan19/OpenAppFilter package/OpenAppFilter

# Gecoos AC
rm -rf package/luci-app-gecoosac
git clone --depth=1 https://github.com/laipeng668/luci-app-gecoosac package/luci-app-gecoosac

# WAN MAC
rm -rf tmp/openwrt-app-actions package/luci-app-wan-mac
git clone --depth=1 https://github.com/linkease/openwrt-app-actions tmp/openwrt-app-actions
mv tmp/openwrt-app-actions/applications/luci-app-wan-mac package/luci-app-wan-mac
rm -rf tmp/openwrt-app-actions

# TCPDump（老 Lua 版，24.10 Web 可能异常）
rm -rf package/luci-app-tcpdump
git clone --depth=1 https://github.com/KFERMercer/luci-app-tcpdump.git package/luci-app-tcpdump

# Harbor File
rm -rf package/luci-app-harbor-file
git clone --depth=1 https://github.com/destan19/luci-app-harbor-file package/luci-app-harbor-file

# ========== 7. 更新并安装 feeds ==========
echo ">>> 更新并安装 feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# ========== 8. 写入插件配置到 .config（必须在 feeds install 之后） ==========
echo ">>> 写入插件配置到 .config..."

cat >> .config << 'EOF'

# iStore
CONFIG_PACKAGE_luci-app-store=y
CONFIG_PACKAGE_xz-utils=y
CONFIG_PACKAGE_curl=y

# OpenAppFilter
CONFIG_PACKAGE_luci-app-oaf=y
CONFIG_PACKAGE_appfilter=y
CONFIG_PACKAGE_kmod-oaf=y

# Gecoos AC
CONFIG_PACKAGE_luci-app-gecoosac=y

# WAN MAC
CONFIG_PACKAGE_luci-app-wan-mac=y

# TCPDump
CONFIG_PACKAGE_luci-app-tcpdump=y
CONFIG_PACKAGE_tcpdump=y

# Harbor File
CONFIG_PACKAGE_luci-app-harbor-file=y
CONFIG_PACKAGE_luci-i18n-harbor-file-zh-cn=y

EOF

# ========== 10. 最终 defconfig ==========
echo ">>> 执行 defconfig..."
make defconfig

echo "=========================================="
echo "  diy.sh 执行完成"
echo "=========================================="
