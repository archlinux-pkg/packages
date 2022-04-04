FROM medzik/archlinux:latest

COPY makepkg.conf /etc/makepkg.conf

RUN pacman -Syu --noconfirm \
      jq \
      git \
      wget \
      curl \
      perl \
      rsync \
      linux \
      ccache \
      python \
      sshpass \
      base-devel \
      multilib-devel \
      pacman-contrib \
 && yes | pacman -Scc

# fix: pod2man: command not found
RUN ln -s /usr/bin/core_perl/pod2man "/usr/bin/pod2man"
