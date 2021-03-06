# Creating a simple CICD Pipeline

Tools used – Jenkins, GitHub, Docker, Google Cloud Platform, Docker Hub.

## Steps to set up environment:

1. **GitHub**  - Creating code repository, pushing changes and creating webhooks
    https://guides.github.com/activities/hello-world/
    
2. **GCP**  - We have used a N1 series n1-standard-1 vm with CentOS 8
    https://cloud.google.com/compute/docs/instances/create-start-instance
    Make sure to set ingress traffic IP such that GitHub and your IP can access it
    
3. **Docker** - We have containerized a Golang REST controller code.
    Docker tutorial - https://www.tutorialspoint.com/docker/index.htm
    Setting up Docker in CentOS – https://phoenixnap.com/kb/how-to-install-docker-centos-
    
4. **Jenkins** - Jenkins is a CI tool used to automate integration and deployment up to some extent.

    Setting up Jenkins in CentOS –
    https://linuxize.com/post/how-to-install-jenkins-on-centos-7/
    Make sure you have the GITScm plugin installed.

5. **Docker Hub** - This is the image repository where our image is stored. There are many alternatives to image repository.
    Docker Hub tutorial -​ ​https://docs.docker.com/docker-hub/
    Authenticate your Docker Hub account in the vm where you intend to push the image.

## Architecture of the CICD pipeline built:

![alt text](https://github.com/nivashegde/tdc-docker-go-pipeline/blob/master/a-image.png?raw=true)


## Steps to build CI/CD Pipeline:

**1. Setting up Jenkins**

● Create a job in Jenkins

● Under source code management tab, add as follows – Repository URL is the code on which you want to automate integration and deployment

● Under Build Triggers, check “GitHub hook trigger for gitSCM polling”

● Under Execute shell, enter the below script

```
#!/bin/sh
echo "Generating tag"**
#Tag of Docker image is stored in dockerversion.txt. We increment it every time we create image. Here tag is an integer variable.
echo $(($(cat "/var/lib/jenkins/workspace/dockerversion.txt")+1)) > /var/lib/jenkins/workspace/dockerversion.txt
echo "Building phase!"
#Building the docker image using docker build command
sudo docker build -t nivashegde01/go-sample-docker:$(cat
'/var/lib/jenkins/workspace/dockerversion.txt').
echo "Build complete!"
echo "Stopping intermediate container"
#Stopping intermediate container to make way to new container
sudo docker ps -q --filter "name=go-container" | grep -q. && sudo docker stop go-container
echo "Pushing image to Docker-hub"
#We are pushing docker image to Dockerhub repository
sudo docker push nivashegde01/go-sample-docker:$(cat
'/var/lib/jenkins/workspace/dockerversion.txt')
echo "Running image!"
#Finally running the image
sudo docker run --rm -d --name go-container -p 10000:10000/tcp nivashegde01/go-sample-docker:$(cat '/var/lib/jenkins/workspace/dockerversion.txt')
```

**2. Creating webhook in GitHub repository**

Go to settings, add webhook, do as follows
● Enter Jenkins URL as shown below in Payload URL
● Content type as application/json
● Select “Just the push event”

Code is a very simple REST controller written in Golang and it includes a Dockerfile.

Once there is a change in code, GitHub will send a POST request to this URL - http://34.94.248.59:8080/github-webhook/

http://34.94.248.59:8080/ is the location where Jenkins is running.

**3. Final step is to push the code**

● Make changes in the code, it should trigger the build.

● Once build is successful, you can notice the code will be running in port 10000 of the same server. Also, you can check your image in the Docker Hub repository with tags numbered.

Individual images can be pulled using -
docker pull nivashegde01/go-sample-docker:version_number
e.g. - docker pull nivashegde01/go-sample-docker:4
