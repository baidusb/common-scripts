#!/bin/bash

# Debian 12 交互式SWAP设置脚本
# 作者：AI助手
# 版本：1.0

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函数：显示颜色消息
print_message() {
    echo -e "${2}${1}${NC}"
}

# 函数：检查root权限
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_message "错误：此脚本需要root权限执行" "$RED"
        print_message "请使用: sudo $0" "$YELLOW"
        exit 1
    fi
}

# 函数：显示当前SWAP信息
show_swap_info() {
    print_message "=== 当前系统SWAP信息 ===" "$BLUE"
    echo "物理内存:"
    free -h | grep Mem
    echo -e "\nSWAP空间:"
    free -h | grep Swap
    echo -e "\nSWAP设备详情:"
    swapon --show
    echo ""
}

# 函数：禁用并删除现有SWAP
remove_existing_swap() {
    print_message "正在检查现有SWAP..." "$YELLOW"
    
    # 检查是否有活跃的SWAP
    if swapon --show | grep -q .; then
        print_message "检测到现有SWAP，正在禁用..." "$YELLOW"
        swapoff -a
        
        # 删除SWAP文件
        if [ -f /swapfile ]; then
            rm -f /swapfile
            print_message "已删除旧SWAP文件" "$GREEN"
        fi
        
        # 从fstab中移除SWAP条目
        sed -i '/swapfile/d' /etc/fstab
        print_message "已从fstab中移除SWAP配置" "$GREEN"
    else
        print_message "未检测到活跃的SWAP" "$GREEN"
    fi
}

# 函数：创建SWAP文件
create_swap() {
    local size=$1
    local size_mb=$2
    
    print_message "正在创建 ${size} SWAP文件..." "$YELLOW"
    
    # 使用dd创建SWAP文件
    if dd if=/dev/zero of=/swapfile bs=1M count=$size_mb status=progress; then
        print_message "SWAP文件创建成功" "$GREEN"
    else
        print_message "SWAP文件创建失败" "$RED"
        exit 1
    fi
    
    # 设置正确的权限
    chmod 600 /swapfile
    
    # 格式化为SWAP
    if mkswap /swapfile; then
        print_message "SWAP格式化成功" "$GREEN"
    else
        print_message "SWAP格式化失败" "$RED"
        exit 1
    fi
    
    # 启用SWAP
    if swapon /swapfile; then
        print_message "SWAP启用成功" "$GREEN"
    else
        print_message "SWAP启用失败" "$RED"
        exit 1
    fi
    
    # 添加到fstab实现开机自动挂载
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    print_message "已添加到fstab，开机自动挂载" "$GREEN"
}

# 函数：调整swappiness
adjust_swappiness() {
    local value=$1
    print_message "正在调整swappiness为 $value..." "$YELLOW"
    sysctl vm.swappiness=$value
    echo "vm.swappiness=$value" >> /etc/sysctl.conf
    print_message "swappiness已设置为 $value" "$GREEN"
}

# 函数：显示菜单
show_menu() {
    clear
    print_message "=== Debian 12 SWAP 设置脚本 ===" "$BLUE"
    echo ""
    show_swap_info
    
    print_message "请选择SWAP大小：" "$YELLOW"
    echo "1) 1GB SWAP"
    echo "2) 2GB SWAP"
    echo "3) 4GB SWAP"
    echo "4) 自定义SWAP大小"
    echo "5) 删除所有SWAP"
    echo "6) 退出脚本"
    echo ""
}

# 主函数
main() {
    check_root
    
    while true; do
        show_menu
        read -p "请输入选择 [1-6]: " choice
        
        case $choice in
            1)
                remove_existing_swap
                create_swap "1GB" 1024
                adjust_swappiness 10
                ;;
            2)
                remove_existing_swap
                create_swap "2GB" 2048
                adjust_swappiness 10
                ;;
            3)
                remove_existing_swap
                create_swap "4GB" 4096
                adjust_swappiness 10
                ;;
            4)
                read -p "请输入SWAP大小(GB): " custom_size
                if [[ $custom_size =~ ^[0-9]+$ ]] && [ $custom_size -gt 0 ]; then
                    remove_existing_swap
                    create_swap "${custom_size}GB" $((custom_size * 1024))
                    adjust_swappiness 10
                else
                    print_message "错误：请输入有效的数字" "$RED"
                    sleep 2
                fi
                ;;
            5)
                remove_existing_swap
                print_message "所有SWAP已删除" "$GREEN"
                ;;
            6)
                print_message "感谢使用！再见！" "$GREEN"
                exit 0
                ;;
            *)
                print_message "错误：无效选择，请重新输入" "$RED"
                sleep 2
                ;;
        esac
        
        # 显示最终结果
        echo ""
        print_message "=== 操作完成 ===" "$BLUE"
        show_swap_info
        
        read -p "按回车键继续..."
    done
}

# 捕获Ctrl+C
trap 'echo -e "\n${RED}操作被用户中断${NC}"; exit 1' INT

# 运行主函数
main
