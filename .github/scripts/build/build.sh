#!/bin/bash
sudo pacman -Sy

./build-package.sh $(cat ./built_packages.txt)
