
++++++++++++++++++++++++

install aws cli

sudo apt install curl
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

$aws configure
----------------------------------------------------------------------------------
install terraform 

$sudo snap install terraform --classic
$terraform --version
----------------------------------------
$terraform init
$terraform plan
$terraform apply -auto-approve
--------------------------------------------------------
Outputs:

cluster_id = "venky_cluster"
node_group_id = "venky_cluster:venky-node-group"
subnet_ids = [
  "subnet-0b0fc650547bdfd8c",
  "subnet-0fb44fbf4e0dafa15",
]
vpc_id = "vpc-0102e3176be47f1df"

============
install kubectl 
 $sudo snap install  kubectl --classic

 $kubectl get nodes
    :error
now upate the kubeconfig file by uisng below command

 $aws eks --region ap-south-1 update-kubeconfig --name venky_cluster
------------------------------------------------------------------------


steup 4 vms-t2-medium -storage 20GB,ubuntu 24.04LTS
1.jenkins master  --> install java,jenkins,docker 
2.jenkins slave
3.SonarQube
4.Nexus
----------------------------------------------------------------
in Jenkins master:-----
install java-17
install jenkins 

docker installation:
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
(sudo usermod -aG docker ubuntu , sudo chmod 666 /var/run/docker.sock )

install pugins --> sonarqube Scanner,config file provider,maven integration,pipeline maven integration Docker,Docker pipeline,pipeline stage view,kubernetes,kubenetes CLI

configure inside jenkins master :
manage jenkins--> tools--> -docker install automatically -Download from docker.com -latest version,  maven3 3.9.8 ,
-sonar-scanner - install automatically.

now create a pipeline
-------------------------
cick on pipeline:
Discard builds -3

pipeline {
 agent any 
 tools {
 maven 'maven3'
 }
 environment {
 SCANNER_HOME= tool 'sonar-scanner'
 }
 stages{
  stage("gitcheckout"){
    steps {
	gitcheckout:hshjxsjhcsavvx
	}
   }
   stage('compile'){
       steps {
	   sh 'mvn compile'
   }
   }
   stage('test'){
       steps {
	   sh 'mvn test'
   }
   }
   stage('Trivy Fs Scan'){
       steps {
	   */install trivy \*
	  sh 'trivy fs ==format table -o fs-report.html . ' 
   }
   }
   stage('SonarQube Analysis'){
       steps {
	   take help form syntax:
	   now configure sonar server
	   goto - sonarqube - Adminstation,security -users- tokens copy tocken 
	   now goto jenkins - manage jenkins -credetials-suystems-global credetials-suystems-global
	   paste token and save it.
	   now again goto jenkins manage -system-sonarqube installations name is sonar-server url of SQ paste token 
	   save
	   now goto piepline sysntax->sonarqube environment
	   
	   withSonarQubeEnv('sonar'){
	   sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectKey=firstjob \
	   -Dsonar.projectName=firstjob -Dsonar.java.binaries= target '''
   }
   }
   stage('Build Application'){
       steps {
	   sh 'mvn clean package'
            }
        }
		stage('Publish Artifacts to nexus '){
         steps {
	     add nexus url,and creds inside pom.xml file. distribution management section
   ADD ID - maven-release and maven-snapshot
   url paste form the nexus repos.
   
   After that configure the setting.xml in jenkins
   
   manage jenkins--> managed file -->add new config --> gobal maven settings
   --> iD settings 
   add credentiaals of nexus inside <server> tags
   id -maven-release
   username-admin
   passwd -admin
   id -maven-snapshot
   passwd -admin
   
   save
   goto pipelinesyntax--> withMaven -maven3--> global settings 
   generate  paste in piepline
   sh 'mvn deploy'
   stage ('build & tag Docker Image'){
      steps{
         script{
		   withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker')
		  sh 'docker build -t adijaiswal/taskmanager:latest .'	  
   }
   }
   }          
    stage('Scan Docker Image By Trivy'){
	steps {
	  sh 'trivy image --formate table -o image-report.html adijaiswal/taskmanager:latest'
	  }
	} 
    stage ('push Docker Image'){
      steps{
         script{
		   withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker')
		  sh 'docker push adijaiswal/taskmanager:latest'
		  }
           }
         }
       }
	  stage('deploy to kubernetes'){
       steps {
	   
	   ---------------------------------
	   go to pipelinesyntax--> withKubeconfig:Configure CLI (kubectl)
	    ADD credentials --> kind secrete text-->paste the token.k8-token name.
	    now k8s server endpoint-->paste here the k8s API server endpoint
	    clustername-->venky_cluster
		Namesapace -->webapps
		save.
		paste here.
		sh 'kubectl apply -f deployment.yml -n webapps'
		sleep 30
	   -----------------------------------
	   
            }
        } 
		----------------------
		before run this job install kubectl on jenkins-server.
		----------------------------
	stage('verify the Deployment'){
       steps {
	   withKubeconfig(...............)
	    sh 'kubectl get pods -n webapps'
		sh 'kubectl get svc -n webapps'
            }
        }
   }
  }
 }


---------------------------------------------------------------------
3.SonarQube
-----------------------
install docker 
switch to root user

$docker run -d -p 9000:9000 sonarqube:lts-community
-----------------
for nexus 
$docker run -d -p 8081:8081 sonatype/nexus3
