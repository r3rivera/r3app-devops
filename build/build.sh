!#/bin/bash
#dir `date`
echo "## Building the project of ${APP_NAME}..."

echo "## Displaying Java Version..."
java -version | head -n 1

echo "## Displaying Maven Version..."
mvn --version | head -n 1

echo "## Displaying GIT Version..."
git --version | head -n 1