!#/bin/bash
#dir `date`
echo "## Building the project of ${APP_NAME}..."
echo "## Workspace is ${WORKSPACE}"



echo "## Displaying Java Version..."
java -version | head -n 1

echo "## Displaying Maven Version..."
mvn --version | head -n 1

echo "## Displaying GIT Version..."
git --version | head -n 1

echo "############## START ::: BUILD INFORMATION ##############"
echo ""
echo ""
echo "Git URL    :: ${GIT_URL}"
echo "Git Branch :: ${GIT_BRANCH}"
GIT_COMMITID="$(git log | head -n 1 | cut -d ' ' -f 2)"
BUILD_DATE="$(date +%m%d%Y_%H%M%S)"
echo "Git Commit :: ${GIT_COMMITID}"
echo ""
echo ""

TARGET_FILE="${APP_NAME}_${GIT_COMMITID}_${BUILD_DATE}.zip"
echo "Building the Application File ::: ${TARGET_FILE}"
echo ""
echo ""
echo "############## END   ::: BUILD INFORMATION ##############"


echo "########## Packaging the ${APP_NAME} ##########"
mvn clean package -B || exit 1
echo "########## Completed packaging the ${APP_NAME} ##########"

if [[ ! -d ${WORKSPACE}/src/.ebextensions ]] 
then 
    echo "AWS Elastic Beanstalk Custom Config is not found!"
    exit 1
else 
   echo "Archicing the AWS Elastic Beanstalk Configuration and JAR Application..."
   zip -r ${TARGET_FILE} ${WORKSPACE}/src/.ebextensions ${WORKSPACE}/target/*.jar
fi

echo "Start uploading the zip file in S3 Bucket as artifact!"
