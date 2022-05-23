#!/bin/sh

kubectl create configmap masterconfig --from-file=/Users/cb-it-01-1557/docker/dist-load-test/data

kubectl create -f master_deploy.yaml

kubectl create -f slaves_deploy.yaml

kubectl wait --for=condition=ready pod $pod

pod=`kubectl get pods | grep 'jmeter-master-c' | awk '{print $1}'`

echo "pod " $pod

kubectl exec -ti $pod -- /bin/bash -c "jmeter -n -t load_test/Http.jmx -Rjmeter-slaves-svc -l output.csv -e -f -o data"


echo "jmx run successful!"
kubectl exec -ti $pod -- /bin/bash -c "mv output.csv data/"

kubectl exec -ti $pod -- /bin/bash -c "mv jmeter.log data/"

kubectl cp $pod:data/ /Users/cb-it-01-1557/docker/dist-load-test/data/pod

