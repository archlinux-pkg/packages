#!/bin/bash
set -e

echo "::group::Generating source archive..."

ROOT_DIR=$(pwd)

sudo chown build -R .

PACKAGE="$(cat $ROOT_DIR/built_packages.txt)"

pkgdir="$ROOT_DIR/long-build/$PACKAGE"

# install yaml parser
wget https://github.com/mikefarah/yq/releases/download/v4.24.2/yq_linux_amd64 -O /tmp/yq
chmod +x /tmp/yq

if [ ! -f "$pkgdir/PKGBUILD" ]
then
  git_repo=$(/tmp/yq '.aur.name' "$pkgdir/auto-update.yaml")
  git_repo="https://aur.archlinux.org/$git_repo.git"
  commit=$(/tmp/yq '.aur.commit' "$pkgdir/auto-update.yaml")

  eval "${custom_vars}"

  mv "${pkgdir}" "${pkgdir}.old"

  git clone "${git_repo}" "${pkgdir}"

  cd "${pkgdir}"

  git reset --hard ${commit}

  code=$?

  if [ "$code" != 0 ]
  then
    echo "exit code: $code"
    exit $code
  fi
fi

cd "$pkgdir"

sudo chown build -R .

# Generate archive with all required sources for the build
# This either includes local or downloads files using an url
su -c "makepkg --allsource --skippgpcheck" build
mv ./*.src.tar.gz $ROOT_DIR
cd $ROOT_DIR

echo "::endgroup::"

VERSION="$(compgen -G "*.src.tar.gz" | grep -Po '([\d\.]+-\d*)')"
NAME="packages"
ID="$(echo "$REGISTRY"/$NAME | tr '[A-Z]' '[a-z]')"
REF="$(echo "$GH_REF" | sed -e 's,.*/\(.*\),\1,')"
[[ "$GH_REF" == "refs/tags/"* ]] && REF=$(echo $REF | sed -e 's/^v//')
[ "$REF" == "master" ] && REF=latest
VERSION_TAG="$ID:$PACKAGE-$VERSION-$(date +%s)"

echo "VERSION=$VERSION"
echo "REGISTRY=$REGISTRY"
echo "NAME=$NAME"
echo "ID=$ID"
echo "REF=$REF"
echo "VERSION_TAG=$VERSION_TAG"

echo "::group::Building container image..."

# Build container from source files
docker build . \
  --file .github/scripts/build/long/Dockerfile \
  --build-arg PACKAGE="$PACKAGE" \
  --tag "$VERSION_TAG" \

# Reduce worker space used
rm -rf ./*

echo "::endgroup::"

echo "::set-output name=version-tag::$VERSION_TAG"
