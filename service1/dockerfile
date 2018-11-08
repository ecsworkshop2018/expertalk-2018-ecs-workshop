FROM openjdk:8-jdk-alpine
ARG JAR_FILE
COPY ${JAR_FILE} service1.jar
ENTRYPOINT ["java","-jar","service1.jar"]
