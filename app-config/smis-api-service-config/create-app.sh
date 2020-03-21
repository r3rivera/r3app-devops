#!/bin/bash

#Check if the application exist
aws elasticbeanstalk describe-applications --application-names rcgc-smis-dev | grep rcgc-smis-dev