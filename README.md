ec2 instance ubuntu machine create
role create and role police add administraccess



set hostname jenkins

sudo apt-get  update
jenkins installation
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins

jenkins configure and required pulgin install (Git, Docker, Kubernets)

docker installation
Install docker
sudo apt install docker.io -y

Add jenkins user to Docker group
sudo usermod -a -G docker jenkins

Restart Jenkins service
sudo service jenkins restart

Reload system daemon files
sudo systemctl daemon-reload

Restart Docker service as well

sudo service docker stop
sudo service docker start

Install the AWS CLI version 2 on Linux 
Follow these steps from the command line to install the AWS CLI on Linux.

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" 

sudo apt install unzip

sudo unzip awscliv2.zip  

sudo ./aws/install

aws --version

Install eksctl on Ubuntu Instance

Download and extract the latest release of eksctl with the following command.

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

Move the extracted binary to /usr/local/bin. 

sudo mv /tmp/eksctl /usr/local/bin

eksctl version

Install kubectl on Ubuntu Instance 
Download and extract the latest release of kubectl with the following command.
sudo curl --silent --location -o /usr/local/bin/kubectl   https://s3.us-west-2.amazonaws.com/amazon-eks/1.22.6/2022-03-09/bin/linux/amd64/kubectl



sudo chmod +x /usr/local/bin/kubectl 


Verify if kubectl got installed
kubectl version --short --client

Create EKS Cluster with two worker nodes using eksctl

eksctl create cluster --name <Cluster-Name> --region us-east-1 --nodegroup-name my-nodes --node-type t3.small --managed --nodes 2

kubeconfig file be updated under /var/lib/jenkins/.kube folder.

you can view the kubeconfig file by entering the below command:

cat  /var/lib/jenkins/.kube/config

 Install kubectl on your instance
 


Create Credentials for connecting to Kubernetes Cluster using kubeconfig
Click on Add Credentials, use Kubernetes configuration from drop down.

image


use secret file from drop down.

image



execute the below command to login as jenkins user.
sudo su - jenkins

you should see the nodes running in EKS cluster.

kubectl get nodes
image



Execute the below command to get kubeconfig info, copy the entire content of the file:
cat /var/lib/jenkins/.kube/config

iamge

Open your text editor or notepad, copy and paste the entire content and save in a file.
We will upload this file.


Enter ID as K8S and choose File and upload the file and save.

image

Enter ID as K8S and choose enter directly and paste the above file content and save.

Create a pipeline in Jenkins
Create a new pipeline job.


