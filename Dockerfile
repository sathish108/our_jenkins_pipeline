FROM centos

MAINTAINER Prasanth

RUN echo "Container is in Build Process"
EXPOSE 8080

ENTRYPOINT ["/opt/tomcat/bin/catalina.sh", "run"]
