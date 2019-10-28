cmake_minimum_required(VERSION 3.13)
project(mingw C CXX)

set(PACKAGE \"mingw-w64\")
set(PACKAGE_BUGREPORT \"mingw-w64-public@lists.sourceforge.net\")
set(PACKAGE_NAME \"mingw-w64\")
set(PACKAGE_STRING \"mingw-w64 4.0b\")
set(PACKAGE_TARNAME \"mingw-w64\")
set(PACKAGE_URL "")
set(PACKAGE_VERSION \"4.0b\")
set(VERSION \"4.0b\")

configure_file(mingw-config.h.in config.h)

add_subdirectory(mingw-w64-crt)
add_subdirectory(mingw-w64-headers)