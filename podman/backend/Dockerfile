FROM docker.io/eclipse-temurin:21-jre-alpine
RUN mkdir -p /opt/app/ressources
WORKDIR /opt/app/ressources
COPY target/*.jar /opt/app/declaris.jar
ENV TZ="Africa/Tunis"
CMD ["java", "-Xms1g", "-Xmx4g", "-jar", "/opt/app/declaris.jar"]
