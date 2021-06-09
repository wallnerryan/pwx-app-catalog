FROM centos:centos7

RUN yum --nogpgcheck group install "Development Tools" -y
RUN yum install --nogpgcheck -y make libaio-devel yum-utils centos-release-scl
RUN yum -y --nogpgcheck --enablerepo=centos-sclo-rh-testing install devtoolset-7-gcc
COPY  fio-3.27.tar.gz fio-3.27.tar.gz
RUN tar -zxvf fio-3.27.tar.gz
WORKDIR /fio-fio-3.27
RUN source /opt/rh/devtoolset-7/enable && ./configure && make && make install
CMD ["/bin/sh"]
