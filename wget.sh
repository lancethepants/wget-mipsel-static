#!/bin/bash

set -e
set -x

mkdir ~/wget && cd ~/wget

BASE=`pwd`
SRC=$BASE/src
WGET="wget --prefer-family=IPv4"
DEST=$BASE/opt
LDFLAGS="-fPIC -L$DEST/lib -Wl,--gc-sections"
CPPFLAGS="-I$DEST/include"
CFLAGS="-fPIC -mtune=mips32 -mips32 -ffunction-sections -fdata-sections"
CXXFLAGS=$CFLAGS
CONFIGURE="./configure --prefix=/opt --host=mipsel-linux"
MAKE="make -j`nproc`"
mkdir $SRC

######## ####################################################################
# ZLIB # ####################################################################
######## ####################################################################

mkdir $SRC/zlib && cd $SRC/zlib
$WGET https://www.zlib.net/zlib-1.3.tar.gz
tar zxvf zlib-1.3.tar.gz
cd zlib-1.3

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
CROSS_PREFIX=mipsel-linux- \
./configure \
--prefix=/opt

$MAKE
make install DESTDIR=$BASE

########### #################################################################
# OPENSSL # #################################################################
########### #################################################################

mkdir -p $SRC/openssl && cd $SRC/openssl
$WGET https://www.openssl.org/source/openssl-3.2.0.tar.gz
tar zxvf openssl-3.2.0.tar.gz
cd openssl-3.2.0

./Configure linux-mips32 \
$LDFLAGS -ffunction-sections -fdata-sections -Wl,--gc-sections \
--prefix=/opt shared zlib zlib-dynamic \
--with-zlib-lib=$DEST/lib \
--with-zlib-include=$DEST/include

$MAKE CC=mipsel-linux-gcc AR=mipsel-linux-ar RANLIB=mipsel-linux-ranlib
make install CC=mipsel-linux-gcc AR=mipsel-linux-ar RANLIB=mipsel-linux-ranlib INSTALLTOP=$DEST OPENSSLDIR=$DEST/ssl

######## ####################################################################
# WGET # ####################################################################
######## ####################################################################

mkdir -p $SRC/wget && cd $SRC/wget
$WGET http://ftp.gnu.org/gnu/wget/wget-1.21.4.tar.gz
tar zxvf wget-1.21.4.tar.gz
cd wget-1.21.4

LDFLAGS=$LDFLAGS \
CPPFLAGS=$CPPFLAGS \
CFLAGS=$CFLAGS \
CXXFLAGS=$CXXFLAGS \
$CONFIGURE \
--with-ssl=openssl


$MAKE LIBS="-static -lssl -lcrypto -lz -ldl -latomic"
make install DESTDIR=$BASE/wget
