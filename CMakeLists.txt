cmake_minimum_required(VERSION 3.13)
project(prereq C ASM)
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
	message(FATAL_ERROR "In-source builds not allowed. Please make a new directory")
endif()

set(BUILDING_ALL "TRUE")
include(CTest)
enable_testing()

add_subdirectory(gmp-6.1.2)
set(GMP_PATH ${CMAKE_BINARY_DIR}/gmp-6.1.2)

add_subdirectory(isl-0.21)
set(ISL_PATH ${CMAKE_BINARY_DIR}/isl-0.21)

add_subdirectory(mpfr-4.0.2)
set(MPFR_PATH ${CMAKE_BINARY_DIR}/mpfr-4.0.2)

add_subdirectory(mpc-1.1.0)
set(MPC_PATH ${CMAKE_BINARY_DIR}/mpc-1.1.0)