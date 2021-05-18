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
    zsh \
  && rm -rf /var/lib/apt/lists/*

# Install Docker
RUN \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
  && echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
  && apt-get update && apt-get install -y \
    docker-ce docker-ce-cli containerd.io \
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
