#!/bin/bash

#定义文字颜色
Green="\033[32m"
Red="\033[31m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"

#定义提示信息
Info="${Green}[信息]${Font}"
OK="${Green}[OK]${Font}"
Error="${Red}[错误]${Font}"

#定义配置文件路径
a=3
b=20
c=9
d=2
f=8

#用户设定 域名 端口 alterID
port_alterid_set(){
	echo -e "${Info} ${GreenBG} 【配置 1/3 】请输入你的域名ping信息,请确保域名A记录已正确解析至服务器IP ${Font}"
	stty erase '^H' && read -p "请输入：" domain
	echo -e "${Info} ${GreenBG} 【配置 2/3 】请输入丢包率 ${Font}"
	stty erase '^H' && read -p "请输入：" port
	echo -e "${Info} ${GreenBG} 【配置 3/3 】请输入内存数据 ${Font}"
	stty erase '^H' && read -p "请输入：" alterID
	echo -e "----------------------------------------------------------"
	echo -e "${Info} ${GreenBG} 你输入的配置信息为 域名：${domain} 端口：${port} alterID：${alterID}  ${Font}"
	echo -e "----------------------------------------------------------"
}

#安装各种依赖工具
dependency_install(){
apt-get update -y
apt-get install bc -y
sleep 2
wget --no-check-certificate -O appex.sh https://raw.githubusercontent.com/bakuniverse/serverSpeeder_Install/master/appex.sh && chmod +x appex.sh && bash appex.sh install
sleep 2
}

modify_ping(){
cms=`ping -c 20 202.98.198.167 | grep '^rtt' | awk -F"/" '{print $5F}'`
cm=`echo "$cms"|sed "s/\..*//g"`
result=`echo "scale=0;$[$cm+12]" | bc`

}
#修正nginx配置配置文件
modify_nginx(){
sleep 1
cp -a /appex/etc/config2 /appex/etc/config1
chmod +x /appex/etc/config1
domain2=$result
domain1="$[domain2+b]"
port=`ping -c 50 202.98.198.167 | grep 'loss' | awk -F',' '{ print $3 }' | awk -F"% packet loss" '{ print $1 }'`
alterID1=`free -m | awk 'NR==2' | awk '{print $2}'`
alterID="512"
initialCwndWan1=`echo "scale=0;$[$domain2/3-2]" | bc`
initialCwndWan2=`echo "scale=0;$[$domain1/3-2]" | bc`
halfCwndLossRateShift1="$port"
halfCwndLossRateShift2="$[$port+d]"
smBurstMS1=`echo "scale=0;$[$domain2/9-5]" | bc`
smBurstMS2=`echo "scale=0;$[$domain1/9-5]" | bc`
engineNum1="$e"
engineNum2="$e"
shortRttMS1=`echo "scale=0;$[$domain2/3-3]" | bc`
shortRttMS2=`echo "scale=0;$[$domain1/3-3]" | bc`
l2wQLimit="$alterID $alterID * $f"
w2lQLimit="$alterID $alterID * $f"
wankbps="1000000"
waninkbps="1000000"
config="/appex/etc"
sleep 1
  sed -i "s!10000000!1000000!g" /appex/etc/config1
	sed -i "s!initialCwndWan="\"'58"!initialCwndWan=\"'$(echo $initialCwndWan1)'\"'"!g" /appex/etc/config1
	sed -i "s!halfCwndLossRateShift="\"'24"!halfCwndLossRateShift=\"'$(echo $halfCwndLossRateShift1)'\"'"!g" /appex/etc/config1
  sed -i "s!smBurstMS="\"'19"!smBurstMS=\"'$(echo $smBurstMS1)'\"'"!g" /appex/etc/config1
	sed -i "s!l2wQLimit="\"'256 2048"!l2wQLimit=\"'$(echo $alterID)' '$(echo $[alterID*8])'\"'"!g" /appex/etc/config1
  sed -i "s!w2lQLimit="\"'256 2048"!w2lQLimit=\"'$(echo $alterID)' '$(echo $[alterID*8])'\"'"!g" /appex/etc/config1
	sed -i "s!shortRttMS="\"'58"!shortRttMS=\"'$(echo $shortRttMS1)'\"'"!g" /appex/etc/config1

}

#修正客户端json配置文件
modify_userjson(){
/appex/bin/serverSpeeder.sh stop
sleep 2
cp -a /appex/etc/config1 /appex/etc/config 
sleep 2
/appex/bin/serverSpeeder.sh restart
sleep 2
/etc/init.d/networking restart
systemctl restart v2ray

}

#命令块执行列表
main_sslon(){
    modify_ping
	  modify_nginx
    modify_userjson
}

main_ssloff(){
	is_root
	v2ray_hello
	port_alterid_set
	modify_nginx
  modify_userjson
}

main(){
if [[ -e /etc/op/v2ray/v2ray.key ]]; then
	echo -e "${Info} ${GreenBG} 提示：检测到你的服务器已经存在ssl证书 为避免重复申请 脚本将自动跳过该步骤 ${Font}"
	echo -e "${Info} ${GreenBG} 如果你已更换新的域名 请按 ctrl+c 退出 然后执行 bash v.sh -q 强制重装 ${Font}"
	read -p "按 回车键 继续 …… "
	main_ssloff
else
	main_sslon
fi
}

#Bash执行选项
if [[ $# > 0 ]];then
	key="$1"
	case $key in
		-r|--rm_userjson)
		rm_userjson
		;;
		-n|--new_uuid)
		new_uuid
		;;
		-s|--add_share)
		add_share
		;;
		-m|--share_uuid)
		share_uuid
		;;
		-q|--main_sslon)
		main_sslon
		;;
		-x|--add_xmr)
		add_xmr
		;;
	esac
else
	main
fi
