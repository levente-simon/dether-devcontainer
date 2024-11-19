# Use Ubuntu base image
FROM ubuntu:24.04

# Set up environment variables
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
    python3-pip \
    python3 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm

# Set up Zsh and Oh My Zsh
RUN curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | zsh || true && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc

# Set Zsh as the default shell
RUN chsh -s $(which zsh)

# Copy custom tmux config
COPY tmux.conf /root/.tmux.conf

# Install Neovim plugins
RUN mkdir -p ~/.config/nvim && \
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    echo 'call plug#begin("~/.vim/plugged")\n\
Plug "neovim/nvim-lspconfig"\n\
Plug "hrsh7th/nvim-compe"\n\
Plug "github/copilot.vim"\n\
call plug#end()' > ~/.config/nvim/init.vim

# Create a non-root user (for better permissions)
RUN useradd -m dether && \
    echo "dether ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/dether && \
    chmod 0440 /etc/sudoers.d/dether

USER dether
WORKDIR /workspaces
