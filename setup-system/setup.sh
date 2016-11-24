# Update local package directory
apt-get -y update

# Update to the latest of all packages
apt-get -y dist-upgrade

# Install packages for general use and dev
apt-get -y install \
  build-essential \
  libncurses5-dev \
  xauth \
  mosh \
  curl \
  zsh \
  tmux \
  git \
  make \
  direnv \
  tig \
  jq \
  liblua5.1-dev \
  libluajit-5.1

# Install Vim Latest
apt-get remove \
  vim \
  vim-runtime \
  gvim \
  vim-tiny \
  vim-common \
  vim-gui-common \
  vim-nox
git clone https://github.com/vim/vim.git
cd vim
./configure \
  --with-features=huge \
  --enable-cscope \
  --enable-luainterp \
  --with-luajit \
  --with-lua-prefix=/usr/include/lua5.1
make
make install
cd -
rm -fR vim

# Install any custom files
cp -R all/* /

# Install optionals
if test "${FEATURES#*go}" != "$FEATURES"
then
  ./install-go.sh
fi
if test "${FEATURES#*swift}" != "$FEATURES"
then
  ./install-swift.sh
fi
if test "${FEATURES#*ruby}" != "$FEATURES"
then
  ./install-ruby.sh
fi
if test "${FEATURES#*rust}" != "$FEATURES"
then
  ./install-rust.sh
fi
if test "${FEATURES#*gcloud}" != "$FEATURES"
then
  ./install-gcloud.sh
fi
if test "${FEATURES#*awscli}" != "$FEATURES"
then
  ./install-awscli.sh
fi

# Set the script that will be executed when new users are added
cp -R all/* /
cp -R ../setup-user /usr/local/sbin/adduser

# Disable root login
passwd -l root
