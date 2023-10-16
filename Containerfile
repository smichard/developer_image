# Use CentOS Stream 9 as the base image
FROM quay.io/centos/centos:stream9

USER 0

RUN dnf -y install epel-release && \
    dnf -y update

# Install required tools and dependencies
RUN dnf install -y git make curl unzip zip which podman buildah skopeo --allowerasing

# Install Java using dnf
RUN dnf install -y java-11-openjdk

# Install Go
RUN curl -sSL https://go.dev/dl/go1.20.3.linux-amd64.tar.gz -o /tmp/go1.20.3.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf /tmp/go1.20.3.linux-amd64.tar.gz && rm /tmp/go1.20.3.linux-amd64.tar.gz

# Install Terraform
RUN curl -sSL https://releases.hashicorp.com/terraform/1.1.2/terraform_1.1.2_linux_amd64.zip -o /tmp/terraform.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    rm /tmp/terraform.zip

# Install Skaffold
RUN curl -sSL https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 -o /usr/local/bin/skaffold && \
    chmod +x /usr/local/bin/skaffold

# Install OpenShift CLI (oc) and kubectl
RUN curl -sSL https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz -o /tmp/oc.tar.gz && \
    tar -C /usr/local/bin -xzf /tmp/oc.tar.gz oc kubectl && \
    rm /tmp/oc.tar.gz

# kubedock setup
ENV PATH=$PATH:/usr/local/go/bin

RUN git clone https://github.com/joyrex2001/kubedock.git && \
    cd kubedock && \
    make build && \
    mv ./kubedock /usr/local/bin && \
    chmod +x /usr/local/bin/kubedock && \
    cd .. && rm -fr kubedock

USER 10001

CMD while [ ! -f /home/user/.kube/config ]; do sleep 1; done; kubedock server --port-forward
