cmake_minimum_required(VERSION 3.5)

project("ffmpeg1f0")

if(NOT DEFINED MMOSROOT)
    if (DEFINED ENV{MMOSROOT}) # if not null, false, etc
        set(MMOSROOT $ENV{MMOSROOT} CACHE STRING "MMOS root")
	message("#### MMOSROOT set from ENV = $ENV{MMOSROOT}")
    else()
        message(FATAL_ERROR "MMOSROOT not set!")
    	return()
    endif()
endif()

if(NOT DEFINED MMOSVC14TOOLSROOT)
    if (DEFINED ENV{MMOSVC14TOOLSROOT}) # if not null, false, etc
        set(MMOSVC14TOOLSROOT $ENV{MMOSVC14TOOLSROOT} CACHE STRING "MMOSVC14TOOLSROOT")
	message("#### MMOSVC14TOOLSROOT set from ENV = $ENV{MMOSVC14TOOLSROOT}")
    else()
        message(FATAL_ERROR "MMOSVC14TOOLSROOT not set!")
    	return()
    endif()
endif()

include (${MMOSROOT}/src/cmake/Scala.cmake)

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

file(TO_NATIVE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/bff4scala.sh" BFF4SCALASH)
file(TO_CMAKE_PATH "${MMOSVC14TOOLSROOT}\\msys64\\usr\\bin\\bash.exe" MSYS2BASH)

# add_custom_command( 
#   OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/config.mak
#   #	WORKING_DIRECTORY ${cmakepathtocdl}
#   COMMAND ${MMOSVC14TOOLSROOT}/msys64/usr/bin/bash.exe --login ${CMAKE_CURRENT_SOURCE_DIR}\\bff4scala.sh ${FFMPEG_ARCH_PARAM} ${FFMPEG_BUILD_TYPE_PARAM}
#   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/bff4scala.sh
#   COMMENT "ffmpeg generate config and build for ${FFMPEG_ARCH_PARAM} ${FFMPEG_BUILD_TYPE_PARAM}")

# add_custom_target( ffmpeg1f0 
#   DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/config.mak
#   )

add_custom_target( ffmpeg1f0
  COMMAND ${MSYS2BASH} --login ${BFF4SCALASH} ${FFMPEG_ARCH_PARAM} ${FFMPEG_BUILD_TYPE_PARAM}
#  SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/bff4scala.sh
  DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/bff4scala.sh
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/config.mak
  #	WORKING_DIRECTORY ${cmakepathtocdl}
  COMMENT "ffmpeg generate config and build for ${FFMPEG_ARCH_PARAM} ${FFMPEG_BUILD_TYPE_PARAM}")

