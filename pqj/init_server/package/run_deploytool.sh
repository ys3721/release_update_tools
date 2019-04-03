export JAVA_HOME=/data0/jdk7/usr/java/jdk1.7.0_15
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$JAVA_HOME/bin:$PATH
export LC_ALL=zh_CN.GBK     # for linux: zh_CN
export LANG=zh_CN.GBK       # for linux: zh_CN

config_xml=`ls ./deploy_config_*.xml`

dir=`pwd | awk -F '/' '{print "/"$2}'`
echo `pwd`
java -cp . -jar deploy_tool.jar -f $config_xml --ue
echo "cp *.com/10.*.*.*/* $dir -rf"
\cp *.com/10.*.*.*/* $dir -rf