#!/bin/bash
sudo pacman -Syy
./build-package.sh $(cat ./built_packages.txt)
