
#!/bin/bash

nginx_install(){
	if [[ -d /dev/shm/default.sock ]];then
	        rm -rf /dev/shm/default.sock
                rm -rf /dev/shm/h2c.sock
		sleep 2
                reboot
	else
		echo -e "${Error} ${RedBG} nginx 安装失败 ${Font}"
		exit 5
	fi
}


#命令块执行列表
main_sslon(){
    nginx_install
}

main_ssloff(){
  nginx_install
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
