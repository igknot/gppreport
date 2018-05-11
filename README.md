# gppreport
####External software
    1.Oracle instantclient-basic-linux 
    2.Oracle instantclient-sdk-linux
    
####Docker
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
```

run:
```
 docker container run -d --env-file ./env.list -p 80:8081  --name gpp-report --rm  gpp-report-go
```