#!/bin/bash

#make sure deps are up to date
rm -fr node_modules packages/*/node_modules
npm install

# get current version
VERSION=$(node --eval "console.log(require('./packages/pouchdb/package.json').version);")

# Build
git checkout -b build

# Publish all modules with Lerna
for pkg in $(ls packages); do
  if [ ! -d "packages/$pkg" ]; then
    continue
  elif [ "true" = $(node --eval "console.log(require('./packages/$pkg/package.json').private);") ]; then
    continue
  fi
  cd packages/$pkg
  echo "Publishing $pkg..."
  npm publish
  cd ../..
done

# Create git tag, which is also the Bower/Github release
rm -fr lib src dist bower.json component.json package.json
cp -r packages/pouchdb/{src,lib,dist,bower.json,component.json,package.json} .
git add -f lib src dist bower.json component.json package.json lerna.json
git rm -fr packages bin docs scripts tests

git commit -m "build $VERSION"

# Tag and push
git tag $VERSION
git push --tags git@github.com:pouchdb/pouchdb.git $VERSION

# Cleanup
git checkout master
git branch -D build
