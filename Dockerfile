FROM ubuntu:latest

ENV HOME /home/blackdentech

# Update packages
RUN apt-get update
RUN apt-get install -y software-properties-common 
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get install -y zsh \
     wget \
     git \
     curl \
     sudo \
     vim \
     python3.8 \
     python3-pip \
     python3-venv \
     build-essential \ 
     procps \ 
     file \
     bat \
     zip \
     jq \
     snapd \
     apt-transport-https

# Link bat
RUN ln -fs /usr/bin/batcat /usr/bin/bat

# Link python3.8 > python
RUN ln -s /usr/bin/python3.8 /usr/bin/python

# Setup pre-commit hook framework
RUN curl https://pre-commit.com/install-local.py | python -

# Install pip packages
RUN pip3 install checkov

# Setup zsh and Powerline
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true \
     && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k \
     && echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc

# Install AWS CLI
RUN sudo curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
     && sudo unzip awscliv2.zip \
     && sudo ./aws/install \
     && aws --version \
     && rm awscliv2.zip \
     && echo "export AWS_CONFIG_FILE=/mnt/c/Users/BlackdenTech/.aws/config" >> ${HOME}/.zshrc \
     && echo "export AWS_SHARED_CREDENTIALS_FILE=/mnt/c/Users/BlackdenTech/.aws/credentials" >> ${HOME}/.zshrc

# Setup Terraform Tooling
RUN sudo git clone https://github.com/tfutils/tfenv.git /home/blackdentech/.tfenv \
     && sudo ln -fs "${HOME}/.tfenv/bin/tfenv" "/usr/bin/tfenv" \
     && sudo ln -fs "${HOME}/.tfenv/bin/terraform" "/usr/bin/terraform" \
     && tfenv install latest \
     && tfenv use latest 

# Setup pwsh
RUN wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb \
     && sudo dpkg -i packages-microsoft-prod.deb \
     && sudo apt-get update \
     && sudo add-apt-repository universe \
     && sudo apt-get install -y powershell

# Configure vim
RUN curl https://raw.githubusercontent.com/amix/vimrc/master/vimrcs/basic.vim -o .vimrc \
     && echo "set number" >> .vimrc  

# Install random stuff
     # rclone
RUN curl https://rclone.org/install.sh | sudo bash

# Add user
RUN useradd -ms /bin/zsh blackdentech \
     && usermod -aG sudo blackdentech \
     && sudo chown -R blackdentech /home \
     && echo blackdentech:password | chpasswd

USER blackdentech
