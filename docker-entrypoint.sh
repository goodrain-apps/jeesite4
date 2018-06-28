#!/bin/bash

[[ $DEBUG ]] &&  set -x

[[ $PAUSE ]] && sleep $PAUSE

#修改配置文件：需要注意的是，云帮平台为所有依赖其它应用的应用配置了代理服务，访问自身的对应端口，就连接了数据库，redis同理。所以做如下修改（33061端口是mysql应用特别设置的监听端口）
sed -i -e "s/root/${MYSQL_USER:-admin}/g" \
       -e "s/123456/${MYSQL_PASS}/g" \
       /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/config/jeesite.yml

#修改tomcat监听端口为8980
sed -i "s/port=\"8080\"/port=\"8980\"/g" /usr/local/tomcat/conf/server.xml

#导入数据库（前提是mysql中已经有了空的jeesite库）

if [[ ! -f /data/.dbinited ]];then
    chmod +x /usr/local/tomcat/bin/mysqlimport.sh
    ./usr/local/tomcat/bin/mysqlimport.sh && touch /data/.dbinited
fi

# detect ENABLE_APM env 通过环境变量开启pinpoint的APM监测（基础镜像自带的功能）
if [ "$ENABLE_APM" == "true" ];then
    COLLECTOR_IP=${COLLECTOR_IP:-127.0.0.1}
    sed -i 's/${PINPOINT_AGETN_VERSION}.jar/${PINPOINT_AGETN_VERSION}-SNAPSHOT.jar/g' /usr/local/tomcat/bin/pinpoint-agent.sh
    sed -i "2 a. /usr/local/tomcat/bin/pinpoint-agent.sh" /usr/local/tomcat/bin/catalina.sh
    sed -i -r -e "s/(profiler.collector.ip)=.*/\1=${COLLECTOR_IP}/" \
              -e "s/#(profiler.applicationservertype=TOMCAT)/\1/" /usr/local/pinpoint-agent/pinpoint.config
fi


# redis session 通过环境变量开启redis session功能（基础镜像自带的功能）
if [ "$REDIS_SESSION" == "true" ];then
    sed -i 's#</Context>##' /usr/local/tomcat/conf/context.xml

cat >>  /usr/local/tomcat/conf/context.xml << END
<Valve className="com.orangefunction.tomcat.redissessions.RedisSessionHandlerValve" />
<Manager className="com.orangefunction.tomcat.redissessions.RedisSessionManager"
             host="127.0.0.1" 
             port="6379" 
             database="0" 
             maxInactiveInterval="60"  />
</Context>
END

fi

exec $@