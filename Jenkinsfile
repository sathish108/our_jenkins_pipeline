pipeline {
	agent any

    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "maven-3.8"
	
	jdk "JDK"
    }

    stages {

        
        stage('Pull The Code From Git To Jenkins Server') {
            steps{
               git branch: 'main', credentialsId: 'Github', url: 'https://github.com/kprasanth999/our_jenkins_pipeline.git'
	        }
	    }	
	 
	    
	stage('Compiling the Code') {
	    steps{
	        echo "COMPILING THE CODE"
                script{
		    sh "mvn clean compile" 
		}   
	    }
	}			
        
       
	    
        stage('SonarQube - SAST') {
            steps {
                  withSonarQubeEnv('sonar-7') {
                  sh "mvn sonar:sonar \
                  -Dsonar.host.url=http://18.209.23.245:9000 \
                  -Dsonar.login=da2c37151854a8de06fe5cb14d6dd186a6ab40d3"
                  }
            }
        }

        stage('SonarQube Code Quality Status') {
            steps {
                  timestamps {
                      script {
                            try{
                       		 def sonar_api_token='da2c37151854a8de06fe5cb14d6dd186a6ab40d3';
                        	 def sonar_project='webapp';
                        	 sh """#!/bin/bash +x
                        	 echo "Checking status of SonarQube Project = ${sonar_project}"
                        	 sonar_status=`curl -s -u ${sonar_api_token}: http://18.209.23.245:9000/api/qualitygates/project_status?projectKey=${sonar_project} | grep '{' | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["'projectStatus'"]["'status'"];'`
                        	 echo "SonarQube status = \$sonar_status"

                        	 case \$sonar_status in
                                 "ERROR")
                                 echo "Quality Gate Failed - Major Issues > 0"
                                 echo "Check the SonarQube Project ${sonar_project} for further details."
                                 exit 1
                                 ;;
                                 "OK")
                                 echo "Quality Gate Passed"
                                 echo "Check the SonarQube Project ${sonar_project} for further details."
                                 exit 0
                                 ;;
                                 esac

                                 """

                                 echo 'Code Quality Checks Complete.'
                                  //mark the pipeline as unstable and continue
                                 }
			     catch(e){
                                 currentBuild.result = 'UNSTABLE'
                                 result = "FAIL"
                                 }
                    }
                }
           }
       }		
        
	    
        stage('Notify through Mail') {
	    steps {
                mail bcc: '', body: '''SonarQube Quality Gate Passed''',
                cc: '', from: '', replyTo: '', subject: 'Jenkins Job', to: 'kpvkpv67@gmail.com'
            }
	}	
        

        stage('Compile,Test & Package') {
	    steps{
		 script {
			
		    sh "mvn clean package" 
				                   
                 }
	     }	
        }   
	
	    
	stage('Nexus Artifactory Upload'){
	    
	    steps {
	    
             	nexusArtifactUploader artifacts: [[artifactId: 'webapp', classifier: '', 
	     	file: '/var/lib/jenkins/workspace/Test/target/webapp.war', 
		type: 'war']], 
        	credentialsId: 'Nexus-pw', 
		groupId: 'com.rnstech.org', 
		nexusUrl: '18.209.23.245:8080/nexus/', 
		nexusVersion: 'nexus2', 
		protocol: 'http', 
		repository: 'Releases', 
		version: '1.0.2'       
        
	    }
	}      
	    
	stage('Build Docker Image') {
            steps{
                sh "docker build -t ecr_testing_repo ."  
            }
        }
	    

        stage('Tagging the Docker Image with ECR Repository Name') {
            steps{
                sh "docker tag ecr_testing_repo:latest 071483313647.dkr.ecr.us-east-1.amazonaws.com/ecr_testing_repo:latest"  
            }
        }
    
    
        stage('Uploading The Image into ECR in Testing Repository') {
            steps{
                script{
                    sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 071483313647.dkr.ecr.us-east-1.amazonaws.com'
                    sh 'docker push 071483313647.dkr.ecr.us-east-1.amazonaws.com/ecr_testing_repo:latest'
                }
            }
        }
      
        stage('Notify UAT through a Mail') {
	    steps {
                mail bcc: '', body: '''Please Pull the Image From ECR With this name for Testing
                071483313647.ecr.us-east-1.amazonaws.com/ecr_testing_repo:latest''',
                cc: '', from: '', replyTo: '', subject: 'Jenkins Job', to: 'kpvkpv67@gmail.com'
            }
	}	

	    
	stage('approve') {
	    steps {
	        echo "Approval State"
                 timeout(time: 7, unit: 'DAYS') {                    
	               input message: 'Do you want to deploy?', submitter: 'Prasanth'
		 }
	    }
        }


        stage('Uploading The Image into ECR for Production Repository') {
            steps{
                script{
                    sh 'aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin account_id.dkr.us-east-1.amazonaws.com'
                    sh 'docker tag ecr_testing_repo:latest 071483313647.dkr.ecr.us-east-1.amazonaws.com/ecr_production_repo:latest'
                    sh 'docker push 071483313647.dkr.ecr.us-east-1.amazonaws.com/ecr_production_repo:latest'
		}                   
		mail bcc: '', body: ''' Container Registered in the Production Repository ''',
                cc: '', from: '', replyTo: '', subject: 'Jenkins Pipeline Success on the New Commit', to: 'kpvkpv67@gmail.com'
            }
        }
    }
}
