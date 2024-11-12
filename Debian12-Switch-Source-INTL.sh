#!/bin/bash

# 输出地区选项
echo "请选择你的地区:"
echo "1) 中国香港"
echo "2) 中国台湾"
echo "3) 日本"
echo "4) 新加坡"
echo "5) 韩国"
echo "6) 美国"
echo "7) 欧洲"

# 读取用户输入
read -p "请输入对应数字 (1-7): " region

# 根据选择更新源地址
case $region in
    1)
        mirror="http://ftp.hk.debian.org/debian/"
        ;;
    2)
        mirror="http://ftp.tw.debian.org/debian/"
        ;;
    3)
        mirror="http://ftp.jp.debian.org/debian/"
        ;;
    4)
        mirror="http://ftp.sg.debian.org/debian/"
        ;;
    5)
        mirror="http://ftp.kr.debian.org/debian/"
        ;;
    6)
        mirror="http://ftp.us.debian.org/debian/"
        ;;
    7)
        mirror="http://ftp.de.debian.org/debian/"
        ;;
    *)
        echo "无效的选项。"
        exit 1
        ;;
esac

# 备份原来的 sources.list 文件
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

# 写入新的源地址到 sources.list 文件
sudo bash -c "cat > /etc/apt/sources.list <<EOF
deb $mirror bookworm main contrib non-free non-free-firmware
deb $mirror bookworm-updates main contrib non-free non-free-firmware
deb $mirror bookworm-backports main contrib non-free non-free-firmware
EOF"

# 更新软件包列表
sudo apt update

echo "源已成功更换为 $mirror 并更新完成。"
