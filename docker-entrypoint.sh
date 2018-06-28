#!/bin/bash

[[ $DEBUG ]] &&  set -x

[[ $PAUSE ]] && sleep $PAUSE

if [[ ! -f ./webapps/ROOT.war ]];then
  rm -rf /usr/local/tomcat/webapps/ROOT
  wget -q https://pkg.goodrain.com/apps/jeesite4/jeesite4.war -O /usr/local/tomcat/webapps/ROOT.war
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