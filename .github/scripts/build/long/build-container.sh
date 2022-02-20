#!/bin/bash

echo "::group::Generating source archive..."

sudo chown build -R .

cd long-build/ungoogled-chromium

# Generate archive with all required sources for the build
# This either includes local or downloads files using an url
su -c "makepkg --allsource" build
mv ./*.src.tar.gz ../..
cd ../..

echo "::endgroup::"

VERSION="$(compgen -G "*.src.tar.gz" | grep -Po '([\d\.]+-\d*)')"
NAME="packages"
ID="$(echo "$REGISTRY"/$NAME | tr '[A-Z]' '[a-z]')"
REF="$(echo "$GH_REF" | sed -e 's,.*/\(.*\),\1,')"
[[ "$GH_REF" == "refs/tags/"* ]] && REF=$(echo $REF | sed -e 's/^v//')
[ "$REF" == "master" ] && REF=latest
VERSION_TAG="$ID:ungoogled-chromium-$VERSION-$(date +%s)"

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
  --build-arg PACKAGE=ungoogled-chromium \
  --tag "$VERSION_TAG" \

# Reduce worker space used
rm -rf ./*

echo "::endgroup::"

echo "::set-output name=version-tag::$VERSION_TAG"
