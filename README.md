# Project 1: Dockerizing Jenkins Pipeline
### Andrew Evans

## Setup workspace
from github.com, fork sample java app at https://github.com/SimplilearnDevOpsOfficial/javamavenapp.git

from the forked repo page on your account, get the URL https://github.com/yourusername/javamavenapp.git

launch VM and clone forked repo
`git clone https://github.com/yourusername/javamavenapp.git`

navigate to the repo folder
`cd javamavenapp`

## Create Docker Container with Ubuntu
Create dockerfile to automate creation of the docker container
`vim Dockerfile`

Add the following to the Dockerfile:
<pre><code>#set the base image
From ubuntu
#install java
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y maven && \
    apt-get clean;
#install git
RUN apt-get install -y git
#clone github repo containing java app
RUN git clone https://github.com/SimplilearnDevOpsOfficial/javamavenapp.git
#build java app with maven
RUN mvn package
#execute app when image is run
ENTRYPOINT java -cp target/my-app-1.0-SNAPSHOT.jar com.mycompany.app.App
</code></pre>
</br>
save and exit

`<escape>:x<enter>`

### Build the docker image
build the contents of the current directory, with project1 tag 
`docker build . -t project1:latest`

verify image has been created
`docker images`
| REPOSITORY | TAG | IMAGE ID | CREATED | SIZE |
|--|--|--|--|--|
| project1 | latest | id | About a minute ago | 644MB |

### Commit the changes
Sync the Dockerfile with the remote repo
`git add .`
`git commit -m "added Dockerfile"`
`git push origin`

## Upload Image to Dockerhub
login to dockerhub
`docker login --username=yourhubusername`
enter your password when prompted
</br>
tag your image
`docker tag <image_id> yourhubusername/project1:firsttry`
</br>
push your image
`docker push yourhubusername/project1`
</br>
verify image has been uploaded
`docker pull yourhubusername/project1:firsttry`

## Setup Jenkins to Pull Image and Deploy
install jenkins from the command line
`sudo apt-get install jenkins`
update the docker permissions for jenkins
`sudo usermod -a -G docker jenkins`
restart jenkins and docker for changes to take effect
`sudo service docker restart`
`sudo service jenkins restart`

### Configure Jenkins 
navigate to the jenkins GUI in a browser
`localhost:8080`

the required admin password can be found with the following command
`sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

select install suggested plugins
Create first admin user
Click "create new jobs"

Name the job "Project1" and select "Pipeline"
Under "Build Triggers" select the "Poll SCM" checkbox. Set the schedule as "* * * * *". Note: there is a space after each *, there is no space after the last *.
Under the Pipeline section enter the following text
<pre><code>pipeline {
    environment {
        registry = "andrewevans1/project1"
        registryCredential = 'dockerhub_id'
        dockerImage = ''
    }
    agent any
    
    stages {
        stage('Cloning git repo') {
            steps {
                git 'https://github.com/andrewevans1/javamavenapp.git'
            }
        }
        stage('Build') {
            steps {
                script {
                    dockerImage = docker.build registry + ":firsttry"
                }
            }
        }
        stage('Deploy') {
            steps {
                // push the new docker image to dockerhub
                script {
                    docker.withRegistry('',registryCredential) {
                        dockerImage.push()
                    }
                }
            }
        }
    }
}
</code></pre>

add dockerhub credentials
go to Account > credentials > Jenkins > Global > Add some credentials
Kind: Username with password
Scope: Glbal (Jenkins, nodes, items, all child items, etc)
Username: yourhubusername
Password: ********
ID: dockerhub_id
Description: Dockerhub Account

add docker plugin to jenkins
Manage Jenkins > Plugin Manager > Available, Search for "Docker"
Select "Docker Pipeline," install without restart

### Trigger a Build
Jenkins is configured to run the build process when it detects a change to the github repo.
In the VM, edit the README.md file, adding some text.
Then, push the changes to github.
`git add .`
`git commit -m "trigger jenkins"`
`git push origin`

Pull up the jenkins GUI, look at your Project1 Status. It should show a new build has executed and completed successfully.
