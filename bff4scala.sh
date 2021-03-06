#!/bin/sh
# l:\m4\vc14build\ff>..\..\buildkansas\msys64\usr\bin\bash.exe --login ..\..\ffmpeg1f0\bff4scala.sh x64 release
arch=x86
archdir=x86
clean_build=true
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
    includes)
            installincludes=true
            ;;
    quick)
            clean_build=false
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

PREFIX=${PWD}/${archdir}/${targetdir}

make_dirs() (
  mkdir -p ${archdir}/${targetdir}
  mkdir -p ${archdir}/${targetdir}/lib
)

copy_libs() (
    cp -u -f --no-preserve=mode,ownership lib*/*mm-*.dll ${MMOSROOTMSYS2}/current/${archdir}/${targetdir}
    cp -u -f --no-preserve=mode,ownership lib*/*mm-*.pdb ${MMOSROOTMSYS2}/current/${archdir}/${targetdir}
    cp -u -f --no-preserve=mode,ownership lib*/*.lib ${MMOSROOTMSYS2}/current/${archdir}/${targetdir}/lib
)

copy_includes() (
if $installincludes; then
	cp -u -f -r --no-preserve=mode,ownership ${PREFIX}/include/* ${MMOSROOTMSYS2}/include
fi
)

clean() (
  make distclean > /dev/null 2>&1
)

configure() (
  OPTIONS="
    --prefix=${PREFIX}                 \
    --libdir=crud                      \
    --enable-shared                    \
    --disable-static                   \
    --enable-w32threads                \
    --disable-all                      \
    --enable-w32threads                \
    --enable-filter=scale,yadif,w3fdif \
    --enable-avformat                  \
    --enable-avcodec                   \
    --enable-avutil                    \
    --enable-swscale                   \
    --build-suffix=mm                  \
    --enable-dxva2                     \
    --disable-iconv                    \
    --enable-hwaccel=*_dxva2           \
    --enable-protocol=file,rtmp*,mms*,rtsp,rtp,tcp,udp,http   \
    --enable-decoder=dvvideo,h261,mpeg4,h264,hevc,mjpeg,mjpegb,mpeg1video,mpeg2video,mpegvideo,prores_lgpl,vc1,wmv*,aac,aac_latm,ac3,eac3,mp1*,mp2*,mp3*,wma*,pcm_bluray,pcm_dvd,pcm_f*,pcm_s*,pcm_lxf,pcm_mulaw,pcm_alaw,pcm_u*,adpcm_g*,adpcm_ima*,adpcm_ms  \
    --enable-parser=aac,aac_latm,ac3,dvbsub,dvdsub,h261,h264,hevc,mjpeg,mpeg4video,mpegaudio,mpegvideo,vc1 \
    --enable-demuxer=mp3,aac,ac3,eac3,asf,avi,dv,g722,h261,h264,hevc,hls,m4v,mjpeg,mov,mpegps,mpegts,mpegtsraw,mpegvideo,pcm_s*,pcm_u*,pcm_f*,pcm_mulaw,pcm_alaw,vc1*,wav,xwma,rtsp,rtp,tcp,sdp \
    --arch=${arch}"

  EXTRA_CFLAGS="-FS -Zi -Zo -GS-"
  EXTRA_LDFLAGS=""

  if $debug ; then
    OPTIONS="${OPTIONS} --enable-debug"
    EXTRA_CFLAGS="${EXTRA_CFLAGS} -MDd"
    EXTRA_LDFLAGS="${EXTRA_LDFLAGS} user32.lib -NODEFAULTLIB:libcmt"
  else
    EXTRA_CFLAGS="${EXTRA_CFLAGS} -O2 -Oy- -MD"
    EXTRA_LDFLAGS="${EXTRA_LDFLAGS} -OPT:REF -DEBUG user32.lib -NODEFAULTLIB:libcmt"
  fi

  sh ${MMOSROOTMSYS2}/ffmpeg1f0/configure --toolchain=msvc --extra-cflags="${EXTRA_CFLAGS}" --extra-ldflags="${EXTRA_LDFLAGS}" ${OPTIONS}
)

build() (
  make -j $NUMBER_OF_PROCESSORS
  make install
)

echo Building ffmpeg in MSVC ${arch} ${targetdir} config in ${PWD}...

make_dirs

pushd ${archdir}/${targetdir}

##cd ffmpeg

if $clean_build ; then
    clean

    ## run configure, redirect to file because of a msys bug
    configure > config.out 2>&1
    CONFIGRETVAL=$?

    ## show configure output
    cat config.out
fi

## Only if configure succeeded, actually build
if ! $clean_build || [ ${CONFIGRETVAL} -eq 0 ]; then
  build &&  copy_libs && copy_includes
  

fi

popd

