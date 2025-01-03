export DOCKERHUB_TAG="dockerhubtag"

echo "DOCKERHUB_TAG: $DOCKERHUB_TAG"

sudo yum update -y
sudo yum install docker -y

sudo service docker start
sudo usermod -aG docker ec2-user

sudo docker run -d -p 443:5000 $DOCKERHUB_TAG
