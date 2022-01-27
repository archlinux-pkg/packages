FROM ghcr.io/archlinux-pkg/packages:latest

COPY packages/rare/PKGBUILD /home/build

RUN sudo -u build bash -c "cd && makepkg --nobuild --noextract --syncdeps --noconfirm"

COPY .github/workflows/container/run.sh /home/build/run.sh

# Expect archive with files required for building created by makepkg --allsource
COPY *.src.tar.gz /home/build/
RUN chown -R build /home/build
RUN tar xf /home/build/*.src.tar.gz -C /home/build --strip 1 && rm /home/build/*.src.tar.gz

RUN echo $(date +"%s") > /etc/buildtime

RUN ls -lah /home/build

USER build

ENTRYPOINT [ "/bin/bash", "/home/build/run.sh" ]
