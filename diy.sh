#!/bin/bash
# ============================================================
# 360T7 专用 diy.sh
# 基于 padavanonly/immortalwrt-mt798x-6.6 (openwrt-24.10-6.6)
# ============================================================

echo "=========================================="
echo "  开始 360T7 自定义配置"
echo "=========================================="

# ========== 1. 从 defconfig 加载 360T7 基础配置 ==========
if [ -f "defconfig/mt7981-ax3000.config" ]; then
    echo ">>> 复制 mt7981-ax3000.config 作为基础配置..."
    cp defconfig/mt7981-ax3000.config .config

    echo ">>> 关闭其他设备，只保留 360T7..."
    # 关闭所有非 360T7 的 mt7981 设备
    for dev in huasifei_wh3000-emmc abt_asr3000 cetron_ct3003 cmcc_a10 \
             cmcc_rax3000m cmcc_rax3000m-emmc cmcc_xr30-stock \
             h3c_nx30pro imou_lc-hx3001 jcg_q30 konka_komi-a31 \
             livinet_zr-3020 mt7981-clt-r30b1 mt7981-clt-r30b1-112M \
             xiaomi_mi-router-ax3000t xiaomi_mi-router-ax3000t-stock \
             xiaomi_mi-router-wr30u-112m xiaomi_mi-router-wr30u-stock; do
        sed -i "s/^CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_${dev}=y/# CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_${dev} is not set/" .config
    done

    # 确认 360T7 已开启
    sed -i 's/^# CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_mt7981-360-t7-108M is not set/CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_mt7981-360-t7-108M=y/' .config

    echo ">>> 360T7 设备配置已启用"
fi

# ========== 2. 修改默认 LAN IP ==========
echo ">>> 设置默认 LAN IP 为 192.168.6.1..."
sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate

# ========== 3. 修改默认主题为 Argon ==========
echo ">>> 设置默认主题为 Argon..."
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# ========== 4. 修改固件显示名称 ==========
echo ">>> 修改固件显示名称..."
sed -i 's/ImmortalWrt/360T7-WRT/g' package/base-files/files/bin/config_generate

# ========== 5. 添加第三方软件源 ==========
echo ">>> 添加第三方软件源..."
#echo 'src-git UA3F https://github.com/SunBK201/UA3F.git' >> feeds.conf.default

# ========== 6. 克隆第三方插件 ==========
echo ">>> 克隆第三方插件..."

# OpenAppFilter 应用过滤
rm -rf package/OpenAppFilter
git clone --depth 1 -b v6.1.8 https://github.com/destan19/OpenAppFilter package/OpenAppFilter

# iStore 应用商店
rm -rf package/luci-app-store
git clone --depth=1 https://github.com/linkease/istore.git package/luci-app-store

# Gecoos AC 控制器
rm -rf package/luci-app-gecoosac
git clone --depth=1 https://github.com/laipeng668/luci-app-gecoosac package/luci-app-gecoosac

# WAN MAC 修改插件
rm -rf tmp/openwrt-app-actions package/luci-app-wan-mac
git clone --depth=1 https://github.com/linkease/openwrt-app-actions tmp/openwrt-app-actions
mv tmp/openwrt-app-actions/applications/luci-app-wan-mac package/luci-app-wan-mac
rm -rf tmp/openwrt-app-actions

# TCPDump 抓包插件
rm -rf package/luci-app-tcpdump
git clone https://github.com/KFERMercer/luci-app-tcpdump.git package/luci-app-tcpdump

# Harbor File 文件管理器（2026 活跃维护）
rm -rf package/luci-app-harbor-file
git clone --depth=1 https://github.com/destan19/luci-app-harbor-file package/luci-app-harbor-file
# ========== 7. 更新并安装 feeds ==========
echo ">>> 更新并安装 feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

echo "=========================================="
echo "  diy.sh 执行完成"
echo "=========================================="
