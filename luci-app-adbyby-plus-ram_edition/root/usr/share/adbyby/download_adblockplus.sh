#!/bin/sh

	[ "$1" != "--down" ] && return 1
	sleep 2
	# 防止重复启动
	for pid in $(ps | grep "${0##*/}" | grep -v grep | awk '{print $1}' &); do
		[ "$pid" != "$$" ] && return 1
	done

	if ! mount | grep adbyby >/dev/null 2>&1; then
		echo "Adbyby is not mounted,Stop update!"
		/etc/init.d/adbyby restart >/dev/null 2>&1 &
		return 1
	fi

	while : ; do
		wget -4 --spider -q -t 1 -T 3 dev.tencent.com
		[ "$?" != "0" ] && sleep 2 || break
	done

	echo "开始下载Adblock规则文件..."
	mkdir -p /tmp/adbyby/adbyby_adblock
	wget -4 -t 9 -T 3 -O /tmp/adbyby/adbyby_adblock/dnsmasq.adblock https://dev.tencent.com/u/Small_5/p/adbyby/git/raw/master/dnsmasq.adblock
	if [ "$?" != "0" ];then
		echo "下载Adblock规则失败，请重试！"
		rm -rf /tmp/adbyby/adbyby_adblock
	fi

	echo "开始下载Adblock规则MD5文件..."
	wget -4 -t 9 -T 3 -O /tmp/adbyby/adbyby_adblock/md5 https://dev.tencent.com/u/Small_5/p/adbyby/git/raw/master/md5_1
	if [ "$?" != "0" ]; then
		echo "下载Adblock规则MD5文件失败，请重试！"
		rm -rf /tmp/adbyby/adbyby_adblock
	fi

	md5_local=$(md5sum /tmp/adbyby/adbyby_adblock/dnsmasq.adblock | awk -F' ' '{print $1}')
	md5_online=$(sed 's/":"/\n/g' /tmp/adbyby/adbyby_adblock/md5 | sed 's/","/\n/g' | sed -n '2P')
	rm -f /tmp/adbyby/adbyby_adblock/md5
	if [ "$md5_local"x != "$md5_online"x ]; then
		echo "校验Adblock规则MD5失败，请重试！"
		rm -rf /tmp/adbyby/adbyby_adblock
	fi

	/etc/init.d/adbyby restart >/dev/null 2>&1 &
