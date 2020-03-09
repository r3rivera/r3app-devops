!#/bin/bash

echo "############## Configuration ::: Setting up AWS CLI ##############"
# Install AWS CLI Command
#curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#unzip awscliv2.zip
#sudo ./aws/install

if ! [ -x "$(command -v aws)" ]; then
  echo 'Error: AWS is not installed.' >&2
  exit 1
fi