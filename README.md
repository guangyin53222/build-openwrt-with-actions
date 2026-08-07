# build-openwrt-nss

雅典娜 JDCloud RE-CS-02 满血 NSS + 点阵屏 + 插件 云编译模板

## 特性
- 源码：`qosmio/openwrt-ipq` @ `qualcommax-6.x-nss-wifi`
- 满血 NSS（PPPoE/NAT/ECM/WiFi offload）
- athena-led 点阵屏驱动 + LuCI 界面
- iStore 应用商店
- OpenAppFilter 应用过滤（v6.1.8）
- Gecoos AC 控制器
- Harbor File 文件管理器
- LuCI Argon 主题 + 中文
- 默认 LAN IP：192.168.68.1

## 使用
1. Fork 本仓库（设为 Public）
2. 本地生成密码 hash：`echo -n '密码' | openssl passwd -5 -stdin`
3. 替换 `diy.sh` 中的占位 hash
4. Actions → Run workflow → 等 1.5~3 小时
5. Releases 下载 `factory.bin` → U-Boot 刷入

## 刷后验证
```bash
ssh root@192.168.68.1
dmesg | grep -i nss          # NSS FW loaded
ls /dev/tmp1628-led          # 屏节点
/etc/init.d/athena_led status # running
```
