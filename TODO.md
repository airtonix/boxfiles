[ ] Switch on Alpine Linux vs Other types [#configure-alpine-linux] and [#configure-ubuntu-linux]
[ ] [#configure-macosx]

## Configure Alpine Linux

```console
    apk --update add \
        util-linux \
        pciutils \
        usbutils \
        coreutils \
        binutils \
        findutils \
        grep \
        shadow
```

### install buildtools

```console


$ apk --update add \
        build-base \
        gcc \
        abuild \
        binutils \
        binutils-doc \
        gcc-doc \
        cmake \
        cmake-doc \
        ccache \
        ccache-doc \
        libstdc++ \
        zsh \
        openssh \
        gnupg \
        git \
        curl \
        python3

$ pip3 install \
        pipenv


```
### When WSL

**install sudo**

```console
    apk --update add sudo
    mkdir -p /etc/sudoers.d/
    echo '%sudo ALL=(ALL) ALL' | tee /etc/sudoers.d/sudo_group
```


## Configure Ubuntu Linux

```console
apt update
    apt install -y \
        zsh \
        openssh-server \
        openssh-client \
        git \
        curl \
        python3 \
        python3-pip
    pip3 install \
        pyenv \
        pipenv
```


## Configure Macosx

**Install homebrew**

```console
$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

**Install ZSH**

```console
sudo brew install zsh
# allow the brew installed shell
cat $(which zsh) | tee /etc/shells
settings
```
