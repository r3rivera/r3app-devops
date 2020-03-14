#!/bin/bash
echo "deploy-app.sh ::: Deploying applications..."
echo "deploy-app.sh ::: Target Environment is :: $1"
echo "deploy-app.sh ::: S3 Bucket is ${S3_BUCKET_PREFIX_SUB}"
echo "deploy-app.sh ::: Target File is ${TARGET_FILE}"