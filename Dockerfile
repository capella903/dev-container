FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install base packages
RUN \
  apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    jq \
    lsb-release \
    git \
    software-properties-common \
    sudo \
    tig \
    tree \
    wget \
    unzip \
    zsh \
  && rm -rf /var/lib/apt/lists/*

# Install Docker
RUN \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
  && echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
  && apt-get update && apt-get install -y \
    docker-ce-cli \
  && rm -rf /var/lib/apt/lists/*

# Install Neovim
RUN \
  add-apt-repository ppa:neovim-ppa/stable \
  && apt-get update && apt-get install -y \
    neovim \
    python3-dev \
    python3-pip \
  && rm -rf /var/lib/apt/lists/* \
  && pip3 install --upgrade pynvim

# Install fzf
RUN \
  git clone --depth 1 https://github.com/junegunn/fzf.git /opt/fzf \
  && /opt/fzf/install --bin \
  && ln -s /opt/fzf/bin/fzf /usr/local/bin/

# Install ghq
RUN \
  curl -o /tmp/ghq_linux_amd64.zip -L https://github.com/x-motemen/ghq/releases/download/v1.2.1/ghq_linux_amd64.zip \
  && unzip /tmp/ghq_linux_amd64.zip -d /tmp \
  && mv /tmp/ghq_linux_amd64 /opt/ghq \
  && ln -s /opt/ghq/ghq /usr/local/bin/ \
  && rm -f /tmp/ghq_linux_amd64.zip

# Create the user
ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN \
  groupadd --gid $USER_GID $USERNAME \
  && useradd --uid $USER_UID --gid $USER_GID --shell /bin/bash --create-home $USERNAME \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  && mkdir /workspace \
  && chown $USERNAME:$USERNAME /workspace

USER $USERNAME

RUN \
  /opt/fzf/install --all --xdg
