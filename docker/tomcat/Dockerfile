FROM tomcat:8.5.81-jdk8
RUN rm -Rf /usr/local/tomcat/webapps/ROOT
COPY BBS_final-0.0.1-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war
COPY jdk-18.0.1.1 /usr/local/lib/jdk-18.0.1.1
ENV JAVA_HOME=/usr/local/lib/jdk-18.0.1.1
