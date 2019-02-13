#!/bin/bash

SOURCE_DIR=`pwd`
EXTERNAL_DIR_PATH="$SOURCE_DIR/../SharedExternal"
CPPZMQ_SOURCES_PATH="$EXTERNAL_DIR_PATH/cppzmq"
CPPZMQ_HEADER_FILE="zmq.hpp"
CPPZMQ_HEADER_PATH="/usr/local/include/$CPPZMQ_HEADER_FILE"

function install_brew_package {
  if brew ls --versions $1 > /dev/null; then 
    echo "$1 is already installed!"
  else
    echo "Installing $1"
    brew install $1
  fi
}

if [[ "$OSTYPE" == "darwin"* ]]; then
  # Check if brew is installed

  install_brew_package "cmake"
  install_brew_package "pkg-config"

  if [ ! -f $CPPZMQ_HEADER_PATH ]; then
      echo "File not found!"
  
    if [ ! -d $CPPZMQ_SOURCES_PATH ]; then
      echo "Installing zeromq"
      git clone https://github.com/zeromq/cppzmq $CPPZMQ_SOURCES_PATH
    fi

    cp $CPPZMQ_SOURCES_PATH/$CPPZMQ_HEADER_FILE $CPPZMQ_HEADER_PATH
  fi
 
  ./install_missing_headers.sh
fi
