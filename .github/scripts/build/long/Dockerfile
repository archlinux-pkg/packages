FROM ghcr.io/archlinux-pkg/packages:latest

ARG PACKAGE

ENV PACKAGE=$PACKAGE

COPY packages/$PACKAGE/PKGBUILD /home/build

RUN pacman -Syu --noconfirm && \
    su -c 'cd && makepkg --nobuild --noextract --syncdeps --noconfirm' build

COPY .github/scripts/build/long/build.sh /home/build/build.sh

# ? Expect archive with files required for building created by makepkg --allsource
COPY *.src.tar.gz /home/build/

RUN chown -R build /home/build
RUN tar xf /home/build/*.src.tar.gz -C /home/build --strip 1 && rm /home/build/*.src.tar.gz

RUN ls -lah /home/build

USER build

RUN cd /home/build

ENTRYPOINT [ "/bin/bash", "/home/build/build.sh" ]
