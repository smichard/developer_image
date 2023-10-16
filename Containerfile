FROM quay.io/devfile/universal-developer-image:ubi8-latest

USER 0

#ENV KUBEDOCK_VERSION 0.9.3

#RUN curl -L https://github.com/joyrex2001/kubedock/releases/download/${KUBEDOCK_VERSION}/kubedock_${KUBEDOCK_VERSION}_linux_amd64.tar.gz | tar -C /usr/local/bin -xz \
#    && chmod +x /usr/local/bin/kubedock

RUN dnf remove -y go-toolset && \
    curl -sSL https://go.dev/dl/go1.20.3.linux-amd64.tar.gz -o /tmp/go1.20.3.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf /tmp/go1.20.3.linux-amd64.tar.gz && rm /tmp/go1.20.3.linux-amd64.tar.gz

ENV PATH=$PATH:/usr/local/go/bin

RUN git clone https://github.com/joyrex2001/kubedock.git && \
    cd kubedock && \
    make build && \
    mv ./kubedock /usr/local/bin && \
    chmod +x /usr/local/bin/kubedock && \
    cd .. && rm -fr kubedock

USER 10001

RUN source $HOME/.sdkman/bin/sdkman-init.sh && sdk default java 17.0.3-tem

CMD while [ ! -f /home/user/.kube/config ]; do sleep 1; done; kubedock server --port-forward