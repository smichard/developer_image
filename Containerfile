# Use CentOS Stream 9 as the base image
FROM quay.io/centos/centos:stream9

USER 0

RUN yum -y update && \
    yum -y install git make podman buildah skopeo java-11-openjdk yum-utils zsh util-linux-user wget

# Install Go
RUN curl -sSL https://go.dev/dl/go1.20.3.linux-amd64.tar.gz -o /tmp/go1.20.3.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf /tmp/go1.20.3.linux-amd64.tar.gz && rm /tmp/go1.20.3.linux-amd64.tar.gz

# Install Skaffold
RUN curl -sSL https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 -o /usr/local/bin/skaffold && \
    chmod +x /usr/local/bin/skaffold

# Install Docker
RUN yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
    yum -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install OpenShift oc client and completion
ENV OC_VERSION=4.6
RUN curl -L https://mirror.openshift.com/pub/openshift-v4/clients/oc/${OC_VERSION}/linux/oc.tar.gz | tar -C /usr/local/bin -xz \
    && chmod +x /usr/local/bin/oc

# Install Kubedock
ENV PATH=$PATH:/usr/local/go/bin

RUN git clone https://github.com/joyrex2001/kubedock.git && \
    cd kubedock && \
    make build && \
    mv ./kubedock /usr/local/bin && \
    chmod +x /usr/local/bin/kubedock && \
    cd .. && rm -fr kubedock

# Install and configure Oh-My-ZSH
RUN sed -i 's#/bin/bash#/bin/zsh#g' /etc/passwd && \
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh && \
    wget -O ~/.zshrc https://gist.githubusercontent.com/smichard/bd86a05ed89a92e364e65ea3ada8e19d/raw/a3cbe29982395dd6fb3fb5d6c604385bb57a0961/my_theme.zshrc

#USER 10001

#RUN source $HOME/.sdkman/bin/sdkman-init.sh && sdk default java 17.0.3-tem

#CMD while [ ! -f /home/user/.kube/config ]; do sleep 1; done; kubedock server --port-forward

CMD ["/bin/sh"]
