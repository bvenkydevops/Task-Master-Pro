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
	 
	  sh 'trivy fs ==format table -o fs-report.html . ' 
   }
   }
   stage('SonarQube Analysis'){
       steps {
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
	  
		sh 'kubectl apply -f deployment.yml -n webapps'
		sleep 30
	   
            }
        } 
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
