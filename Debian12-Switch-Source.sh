#!/bin/bash

echo "请选择你的地区:"
echo "1) 中国大陆"
echo "2) 中国香港"
echo "3) 中国台湾"
echo "4) 日本"
echo "5) 新加坡"
echo "6) 韩国"
echo "7) 美国"
echo "8) 欧洲"

# 读取用户输入
read -p "请输入对应数字 (1-8): " region

if [ "$region" -eq 1 ]; then
    # 调用 CN.sh 脚本中的功能
    echo "选择中国大陆，正在使用国内最快镜像源..."
    
    # 国内常用的 Debian 镜像源列表
    MIRRORS=(
        "http://mirrors.aliyun.com/debian/"
        "https://mirrors.tuna.tsinghua.edu.cn/debian/"
        "http://mirrors.cloud.tencent.com/debian/"
        "https://mirror.sjtu.edu.cn/debian/"
        "http://ftp.cn.debian.org/debian/"
    )

    # 测试网络延迟，返回最快的源
    function select_fastest_mirror() {
        echo "正在测试镜像源的网络延迟，请稍候..."
        fastest_mirror=""
        fastest_time=1000000  # 初始化为一个较大的时间

        for mirror in "${MIRRORS[@]}"; do
            start_time=$(curl -o /dev/null -s -w %{time_connect} "$mirror")
            echo "$mirror 延迟: $start_time 秒"

            if awk "BEGIN {exit !($start_time < $fastest_time)}"; then
                fastest_time=$start_time
                fastest_mirror=$mirror
            fi
        done

        echo "最快的镜像源是: $fastest_mirror"
    }

    # 更新 /etc/apt/sources.list
    function update_sources_list() {
        local mirror=$1
        echo "正在更新 /etc/apt/sources.list..."

        sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
        sudo tee /etc/apt/sources.list > /dev/null <<EOF
deb $mirror bookworm main contrib non-free non-free-firmware
deb $mirror bookworm-updates main contrib non-free non-free-firmware
deb $mirror bookworm-backports main contrib non-free non-free-firmware
EOF

        echo "更新完成！"
    }

    # 执行镜像选择和更新
    select_fastest_mirror
    if [ -n "$fastest_mirror" ]; then
        update_sources_list "$fastest_mirror"
        echo "正在更新软件包索引..."
        sudo apt update
        echo "所有操作已完成！"
    else
        echo "未找到可用的镜像源，请检查网络连接。"
    fi

else
    # 其他地区的镜像源
    case $region in
        2)
            mirror="http://ftp.hk.debian.org/debian/"
            ;;
        3)
            mirror="http://ftp.tw.debian.org/debian/"
            ;;
        4)
            mirror="http://ftp.jp.debian.org/debian/"
            ;;
        5)
            mirror="http://ftp.sg.debian.org/debian/"
            ;;
        6)
            mirror="http://ftp.kr.debian.org/debian/"
            ;;
        7)
            mirror="http://ftp.us.debian.org/debian/"
            ;;
        8)
            mirror="http://ftp.de.debian.org/debian/"
            ;;
        *)
            echo "无效的选项。"
            exit 1
            ;;
    esac

    # 更新 sources.list
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
    sudo tee /etc/apt/sources.list > /dev/null <<EOF
deb $mirror bookworm main contrib non-free non-free-firmware
deb $mirror bookworm-updates main contrib non-free non-free-firmware
deb $mirror bookworm-backports main contrib non-free non-free-firmware
EOF

    sudo apt update
    echo "源已成功更换为 $mirror 并更新完成。"
fi
