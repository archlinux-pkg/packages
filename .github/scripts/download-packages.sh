#!/bin/bash

gh release download --repo archlinux-pkg/packages --pattern 'medzikuser.*' --dir packages

gh release download --repo archlinux-pkg/packages queue --pattern '*' --dir queue
gh release delete --repo archlinux-pkg/packages queue --yes
#gh release create --repo archlinux-pkg/packages queue --notes "packages queue" --prerelease

echo
