#!/bin/bash

# Install Tomcat
echo "Installing tomcat"
sudo yum install tomcat

# Setup variables
export TOMCAT_PATH='/etc/tomcat/'
export ARTIFACT_TMP_PATH='/home/jenkins/tmp_web_artifact'
export ARTIFACT_NAME='web_artifact.tar.gz'

# Remove tmp directory
if [ -d ${ARTIFACT_TMP_PATH} ]; then
  rm -rf ${ARTIFACT_TMP_PATH}
fi

# Copy artifact to tmp dir and extract
mkdir -p ${ARTIFACT_TMP_PATH}
cp ${ARTIFACT_NAME} ${ARTIFACT_TMP_PATH}
cd ${ARTIFACT_TMP_PATH}
echo "Extracting files:"
tar xvzf ${ARTIFACT_NAME}

# Remove env from config files
for FILENAME in ${ARTIFACT_TMP_PATH}/web_artifact/config/*; do
  TRIMMED_FILENAME=$(echo ${FILENAME} | cut -d. -f1,2)
  mv ${FILENAME} ${TRIMMED_FILENAME}
done

# Stop TOMCAT7
echo "Stopping TOMCAT"
sudo service tomcat stop

# Delete any existing deployments
echo "Removing previous deployments"
sudo rm -rf ${TOMCAT_PATH}/*

# Copy new war file and config to deployments directory
sudo \cp ${ARTIFACT_TMP_PATH}/web_artifact/config/* ${TOMCAT_PATH}/configuration/
sudo \cp ${ARTIFACT_TMP_PATH}/web_artifact/war/*.war ${TOMCAT_PATH}/deployments/

# Change permissions
sudo chown -R jboss. ${TOMCAT_PATH}/deployments/*
sudo chown -R jboss. ${TOMCAT_PATH}/configuration/*

# Start TOMCAT7
sudo service tomcat start