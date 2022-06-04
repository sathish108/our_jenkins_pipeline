pipeline {
	agent { label 'Build_server'}

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
        
        stage('SonarQube analysis') {
            steps{
		  
		echo "Sonar Scanner"
		    script{
		         sh "mvn sonar:sonar \
                         -Dsonar.host.url=http://3.84.16.46:9000 \
                         -Dsonar.login=fec74e7156c6b4441ee5acf4ac9fe684a3f99c7b"
		    }
	    
			
                mail bcc: '', body: ''' Sonarqube Returns QualityGate Failure''',
                cc: '', from: '', replyTo: '', subject: 'SonarQube Returns Quality Passed', to: 'kpvkpv67@gmail.com'
                  
            }
	}
        

        stage('Compile,Test & Package') {
	     steps{
		 script {
			
		    sh "mvn clean package" 
				
                    junit 'target/surefire-reports/*.xml'
                    archiveArtifacts artifacts: '**/*.jar', followSymlinks: false
                 }
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
                    sh 'aws ecr get-login-password --region us-east-2 | dockerlogin --username AWS --password-stdin account_id.dkr.us-east-1.amazonaws.com'
                    sh 'docker tag ecr_testing_repo:latest 071483313647.dkr.ecr.us-east-1.amazonaws.com/ecr_production_repo:latest'
                    sh 'docker push 071483313647.dkr.ecr.us-east-1.amazonaws.com/ecr_production_repo:latest'
		}                   
		mail bcc: '', body: ''' Container Registered in the Production Repository ''',
                cc: '', from: '', replyTo: '', subject: 'Jenkins Pipeline Success on the New Commit', to: 'kpvkpv67@gmail.com'
            }
        }
    }
}
