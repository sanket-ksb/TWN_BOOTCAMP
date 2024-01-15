## This folder contains deployment.yaml which is used for deploying microservice arch. application on k8s. required env variables can be added into .env file
1. Make sure nginx ingress is installed.

2. Follow below steps

3. create imagePullSecrets: acr
kubectl create secret docker-registry acr --docker-server=<registry-server> --docker-username=<-name> --docker-password=<-pword> --docker-email=<-email>

4. Create configmap for kafka properties files
kubectl create configmap kafka-server-onpremise --from-file <path-to-file>

5. kubectl create secret generic rsa-key-secret --from-file <path-to-file>

6. Modify Mount paths if required

## To Run with env file
7. To set .env file in environment use below command - Make sure you have .env file in current folder (Use linux terminal)
set -o allexport; source .env; set +o allexport

8. Below command runs Stack on  kubernates by replacing Variables from yaml file with ENV variables with we set in step 1
cat pumptest-deployment.yaml | envsubst | kubectl apply -f -

## Kubectl commands sheet
https://kubernetes.io/docs/reference/kubectl/cheatsheet/      
