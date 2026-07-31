#!/bin/bash
# ============================================================
# diy.sh — CMCC XR30 eMMC 最终版编译前预处理脚本
# 用法：放在仓库根目录，chmod +x，由 GitHub Actions 自动调用
# ============================================================

set -e

echo "============================================"
echo "  CMCC XR30 eMMC — diy.sh 开始执行"
echo "============================================"

# ---------- 1. 基础系统修改 ----------
echo "[1/6] 设置 LAN IP & 主机名..."

# 修改默认 LAN IP 为 192.168.100.1
sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate 2>/dev/null || true

# 修改主机名
sed -i 's/ImmortalWrt/ARWRT/g' package/base-files/files/etc/config/system 2>/dev/null || true

# ---------- 2. 拉取第三方插件 ----------
echo "[2/6] 拉取第三方插件..."

mkdir -p package/extra

# OpenAppFilter
if [ ! -d package/extra/luci-app-openappfilter ]; then
  git clone --depth=1 https://github.com/destan19/OpenAppFilter.git package/extra/luci-app-openappfilter 2>/dev/null || true
fi

# iStore
if [ ! -d package/extra/luci-app-store ]; then
  git clone --depth=1 https://github.com/linkease/istore.git package/extra/luci-app-store 2>/dev/null || true
fi

# GecoosAC
if [ ! -d package/extra/luci-app-gecoosac ]; then
  git clone --depth=1 https://github.com/gecoosac/luci-app-gecoosac.git package/extra/luci-app-gecoosac 2>/dev/null || true
fi

# WAN MAC 修改工具
if [ ! -d package/extra/luci-app-wan-mac ]; then
  git clone --depth=1 https://github.com/gygy/OpenWrt-wan-mac.git package/extra/luci-app-wan-mac 2>/dev/null || true
fi

# tcpdump
if [ ! -d package/extra/luci-app-tcpdump ]; then
  git clone --depth=1 https://github.com/KFERMercer/luci-app-tcpdump.git package/extra/luci-app-tcpdump 2>/dev/null || true
fi

# Argon 主题
if [ ! -d package/extra/luci-theme-argon ]; then
  git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon.git package/extra/luci-theme-argon 2>/dev/null || true
fi

# ---------- 3. Feeds 更新安装 ----------
echo "[3/6] 更新并安装 feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# ---------- 4. 设备校验 ----------
echo "[4/6] 校验 XR30 eMMC 设备定义..."

# 检查 DTS 文件是否存在
if [ -f "target/linux/mediatek/dts/mt7981b-cmcc-xr30-emmc.dts" ]; then
    echo "  ✅ DTS 文件存在"
else
    echo "  ❌ 错误：DTS 文件不存在！"
    echo "     请确认已放置：target/linux/mediatek/dts/mt7981b-cmcc-xr30-emmc.dts"
    exit 1
fi

# 检查 mk 里是否注册了设备
if grep -q "cmcc_xr30_emmc" target/linux/mediatek/image/filogic.mk 2>/dev/null; then
    echo "  ✅ mk 设备定义存在"
else
    echo "  ❌ 错误：mt7981.mk 中未找到 cmcc_xr30_emmc"
    echo "     请将 filogic-mk-xr30-emmc.mk 的内容追加到 filogic.mk 末尾"
    exit 1
fi

# 检查 base-files 脚本
if [ -f "target/linux/mediatek/filogic/base-files/etc/board.d/02_network" ]; then
    echo "  ✅ 02_network 存在"
fi

if [ -f "target/linux/mediatek/filogic/base-files/lib/preinit/90_extract_caldata" ]; then
    echo "  ✅ 90_extract_caldata 存在"
fi

# ---------- 5. 强制锁定 .config ----------
echo "[5/6] 锁定 .config → cmcc_xr30_emmc..."

# 先注释掉其他 DEVICE（防止冲突）
sed -i 's/^CONFIG_TARGET_mediatek_filogic_DEVICE_.*=y$/# &/g' .config 2>/dev/null || true

# 写入 XR30 eMMC 的完整配置
cat >> .config <<'EOF'

# ===== CMCC XR30 eMMC (强制锁定) =====
CONFIG_TARGET_mediatek=y
CONFIG_TARGET_mediatek_filogic=y
CONFIG_TARGET_mediatek_filogic_DEVICE_cmcc_xr30_emmc=y
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-ssl=y
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_kmod-mt7915e=y
CONFIG_PACKAGE_kmod-mt7981-firmware=y
CONFIG_PACKAGE_mt7981-wo-firmware=y
CONFIG_PACKAGE_kmod-usb3=y
CONFIG_PACKAGE_kmod-mmc=y
CONFIG_PACKAGE_kmod-fs-f2fs=y
CONFIG_PACKAGE_mkf2fs=y
CONFIG_PACKAGE_f2fsck=y
CONFIG_PACKAGE_automount=y
CONFIG_PACKAGE_luci-app-oaf=y
CONFIG_PACKAGE_luci-app-store=y
CONFIG_PACKAGE_luci-app-gecoosac=y
CONFIG_PACKAGE_luci-app-wan-mac=y
CONFIG_PACKAGE_luci-app-tcpdump=y
EOF

# 让 make defconfig 展开依赖
make defconfig

# ---------- 6. 最终确认 ----------
echo "[6/6] 最终校验..."

if grep -q "CONFIG_TARGET_mediatek_filogic_DEVICE_cmcc_xr30_emmc=y" .config; then
    echo "  ✅ .config 已锁定 cmcc_xr30_emmc"
else
    echo "  ❌ 锁定失败，请检查 mk 和 DTS 文件"
    exit 1
fi

echo ""
echo "============================================"
echo "  ✅ diy.sh 执行完成，准备编译 XR30 eMMC"
echo "============================================"
echo ""
echo "编译命令（本地）："
echo "  make -j\$(nproc) V=s"
echo ""
echo "预期产物："
echo "  bin/targets/mediatek/filogic/"
echo "  ├── immortalwrt-mediatek-filogic-cmcc_xr30_emmc-squashfs-sysupgrade.itb"
echo "  ├── immortalwrt-mediatek-filogic-cmcc_xr30_emmc-emmc-gpt.bin"
echo "  └── immortalwrt-mediatek-filogic-cmcc_xr30_emmc.manifest"
