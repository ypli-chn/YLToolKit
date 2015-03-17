#!/bin/bash
#
#########################################################################
# File Name: charon
# Author: Li Yunpeng
# use: The shell named from "Charon Star" for guarding FTP upload.
# Created Time: Wed 27 Aug 2014
#########################################################################

ERROR_DIR="$3"  #错误日志目录
MAIL="$2" # 管理员邮箱
FILE="$1" # 守护文件

sleep 300      #等待300s
#若300s都未传完一个文件(20M),发送传输失败
echo "$FILE      [ fail ]" > $ERROR_DIR
echo "Network failure" >> $ERROR_DIR
echo "Abort the transmission" >> $ERROR_DIR

cat $ERROR_DIR >> /botwall/log/tran.log
mutt -s "Tran_Error_Report" $MAIL < $ERROR_DIR
pkill -9 auto_upload    #终止自动上传
pkill -9 ncftpput       #终止ncftp进程
