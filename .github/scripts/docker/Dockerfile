FROM medzik/archlinux:latest

COPY makepkg.conf /etc/makepkg.conf

RUN pacman -Syu --noconfirm \
      jq \
      git \
      wget \
      curl \
      rsync \
      go-yq \
      linux \
      ccache \
      python \
      sshpass \
      base-devel \
      multilib-devel \
      pacman-contrib \
 && yes | pacman -Scc
