# Start from the official Nexus image (version 3.61.0)
FROM sonatype/nexus3:3.61.0

# Switch to the 'root' user so we have permission to download files
USER root

# Define our newer versions
ARG NEXUS_VERSION=3.61.0
ARG PLUGIN_VERSION=0.61.0

# Download the Google Cloud Storage plugin directly into the Nexus auto-deploy folder
RUN curl -L -o /opt/sonatype/nexus/deploy/nexus-blobstore-google-cloud.kar \
    "https://repo1.maven.org/maven2/org/sonatype/nexus/plugins/nexus-blobstore-google-cloud/${PLUGIN_VERSION}/nexus-blobstore-google-cloud-${PLUGIN_VERSION}-bundle.kar"
# Change the ownership of the downloaded file to the 'nexus' user
RUN chown nexus:nexus /opt/sonatype/nexus/deploy/nexus-blobstore-google-cloud.kar

# Switch back to the 'nexus' user for security best practices
USER nexus