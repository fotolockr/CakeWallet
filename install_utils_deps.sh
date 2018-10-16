#!/bin/bash

SOURCE_DIR=`pwd`
EXTERNAL_DIR_PATH="$SOURCE_DIR/External"
BOOST_URL="https://github.com/fotolockr/ofxiOSBoost.git"
BOOST_DIR_PATH="$EXTERNAL_DIR_PATH/ofxiOSBoost"
OPEN_SSL_URL="https://github.com/x2on/OpenSSL-for-iPhone.git"
OPEN_SSL_DIR_PATH="$EXTERNAL_DIR_PATH/OpenSSL"
LMDB_DIR_URL="https://github.com/LMDB/lmdb.git"
LMDB_DIR_PATH="lmdb/Sources"

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

echo "============================ OpenSSL ============================"
echo "Cloning lmdb from - $LMDB_DIR_URL"
git clone $LMDB_DIR_URL $LMDB_DIR_PATH
cd $LMDB_DIR_PATH
git checkout b9495245b4b96ad6698849e1c1c816c346f27c3c
cd $SOURCE_DIR