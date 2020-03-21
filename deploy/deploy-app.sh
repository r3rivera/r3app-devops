#!/bin/bash

function getApplConfiguration() {
    echo "deploy-app.sh ::: Deploying applications..."
    echo "deploy-app.sh ::: Target Environment is :: $1"
    echo "deploy-app.sh ::: S3 Target Bucket Prefix is [ ${S3_TARGET_BUCKET_PREFIX} ]"
    echo "deploy-app.sh ::: Target File is [ ${TARGET_FILE} ]"

    #1. Get the environment config from S3
    echo "deploy-app.sh ::: Configuration bucket is ::: ${S3_APPL_CONFIG_BUCKET}"

    CONFIG_NAME=$(echo ${S3_APPL_CONFIG_BUCKET} | cut -d '/' -f 5)
    echo "deploy-app.sh ::: Configuration Name is ::: ${CONFIG_NAME}"
    aws s3 cp ${S3_APPL_CONFIG_BUCKET} ${CONFIG_NAME}
    if [[ ! -f ./${CONFIG_NAME} ]]
    then
        echo "Environment configuration is missing!" && exit 1

    fi 
    source ./${CONFIG_NAME}
    echo "deploy-app.sh ::: EB Application Name :: ${dev_smis_eb_appl_name}"
    echo "deploy-app.sh ::: EB Environment Name :: ${dev_smis_eb_env_name}"
}

function checkApplStatusAndWait() {
    echo "deploy-app.sh ::: Checking environment sattus..."
    EB_APPL_STATUS = "Updating"
    time_counter=0

    while [ ${EB_APPL_STATUS} != "Ready" ]
    do 
       if [[ ${time_counter} == 40 ]]
       then 
            echo "ERROR: Maximum number of retries is reached. The environment is not yet ready. Status is ${EB_APPL_STATUS}." && exit 1
       elif [[ ${time_counter} > 0]]
       then 
            echo "Sleeping for 30"
            sleep 30
       fi

        echo "Checking the status of the ${dev_smis_eb_env_name} environment"
        #EB_APPL_STATUS=$(aws elasticbeanstalk describe-environment-health --environment-name ${dev_smis_eb_env_name} \ 
        #   --attribute-names Status | python3 -c 'import sys, json; print json.load(sys.stdin)["Status"])

    done
}

echo "1. Getting Application Status"
getApplConfiguration