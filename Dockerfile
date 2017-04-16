FROM ubuntu:17.04
MAINTAINER Vytautas Astrauskas "vastrauskas@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

# Install needed tools.
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y \
        software-properties-common \
        unzip \
        wget \
        curl \
        gdebi-core \
        git \
        build-essential \
        python \
        tmux \
        sudo \
        fish \
        xonsh \
        python3-pip \
        man-db \
        locales \
        vim \
    && \
    pip3 install xonsh-apt-tabcomplete xonsh-docker-tabcomplete && \
    apt-get clean

# Set locale.
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV USER_ID 1000
RUN echo "developer:x:${USER_ID}:${USER_ID}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${USER_ID}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown root:root /usr/bin/sudo && \
    chmod 4755 /usr/bin/sudo && \
    mkdir -p /home/developer && \
    mkdir -p /home/developer/.config/xonsh && \
    echo '{ "xontribs": [ "apt_tabcomplete", "docker_tabcomplete", "mpl", "prompt_ret_code" ] }' > \
      /home/developer/.config/xonsh/config.json && \
    echo '$XONSH_COLOR_STYLE="native"' >> /home/developer/.xonshrc && \
    chown developer:developer -R /home/developer

WORKDIR /home/developer
USER developer

RUN git clone --recursive https://github.com/vakaras/dotfiles.git /home/developer/.dotfiles 

RUN cd /home/developer/.dotfiles/ && \
    sed -e 's/^setup_gitconfig$//g' -i script/bootstrap && \
    sed -e "s/AUTHORNAME/Vytautas Astrauskas/g" \
        -e "s/AUTHOREMAIL/vastrauskas@gmail.com/g" \
        -e "s/GIT_CREDENTIAL_HELPER/cache/g" \
        git/gitconfig.symlink.example > git/gitconfig.symlink && \
    bash script/bootstrap && \
    sed -e 's/status-bg green/status-bg black/g' -i tmux/tmux.conf.symlink && \
    sed -e 's/status-fg black/status-fg white/g' -i tmux/tmux.conf.symlink && \
    sed -e 's/prefix C-a/prefix C-s/g' -i tmux/tmux.conf.symlink && \
    mkdir -p /home/developer/.config/fish && \
    echo 'fish_vi_key_bindings' > /home/developer/.config/fish/config.fish && \
    echo 'set PATH "$HOME/.cargo/bin" $PATH' >> /home/developer/.config/fish/config.fish && \
    echo 'set PATH "$HOME/.dotfiles/bin" $PATH' >> /home/developer/.config/fish/config.fish

RUN cd /tmp && \
    curl https://sh.rustup.rs -sSf > rustup.sh && \
    sh ./rustup.sh -y && \
    rm -rf /tmp/*
