#!/bin/sh
mkdir -p dist
cp -R ../contacts_manager_flutter_src/build/linux/release/* dist
tar czf dist.tar.gz dist
snapcraft --use-lxd

