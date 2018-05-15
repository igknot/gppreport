# gppreport

### External software
    1.Oracle instantclient-basic-linux 
    2.Oracle instantclient-sdk-linux

### Running local



### Docker
Docker build:
```
docker build -t gpp-report-go .
```
Environment file ./env.list
```
ORACLE_USER=MYUSER
ORACLE_PASSWORD=MYPASSWORD
ORACLE_HOST=123.456.789.012
ORACLE_SERVICE=MYSERVICE
ORACLE_PORT=MYPORT
ENVIRONMENT=MYENV
MAILFROM=DO.NOT.REPLY@example.com
MAILTO=manager@example.com
MAILSERVER=mail.exmaple.com:25
TEST=YES/NO  #YES schedule every 2 minutes/NO fixed time 
```

run:
```
 docker container run -d --env-file ./env.list -p 80:8081  --name gpp-report --rm  gpp-report-go
```

### Kubernetes

````
kubectl create configmap gppreport-config-map --from-env-file=env_dev.list
kubectl create -f service.yaml
kubectl create -f deploment.yaml
````