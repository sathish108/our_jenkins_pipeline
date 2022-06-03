pipeline {
	agent { label 'Build_server'}

    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "maven-3.8"
    }

    stages {

        
        stage('Pull The Code From Git To Jenkins Server') {
            steps{
               git branch: 'main', credentialsId: 'Github', url: 'https://github.com/kprasanth999/our_jenkins_pipeline.git'
	        }
	    }	
	    
        
        stage('SonarQube analysis') {
            steps{
		  
		sh "mvn clean compile"  
		echo "Sonar Scanner"
                sh "mvn sonar:sonar \
                -Dsonar.host.url=http://44.201.116.110:9000 \
                -Dsonar.login=fec74e7156c6b4441ee5acf4ac9fe684a3f99c7b"
		
            }                     
       }
        
        
        stage("Quality gate") {
            steps {
                waitforQualityGate abortPipeline: true
            }
            post {
                failure {
                    mail bcc: '', body: ''' Sonarqube Returns QualityGate Failure''',
                    cc: '', from: '', replyTo: '', subject: 'SonarQube Returns Quality Failure', to: 'prabagar.chinnappa@photon.com'
                }
            }
        }


        stage('Compile,Test & Package') {
	        steps{
		        sh "mvn clean package"  
	        }
            post {
                success {
                   junit 'target/surefire-reports/*.xml'
                   archiveArtifacts artifacts: '**/*.war', followSymlinks: false
                }
            }   
        }   
        
	    
        stage('Deploying in to Nexus Server') {
	        steps{
		        sh "mvn clean deploy"  
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
                acct_id.dkr.ecr.us-east-1.amazonaws.com/ecr_testing_repo:latest''',
                cc: '', from: '', replyTo: '', subject: 'Jenkins Job', to: 'prabagar.chinnappa@photon.com'
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
            }
            post{
                success{
                    mail bcc: '', body: ''' Container Registered in the Production Repository ''',
                    cc: '', from: '', replyTo: '', subject: 'Jenkins Pipeline Success on the New Commit', to: 'prabagar.chinnappa@photon.com'
                }
            }
        }
    }
}
