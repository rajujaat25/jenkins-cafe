

# DevOps Project: Setting Up Jenkins, Docker, AWS CLI eksctl, and kubectl on Ubuntu EC2 Instance

This guide provides step-by-step instructions for setting up Jenkins, Docker, AWS CLI, eksctl, and kubectl on

an Ubuntu EC2 instance.

**EC2 Instance Setup**

1\. Create an Ubuntu EC2 Instance: Launch an Ubuntu EC2 instance on AWS.

2\. SSH into the Instance: Use SSH to connect to your Ubuntu EC2 instance.

## Add Administrator Role

To add an administrator role in AWS IAM, follow these steps:

1. **Navigate to IAM Dashboard**: From the services menu, select IAM to navigate to the IAM dashboard.

2. **Create a New Role**: Click on "Roles" in the sidebar and then click on "Create role".

3. **Select Role Type**: Choose "AWS service" as the trusted entity and select EC2 as the service that will use this role. Click "Next: Permissions".

4. **Attach Administrator Policy**: In the permissions step, search for and select the "AdministratorAccess" policy. This policy grants full access to AWS services and resources.

5. **Review and Create**: Review the role configuration and click "Next: Tags" if you want to add tags. Otherwise, click "Next: Review".

6. **Name and Create Role**: Provide a name and description for the role and click "Create role" to create the role.

Once the role is created, you can assign it to your EC2 instance during or after the instance launch process. This will give the EC2 instance the necessary permissions to perform administrative tasks within your AWS account.


**Jenkins Installation**

1\. #sudo apt-get update

2\. #sudo apt install openjdk-11-jre-headless

3\. #sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

4\. #echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

5\. #sudo apt-get update

6\. #sudo apt-get install jenkins -y

Configure Jenkins: Open Jenkins in a web browser and complete the initial configuration. Install required

plugins, including Git, and Kubernetes(Kubernetes Credentials, Kubernetes CLI,Kubernetes Pipeline, Kubernetes Credentials Provider ).

**Docker Installation**

1\. #sudo apt install docker.io -y

2\. #sudo usermod -a -G docker jenkins

3\. #sudo service jenkins restart

4\. #sudo systemctl daemon-reload

5\. #sudo service docker stop

6\. #sudo service docker start`



**AWS CLI Installation**

1\. #curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

2\. #sudo apt install unzip

3\. #unzip awscliv2.zip

4\. #sudo ./aws/install

5\. #aws --version

**eksctl Installation**

1\. #sudo curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | sudo tar xz -C /tmp

2\. #sudo mv /tmp/eksctl /usr/local/bin

3\. #eksctl version

**kubectl Installation**

1\. #sudo curl --silent --location -o /usr/local/bin/kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.22.6/2022-03-09/bin/linux/amd64/kubectl

2\. #sudo chmod +x /usr/local/bin/kubectl

3\. #kubectl version --short --client

**Create EKS Cluster**

1\. #eksctl create cluster --name (cluster-name) --node-type t2.micro --region us-east-2

Replace with the desired name for your EKS cluster.

Now you have Jenkins, Docker, AWS CLI, eksctl, and kubectl installed and configured on your Ubuntu EC2instance. You can proceed to use these tools for your development and deployment tasks.

**Configure Kubernetes Credentials in**

**Jenkins**

1\. View kubeconfig file: Execute the following command to view the kubeconfig file:

1\. #cat /home/ubuntu/.kube/config

2\. Create Credentials: In Jenkins, go to Credentials, click on Add Credentials, and choose Kubernetes

configuration. You can either use a secret file or enter the content directly.

Then, verify the connection to the EKS cluster:

1\. #kubectl get nodes

# Create Jenkins Pipeline

Create a New Pipeline Job: In Jenkins, create a new pipeline job to define your deployment pipeline. You can

use the provided example pipeline code and customize it according to your requirements.

##  Deployment Pipeline:

```groovy
pipeline {

   agent any

          environment {

                DOCKER_PASSWORD = credentials('Docker-Password') // Assuming you've added Docker Hub password as a secret text credential with ID 'dockerhub-password'

                       }
          triggers {

          githubPush() // Trigger the pipeline when a push event occurs on the GitHub repository

                   }

          stages {

            stage('Checkout Git Repository') {

              steps {

                  // Checkout the Git repository

                  git 'https://github.com/rajujaat25/jenkins-cafe.git'

                    }

                }
 
          stage ('Docker file build'){

             steps{

          sh 'docker build -t rajujaat25/cafenewimage:latest .'

                  }

              }

         stage('login to dockerhub') {

            steps{

         sh "echo ${DOCKER_PASSWORD} | docker login -u Docker_UserName --password-stdin"

                 }

              }

        stage('push image') {

           steps{

        sh 'docker push rajujaat25/cafenewimage:latest'

                }

           }

       stage('Deploy to Kubernetes') {

           steps {

              script {

                   withKubeConfig([credentialsId: 'eks', serverUrl: '']) {

                   def yamlFiles = ['Deployment.yml','service.yml'] // Add more YAML file names as needed

                   yamlFiles.each { yamlFile ->

                   sh "kubectl apply -f $yamlFile"

                                  }

                              }

                          }

                     }

                 }

              }

           }
```

# Deployment Process Overview

In a real-world scenario where code changes need to be deployed, it's common to follow a two-step process:

## Initial Deployment Pipeline:

- This pipeline is triggered when there's a new version of the application or significant changes requiring a full deployment.
- It typically involves stages such as pulling the code from the Git repository in Jenkins, building the Docker image, pushing the image to Docker Hub, and deploying the image to the Kubernetes cluster in the target environment.

## Deployment Restart Pipeline:

- This pipeline is triggered for subsequent code changes that don't necessitate a full redeployment but rather an update to the existing deployment.
- It's designed to be more lightweight and faster than the initial deployment pipeline.
- Stages in this pipeline might include pulling the latest changes from the version control system, building the updated artifacts, and deploying them to the target environment.

## Restart Deployment Pipeline

```groovy
pipeline {
     agent any
       environment {
          // Reference the secret file credential by its ID
          KUBECONFIG_FILE = credentials('eks')
           }
    
      stages {
          stage('Restart Deployment') {
              steps {
                     sh "kubectl rollout restart deployment.apps/mydeploy --kubeconfig=${KUBECONFIG_FILE}"
                   }
               }
           }
     }
```
These pipelines help streamline the deployment process, ensuring that new changes are deployed efficiently while minimizing downtime and maintaining system reliability. Automation and continuous integration practices play a crucial role in executing these pipelines reliably and consistently.


