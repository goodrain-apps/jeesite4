FROM goodrainapps/tomcat:7.0.82-jre7-alpine

COPY docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

RUN wget -q https://pkg.goodrain.com/apps/jeesite4/jeesite4.war -O /usr/local/tomcat/webapps/ROOT.war \
&& rm -rf /usr/local/tomcat/webapps/ROOT && mkdir -p /usr/local/tomcat/webapps/ROOT \
&& unzip /usr/local/tomcat/webapps/ROOT.war -d /usr/local/tomcat/webapps/ROOT

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]