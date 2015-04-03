#
# OpenResty docker image on ARM
#

FROM resin/rpi-raspbian

MAINTAINER Pahud Hsieh <pahudnet@gmail.com>

# Set environment.
ENV \
  DEBCONF_FRONTEND=noninteractive \
  DEBIAN_FRONTEND=noninteractive \
  TERM=xterm-color

# Install packages.
RUN apt-get update && apt-get -y install \
  build-essential \
  vim-tiny \
  curl \
  telnet \
  libreadline-dev \
  libncurses5-dev \
  libpcre3-dev \
  libssl-dev \
  luarocks \
  libgeoip-dev \
  nano \
  perl \
  wget \
  supervisor

# Compile openresty from source.
RUN \
  wget http://openresty.org/download/ngx_openresty-1.7.10.1.tar.gz && \
  tar -xzvf ngx_openresty-*.tar.gz && \
  rm -f ngx_openresty-*.tar.gz && \
  cd ngx_openresty-* && \
  sed -ie 's/DEFAULT_ENCODE_EMPTY_TABLE_AS_OBJECT 1/DEFAULT_ENCODE_EMPTY_TABLE_AS_OBJECT 0/g' bundle/lua-cjson-2.1.0.2/lua_cjson.c && \
  ./configure \
  --prefix=/opt/openresty \
  --with-pcre-jit --with-ipv6 \
  --with-http_stub_status_module \
  --with-luajit  \
  -j2  && \
  make && \
  make install && \
  make clean && \
  cd .. && \
  rm -rf ngx_openresty-*&& \
  ln -s /opt/openresty/nginx/sbin/nginx /usr/local/bin/nginx && \
  ln -sf /opt/openresty/nginx /opt/nginx && \
  ldconfig


# Set the working directory.
WORKDIR /opt/openresty
#WORKDIR /usr/local/openresty

# Add files to the container.
#ADD . /opt/openresty
#ADD nginx-conf /opt/nginx/conf
ADD supervisor.d /etc/supervisor/conf.d
RUN sed -ie 's/worker_processes.*/worker_processes 4;/g'  /opt/nginx/conf/nginx.conf

# Expose volumes.
#VOLUME ["/etc/nginx"]

# expose HTTP
EXPOSE 80 443

# Set the entrypoint script.
#ENTRYPOINT ["./entrypoint"]

# Define the default command.
#CMD ["nginx", "-c", "/usr/local/openresty/nginx/conf/nginx.conf"]
#CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf",  "--nodaemon"]
