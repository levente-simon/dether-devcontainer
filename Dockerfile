FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PNPM_HOME="/usr/local/share/pnpm"
ENV PATH="${PNPM_HOME}:${PATH}"

# Update and install base packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    curl \
    git \
    zsh \
    tmux \
    build-essential \
    neovim \
    nodejs \
    npm \
    sudo \
    python3-pip \
    python3 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm

# Set up Zsh and Oh My Zsh globally
RUN echo Y | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    cp -rp /root/.oh-my-zsh /etc/skel/


RUN cp /root/.zshrc /etc/skel/.zshrc && \
    sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' /etc/skel/.zshrc

RUN mkdir -p /etc/skel/.config && \
    git clone https://github.com/github/copilot.vim.git /etc/skel/.config/nvim/pack/github/start/copilot.vim

# Copy tmux config for all users
COPY tmux.conf /etc/skel/.tmux.conf
COPY zshrc /etc/skel/.zshrc

# Add non-root user and set permissions
RUN useradd -m dether -s $(which zsh) && \
    mkdir -p /workspaces && \
    chown -R dether:dether /workspaces && \
    mkdir -p /etc/sudoers.d && \
    echo "dether ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/dether && \
    chmod 0440 /etc/sudoers.d/dether

# Switch to non-root user
USER dether
WORKDIR /workspaces
