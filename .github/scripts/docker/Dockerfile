FROM medzik/archlinux:latest

COPY makepkg.conf /etc/makepkg.conf

RUN sudo pacman -Syu --noconfirm \
 && yes | sudo pacman -Scc
