#!/bin/bash

SRC_PATH=`pwd`
INJECT_REAL_PATH="${SRC_PATH}/__inject_secrets.sh"

if [ -f $INJECT_REAL_PATH ]; then
    source $INJECT_REAL_PATH
fi