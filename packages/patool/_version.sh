_pkgver() {
  curl --location --silent "https://api.github.com/repos/$_repo/tags" | jq -r '.[0].name'
}

_ver=$(_pkgver)
pkgver=${_ver//upstream\//}
