#!/bin/bash
source /etc/profile

APP_NAME=happy-sales-api
APP_DIR=/opt/service/happy-sales-api
APP_VER=0.0.1
APP_JAR=$APP_NAME-$APP_VER-SNAPSHOT.jar

PID=$(ps aux | grep ${APP_JAR} | grep -v grep | awk '{print $2}' )

function check_if_process_is_running {
if [ "$PID" = "" ]; then
return 1
fi
ps -p $PID | grep "java"
return $?
}


case "$1" in
status)
if check_if_process_is_running
then
echo -e "\033[32m $APP_NAME is running \033[0m"
else
echo -e "\033[32m $APP_NAME not running \033[0m"
fi
;;
stop)
if ! check_if_process_is_running
then
echo -e "\033[32m $APP_NAME already stopped \033[0m"
exit 0
fi
kill -9 $PID
echo -e "\033[32m Waiting for process to stop \033[0m"
NOT_KILLED=1
for i in {1..20}; do
if check_if_process_is_running
then
echo -ne "\033[32m . \033[0m"
sleep 1
else
NOT_KILLED=0
fi
done
echo
if [ $NOT_KILLED = 1 ]
then
echo -e "\033[32m Cannot kill process \033[0m"
exit 1
fi
echo -e "\033[32m $APP_NAME already stopped \033[0m"
;;
start)
if [ "$PID" != "" ] && check_if_process_is_running
then
echo -e "\033[32m $APP_NAME already running \033[0m"
exit 1
fi
nohup java -jar -Xms512m -Xmx2048m -Xss512k -XX:MaxDirectMemorySize=128m $APP_DIR/$APP_JAR --spring.profiles.active=prod > $APP_DIR/log/$APP_NAME.log 2>&1 &
echo -ne "\033[32m Starting \033[0m"
for i in {1..20}; do
echo -ne "\033[32m.\033[0m"
sleep 1
done
if check_if_process_is_running
then
echo -e "\033[32m $APP_NAME fail \033[0m"
else
echo -e "\033[32m $APP_NAME started \033[0m"
fi
;;
restart)
$0 stop
if [ $? = 1 ]
then
exit 1
fi
$0 start
;;
*)
echo "Usage: $0 {start|stop|restart|status}"
exit 1
esac

exit 0
