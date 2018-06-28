FROM goodrainapps/tomcat:8.5.20-jre8-alpine

VOLUME ["/data"]

RUN apk add --no-cache --virtual .fetch-deps mysql-client

COPY docker-entrypoint.sh /

COPY scripts/mysqlimport.sh /usr/local/tomcat/bin

COPY scripts/jeesite.sql /data

RUN chmod +x /docker-entrypoint.sh

RUN wget -q https://pkg.goodrain.com/apps/jeesite4/jeesite4.war -O /usr/local/tomcat/webapps/ROOT.war \
&& rm -rf /usr/local/tomcat/webapps/ROOT && mkdir -p /usr/local/tomcat/webapps/ROOT \
&& unzip /usr/local/tomcat/webapps/ROOT.war -d /usr/local/tomcat/webapps/ROOT && rm -rf /usr/local/tomcat/webapps/ROOT.war

COPY scripts/startup.sh /usr/local/tomcat/webapps/ROOT/WEB-INF

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]