FROM centos:6 AS builder
MAINTAINER liuweikai "vicliu@outlook.com"

WORKDIR /build
RUN yum clean all \
    && yum update -y \
    && yum clean all \
    && yum install -y gcc gcc-c++ git make openssl-devel unixODBC unixODBC-devel libxml2 libxml2-devel mysql-connector-odbc libcurl-devel \
    && git clone https://gitee.com/vicliu624/XTransServer.git \
    && cd XTransServer \
    && make libXTransServerMySql \
    && make clean \
    && cp lib64/libXTransServerMySql.so /lib64/

#业务代码编译
#业务代码拷贝到容器
COPY ./YunTongCard ./YunTongCard
RUN cd YunTongCard \
    && mkdir ../app \
    && make

#配置ODBC
COPY ./odbc.ini /etc/odbc.ini
#业务程序配置文件拷贝到容器
COPY ./8583.config.xml /build/app/
COPY ./8583Login.config.xml /build/app/
COPY ./alipay /build/app/alipay
COPY ./alipay_ynjt /build/app/alipay_ynjt
COPY ./certs /build/app/certs

# Build a small image
FROM centos:6

RUN yum update -y \
    && yum clean all \
    && yum install -y unixODBC mysql-connector-odbc 
    
COPY --from=builder /build/app/* ./app/
RUN cp ./app/libXTransServerMySql.so /lib64/
COPY ./odbc.ini /etc/odbc.ini

ENTRYPOINT ["./app/YNYTPlatform"]
