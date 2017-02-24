#!/bin/sh
arch=x86
archdir=x86
debug=true
installincludes=false
targetdir=Debug

if [ -z "$MMOSROOT" ]; then
    echo "envvar MMOSROOT is not set, exiting..."
    exit 1
fi 

# convert path in MMOSROOT from Windows style to something MSYS2 can handle
export MMOSROOTMSYS2=$(cygpath ${MMOSROOT})

for opt in "$@"
do
    case "$opt" in
    x86)
            ;;
    x64 | amd64)
            arch=x86_64
            archdir=x64
            ;;
    release)
            debug=false
			targetdir=RWDI
            ;;
    *)
            echo "Unknown Option $opt"
            exit 1
    esac
done

PREFIX=${PWD}

copy_libs() (
    cp -u -f --no-preserve=mode,ownership lib*/*mm-*.dll ${MMOSROOTMSYS2}/current/${archdir}/${targetdir}
#    cp -u -f --no-preserve=mode,ownership lib*/*mm-*.pdb ${MMOSROOTMSYS2}/current/${archdir}/${targetdir}
    cp -u -f --no-preserve=mode,ownership lib*/*.lib ${MMOSROOTMSYS2}/current/${archdir}/${targetdir}/lib
)

build() (
  make -j $NUMBER_OF_PROCESSORS
  make install
)

echo Building ffmpeg in MSYS2 ${arch} ${targetdir} config in ${PWD}...

build && copy_libs
