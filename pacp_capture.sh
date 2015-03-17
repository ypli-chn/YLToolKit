#!/bin/bash
#
#########################################################################
# File Name  : pacp_capture
# Author     : Li Yunpeng
# E-mail	 : ypli.chn@outlook.com
# use        : This script is used for capturing data packet.
# correlation：charon.sh
# Time       : Wed 27 Aug 2014
#########################################################################



FILE_SIZE=20 
usage(){
	echo "usage:$0 {start | stop | restart}"
	#非法参数输入时提示
}
start()
{
	#每天一个文件夹，每次启动将启动时间设为文件名，以此防止重启后覆盖原文件
	TIME=$(date +%Y%m%d)
	if [ -d $TIME ];then
		log=$(date +%H%M%S)
	else
		mkdir $TIME
	fi
	pkill -2 tcpdump
	tcpdump  -i $HOME_NET -s 0 -C $FILE_SIZE -w ${TIME}/$log  #进行抓包

}
stop()
{
	pkill -2 tcpdump
}

if
    echo $2 | grep "^eth"
then
    HOME_NET=$2
    #若传入网口信息，则使用指定网口
else
    HOME_NET="eth0"
    #否则使用默认网口
fi

case $1 in
   start)
	start &
	;;
   stop)
	stop
	;;
   restart)
	start
	;;
   *)
	usage
	;;
esac
exit 0
