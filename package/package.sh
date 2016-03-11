#!/usr/bin/env bash

#############################
# CONFIGURATION
#############################

BUILD_TARGET=${1:-none}

## Do we want to create a final archive
ARCHIVE_FOR_DISTRIBUTION=1

#############################
# Actual build script
#############################

if [ "$BUILD_TARGET" = "none" ]; then
	echo "You need to specify a build target with:"
	echo "$0 debian_i386"
	echo "$0 debian_amd64"
	exit 0
fi

MAKE=make

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

TAR=tar

OCE_MAJOR_VERSION=`grep "set(OCE_VERSION_MAJOR" ../CMakeLists.txt | cut -d ' ' -f2 | sed 's/)//'`
OCE_MINOR_VERSION=`grep "set(OCE_VERSION_MINOR" ../CMakeLists.txt | cut -d ' ' -f2 | sed 's/)//'`
OCE_PATCH_VERSION=`grep "set(OCE_VERSION_PATCH" ../CMakeLists.txt | cut -d ' ' -f2 | sed 's/)//'`

# Actually for PATCH version the following is implemented:
OCE_PATCH_VERSION=`git rev-list HEAD | wc -l | sed -e 's/ *//g' | xargs -n1 printf %04d`

FULL_VERSION=${OCE_MAJOR_VERSION}.${OCE_MINOR_VERSION}.${OCE_PATCH_VERSION}

echo "Trying to build OpenCASCADE $FULL_VERSION "
echo $FULL_VERSION > BUILD_VERSION

#############################
# Debian .deb
#############################
if [[ "$BUILD_TARGET" = "debian_i386" || "$BUILD_TARGET" = "debian_amd64" ]]; then
	BUILD_DIR="$SCRIPT_DIR/build"
	TARGET_DIR="$SCRIPT_DIR/target"
	BUILD_ARCH="Unknown"
	if [ "$BUILD_TARGET" = "debian_i386" ]; then
		BUILD_ARCH="i386"
	else
		BUILD_ARCH="amd64"
	fi

	echo "Building OpenCASCADE in $BUILD_DIR"
#	rm -Rf $BUILD_DIR
	mkdir -p $BUILD_DIR


# Now the configs that is standard:
# -DOCE_WITH_FREEIMAGE=OFF \
# -DOCE_WITH_GL2PS=OFF \
	cd $BUILD_DIR
	cmake	-DCMAKE_INSTALL_PREFIX:PATH=/usr/local \
		-DOCE_INSTALL_PREFIX:PATH=/usr \
		-DCMAKE_BUILD_TYPE=Debug \
		-DOCE_VISUALISATION=ON \
		-DOCE_DATAEXCHANGE=ON \
		-DOCE_MULTITHREAD_LIBRARY=TBB \
		../..
	if [ $? != 0 ]; then echo "Failed to configure OpenCASCADE"; exit 1; fi
	$MAKE -j3
	if [ $? != 0 ]; then echo "Failed to Make OpenCASCADE"; exit 1; fi
	echo "Installing OpenCASCADE to  $TARGET_DIR"
	rm -Rf $TARGET_DIR
	mkdir -p $TARGET_DIR
# Installing
	$MAKE DESTDIR=$TARGET_DIR install
	if [ $? != 0 ]; then echo "Failed to Install FreeCAD"; exit 1; fi
	cd $SCRIPT_DIR
# Additional Debian-specific stuff: share directory

	exit
fi
	
