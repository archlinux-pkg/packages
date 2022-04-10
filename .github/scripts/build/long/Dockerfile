# https://github.com/ungoogled-software/ungoogled-chromium-archlinux/blob/6951233c1f35bd2932115cef95a919f0f58152a6/.github/workflows/container/Dockerfile
FROM ghcr.io/archlinux-pkg/packages:latest

ARG PACKAGE
ENV PACKAGE=$PACKAGE

COPY .github/scripts/build/long/build.sh /home/build/build.sh

# Expect archive with files required for building created by makepkg --allsource
COPY *.src.tar.gz /home/build/

RUN chown -R build /home/build
RUN tar xf /home/build/*.src.tar.gz -C /home/build --strip 1 && rm /home/build/*.src.tar.gz

RUN pacman -Sy && \
    su -c "cd && makepkg --nobuild --noextract --syncdeps --noconfirm" build && \
    su -c "cd && makepkg --nobuild --noextract --syncdeps --noconfirm" build && \
    su -c "cd && makepkg --nobuild --noextract --syncdeps --noconfirm" build

RUN ls -lah /home/build

RUN echo $(date +"%s") > /etc/buildtime

USER build

ENTRYPOINT [ "/bin/bash", "/home/build/build.sh" ]
