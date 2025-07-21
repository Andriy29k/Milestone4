FROM eclipse-temurin:11-jre-alpine AS deploy

RUN apk add --no-cache curl && \
    mkdir -p /opt && \
    curl -sSL https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz -o /tmp/tomcat.tar.gz && \
    tar -xzf /tmp/tomcat.tar.gz -C /opt && \
    mv /opt/apache-tomcat-9.0.85 /opt/tomcat && \
    rm -rf /opt/tomcat/webapps/* /tmp/tomcat.tar.gz

COPY  ROOT/ /opt/tomcat/webapps/ROOT/

COPY entrypoint.sh /conf/entrypoint.sh
RUN chmod +x /conf/entrypoint.sh
ENTRYPOINT [ "/conf/entrypoint.sh" ]

EXPOSE 8080

CMD ["/opt/tomcat/bin/catalina.sh", "run"]
