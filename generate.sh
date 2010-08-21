#!/bin/bash

# Defaults
DEFAULT_DARWIN_VER=9
DEFAULT_SDK_PREFIX_PATH=/Developer
DEFAULT_ARCHIVE_HEADERS=../libarchive
DEFAULT_ARCHIVE_STATIC_LIB=../libarchive/libarchive.a
DEFAULT_KENNYTM_PRIVATE_FRAMEWORKS=../kennytm-private-frameworks
DEFAULT_IPHONE_IP=192.168.1.69

echo "Generating Makefile for Bootlace"
echo

# Darwin Version
echo -n "Darwin Version (9 or 10) [$DEFAULT_DARWIN_VER]: "
read DARWIN_VER
if [ "$DARWIN_VER" == "" ]; then
  DARWIN_VER=$DEFAULT_DARWIN_VER
fi
echo "Set to '$DARWIN_VER'"
echo

# SDK Prefix Path
echo -n "SDK Prefix Path [$DEFAULT_SDK_PREFIX_PATH]: "
read SDK_PREFIX_PATH
if [ "$SDK_PREFIX_PATH" == "" ]; then
  SDK_PREFIX_PATH=$DEFAULT_SDK_PREFIX_PATH
fi
echo "Set to '$SDK_PREFIX_PATH'"
echo

# libarchive Headers
echo -n "libarchive Headers [$DEFAULT_ARCHIVE_HEADERS]: "
read ARCHIVE_HEADERS
if [ "$ARCHIVE_HEADERS" == "" ]; then
  ARCHIVE_HEADERS=$DEFAULT_ARCHIVE_HEADERS
fi
echo "Set to '$ARCHIVE_HEADERS'"
echo

# libarchive static library
echo -n "libarchive Static Library [$DEFAULT_ARCHIVE_STATIC_LIB]: "
read ARCHIVE_STATIC_LIB
if [ "$ARCHIVE_STATIC_LIB" == "" ]; then
  ARCHIVE_STATIC_LIB=$DEFAULT_ARCHIVE_STATIC_LIB
fi
echo "Set to '$ARCHIVE_STATIC_LIB'"
echo

# libarchive static library
echo -n "kennytm Private Frameworks [$DEFAULT_KENNYTM_PRIVATE_FRAMEWORKS]: "
read KENNYTM_PRIVATE_FRAMEWORKS
if [ "$KENNYTM_PRIVATE_FRAMEWORKS" == "" ]; then
  KENNYTM_PRIVATE_FRAMEWORKS=$DEFAULT_KENNYTM_PRIVATE_FRAMEWORKS
fi
echo "Set to '$KENNYTM_PRIVATE_FRAMEWORKS'"
echo

# iPhone IP Address
echo -n "iPhone IP Address [$DEFAULT_IPHONE_IP]: "
read IPHONE_IP
if [ "$IPHONE_IP" == "" ]; then
  IPHONE_IP=$DEFAULT_IPHONE_IP
fi
echo "Set to '$IPHONE_IP'"
echo


# Backup existing Makefile
echo "Saving Makefile to Makefile.old"
mv Makefile Makefile.old

# Create Makefile
echo "Creating Makefile"
cat Makefile.template | \
	sed -e s~%DARWIN_VER%~$DARWIN_VER~g | \
	sed -e s~%SDK_PREFIX_PATH%~$SDK_PREFIX_PATH~g | \
	sed -e s~%ARCHIVE_HEADERS%~$ARCHIVE_HEADERS~g | \
	sed -e s~%ARCHIVE_STATIC_LIB%~$ARCHIVE_STATIC_LIB~g | \
	sed -e s~%KENNYTM_PRIVATE_FRAMEWORKS%~$KENNYTM_PRIVATE_FRAMEWORKS~g | \
	sed -e s~%IPHONE_IP%~$IPHONE_IP~g > Makefile

echo
echo "To build and install, run: make clean && make && make install"
echo