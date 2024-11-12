# 个人自用便捷脚本
## 一、Debian12常用脚本：
### 1、Debian12国内外一键切换源：
国内：
```
wget https://gitee.com/baidusb/common-scripts/raw/master/Debian12-Switch-Source-CN.sh && \
chmod +x Debian12-Switch-Source-CN.sh && \
sed -i 's/\r$//' Debian12-Switch-Source-CN.sh && \
bash Debian12-Switch-Source-CN.sh
```
国外：
```
wget https://raw.githubusercontent.com/baidusb/common-scripts/refs/heads/main/Debian12-Switch-Source-INTL.sh && \
chmod +x Debian12-Switch-Source-INTL.sh && \
sed -i 's/\r$//' Debian12-Switch-Source-INTL.sh && \
bash Debian12-Switch-Source-INTL.sh
```

### 2、Debian12一键升级到当前最新版并安装常用工具
```
sudo apt update && sudo apt -y upgrade && sudo apt -y dist-upgrade && sudo apt -y install curl wget sudo net-tools vim unzip htop build-essential && sudo apt autoremove -y && sudo apt clean
```
