#!/bin/bash

./install_shared_libs.sh
./install_lmdb.sh
cd CWMonero
./install_osx_dependencies.sh
./install_monero.sh
cd ..