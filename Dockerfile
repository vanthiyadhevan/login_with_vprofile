# Use the official Tomcat image as the base image
FROM tomcat:8.5-jre8-alpine

# Set the working directory to the Tomcat webapps directory
WORKDIR /usr/local/tomcat/webapps

# To Clear the default server files
RUN rm -rf /usr/local/tomcat/webapps/*

# ARG instruction defines a variable that users can pass at build-time to the builder with the docker build command
ARG WAR_FILE

# Copy the WAR file from the build context to the current working directory
COPY ${WAR_FILE} /usr/local/tomcat/webapps/ROOT.war

# Expose the default Tomcat port
EXPOSE 8080

# Command to run when the container starts
CMD ["catalina.sh", "run"]
