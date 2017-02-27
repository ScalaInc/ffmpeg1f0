#!/bin/sh
# l:\m4\vc14build\ff>..\..\buildkansas\msys64\usr\bin\bash.exe --login ..\..\ffmpeg1f0\bff4scala.sh x64 release
 arch=x86
 archdir=x86
 debug=true
 installincludes=false
 targetdir=Debug
 mp4pt2=""

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
	 mp4pt2)
            echo "Got mp4pt2 Option"
			 mp4pt2="mpeg4,"
			 ;;
    *)
            echo "Unknown Option $opt"
            exit 1
    esac
done

PREFIX=${PWD}

configure() (
  OPTIONS="
    --prefix=${PREFIX}                 \
    --libdir=crud                      \
    --arch=${arch}                     \
    --enable-shared                    \
    --disable-static                   \
    --disable-all                      \
    --disable-videotoolbox             \
    --enable-w32threads                \
    --enable-avformat                  \
    --enable-avcodec                   \
    --enable-avutil                    \
    --enable-swscale                   \
    --build-suffix=mm                  \
    --enable-dxva2                     \
    --disable-iconv                    \
    --enable-hwaccel=*_dxva2           \
    --enable-protocol=file   \
    --enable-decoder=dvvideo,h261,${mp4pt2}h264,hevc,mjpeg,mjpegb,mpeg1video,mpeg2video,mpegvideo,prores_lgpl,vc1,wmv*,aac,aac_latm,ac3,eac3,mp1*,mp2*,mp3*,wma*,pcm_bluray,pcm_dvd,pcm_f*,pcm_s*,pcm_lxf,pcm_mulaw,pcm_alaw,pcm_u*,adpcm_g*,adpcm_ima*,adpcm_ms  \
    --enable-parser=aac,aac_latm,ac3,dvbsub,dvdsub,h261,h264,hevc,mjpeg,mpeg4video,mpegaudio,mpegvideo,vc1 \
    --enable-demuxer=mp3,aac,ac3,eac3,asf,avi,dv,g722,h261,h264,hevc,m4v,mjpeg,mov,mpegps,mpegts,mpegtsraw,mpegvideo,pcm_s*,pcm_u*,pcm_f*,pcm_mulaw,pcm_alaw,vc1*,wav,xwma"

  EXTRA_CFLAGS="-D_WIN32_WINNT=0x0601 -DWINVER=0x0601 -msse -mfpmath=sse"
  ## I need zlib and others to be statically linked.  This used to be more elaborate, but I changed to -static and deleted all libz.dll.a and pthread.dll.a from my msys2 install.  Yuck.
  EXTRA_LDFLAGS="-static"

  if test "$arch"="x86" ; then
    OPTIONS="--cpu=i686 ${OPTIONS}"
  fi

  sh ${MMOSROOTMSYS2}/src/ffmpeg1f0/configure --extra-cflags="${EXTRA_CFLAGS}" --extra-ldflags="${EXTRA_LDFLAGS}" ${OPTIONS}
)

echo Config ffmpeg in MSYS2 ${arch} ${targetdir} config in ${PWD}...

## run configure, redirect to file because of a msys bug
configure > config.out 2>&1
CONFIGRETVAL=$?

## show configure output
cat config.out
