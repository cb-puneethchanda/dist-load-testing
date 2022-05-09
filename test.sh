#!/bin/sh
 
docker run -dit --name slave01 cbpuneethchanda/jmserver /bin/bash
docker run -dit --name slave02 cbpuneethchanda/jmserver /bin/bash
docker run -dit --name slave03 cbpuneethchanda/jmserver /bin/bash

docker run -dit --name master cbpuneethchanda/jmmaster /bin/bash

docker ps -a

docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(docker ps -a -q) > output.txt

docker exec -it master jmeter -n -t sample-test/sample-test.jmx -R`tail -3 output.txt | xargs | sed -e 's/ /,/g'` -l results.csv -e -f -o data
