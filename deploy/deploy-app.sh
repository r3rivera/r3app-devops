#!/bin/bash

function getApplConfiguration() {
    echo "::: Deploying applications..."
    echo "::: Target Environment is :: $1"
    echo "::: S3 Target Bucket Prefix is [ ${S3_TARGET_BUCKET_PREFIX} ]"
    echo "::: Target File is [ ${TARGET_FILE} ]"

    #1. Get the environment config from S3
    echo "::: Configuration bucket is ::: ${S3_APPL_CONFIG_BUCKET}"

    CONFIG_NAME=$(echo ${S3_APPL_CONFIG_BUCKET} | cut -d '/' -f 5)
    echo "::: Configuration Name is ::: ${CONFIG_NAME}"
    aws s3 cp ${S3_APPL_CONFIG_BUCKET} ${CONFIG_NAME}
    if [[ ! -f ./${CONFIG_NAME} ]]
    then
        echo "::: Environment configuration is missing!" && exit 1

    fi 
    source ./${CONFIG_NAME}
    echo "::: EB Application Name :: ${dev_smis_eb_appl_name}"
    echo "::: EB Environment Name :: ${dev_smis_eb_env_name}"
}


function checkApplStatusAndWait() {
    echo "::: Checking environment sattus..."
    EB_APPL_STATUS = "Updating"
    time_counter=0

    while [ ${EB_APPL_STATUS} != "Ready" ]
    do 
       if [[ ${time_counter} == 40 ]]
       then 
            echo "::: ERROR: Maximum number of retries is reached. The environment is not yet ready. Status is ${EB_APPL_STATUS}." && exit 1
       elif [[ ${time_counter} > 0 ]]
       then 
            echo "::: Sleeping for 30"
            sleep 30
       fi

        echo "::: Checking the status of the ${dev_smis_eb_env_name} environment..."
        #EB_APPL_STATUS=$(aws elasticbeanstalk describe-environment-health --environment-name ${dev_smis_eb_env_name} \ 
        #   --attribute-names Status | python3 -c 'import sys, json; print json.load(sys.stdin)["Status"])

        EB_APPL_STATUS=$(aws elasticbeanstalk describe-environment-health --environment-name rcgc-smis-dev-01-webapp --attribute-names Status \
               | grep Status | cut -d ' ' -f 2)
        echo "::: The status of the ${dev_smis_eb_env_name} is currently ${EB_APPL_STATUS}..."
    done
}


function createApplication() {
    echo "::: Creating application of ${dev_smis_eb_appl_name}..."
    EB_APPL_NAME=$(aws elasticbeanstalk describe-applications --application-names ${dev_smis_eb_appl_name} | grep ${dev_smis_eb_appl_name})
    if [[ ${EB_APPL_NAME} == "" ]]
    then 
        echo "::: Application of ${dev_smis_eb_appl_name} does not exist..."
    else
        echo "::: Application of ${dev_smis_eb_appl_name} is exist..."
    fi
}


echo "1. Getting Application Configuration..."
createApplication
getApplConfiguration
echo "2. Getting Elastic Beanstalk Status..."