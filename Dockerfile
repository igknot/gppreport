FROM golang
RUN mkdir oreclient_install_dir
RUN apt-get update 
RUN apt-get install libaio1 libaio-dev
RUN apt-get install unzip -y
ADD database/clientSoftware/instantclient-basic-linux.x64-12.2.0.1.0.zip  /oreclient_install_dir/instantclient-basic-linux.x64-12.2.0.1.0.zip
ADD database/clientSoftware/instantclient-sdk-linux.x64-12.2.0.1.0.zip /oreclient_install_dir/instantclient-sdk-linux.x64-12.2.0.1.0.zip
ADD database/clientSoftware/oci8_linux.pc /oreclient_install_dir/instantclient_12_2/oci8.pc
RUN cd /oreclient_install_dir ; unzip /oreclient_install_dir/instantclient-basic-linux.x64-12.2.0.1.0.zip
RUN cd /oreclient_install_dir ; unzip /oreclient_install_dir/instantclient-sdk-linux.x64-12.2.0.1.0.zip
RUN mkdir -p /reports ; mkdir -p /queries



ENV PKG_CONFIG_PATH "/oreclient_install_dir/instantclient_12_2"
ENV LD_LIBRARY_PATH "/oreclient_install_dir/instantclient_12_2"

ENV REPORT_DIR "/reports"
ENV QUERY_DIR "/queries"


RUN ln -s /oreclient_install_dir/instantclient_12_2/libclntsh.so.12.1 /usr/lib/libclntsh.dylib
RUN ln -s /oreclient_install_dir/instantclient_12_2/libclntsh.so.12.1 /usr/lib/libclntsh.so
RUN ln -s /oreclient_install_dir/instantclient_12_2/libocci.so.12.1 /usr/lib/libocci.dylib
RUN ln -s /oreclient_install_dir/instantclient_12_2/libocci.so.12.1 /usr/lib/libocci.so

ADD queries/*.sql /queries/
WORKDIR /go/src/gppreport
COPY main.go .
RUN rm -fr /var/lib/apt/lists/*
RUN go get -d -v ./...
RUN rm -fr /go/src/gppreport/database/clientSoftware
RUN go install -v ./...
ENTRYPOINT /go/bin//gppreport
EXPOSE 8081
RUN touch /reports/nofiles_here_yet.txt

