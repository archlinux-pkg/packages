FROM medzik/archlinux:latest

COPY makepkg.conf /etc/makepkg.conf

RUN pacman -Syu --noconfirm \
      base-devel \
      multilib-devel \
      git \
      wget \
      curl \
      ccache \
      python \
      pacman-contrib \
      jq \
 && yes | pacman -Scc
