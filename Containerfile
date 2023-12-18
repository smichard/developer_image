FROM registry.redhat.io/devspaces/udi-rhel8

USER 0

# Update, install packages, and clean up in one layer
RUN dnf -y update && \
    dnf -y install zsh util-linux-user && \
    dnf clean all && \
    rm -rf /var/cache/yum && \
    # Install Skaffold
    curl -sSL https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 -o /usr/local/bin/skaffold && \
    chmod +x /usr/local/bin/skaffold && \
    # Install Tekton CLI
    curl -L https://github.com/tektoncd/cli/releases/download/v0.33.0/tkn_0.33.0_Linux_x86_64.tar.gz | tar -xz -C /usr/local/bin/ tkn && \
    chmod +x /usr/local/bin/tkn && \
    # Install and configure Oh-My-ZSH
    sed -i 's#/bin/bash#/bin/zsh#g' /etc/passwd && \
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh && \
    wget -O ~/.zshrc https://gist.githubusercontent.com/smichard/bd86a05ed89a92e364e65ea3ada8e19d/raw/a3cbe29982395dd6fb3fb5d6c604385bb57a0961/my_theme.zshrc

USER 10001
