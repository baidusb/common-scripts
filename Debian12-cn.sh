#!/bin/bash

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
        # 使用 curl 测试连接时间（只请求头部信息）
        start_time=$(curl -o /dev/null -s -w %{time_connect} "$mirror")
        echo "$mirror 延迟: $start_time 秒"

        # 使用 awk 进行浮点数比较
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

    # 备份原来的 sources.list
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

    # 写入新的 sources.list
    sudo tee /etc/apt/sources.list > /dev/null <<EOF
deb $mirror bookworm main contrib non-free non-free-firmware
deb $mirror bookworm-updates main contrib non-free non-free-firmware
deb $mirror bookworm-backports main contrib non-free non-free-firmware
EOF

    echo "更新完成！"
}

# 主程序逻辑
select_fastest_mirror
if [ -n "$fastest_mirror" ]; then
    update_sources_list "$fastest_mirror"
    echo "正在更新软件包索引..."
    sudo apt update
    echo "所有操作已完成！"
else
    echo "未找到可用的镜像源，请检查网络连接。"
fi

