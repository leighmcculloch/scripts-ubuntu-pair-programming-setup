FROM debian:buster

RUN apt-get update \
  && apt-get -y install \
    procps \
    locales \
    curl \
    zsh \
    tmux \
    git \
    make \
    tig \
    tree \
    jq \
    gcc \
    sudo \
    man \
    vim-nox \
  && apt-get -y autoremove \
  && apt-get -y clean

# locale with utf8
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# add user
ARG USER=leighmcculloch
RUN adduser --home /home/$USER --disabled-password --gecos GECOS $USER \
  && echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
  && chmod 0440 /etc/sudoers.d/$USER \
  && groupadd docker \
  && usermod -aG docker $USER \
  && chsh -s /bin/zsh $USER
USER $USER
ENV HOME=/home/$USER

# directory for projects
ENV DEVEL="$HOME/devel"
ENV LOCAL="$HOME/local"
ENV LOCAL_BIN="$LOCAL/bin"
ENV PATH="$PATH:$LOCAL_BIN"
RUN mkdir -p "$LOCAL_BIN" \
  && mkdir -p "$DEVEL"

# vim latest
RUN git clone https://github.com/leighmcculloch/vim-compile $DEVEL/vim-compile \
  && cd $DEVEL/vim-compile \
  && git remote set-url origin github:leighmcculloch/vim-compile \
  && git clone https://github.com/vim/vim $DEVEL/vim \
  && cd $DEVEL/vim \
  && sudo $DEVEL/vim-compile/install-debian.sh $LOCAL

# ssh files
RUN mkdir $HOME/.ssh
RUN ln -s $HOME/devel/devenv/dotfiles/ssh/config $HOME/.ssh/config \
  && ln -s $HOME/devel/devenv/dotfiles/ssh/known_hosts $HOME/.ssh/known_hosts

# dotfiles
RUN ln -s $HOME/devel/devenv/dotfiles/zshenv $HOME/.zshenv \
  && ln -s $HOME/devel/devenv/dotfiles/zshrc $HOME/.zshrc \
  && ln -s $HOME/devel/devenv/dotfiles/gitconfig $HOME/.gitconfig \
  && ln -s $HOME/devel/devenv/dotfiles/gitignore_global $HOME/.gitignore_global \
  && ln -s $HOME/devel/devenv/dotfiles/gitmessage $HOME/.gitmessage

# oh-my-zsh
RUN git clone https://github.com/robbyrussell/oh-my-zsh $HOME/.oh-my-zsh \
  && mkdir -p $HOME/.oh-my-zsh/custom/themes \
  && curl https://raw.githubusercontent.com/leighmcculloch/zsh-theme-enormous/master/enormous.zsh-theme > $HOME/.oh-my-zsh/custom/themes/enormous.zsh-theme

# tmux dot files
RUN git clone --recursive https://github.com/leighmcculloch/tmux_dotfiles $DEVEL/tmux_dotfiles \
  && cd $DEVEL/tmux_dotfiles \
  && git remote set-url origin github:leighmcculloch/tmux_dotfiles \
  && make install

# vim dot files
RUN git clone https://github.com/leighmcculloch/vim_dotfiles $DEVEL/vim_dotfiles \
  && cd $DEVEL/vim_dotfiles \
  && git remote set-url origin github:leighmcculloch/vim_dotfiles \
  && make install

# working directory
WORKDIR $DEVEL

# shell
SHELL ["/bin/zsh", "--login", "-c"]

# basic setup
#COPY . $DEVEL/devenv
#RUN $HOME/devel/devenv/lazybin/rvm install ruby
#RUN $HOME/devel/devenv/lazybin/go version
#RUN go get github.com/go-delve/delve/cmd/dlv \
#  && go get golang.org/x/tools/cmd/gopls

# tmux
ENTRYPOINT tmux -2 new
