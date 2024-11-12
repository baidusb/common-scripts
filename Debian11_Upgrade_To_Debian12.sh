#!/bin/bash

# 检查是否是root用户
if [ "$(id -u)" != "0" ]; then
  echo "请以root权限运行该脚本。"
  exit 1
fi

echo "正在更新当前系统的软件包..."
apt update && apt upgrade -y && apt full-upgrade -y && apt --purge autoremove -y

echo "备份当前的 sources.list 文件..."
cp /etc/apt/sources.list /etc/apt/sources.list.bak

echo "替换 Debian 11 (Bullseye) 的源为 Debian 12 (Bookworm) 的源..."
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list

echo "更新 APT 缓存..."
apt update

echo "执行系统升级到 Debian 12..."
apt upgrade --without-new-pkgs -y
apt full-upgrade -y

echo "清理不必要的包..."
apt --purge autoremove -y
apt clean

echo "升级完成！请重启系统以应用更改。"
echo "输入 'reboot' 命令重启系统。"
