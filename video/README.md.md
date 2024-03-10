

**Setting Up Jenkins, Docker, AWS CLI eksctl, and kubectl on Ubuntu EC2 Instance**

This guide provides step-by-step instructions for setting up Jenkins, Docker, AWS CLI, eksctl, and kubectl on

an Ubuntu EC2 instance.

**EC2 Instance Setup**

1\. Create an Ubuntu EC2 Instance: Launch an Ubuntu EC2 instance on AWS.

2\. SSH into the Instance: Use SSH to connect to your Ubuntu EC2 instance.

**Jenkins Installation**

1\. #sudo apt-get update

2\. #sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

3\. #echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

4\. #sudo apt-get update

5\. #sudo apt-get install jenkins

Configure Jenkins: Open Jenkins in a web browser and complete the initial configuration. Install required

plugins, including Git, Docker, and Kubernetes.

**Docker Installation**

1\. #sudo apt install docker.io -y

2\. #sudo usermod -a -G docker jenkins

3\. #sudo service jenkins restart

4\. #sudo systemctl daemon-reload

5\. #sudo service docker stop

6\. #sudo service docker start`



**AWS CLI Installation**

1\. #curl "https://awscli.amazonaws.com/awscli-exe-linux-x86\_64.zip" -o "awscliv2.zip"

2\. #sudo apt install unzip

3\. #sudo unzip awscliv2.zip

4\. #sudo ./aws/install

5\. #aws --version

**eksctl Installation**

1\. #curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl\_$(uname -s)\_amd64.tar.gz" | tar xz -C /tmp

2\. #sudo mv /tmp/eksctl /usr/local/bin

3\. #eksctl version

**kubectl Installation**

1\. #sudo curl --silent --location -o /usr/local/bin/kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.22.6/2022-03-09/bin/linux/amd64/kubectl

2\. #sudo chmod +x /usr/local/bin/kubectl

3\. #kubectl version --short --client

**Create EKS Cluster**

1\. #eksctl create cluster --name <Cluster-Name> --region us-east-1 --nodegroup-name my-nodes --node-type t3.small --managed --nodes 2

Replace with the desired name for your EKS cluster.

Now you have Jenkins, Docker, AWS CLI, eksctl, and kubectl installed and configured on your Ubuntu EC2instance. You can proceed to use these tools for your development and deployment tasks.

**Configure Kubernetes Credentials in**

**Jenkins**

1\. View kubeconfig file: Execute the following command to view the kubeconfig file:

1\. #cat /var/lib/jenkins/.kube/config

2\. Create Credentials: In Jenkins, go to Credentials, click on Add Credentials, and choose Kubernetes

configuration. You can either use a secret file or enter the content directly.

3\. Verify Connection: Switch to the Jenkins user:

1\. #sudo su - jenkins

Then, verify the connection to the EKS cluster:

1\. #kubectl get nodes

**Create Jenkins Pipeline**

Create a New Pipeline Job: In Jenkins, create a new pipeline job to define your deployment pipeline. You can

use the provided example pipeline code and customize it according to your requirements.
```groovy
pipeline {

  agent any
```

          environment {

                DOCKER\_PASSWORD = credentials('Docker-Password') // Assuming you've added Docker Hub password as a secret 
                text credential with ID 'dockerhub-password'

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

         sh "echo ${DOCKER\_PASSWORD} | docker login -u rajujaat25 --password-stdin"

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

