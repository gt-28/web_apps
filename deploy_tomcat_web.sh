#!/bin/bash

# Setup variables
export apache2_PATH='/var/www/html/'
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
ar xvzf ${ARTIFACT_NAME}

# Remove env from config files
for FILENAME in ${ARTIFACT_TMP_PATH}/web_artifact/config/*; do
TRIMMED_FILENAME=$(echo ${FILENAME} | cut -d. -f1,2)
mv ${FILENAME} ${TRIMMED_FILENAME}
done

# Stop apache27
echo "Stopping apache2"
sudo service apache2 stop

# Delete any existing deployments
echo "Removing previous deployments"
sudo rm -rf ${apache2_PATH}/*

# Copy new war file and config to deployments directory
sudo \cp ${ARTIFACT_TMP_PATH}/web_artifact/config/* ${apache2_PATH}/configuration/
sudo \cp ${ARTIFACT_TMP_PATH}/web_artifact/war/*.war ${apache2_PATH}/deployments/

# Change permissions
sudo chown -R apache2. ${apache2_PATH}/deployments/*
sudo chown -R apache2. ${apache2_PATH}/configuration/*

# Start apache27
sudo service apache2 start
