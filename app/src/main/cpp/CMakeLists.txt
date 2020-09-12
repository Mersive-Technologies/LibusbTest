cmake_minimum_required(VERSION 3.4.1)

add_library(  native-lib SHARED native-lib.cpp )

add_subdirectory( libusb/libusb )

find_library( log-lib log )

target_link_libraries( native-lib ${log-lib} usb-1.0 )
