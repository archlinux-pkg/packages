#!/bin/bash

sudo chown -R build /home/archlinux-pkg

cd /home/archlinux-pkg

./build-package.sh $(cat ./built_packages.txt)
