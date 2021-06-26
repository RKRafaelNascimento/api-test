podTemplate(
    cloud: 'kubernetes', 
    containers: [
        containerTemplate(
            args: '9999999', 
            command: 'sleep',
            image: 'docker', 
            livenessProbe: containerLivenessProbe(
                execArgs: '', 
                failureThreshold: 0, 
                initialDelaySeconds: 0, 
                periodSeconds: 0, 
                successThreshold: 0, 
                timeoutSeconds: 0
                ), 
        name: 'docker-container', 
        resourceLimitCpu: '', 
        resourceLimitEphemeralStorage: '',
        resourceLimitMemory: '', 
        resourceRequestCpu: '', 
        resourceRequestEphemeralStorage: '', 
        resourceRequestMemory: '', 
        workingDir: '/home/jenkins/agent'
        )], 
        label: 'questcode',
        namespace: 'devops', 
        volumes: [hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock')]
        ) 
{
    node("questcode") {
        def REPOS
        def IMAGE_VERSION
        def IMAGE_NAME = "api-test"
        def GIT_BRANCH
        def KUBE_NAMESPACE
        stage("Checkout"){
            echo 'Iniciando  Clone do Repositorio'
            REPOS = checkout([$class: 'GitSCM', branches: [[name: '*/main'],[name: '*/develop'] ], extensions: [], userRemoteConfigs: [[credentialsId: 'rafaelnascdev-github2', url: 'https://github.com/RKRafaelNascimento/api-test']]])
            GIT_BRANCH = REPOS.GIT_BRANCH

            if(GIT_BRANCH.equals("origin/main")){
                KUBE_NAMESPACE = "prod"
            } else if (GIT_BRANCH.equals("origin/develop")) {
                KUBE_NAMESPACE = "staging"
            } else {
                def error = "Não existe pipeline para a branch ${GIT_BRANCH}"
                echo error
                throw new Exception(error)
            }

            IMAGE_VERSION = sh returnStdout: true, script: 'sh read-package-version.sh'
            IMAGE_VERSION = IMAGE_VERSION.trim()
            sh 'ls -ltra'

        }
        stage("Build"){
              container('docker-container'){
                    echo 'Iniciando Build...'
                    withCredentials([usernamePassword(credentialsId: 'rafaelnascdev-dockerhub-global', passwordVariable: 'DOCKER_HUB_PASSWORD', usernameVariable: 'DOCKER_HUB_USERNAME')]) {
                       sh "docker login -u ${DOCKER_HUB_USERNAME} -p ${DOCKER_HUB_PASSWORD}"
                       sh "docker build -t ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:${IMAGE_VERSION} ."
                       sh "docker push ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:${IMAGE_VERSION}"
                    }
              }
        }
        stage("Deploy"){
                echo 'Iniciando  Deploy com Helm'
                echo "Namespace ${KUBE_NAMESPACE}"
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[credentialsId: 'rafaelnascdev-github2', url: 'https://github.com/RKRafaelNascimento/chart']]])
                sh "helm install . ${KUBE_NAMESPACE}-${IMAGE_NAME} -n ${KUBE_NAMESPACE}"
        }
    }
}