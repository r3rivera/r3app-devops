!#/bin/bash
echo "## Building the configuration of ${APP_NAME}..."
echo "## Workspace is ${WORKSPACE}"
echo "############## START ::: BUILD INFORMATION ##############"
echo ""
echo "## Displaying Java Version..."
java -version | head -n 1

echo "## Displaying Maven Version..."
mvn --version | head -n 1

echo "## Displaying GIT Version..."
git --version | head -n 1
echo ""
echo "Git URL      :: ${GIT_URL}"
echo "Git Branch   :: ${GIT_BRANCH}"
echo "Build ID     :: ${BUILD_ID}"
echo "Build Number :: ${BUILD_NUMBER}"
echo "Git Branch   :: ${GIT_BRANCH}"
GIT_COMMITID="$(git log | head -n 1 | cut -d ' ' -f 2)"
BUILD_DATE="$(date +%m%d%Y)"
BUILD_TIME="$(date +%H%M%S)"
echo "Build Date   :: ${BUILD_DATE}"
echo "Build Time   :: ${BUILD_TIME}"
echo "Git Commit   :: ${GIT_COMMITID}"
echo ""
echo ""
S3_BUCKET=$1
S3_BUCKET_PREFIX=$2
echo "S3 Bucket    :: ${S3_BUCKET}"
echo "S3 Prefix    :: ${S3_BUCKET_PREFIX}"
echo ""
echo ""
if [[ ${APP_NAME} == "" ]]
then
    echo "WARNING :: APP_NAME is not found. Using Git repo as APP_NAME"

    #Parsing the GIT URL to grab the repo name.
    APP_NAME=$(echo ${GIT_URL} | cut -d '/' -f 5 | cut -d '.' -f 1)
    echo "Using ${APP_NAME} as target name"
fi
GIT_COMMIT_SUFFIX=$(echo ${GIT_COMMITID} | tail -c 6)
TARGET_FILE="${APP_NAME}_${GIT_COMMITID:0:5}${GIT_COMMIT_SUFFIX}_${BUILD_DATE}.zip"
echo "Building the Application File ::: ${TARGET_FILE}"
echo ""
echo ""
echo "############## END   ::: BUILD INFORMATION ##############"