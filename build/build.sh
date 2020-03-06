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

echo "########## Start Building the Application ##########"
GIT_COMMITID="$(git log | head -n 1)"
echo "Latest Git Commit is ${GIT_COMMITID}"