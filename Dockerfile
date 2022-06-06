FROM centos

LABEL Maintainer=Prasanth


RUN yum -y install java
RUN java -version
RUN yum install -y unzip
RUN  yum install -y wget
#RUN mkdir /opt/tomcat/

WORKDIR /opt
RUN wget https://www-eu.apache.org/dist/tomcat/tomcat-8/v8.5.37/bin/apache-tomcat-8.5.37.tar.gz
RUN tar -xzvf apache-tomcat-8.5.73.tar.gz 
RUN mv /opt/apache-tomcat-8.5.73/ /opt/tomcat

WORKDIR /opt/tomcat/bin
RUN chmod +x ./*

WORKDIR /opt/tomcat/webapps
COPY target/*.war /opt/tomcat/webapps/webapp.war

EXPOSE 8080

ENTRYPOINT ["/opt/tomcat/bin/catalina.sh", "run"]
