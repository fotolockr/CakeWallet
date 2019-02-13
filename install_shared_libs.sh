#!/bin/bash

SOURCE_DIR=`pwd`
SHARED_LIBS_PATH="$SOURCE_DIR/SharedExternal"
EXTERNAL_SOURCES_DIR_PATH="$SHARED_LIBS_PATH/sources"
BOOST_URL="https://github.com/fotolockr/ofxiOSBoost.git"
BOOST_DIR_PATH="$EXTERNAL_SOURCES_DIR_PATH/ofxiOSBoost"
OPEN_SSL_URL="https://github.com/x2on/OpenSSL-for-iPhone.git"
OPEN_SSL_DIR_PATH="$EXTERNAL_SOURCES_DIR_PATH/OpenSSL"
SODIUM_PATH="$EXTERNAL_SOURCES_DIR_PATH/libsodium"
SODIUM_URL="https://github.com/jedisct1/libsodium.git"
SODIUM_LIBRARY_PATH="$SODIUM_PATH/libsodium-ios/lib/libsodium.a"
SODIUM_INCLUDE_PATH="$SODIUM_PATH/libsodium-ios/include"

mkdir -p $EXTERNAL_SOURCES_DIR_PATH

if [ -z "$EXTERNAL_LIBS_PATH"]
then
  EXTERNAL_LIBS_PATH="$SHARED_LIBS_PATH/libs"
fi

EXTERNAL_BOOST_LIB_PATH="$EXTERNAL_LIBS_PATH/boost/lib"
EXTERNAL_BOOST_BUILD_LIBS_PATH="$EXTERNAL_LIBS_PATH/boost/build"
EXTERNAL_BOOST_INCLUDE_PATH="$EXTERNAL_LIBS_PATH/boost/include"
EXTERNAL_OPENSSL_LIB_PATH="$EXTERNAL_LIBS_PATH/OpenSSL/lib"
EXTERNAL_OPENSSL_INCLUDE_PATH="$EXTERNAL_LIBS_PATH/OpenSSL/include"
EXTERNAL_SODIUM_LIB_PATH="$EXTERNAL_LIBS_PATH/sodium/lib"
EXTERNAL_SODIUM_INCLUDE_PATH="$EXTERNAL_LIBS_PATH/sodium/include"

echo "============================ Init external libs ============================"
mkdir -p $EXTERNAL_SOURCES_DIR_PATH

echo "============================ Boost ============================"

echo "Cloning ofxiOSBoost from - $BOOST_URL"
git clone -b build $BOOST_URL $BOOST_DIR_PATH
cd $BOOST_DIR_PATH/scripts/
export BOOST_LIBS="random regex graph random chrono thread signals filesystem system date_time locale serialization program_options"
./build-libc++

#copy to libs directory
mkdir -p $EXTERNAL_BOOST_LIB_PATH
mkdir -p $EXTERNAL_BOOST_BUILD_LIBS_PATH
mkdir -p $EXTERNAL_BOOST_BUILD_LIBS_PATH/ios
mkdir -p $EXTERNAL_BOOST_BUILD_LIBS_PATH/libs
mkdir -p $EXTERNAL_BOOST_INCLUDE_PATH
mv $BOOST_DIR_PATH/libs/boost/ios/* $EXTERNAL_BOOST_LIB_PATH/
mv $BOOST_DIR_PATH/build/ios/prefix/lib/* $EXTERNAL_BOOST_BUILD_LIBS_PATH/ios/
mv $BOOST_DIR_PATH/build/libs/boost/lib/* $EXTERNAL_BOOST_BUILD_LIBS_PATH/libs/
mv $BOOST_DIR_PATH/libs/boost/include/* $EXTERNAL_BOOST_INCLUDE_PATH/

cd $SOURCE_DIR

echo "============================ OpenSSL ============================"

echo "Cloning Open SSL from - $OPEN_SSL_URL"
git clone $OPEN_SSL_URL $OPEN_SSL_DIR_PATH
cd $OPEN_SSL_DIR_PATH
./build-libssl.sh --version=1.0.2j --archs="x86_64 arm64 armv7s armv7" --targets="ios-sim-cross-x86_64 ios64-cross-arm64 ios-cross-armv7s ios-cross-armv7"

#copy to libs directory
mkdir -p $EXTERNAL_OPENSSL_LIB_PATH
mkdir -p $EXTERNAL_OPENSSL_INCLUDE_PATH
mv $OPEN_SSL_DIR_PATH/lib/* $EXTERNAL_OPENSSL_LIB_PATH/
mv $OPEN_SSL_DIR_PATH/include/* $EXTERNAL_OPENSSL_INCLUDE_PATH/

cd $SOURCE_DIR

echo "============================ SODIUM ============================"
echo "Cloning SODIUM from - $SODIUM_URL"
git clone $SODIUM_URL $SODIUM_PATH --branch stable
cd $SODIUM_PATH
./dist-build/ios.sh

#copy to libs directory
mkdir -p $EXTERNAL_SODIUM_LIB_PATH
mkdir -p $EXTERNAL_SODIUM_INCLUDE_PATH
mv $SODIUM_PATH/libsodium-ios/lib/* $EXTERNAL_SODIUM_LIB_PATH/
mv $SODIUM_PATH/libsodium-ios/include/* $EXTERNAL_SODIUM_INCLUDE_PATH/