#!/bin/bash

#Check if the application exist
aws elasticbeanstalk describe-applications --application-names ${EB_APPL_NAME} | grep ${EB_APPL_NAME}