FROM goodrainapps/tomcat:7.0.82-jre7-alpine

COPY docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]