# nginx-custom-sti
FROM registry.access.redhat.com/ubi8/nginx-120:latest

# Expose ports.
EXPOSE 8080
EXPOSE 443

#ADD nginx.conf "${NGINX_CONF_PATH}"
#ADD nginx-default-cfg/*.conf "${NGINX_DEFAULT_CONF_PATH}"
#ADD nginx-cfg/*.conf "${NGINX_CONFIGURATION_PATH}"

# Add application sources
ADD content/ .

# Run
CMD ["nginx", "-g", "daemon off;"]
