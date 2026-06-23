FROM tomcat:9.0-jdk8-openjdk

# Install Docker CLI so the Java app can run docker commands
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Copy the built WAR file to Tomcat webapps
COPY dist/RailTrack.war /usr/local/tomcat/webapps/ROOT.war

# Set default work dir for RailTrack (cloned student repositories)
ENV RAILTRACK_WORK_DIR=/var/railtrack
RUN mkdir -p /var/railtrack && chmod 777 /var/railtrack

EXPOSE 8080
