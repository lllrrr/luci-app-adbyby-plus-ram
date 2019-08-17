#!/bin/sh

if ! mount | grep adbyby >/dev/null 2>&1; then
	echo "Adbyby is not mounted,Stop update!"
	return 1
fi
	wan_mode=`uci get adbyby.@adbyby[0].wan_mode 2>/dev/null`
	if [ $wan_mode -eq 1 ]; then
		rm -f /tmp/dnsmasq.adblock
		wget-ssl -4 -t 9 -T 3 -O- https://dev.tencent.com/u/Small_5/p/adbyby/git/raw/master/easylistchina%2Beasylist.txt | grep ^\|\|[^\*]*\^$ | sed -e 's:||:address\=\/:' -e 's:\^:/0\.0\.0\.0:' > /tmp/dnsmasq.adblock || \
		wget-ssl -4 -O- https://easylist-downloads.adblockplus.org/easylistchina+easylist.txt | grep ^\|\|[^\*]*\^$ | sed -e 's:||:address\=\/:' -e 's:\^:/0\.0\.0\.0:' > /tmp/dnsmasq.adblock
		if [ -s "/tmp/dnsmasq.adblock" ];then
			sed -i '/youku.com/d' /tmp/dnsmasq.adblock
			if ( ! cmp -s /tmp/dnsmasq.adblock /tmp/adbyby/adbyby_adblock/dnsmasq.adblock );then
				mv -f /tmp/dnsmasq.adblock /tmp/adbyby/adbyby_adblock/dnsmasq.adblock
				/usr/share/adbyby/adupdate.sh restartdnsmasq
			else
				rm -f /tmp/dnsmasq.adblock
				/usr/share/adbyby/adupdate.sh
			fi
		fi
	else
		/usr/share/adbyby/adupdate.sh
	fi
