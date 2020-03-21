#!/bin/bash

function getApplConfigurationAndCreateApp() {

    echo "::: Target Environment is :: $1"
    echo "::: S3 Target Bucket Prefix is [ ${S3_TARGET_BUCKET_PREFIX} ]"
    echo "::: S3 Target Bucket SUB Prefix is [ ${S3_BUCKET_PREFIX_SUB} ]"
    echo "::: Target File is [ ${TARGET_FILE} ]"

    if [[ -z ${S3_APPL_CONFIG_BUCKET} ]]
    then
        echo "S3 bucket with configuration is not available or provided!"
        exit 1;
    fi

    #1. Get the environment config from S3
    echo "::: Configuration bucket is ::: ${S3_APPL_CONFIG_BUCKET}"

    CONFIG_NAME=$(echo ${S3_APPL_CONFIG_BUCKET} | cut -d '/' -f 5)
    echo "::: Configuration Name is ::: ${CONFIG_NAME}"
    aws s3 cp ${S3_APPL_CONFIG_BUCKET} ${CONFIG_NAME} || exit 1
    if [[ ! -f ./${CONFIG_NAME} ]]
    then
        echo "::: Environment configuration is missing!" && exit 1
    fi 
    source ./${CONFIG_NAME}
    echo "::: EB Default AWS Region      :: ${aws_default_region}"
    echo "::: EB Application Name        :: ${dev_smis_eb_appl_name}"
    echo "::: EB Application Description :: ${dev_smis_eb_appl_description}"
    echo "::: EB Environment Name        :: ${dev_smis_eb_env_name}"
    
    #Use the bucket folder as the version label
    createApplicationVersion "${dev_smis_eb_appl_name}" \
                        "${dev_smis_eb_appl_description}" \
                        "${S3_BUCKET_PREFIX_SUB}" \
                        "${S3_TARGET_BUCKET_PREFIX}/${TARGET_FILE}" \
                        "${aws_default_region}" \
                        "${TARGET_FILE}"
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
        EB_APPL_STATUS=$(aws elasticbeanstalk describe-environment-health --environment-name rcgc-smis-dev-01-webapp --attribute-names Status \
               | grep Status | cut -d ' ' -f 2)
        echo "::: The status of the ${dev_smis_eb_env_name} is currently ${EB_APPL_STATUS}..."
    done
}


function createApplicationVersion() {
    APP_NAME_EB=$1
    APP_DESC_EB=$2
    APP_ARTIFACT_LABEL=$3
    APP_ARTIFACT_FULLPATH=$4
    APP_REGION=$5
    APP_FILE=$6
    echo ":::"
    echo ":::"
    echo "::: Creating application of ${APP_NAME_EB}..."
    echo "::: Application description is ${APP_DESC_EB}..."
    echo "::: Application version label is ${APP_ARTIFACT_LABEL}"
    echo "::: Application artifact version source is ${APP_ARTIFACT_FULLPATH}"
    echo "::: Application artifact name source is ${APP_FILE}"
    echo ":::"
    echo ":::"
    echo ":::"
    EB_APPL_NAME=$(aws elasticbeanstalk describe-applications --application-names ${APP_NAME_EB} | grep ${APP_NAME_EB})
    if [[ ! -z ${EB_APPL_NAME} ]] #Application Name exist
    then 

        APP_ACCT_ID=$(aws sts get-caller-identity | grep Arn: | cut -d ':' -f 6)
        echo "::: AWS Account ID is ${APP_ACCT_ID}"

        echo "::: Uploading application version of ${APP_ARTIFACT_LABEL} into the S3 bucket"
        TARGET_APPVERSION_BUCKET="elasticbeanstalk-${APP_REGION}-${APP_ACCT_ID}"

        echo "::: Uploading file in ELastic Beanstalk Target Version Bucket. Bucket is ${TARGET_APPVERSION_BUCKET}"
        aws s3 cp ${APP_ARTIFACT_FULLPATH} s3://${TARGET_APPVERSION_BUCKET}/${APP_FILE}
        echo "::: File version upload is complete."

        echo "::: Application of ${APP_NAME_EB} exist. Creating a new version."
        aws elasticbeanstalk create-application-version \
                                    --application-name ${APP_NAME_EB} \
                                    --description ${APP_DESC_EB} \
                                    --version-label ${APP_ARTIFACT_LABEL} \
                                    --source-bundle S3Bucket="${TARGET_APPVERSION_BUCKET}",S3Key="${APP_FILE}" \
                                    --auto-create-application || exit 1

    else
        echo "::: Application of ${APP_NAME_EB} does not exist..."
        echo "::: Application details is ${EB_APPL_NAME}"

    fi
}


echo "1. Getting Application Configuration..."
getApplConfigurationAndCreateApp
echo "2. Getting Elastic Beanstalk Status..."