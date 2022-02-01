FROM medzik/archlinux:latest

COPY makepkg.conf /etc/makepkg.conf

RUN sudo pacman -Syu --noconfirm \
      base-devel \
      multilib-devel \
      git \
      wget \
      curl \
      pacman-contrib \
      ccache \
      python \
 && yes | sudo pacman -Scc
