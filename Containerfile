# Use CentOS Stream 9 as the base image
FROM quay.io/centos/centos:stream9

USER 0

RUN dnf -y install epel-release && \
    dnf -y update

# Install required tools and dependencies
RUN dnf install -y git make curl unzip zip which podman buildah skopeo java-11-openjdk --allowerasing

# Install Go
RUN dnf remove -y go-toolset && \
    curl -sSL https://go.dev/dl/go1.20.3.linux-amd64.tar.gz -o /tmp/go1.20.3.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf /tmp/go1.20.3.linux-amd64.tar.gz && rm /tmp/go1.20.3.linux-amd64.tar.gz

# Install Skaffold
RUN curl -sSL https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 -o /usr/local/bin/skaffold && \
    chmod +x /usr/local/bin/skaffold

# Install OpenShift oc client and completion
ENV OC_VERSION=4.6
RUN curl -L https://mirror.openshift.com/pub/openshift-v4/clients/oc/${OC_VERSION}/linux/oc.tar.gz | tar -C /usr/local/bin -xz \
    && chmod +x /usr/local/bin/oc  \
    && oc completion bash > /usr/share/bash-completion/completions/oc \
    && echo "source /usr/share/bash-completion/completions/oc" >> /home/user/.bashrc

# kubedock setup
#ENV PATH=$PATH:/usr/local/go/bin

#RUN git clone https://github.com/joyrex2001/kubedock.git && \
#    cd kubedock && \
#    make build && \
#    mv ./kubedock /usr/local/bin && \
#    chmod +x /usr/local/bin/kubedock && \
#    cd .. && rm -fr kubedock

# Install kubedock
ENV KUBEDOCK_VERSION 0.13.0
RUN curl -L https://github.com/joyrex2001/kubedock/releases/download/${KUBEDOCK_VERSION}/kubedock_${KUBEDOCK_VERSION}_linux_amd64.tar.gz | tar -C /usr/local/bin -xz \
    && chmod +x /usr/local/bin/kubedock

# Configure the podman wrapper
COPY --chown=0:0 podman-wrapper.sh /usr/bin/podman.wrapper
RUN mv /usr/bin/podman /usr/bin/podman.orig

USER 10001

CMD while [ ! -f /home/user/.kube/config ]; do sleep 1; done; kubedock server --port-forward
