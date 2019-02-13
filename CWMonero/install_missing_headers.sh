#!/bin/bash

echo "Installing missing headers"

# vmmeter
mkdir -p /usr/local/include/sys

if [ ! -f /usr/local/include/sys/vmmeter.h ]; then
  ln -s /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/sys/vmmeter.h /usr/local/include/sys/vmmeter.h
fi

# netinet
mkdir -p /usr/local/include/netinet
if [ ! -f /usr/local/include/netinet/ip_var.h ]; then
  ln -s /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/netinet/ip_var.h /usr/local/include/netinet/ip_var.h
fi

if [ ! -f /usr/local/include/netinet/udp_var.h ]; then
  ln -s /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/netinet/udp_var.h /usr/local/include/netinet/udp_var.h
fi

# IOKit
mkdir -p /usr/local/include/IOKit
if [ ! -f /usr/local/include/IOKit/IOTypes.h ]; then
  ln -s /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/IOKit.framework/Versions/A/Headers/IOTypes.h  /usr/local/include/IOKit/IOTypes.h
fi

if [ ! -f /usr/local/include/IOKit/IOKitLib.h ]; then
  ln -s /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/IOKit.framework/Versions/A/Headers/IOKitLib.h /usr/local/include/IOKit/IOKitLib.h
fi

if [ ! -f /usr/local/include/IOKit/IOReturn.h ]; then
  ln -s /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/IOKit.framework/Versions/A/Headers/IOReturn.h /usr/local/include/IOKit/IOReturn.h
fi

if [ ! -f /usr/local/include/IOKit/OSMessageNotification.h ]; then
  ln -s /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/IOKit.framework/Versions/A/Headers/OSMessageNotification.h  /usr/local/include/IOKit/OSMessageNotification.h
fi

# IOKit/ps
mkdir -p /usr/local/include/IOKit/ps

if [ ! -f /usr/local/include/IOKit/ps/IOPSKeys.h ]; then
  ln -s /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/IOKit.framework/Versions/A/Headers/ps/IOPSKeys.h /usr/local/include/IOKit/ps/IOPSKeys.h
fi

if [ ! -f /usr/local/include/IOKit/ps/IOPowerSources.h ]; then
  ln -s /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/IOKit.framework/Versions/A/Headers/ps/IOPowerSources.h /usr/local/include/IOKit/ps/IOPowerSources.h
fi


# libkern
mkdir -p /usr/local/include/libkern

if [ ! -f /usr/local/include/libkern/OSTypes.h ]; then
  ln -s /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/libkern/OSTypes.h /usr/local/include/libkern/OSTypes.h
fi

if [ ! -f /usr/local/include/IOKit/IOKitKeys.h ]; then
  ln -s /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/IOKit.framework/Versions/A/Headers/IOKitKeys.h /usr/local/include/IOKit/IOKitKeys.h
fi
