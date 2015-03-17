#!/bin/bash
#
#########################################################################
# File Name : auto_upload
# Author    : Li Yunpeng
# E-mail	: ypli.chn@outlook.com
# use       : This script is used for uploading document using the FTP server automaticly.
# Time      : Wed 27 Aug 2014
#########################################################################

# FTP服务器的IP地址
ftp_ip=192.168.1.100

# FTP服务器的端口 
ftp_port=20

# FTP服务器的用户名
ftp_user="test"

# FTP服务器的密码
ftp_passwd="passwd"

# 管理员邮箱
MAIL=xxx@gmail.com

# 控制文件自动上传下限容量,单位为M
MAX_VOL=20

# 上传日志存储路径
TRAN_LOG='/log/tran.log'

# 错误日志路径
ERROR_DIR='/log/tran.error'

# 上传文件路径
TRAN_CATALOG='/Documents'


# 检测文件间隔,单位为s
INTERVAL=60

# 即 文件总大小大于 MAX_VOL 就开始自动上传,传输成功即将成功传输的
# 文件删除。设定值的单位为 M。


upload() {
	FILE_SIZE=$(du -m $TRAN_CATALOG | awk '{print $1}')
	if [ $FILE_SIZE -gt $MAX_VOL ]
	    echo "*******************************************************" >> $TRAN_LOG
	    date >> $TRAN_LOG
	    for DATA in $(ls ${TRAN_CATALOG}/)
	    do
	        for log in $(ls ${TRAN_CATALOG}/$DATA)
		do
		    ./charon $log
		    #为了避免网络故障进程一直阻塞,启动上传守护脚本
		    ncftpput -DD -u $ftp_user -p $ftp_passwd -m $ftp_ip ${TRAN_CATALOG}/$DATA $log $ERROR_DIR
		    pkill -9 charon
		    #正常上传则终止上传守护
		    echo "$log      [ ok ]" >> $TRAN_LOG
		done
	    done
	    echo "The transmission is finished !" >> $TRAN_LOG 
	    echo "" >> $TRAN_LOG
	fi
}

# 每隔一段时间检测一次
while true
do
	sleep $INTERVAL
	upload
done