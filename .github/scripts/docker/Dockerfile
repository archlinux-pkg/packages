FROM medzik/archlinux:latest

COPY makepkg.conf /etc/makepkg.conf

RUN pacman -Syyu --noconfirm \
      base-devel \
      multilib-devel \
      git \
      wget \
      curl \
      ccache \
      python \
      pacman-contrib \
      jq \
      sshpass \
 && yes | pacman -Scc
