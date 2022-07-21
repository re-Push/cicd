FROM nginx
RUN unlink "/etc/nginx/conf.d/default.conf"
COPY reverse-proxy.conf /etc/nginx/conf.d/reverse-proxy.conf
