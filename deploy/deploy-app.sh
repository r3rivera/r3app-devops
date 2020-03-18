#!/bin/bash
echo "deploy-app.sh ::: Deploying applications..."
echo "deploy-app.sh ::: Target Environment is :: $1"
echo "deploy-app.sh ::: S3 Target Bucket Prefix is [ ${S3_TARGET_BUCKET_PREFIX} ]"
echo "deploy-app.sh ::: Target File is [ ${TARGET_FILE} ]"

#1. Get the environment config from S3
echo "deploy-app.sh ::: Configuration bucket is ::: ${S3_APPL_CONFIG_BUCKET}"
aws s3 cp ${S3_APPL_CONFIG_BUCKET} .
if [[ ! -f env-config.properties ]]
then
  echo "Environment configuration is missing!"
  exit 1
fi 
source ./env-config.properties
echo "deploy-app.sh ::: EB Application Name :: ${dev-smis-eb-appl-name}"
echo "deploy-app.sh ::: EB Environment Name :: ${dev-smis-eb-env-name}"