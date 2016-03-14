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
# OCE_PATCH_VERSION=`grep "set(OCE_VERSION_PATCH" ../CMakeLists.txt | cut -d ' ' -f2 | sed 's/)//'`

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


# Now the configure via cmake
# -DOCE_DRAW=OFF
# -DOCE_WITH_OPENCL=OFF
# -DOCE_WITH_VTK=OFF
	cd $BUILD_DIR
	cmake	-DCMAKE_BUILD_TYPE=Debug \
		-DOCE_INSTALL_LIB_DIR=/usr/lib/oce-$OCE_MAJOR_VERSION.$OCE_MINOR_VERSION \
		-DOCE_VERSION_PATCH=$OCE_PATCH_VERSION \
		-DOCE_INSTALL_PREFIX=/usr \
		-DOCE_VISUALISATION=ON \
		-DOCE_WITH_FREEIMAGE=ON \
		-DOCE_WITH_GL2PS=ON \
		-DOCE_DATAEXCHANGE=ON \
		-DOCE_OCAF=ON \
		-DOCE_TBB_MALLOC_SUPPORT=ON \
		-DOCE_MULTITHREAD_LIBRARY=TBB \
		-DOCE_VISUALISATION=ON \
		../..
	if [ $? != 0 ]; then echo "Failed to configure OpenCASCADE"; exit 1; fi
	$MAKE -j3
	if [ $? != 0 ]; then echo "Failed to Make OpenCASCADE"; exit 1; fi
	echo "Installing OpenCASCADE to  $TARGET_DIR"
	rm -Rf $TARGET_DIR
	mkdir -p $TARGET_DIR
# Installing
	$MAKE DESTDIR=$TARGET_DIR install
	if [ $? != 0 ]; then echo "Failed to Install OpenCASCADE"; exit 1; fi
	cd $SCRIPT_DIR
# Additional Debian-specific stuff: share directory
	rm -rf $TARGET_DIR/usr/lib/oce-$OCE_MAJOR_VERSION.$OCE_MINOR_VERSION/*.so
	rm -rf $TARGET_DIR/usr/lib/oce-$OCE_MAJOR_VERSION.$OCE_MINOR_VERSION/*.so.10
	cd  $TARGET_DIR/usr/lib
	LIB_FILES="$TARGET_DIR/usr/lib/oce-$OCE_MAJOR_VERSION.$OCE_MINOR_VERSION/*.so.10.0.0"
	for lib_file in $LIB_FILES 
	do
		LIB_FILE_NOEXT=$(basename $lib_file)
		LIB_FILE_NOEXT=${LIB_FILE_NOEXT%.*}
		LIB_FILE_NOEXT=${LIB_FILE_NOEXT%.*}
		echo "Linking - $LIB_FILE_NOEXT"
		ln -s oce-$OCE_MAJOR_VERSION.$OCE_MINOR_VERSION/$(basename $lib_file) $LIB_FILE_NOEXT
	done
	cd $SCRIPT_DIR


# Debian package directory should reside inside the target directory
        mkdir -p ${TARGET_DIR}/DEBIAN
        cat debian/control | sed "s/\[BUILD_VERSION\]/${FULL_VERSION}/" | sed "s/\[ARCH\]/${BUILD_ARCH}/" > ${TARGET_DIR}/DEBIAN/control
        cp debian/postinst ${TARGET_DIR}/DEBIAN/postinst
        cp debian/postrm ${TARGET_DIR}/DEBIAN/postrm
        cp debian/shlibs ${TARGET_DIR}/DEBIAN/shlibs

# Now that the directory structure is ready, let's build a package
	rm -Rf ${SCRIPT_DIR}/liboce10_*.deb
# Now that the directory structure is ready, let's build a package
	fakeroot sh -ec "
		chown root:root ${TARGET_DIR} -R
		chmod u+w,a+rX,go-w ${TARGET_DIR} -R
		chmod a+x ${TARGET_DIR}/DEBIAN -R
		dpkg-deb -Zgzip --build ${TARGET_DIR} ${SCRIPT_DIR}/liboce10_${FULL_VERSION}_${BUILD_ARCH}.deb
		chown `id -un`:`id -gn` ${TARGET_DIR} -R
	"
	exit
fi
	
