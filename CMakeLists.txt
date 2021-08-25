cmake_minimum_required(VERSION 3.5)

if(NOT DEFINED CMAKE_DEVROOT)
    if (DEFINED ENV{MMOSROOT}) # if not null, false, etc
        set(CMAKE_DEVROOT $ENV{MMOSROOT} CACHE STRING "Normalized Root")
        message("CMAKE_DEVROOT set from environment variable MMOSROOT = $ENV{MMOSROOT}")
    elseif (DEFINED ENV{SCALA_ROOT}) # if not null, false, etc
        set(CMAKE_DEVROOT $ENV{SCALA_ROOT} CACHE STRING "Normalized Root")
        message("CMAKE_DEVROOT set from environment variable SCALA_ROOT = $ENV{SCALA_ROOT}")
    else()
        message(FATAL_ERROR "Either MMOSROOT or preferably SCALA_ROOT environment variable must be set!")
    	return()
    endif()
endif()

###########################################################################################################

project("ffmpeg1f0")

if(NOT DEFINED MMOSVC14TOOLSROOT)
    if (DEFINED ENV{MMOSVC14TOOLSROOT}) # if not null, false, etc
        set(MMOSVC14TOOLSROOT $ENV{MMOSVC14TOOLSROOT} CACHE STRING "MMOSVC14TOOLSROOT")
	message("#### MMOSVC14TOOLSROOT set from ENV = $ENV{MMOSVC14TOOLSROOT}")
    else()
        message(FATAL_ERROR "MMOSVC14TOOLSROOT not set!")
    	return()
    endif()
endif()

include (${CMAKE_DEVROOT}/src/cmake/Scala-MMOS.cmake)

set(MP4PT2_OPTION "")

if(DEFINED ENABLE_MP4PT2)
  if(ENABLE_MP4PT2)
	set(MP4PT2_OPTION "mp4pt2")
  endif()
endif()

if ( CMAKE_BUILD_TYPE MATCHES DEBUG )
  set(FFMPEG_BUILD_TYPE_PARAM "")
  #   message("####################  Assume a Debug build")
else()
  set(FFMPEG_BUILD_TYPE_PARAM "release")
endif()

if ( PROJECT_ARCH MATCHES _AMD64_ )
  set(FFMPEG_ARCH_PARAM "x64")
else()
  set(FFMPEG_ARCH_PARAM "x86")
endif()

file(TO_NATIVE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/config4scala.sh" CONFIG4SCALASH)
file(TO_NATIVE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/build4scala.sh" BUILD4SCALASH)
file(TO_CMAKE_PATH "${MMOSVC14TOOLSROOT}\\msys64\\usr\\bin\\bash.exe" MSYS2BASH)

if ( NOT ( CMAKE_BUILD_TYPE MATCHES PREBUILD ) )
  if ( NOT TARGET ffmpeg1f0 )
	add_custom_target( ffmpeg1f0 ALL COMMENT "build ffmpeg1f0")
  endif()

  add_custom_command( 
	OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/config.mak
	COMMAND ${MSYS2BASH} --login ${CONFIG4SCALASH} ${FFMPEG_ARCH_PARAM} ${FFMPEG_BUILD_TYPE_PARAM} ${MP4PT2_OPTION}
	DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/config4scala.sh
	COMMENT "ffmpeg generate config for ${FFMPEG_ARCH_PARAM} ${FFMPEG_BUILD_TYPE_PARAM}")

  add_custom_target( ffmpeg1f0_config
	DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/config.mak
	)

  add_dependencies( ffmpeg1f0 ffmpeg1f0_config )

  # run always, but after config
  add_custom_command( 
	OUTPUT  ${CMAKE_CURRENT_BINARY_DIR}/intentionallynonextantfile.dll
	COMMAND ${MSYS2BASH} --login ${BUILD4SCALASH} ${FFMPEG_ARCH_PARAM} ${FFMPEG_BUILD_TYPE_PARAM}
	DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/config.mak
	COMMENT "ffmpeg build for ${FFMPEG_ARCH_PARAM} ${FFMPEG_BUILD_TYPE_PARAM}")

  add_custom_target( ffmpeg1f0_build
	DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/intentionallynonextantfile.dll
	)

  add_dependencies( ffmpeg1f0 ffmpeg1f0_build )
endif()


