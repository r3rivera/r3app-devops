#!/bin/bash

function processDeployment() {
 
    ENV_TYPE_NAME="$1"
    echo "::: Target Environment is :: ${ENV_TYPE_NAME}"
    echo "::: S3 Target Bucket Prefix is [ ${S3_TARGET_BUCKET_PREFIX} ]"
    echo "::: S3 Target Bucket SUB Prefix is [ ${S3_BUCKET_PREFIX_SUB} ]"
    echo "::: Target File is [ ${TARGET_FILE} ]"

    if [[ ${ENV_TYPE_NAME} == "" ]]
    then
        echo "Environment not found!!"
        exit 1;
    fi

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

    
    eval AWS_EB_APPLNAME='$'${ENV_TYPE_NAME}"_eb_appl_name"} || exit 1
    eval AWS_EB_APPLDESC='$'${ENV_TYPE_NAME}"_eb_appl_description"}|| exit 1
    eval AWS_EB_ENVINAME='$'${ENV_TYPE_NAME}"_eb_env_name"} || exit 1


    echo "::: EB Default AWS Region      :: ${aws_default_region}"
    echo "::: EB Application Name        :: ${AWS_EB_APPLNAME}"
    echo "::: EB Application Description :: ${AWS_EB_APPLDESC}"
    echo "::: EB Environment Name        :: ${AWS_EB_ENVINAME}"

    #Use the bucket folder as the version label
    createApplicationVersion "${AWS_EB_APPLNAME}" \
                        "${AWS_EB_APPLDESC}" \
                        "${S3_BUCKET_PREFIX_SUB}" \
                        "${S3_TARGET_BUCKET_PREFIX}/${TARGET_FILE}" \
                        "${aws_default_region}" \
                        "${TARGET_FILE}"

    #Check the environment status
    checkApplStatusAndWait "${AWS_EB_ENVINAME}"

    #Update the environment with a new version
    updateApplicationEnvironment "${AWS_EB_ENVINAME}" "${S3_BUCKET_PREFIX_SUB}" 

    #Check the environment status
    checkApplStatusAndWait "${AWS_EB_ENVINAME}"

    #Get Environemnt Details
    getApplicationEnvironmentDetails "${AWS_EB_ENVINAME}"
}


function checkApplStatusAndWait() {
    echo "::: Checking environment status..."
    APP_EB_ENV=$1
    EB_APPL_STATUS="Updating"
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

        echo "::: Checking the status of the ${APP_EB_ENV} environment..."
        EB_APPL_STATUS=$(aws elasticbeanstalk describe-environment-health --environment-name ${APP_EB_ENV}  --attribute-names Status \
               | grep Status | cut -d ' ' -f 2)
        echo "::: The status of the ${APP_EB_ENV} is currently ${EB_APPL_STATUS}..."
    done
    echo "::: Status of Elastic Beanstalk Env of ${APP_EB_ENV} is now ${EB_APPL_STATUS}"
}


function getApplicationEnvironmentDetails(){
    echo "::: Getting environment status..."
    APP_EB_ENV=$1
    aws elasticbeanstalk describe-environment-health --environment-name ${APP_EB_ENV}  --attribute-names All
    echo "::: Done environment deployment..."
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
        aws s3 cp ${APP_ARTIFACT_FULLPATH} s3://${TARGET_APPVERSION_BUCKET}/${APP_FILE} || exit 1
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

function updateApplicationEnvironment(){
    echo "::: Start updating the Elastic Bean Environment..."
    UPD_EB_APPL_ENV=$1
    UPD_EB_APPL_VERSION_LABEL=$2
    echo "::: Updating env of ${UPD_EB_APPL_ENV} with application version of ${UPD_EB_APPL_VERSION_LABEL}"

    aws elasticbeanstalk update-environment --environment-name ${UPD_EB_APPL_ENV} \
                                            --version-label ${UPD_EB_APPL_VERSION_LABEL} || exit 1


    echo
}


echo "START Deployment..."
processDeployment $1
