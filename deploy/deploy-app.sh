#!/bin/bash
echo "deploy-app.sh ::: Deploying applications..."
echo "deploy-app.sh ::: Target Environment is :: $1"
echo "deploy-app.sh ::: S3 Target Bucket Prefix is [ ${S3_TARGET_BUCKET_PREFIX} ]"
echo "deploy-app.sh ::: Target File is [ ${TARGET_FILE} ]"

#1. Get the environment config from S3
echo "Configuration bucket is ::: ${S3_APPL_CONFIG_BUCKET}"