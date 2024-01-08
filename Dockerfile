FROM tomcat:8.5-jre8-alpine

# Set the working directory in the container
WORKDIR /usr/local/tomcat/webapps

# Copy the artifact from Nexus to the container
COPY http://192.168.1.20:8081/repository/vprofile-docker/com/visualpathit/vproapp/5-24-01-08_02-53/vproapp-5-24-01-08_02-53.war .

# Rename the artifact to ROOT.war to deploy it as the default web app
RUN mv vproapp-5-24-01-08_02-53.war ROOT.war

# Expose the port the app runs on
EXPOSE 8084

# Start Tomcat
CMD ["catalina.sh", "run"]