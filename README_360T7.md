# 360T7 ImmortalWrt 云编译指南

## 📌 概述

本配置基于 [padavanonly/immortalwrt-mt798x-6.6](https://github.com/padavanonly/immortalwrt-mt798x-6.6) 源码，
使用 GitHub Actions 自动编译 **360T7** 路由器固件。

## 🔧 技术参数

| 项目 | 说明 |
|------|------|
| 源码仓库 | padavanonly/immortalwrt-mt798x-6.6 |
| 分支 | openwrt-24.10-6.6 |
| 内核版本 | Linux 6.6 LTS |
| WiFi 驱动 | MTK 闭源驱动 |
| 目标设备 | 360T7 (mt7981b-qihoo-360t7) |
| Flash | 128MB (ESMT F50L1G41LB) |
| RAM | 256MB |

## 📂 文件说明

| 文件 | 作用 |
|------|------|
| `.github/workflows/build_360t7.yml` | GitHub Actions 工作流定义 |
| `.config` | OpenWrt 编译配置（会被 diy.sh 覆盖） |
| `diy.sh` | 自定义脚本（加载360T7配置+安装插件） |

## 🚀 使用方法

### 1. Fork 本仓库

点击右上角 Fork 按钮，将仓库复制到你的 GitHub 账户下。

### 2. 开启 Actions

进入你 Fork 的仓库 → Settings → Actions → General → 
将 "Workflow permissions" 设为 `Read and write permissions`。

### 3. 触发编译

进入 Actions 标签页 → 选择 "🚀 编译 ImmortalWrt for 360T7" → 
点击 "Run workflow" → 选择参数后点击运行。

### 4. 下载固件

编译完成后（约 1.5~3 小时），在 Actions 运行详情页底部下载 Artifact：
- `immortalwrt-360t7-openwrt-24.10-6.6` - 360T7 固件文件

## ⚙️ Workflow 参数说明

| 参数 | 默认 | 说明 |
|------|------|------|
| multithreading | true | 开启多线程编译（推荐） |
| ssh | false | 开启后可通过 SSH 手动 `make menuconfig` |
| isFiles | false | 是否使用 files 大法保留配置 |

## 📦 编译产物

主要固件文件：
- `immortalwrt-mediatek-filogic-qihoo_360t7-squashfs-sysupgrade.bin` - **刷机固件（推荐）**
- `immortalwrt-mediatek-filogic-qihoo_360t7-initramfs-recovery.itb` - 救砖固件
- `immortalwrt-mediatek-filogic-qihoo_360t7-preloader.bin` - BL2 引导
- `immortalwrt-mediatek-filogic-qihoo_360t7-bl31-uboot.fip` - U-Boot FIP

## 🔄 刷机方法

### 首次刷机（需要 UART 串口）

1. 连接 UART 串口，开机进入 failsafe 模式
2. 执行 `mount_root`，然后 `fw_setenv bootmenu_delay 3`
3. 备份所有 mtd 分区！
4. 重启进入 U-Boot 菜单
5. 依次刷入 `preloader.bin` → `bl31-uboot.fip` → initramfs 固件
6. 启动后执行 `sysupgrade` 刷入正式固件

### 升级刷机

直接在 LuCI 界面 → 系统 → 备份/升级 → 选择 `sysupgrade.bin` 刷入。

## ⚠️ 注意事项

1. **必须公开仓库**：私有仓库只有 50G 空间，编译大概率失败；公开仓库有 120G
2. **首次编译较慢**：约 1.5~3 小时，取决于服务器负载
3. **不要勾选太多插件**：容易导致编译失败或空间不足
4. **跨版本升级不保留配置**：建议先备份再升级

## 🔌 预装插件

- PassWall（代理工具）
- SSR-Plus（代理工具）
- TurboACC（网络加速）
- OpenAppFilter（应用过滤）
- iStore（应用商店）
- EqOS（智能限速）
- 等等...

## 📝 自定义修改

### 修改默认 IP

编辑 `diy.sh`，修改这一行：
```bash
sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate
```

### 添加/删除插件

编辑 `diy.sh`，在 "克隆第三方插件" 部分添加或注释相关行。
然后在 `.config` 中添加/删除对应的 `CONFIG_PACKAGE_xxx=y` 配置项。

### 手动配置 (SSH 模式)

运行 workflow 时勾选 `ssh: true`，系统会提供一个 SSH 连接地址，
连接后执行 `make menuconfig` 手动配置，配置完成后断开连接即可继续编译。

## 🔗 相关链接

- [padavanonly/immortalwrt-mt798x-6.6](https://github.com/padavanonly/immortalwrt-mt798x-6.6) - 源码仓库
- [hanwckf/bl-mt798x](https://github.com/hanwckf/bl-mt798x) - 360T7 U-Boot
- [恩山论坛 360T7 专区](https://www.right.com.cn/forum/) - 交流讨论
