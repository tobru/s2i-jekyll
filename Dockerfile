# jekyll-centos7
FROM openshift/base-centos7
MAINTAINER Tobias Brunner <tobias@tobru.ch

# Inform about software versions being used inside the builder
ENV JEKYLL_VERSION=3.5.0

# Labels used in OpenShift to describe the builder image
LABEL io.k8s.description="Platform for building Jekyll-based static sites" \
      io.k8s.display-name="Jekyll" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="jekyll,static"

# Install required packages
RUN yum install -y --setopt=tsflags=nodocs centos-release-scl && \
    yum install -y --setopt=tsflags=nodocs rh-ruby23 \
                                           rh-ruby23-ruby-devel \
                                           rh-ruby23-rubygem-bundler \
                                           rh-nginx18 && \
    yum clean all -y

# Get prefix path and path to scripts rather than hard-code them in scripts
ENV CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts \
    ENABLED_COLLECTIONS="rh-nginx18 rh-ruby23"

# When bash is started non-interactively, to run a shell script, for example it
# looks for this variable and source the content of this file. This will enable
# the SCL for all scripts without need to do 'scl enable'.
ENV BASH_ENV=${CONTAINER_SCRIPTS_PATH}/scl_enable \
    ENV=${CONTAINER_SCRIPTS_PATH}/scl_enable \
    PROMPT_COMMAND=". ${CONTAINER_SCRIPTS_PATH}/scl_enable"

ADD root /

# Install Jekyll and Bundler with RubyGems
RUN bash -c "gem install --no-ri --no-rdoc jekyll bundler"

# Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7
# image sets io.openshift.s2i.scripts-url label that way
COPY ./.s2i/bin/ /usr/libexec/s2i

# Create directories for nginx
RUN mkdir -p /opt/app-root/etc/nginx && \
    mkdir -p /opt/app-root/etc/nginx.include.d && \
    mkdir -p /opt/app-root/var/run/nginx && \
    mkdir -p /opt/app-root/var/log/nginx && \
    mkdir -p /opt/app-root/var/lib/nginx/tmp && \
    chgrp -R 0 /var/opt/rh/rh-nginx18 && \
    chmod -R g+rwX /var/opt/rh/rh-nginx18

# Copy the nginx configuration
COPY ./etc /opt/app-root/etc

# Link the nginx logs to stdout/stderr
RUN ln -sf /dev/stdout /opt/app-root/var/log/nginx/access.log && \
    ln -sf /dev/stderr /opt/app-root/var/log/nginx/error.log

# Chown /opt/app-root to the deployment user and drop privileges
RUN chown -R 1001:0 /opt/app-root && chmod -R og+rwx /opt/app-root
USER 1001

# Set the default port for applications built using this image
EXPOSE 8080

# Set the default CMD for the image when executed directly
CMD ["/usr/libexec/s2i/usage"]
