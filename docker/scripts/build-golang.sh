#!/usr/bin/env bash

set -ex
mkdir -p ${CROSS_ROOT}/bootstrap
if [ ! -f "golang-bootstrap.tar.gz" ]; then
  wget -q "https://dl.google.com/go/go${GOLANG_BOOTSTRAP_VERSION}.tar.gz" -O golang-bootstrap.tar.gz
fi
echo "$GOLANG_BOOTSTRAP_SHA256  golang-bootstrap.tar.gz" | sha256sum -c -
tar -C ${CROSS_ROOT}/bootstrap -xzf golang-bootstrap.tar.gz
rm golang-bootstrap.tar.gz
cd ${CROSS_ROOT}/bootstrap/go/src
./make.bash
export GOROOT_BOOTSTRAP=${CROSS_ROOT}/bootstrap/go

cd /build
if [ ! -f "golang.tar.gz" ]; then
  wget -q "https://golang.org/dl/go${GOLANG_VERSION}.src.tar.gz" -O golang.tar.gz
fi
echo "$GOLANG_SRC_SHA256  golang.tar.gz" | sha256sum -c -
tar -C ${CROSS_ROOT} -xzf golang.tar.gz
rm golang.tar.gz
cd ${CROSS_ROOT}/go/src
./make.bash

CC_FOR_TARGET=${GOLANG_CC} \
  CXX_FOR_TARGET=${GOLANG_CXX} \
  GOOS=${GOLANG_OS} \
  GOARCH=${GOLANG_ARCH} \
  GOARM=${GOLANG_ARM} \
  CGO_ENABLED=1 \
  ./make.bash --no-clean
rm -rf ${CROSS_ROOT}/bootstrap ${CROSS_ROOT}/go/pkg/bootstrap
