#!/bin/bash

SOURCE_DIR=`pwd`
EXTERNAL_DIR_PATH="$SOURCE_DIR/External"
BOOST_URL="https://github.com/fotolockr/ofxiOSBoost.git"
BOOST_DIR_PATH="$EXTERNAL_DIR_PATH/ofxiOSBoost"
OPEN_SSL_URL="https://github.com/x2on/OpenSSL-for-iPhone.git"
OPEN_SSL_DIR_PATH="$EXTERNAL_DIR_PATH/OpenSSL"
MONERO_CORE_URL="https://github.com/fotolockr/monero-gui.git"
MONERO_CORE_DIR_PATH="$EXTERNAL_DIR_PATH/monero-gui"
MONERO_URL="https://github.com/fotolockr/monero.git"
MONERO_DIR_PATH="$MONERO_CORE_DIR_PATH/monero"

echo "Init external libs."
mkdir -p $EXTERNAL_DIR_PATH

echo "============================ Boost ============================"

echo "Cloning ofxiOSBoost from - $BOOST_URL"
git clone -b build $BOOST_URL $BOOST_DIR_PATH
cd $BOOST_DIR_PATH/scripts/
export BOOST_LIBS="random regex graph random chrono thread signals filesystem system date_time locale serialization program_options"
./build-libc++
cd $SOURCE_DIR

echo "============================ OpenSSL ============================"

echo "Cloning Open SSL from - $OPEN_SSL_URL"
git clone $OPEN_SSL_URL $OPEN_SSL_DIR_PATH
cd $OPEN_SSL_DIR_PATH
./build-libssl.sh --version=1.0.2j
cd $SOURCE_DIR

echo "============================ Monero-gui ============================"

echo "Cloning monero-gui from - $MONERO_CORE_URL"
git clone -b build $MONERO_CORE_URL $MONERO_CORE_DIR_PATH
cd $MONERO_CORE_DIR_PATH
echo "Cloning monero from - $MONERO_URL to - $MONERO_DIR_PATH"
git clone -b build $MONERO_URL $MONERO_DIR_PATH
echo "Export Boost vars"
export BOOST_LIBRARYDIR="`pwd`/../ofxiOSBoost/build/ios/prefix/lib"
export BOOST_INCLUDEDIR="`pwd`/../ofxiOSBoost/build/ios/prefix/include"
echo "Export OpenSSL vars"
export OPENSSL_INCLUDE_DIR="`pwd`/../OpenSSL/include"
export OPENSSL_ROOT_DIR="`pwd`/../OpenSSL/lib"
mkdir -p monero/build
./ios_get_libwallet.api.sh

