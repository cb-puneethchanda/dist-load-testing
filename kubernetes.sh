#!/bin/sh
while getopts n:f: flag
do
    case "${flag}" in
        n) namespace=${OPTARG};;
        f) filepath=${OPTARG};;
    esac
done

# echo "namespace: $namespace";
kubectl create namespace $namespace

kubectl create configmap -n $namespace masterconfig --from-file=/Users/cb-it-01-1557/docker/dist-load-test/data

kubectl create -n $namespace -f master_deploy.yaml

kubectl create  -n $namespace -f slaves_deploy.yaml

kubectl create  -n $namespace -f service.yaml

pod=`kubectl get pods -n $namespace | grep 'jmeter-master-c' | awk '{print $1}'`

echo "pod " $pod

sleep 4

echo ""

kubectl exec -ti -n $namespace $pod -- /bin/bash -c "jmeter -n -t load_test/$filepath -Rjmeter-slaves-svc -l output.csv -e -f -o data"


echo "jmx run successful!"

kubectl exec -ti -n $namespace $pod -- /bin/bash -c "mv output.csv data/"

kubectl exec -ti -n $namespace $pod -- /bin/bash -c "mv jmeter.log data/"

kubectl cp -n $namespace $pod:data/ /Users/cb-it-01-1557/docker/dist-load-testing/data/pod
