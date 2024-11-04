#!/bin/sh

set -eu

mkdir -p ~/.local/bin
export PATH=~/.local/bin:"$PATH":/tmp/ghc/bin

apk upgrade --no-cache --no-interactive
apk add --no-cache --no-interactive \
  automake \
  bash \
  clang \
  curl \
  git \
  gmake \
  gmp-devel \
  gtar \
  libffi-devel \
  llvm \
  ncurses-devel \
  python

cd "$(mktemp -d)"
curl -L https://downloads.haskell.org/ghc/9.8.2/ghc-9.8.2-x86_64-alpine3_12-linux-static-int_native.tar.xz | gtar xJ --strip-components=1
./configure --prefix=/tmp/ghc
make install

curl -L https://downloads.haskell.org/cabal/cabal-install-3.12.1.0/cabal-install-3.12.1.0-x86_64-linux-alpine3_18.tar.xz | gtar xJ -C ~/.local/bin cabal
cabal update
cabal install \
  alex-3.5.1.0 \
  happy-1.20.1.1

cd "$(mktemp -d)"
git clone --ref-format=reftable --depth=1 --recurse-submodules --shallow-submodules --jobs=32 --branch=ghc-9.10 https://gitlab.haskell.org/ghc/ghc.git .
curl -L https://gitlab.haskell.org/ghc/ghc/-/commit/ae170155e82f1e5f78882f7a682d02a8e46a5823.patch | git apply
./boot
./configure --with-system-libffi
hadrian/build --flavour=release+llvm --docs=none -j binary-dist-dir

cd _build/bindist/ghc-*
./configure --prefix="$HOME/.local"
make install

rm -rf \
  ~/.cache/cabal \
  ~/.config/cabal \
  ~/.local/bin/alex \
  ~/.local/bin/happy \
  ~/.local/state/cabal \
  /tmp/*
