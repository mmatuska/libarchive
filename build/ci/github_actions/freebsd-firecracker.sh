#!/bin/sh
BS="${BS:-autotools}"

# Remove schg flag from /
#chflags -R noschg /

# Download and extract FreeBSD base
#RELEASE=`uname -r`
#fetch -o - https://download.freebsd.org/releases/amd64/${RELEASE}/base.txz | tar -x -C / 

# Install necessary packages
pkg install -y autoconf automake cmake libiconv libtool pkgconf expat libxml2 liblz4 zstd gmake llvm19-lite || exit 1

# Remount root with POSIX.1e ACLs
mount -u -o acls /
mount

# Configure and build
env BS=${BS} CC=clang19 CPP=clang-cpp19 CXX=clang++19 MAKE=gmake CFLAGS=-I/usr/local/include LDFLAGS=-L/usr/local/lib ./build/ci/build.sh -a autogen || exit 1
env BS=${BS} CC=clang19 CPP=clang-cpp19 CXX=clang++19 MAKE=gmake CFLAGS=-I/usr/local/include LDFLAGS=-L/usr/local/lib ./build/ci/build.sh -a configure || exit 1
env BS=${BS} CC=clang19 CPP=clang-cpp19 CXX=clang++19 MAKE=gmake CFLAGS=-I/usr/local/include LDFLAGS=-L/usr/local/lib ./build/ci/build.sh -a build || exit 1

# Run tests
env BS=${BS} CC=clang19 CPP=clang-cpp19 CXX=clang++19 MAKE=gmake ./build/ci/build.sh -a test || touch /tmp/build-test.error

if [ -f /tmp/build-test.error ]
then
	cat build_ci/*/test-suite.log
	cat /tmp/libarchive_test*/*.log
	exit 1
fi

# Additional NFSv4 ACL tests"
echo "Additional NFSv4 ACL tests"

# Create tmp directory with NFSv4 ACLs
MD=`mdconfig -a -t swap -s 128M`
newfs /dev/$MD
tunefs -N enable /dev/$MD
mkdir -p /tmp_acl_nfsv4
mount /dev/$MD /tmp_acl_nfsv4
chmod 1777 /tmp_acl_nfsv4
mount

CURDIR=`pwd`
if [ "${BS}" = "cmake" ]
then
	BIN_SUBDIR="bin"
se
	BIN_SUBDIR=.
fi
BUILDDIR="${CURDIR}/build_ci/${BS}"
cd "$BUILDDIR"
TMPDIR=/tmp_acl_nfsv4 ${BIN_SUBDIR}/libarchive_test -r "${CURDIR}/libarchive/test" -v test_acl_platform_nfs4 || touch /tmp/build-test.error

if [ -f /tmp/build-test.error ]
then
	cat /tmp_acl_nfsv4/libarchive_test*/*.log
	umount /tmp_acl_nfsv4
	exit 1
fi

umount /tmp_acl_nfsv4

# Run install
env BS=${BS} MAKE=gmake ./build/ci/build.sh -a install || exit 1
