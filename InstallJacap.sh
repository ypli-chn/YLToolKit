#! /bin/bash
#! /bin/bash
#
# Program:
#	Usage: InstallJacap <source files> <source files> [<source files>]
#
#	This program can help you install Jacap rapidly
#	and help configure relevant settings.
#	
# History:
# 2014/7/31   Li Yunpeng  First release

function GetFilename(){
	ls > /tmp/InstallJavaCatalog.old
	#Decompressing files
	#echo "start to tar..."
	tar zxvf "$1" > /dev/null
	ls> /tmp/InstallJavaCatalog.new
	#Get the folder's name of Java
	diff /tmp/InstallJavaCatalog.old /tmp/InstallJavaCatalog.new | grep "^>" |tr -d '> '
	#Delete temporary files
	rm -f /tmp/InstallJavaCatalog.old
	rm -f /tmp/InstallJavaCatalog.new
}

function InstallJDK() {
	echo "start to install Java..."
	JavaFilename=`GetFilename "$1"`
	#Found the folder
	#Move Java's folder to /usr/lib/jvm/
	mv -i $JavaFilename /usr/lib/jvm/
	echo "complete the installation of Java..."
	echo "configure relevant settings about Java..."
	#Add the environment variable
	echo  "JAVA_HOME=/usr/lib/jvm/$JavaFilename" >> /etc/profile
	echo  'PATH=$JAVA_HOME/bin:$PATH
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export JAVA_HOME
export PATH
export CLASSPATH' >> /etc/profile
	source /etc/profile
} #Install JDK


#check up if log in by root
if [ `whoami` != "root" ];then
	echo "Please use this command in root."
	exit 1
fi



InstallCatalog=`pwd`
mkdir -p /usr/lib/jvm/

case $# in
  "2")
	#Exclude other documents.
	if [ "`echo $1 | sed 's/^.*\.//g'`" != "gz" -a "`echo $2 | sed 's/^.*\.//g'`" != "gz" ];then
		echo "File type error ."
		echo "InstallJacap <*.tar.gz> <*.tar.gz> ."
	fi
	#Check if Java has been installed
	if [ `echo $JAVA_HOME > /dev/null` ];then
		echo "Java has NOT been installed."
		exit 1
	fi
	;;
  "3")
	#Exclude other documents.
	if [ "`echo $1 | sed 's/^.*\.//g'`" != "bin" -a "`echo $2 | sed 's/^.*\.//g'`" != "gz" -a "`echo $3 | sed 's/^.*\.//g'`" != "gz" ];then
		echo "File type error ."
		echo "InstallJacap <*.bin> <*.tar.gz> <*.tar.gz> ."
	fi
	#Check if Java has been installed
	if [ ! `echo $JAVA_HOME > /dev/null` ];then
		echo "Java has been already installed."
		exit 1
	else
		#Install Java
		InstallJDK $1
		shift
	fi
	;;
	
  *)
	echo "parameter(s) error."
	exit 1
	;;
esac

#First determine the catalog ，Because different Java's versions can lead to configuration files which will move to different folder.
cd ${JAVA_HOME}/jre/lib
if [ -e amd64];then
	Moveto=amd64
elif [ -e i386 ];then
	Moveto=i386
elif [ -e i686 ]
	Moveto=i686
else
	echo "Not Found current catalog."
fi
Catalog=${JAVA_HOME}/jre/lib/${Moveto}
cd $InstallCatalog


#check gcc,flex,make and bison exist
echo "Check gcc,flex,make and bison exist"
dpkg -l | grep gcc  > /dev/null || apt-get install gcc
dpkg -l | grep flex > /dev/null || apt-get install flex
dpkg -l | grep make > /dev/null || apt-get install make
dpkg -l | grep bison > /dev/null || apt-get install bison

LibpcapFilename=$(GetFilename "$1")
#move folder
mv -i $LibpcapFilename /usr/lib/jvm/
cd $JAVA_HOME
./configure
make
make install
cp /usr/local/lib/libpcap.so.1 $Catalog


cd $InstallCatalog
JpcapFilename=$(GetFilename "$2")
#move folder
mv -i $JpcapFilename /usr/lib/jvm/
#add "-fPIC" to "Makefile"
sed -i 's/$(CC) $(COMPILE_OPTION)/$(CC) $(COMPILE_OPTION) -fPIC/g' /usr/lib/jvm/$JpcapFilename/src/c/Makefile
cd /usr/lib/jvm/$JpcapFilename/src/c
make
#move libjpcap.so to $Catalog  ps:$Catalog=${JAVA_HOME}/jre/lib/[amd64 or i386 or i686]
cp libjpcap.so $Catalog

#move jpcap.jar to ${JAVA_HOME}/jre/lib/ext
cp /usr/lib/jvm/$JpcapFilename/lib/jpcap.jar ${JAVA_HOME}/jre/lib/ext


echo "--------------------------------------"
echo "Installation has been completed."
echo "Please logoff."
echo "--------------------------------------"




