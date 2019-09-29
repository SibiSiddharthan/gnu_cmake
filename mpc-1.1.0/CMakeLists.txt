cmake_minimum_required(VERSION 3.13)
project(mpc C)
INCLUDE (CheckTypeSize)
INCLUDE(CheckIncludeFile)
INCLUDE(CheckSymbolExists)
INCLUDE(CheckFunctionExists)
INCLUDE(CheckCSourceCompiles)
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
	message(FATAL_ERROR "In-source builds not allowed. Please make a new directory")
endif()


if(NOT DEFINED GMP_PATH)
message(FATAL_ERROR "GMP is required")
else()
find_file(GMP_HEADER gmp.h ${GMP_PATH}/include)
find_library(GMP_LIB gmp ${GMP_PATH}/lib)
if(GMP_HEADER STREQUAL "GMP_HEADER-NOTFOUND" OR GMP_LIB STREQUAL "GMP_LIB-NOTFOUND")
message(FATAL_ERROR "GMP path is invalid")
endif()
endif()

if(NOT DEFINED MPFR_PATH)
message(FATAL_ERROR "MPFR is required")
else()
find_file(MPFR_HEADER NAMES mpfr.h mpf2mpfr.h PATHS ${MPFR_PATH}/include)
find_library(MPFR_LIB mpfr ${MPFR_PATH}/lib)
if(MPFR_HEADER STREQUAL "MPFR_HEADER-NOTFOUND" OR MPFR_LIB STREQUAL "MPFR_LIB-NOTFOUND")
message(FATAL_ERROR "MPFR path is invalid")
endif()
endif()

set(PACKAGE \"mpc\")
set(PACKAGE_BUGREPORT \"mpc-discuss@lists.gforge.inria.fr\")
set(PACKAGE_NAME \"mpc\")
set(PACKAGE_STRING \"mpc 1.1.0\")
set(PACKAGE_TARNAME \"mpc\")
set(PACKAGE_URL \"\")
set(PACKAGE_VERSION \"1.1.0\")
set(VERSION \"1.1.0\")

#is true for gcc,clang and msvc on windows
set(STDC_HEADERS 1)

function(check_headers headers) 
foreach(i ${${headers}})
set(var ${i})
string(REPLACE "/" "_" var ${var})
string(REPLACE "." "_" var ${var})
string(TOUPPER ${var} var)
string(PREPEND var "HAVE_")
#message(${var})
check_include_file(${i} ${var})
	if(${var})
	set(${var} 1)
	set(${var} PARENT_SCOPE)
	endif()	
endforeach()
endfunction()

function(check_functions funcs) 
foreach(i ${${funcs}})
set(var ${i})
string(TOUPPER ${var} var)
string(PREPEND var "HAVE_")
check_function_exists(${i} ${var})
	if(${var})
	set(${var} 1)
	endif()	
endforeach()
endfunction()

function(check_functions_declaration funcs) 
foreach(i ${${funcs}})
set(var ${i})
string(TOUPPER ${var} var)
string(PREPEND var "HAVE_DECL_")
check_symbol_exists(${i} "stdio.h" ${var})
endforeach()
endfunction()

function(check_types_presence types)
foreach(i ${${types}})
set(var ${i})
string(REPLACE " " "_" var ${var})
string(TOUPPER ${var} var)
string(PREPEND var "HAVE_")
check_type_size(${i} ${var})
if(${${var}})
set(${var} 1 CACHE STRING "have type ${i}" FORCE )
endif()	
endforeach()
endfunction()

function(check_types_size types)
foreach(i ${${types}})
set(var ${i})
string(REPLACE " " "_" var ${var})
string(REPLACE "*" "P" var ${var})
string(TOUPPER ${var} var)
string(PREPEND var "SIZEOF_")
check_type_size(${i} ${var})
endforeach()
endfunction()


set(functions dup dup2 getrusage gettimeofday localeconv setlocale )

check_functions(functions)

#works with gcc,clang msvc on windows
set(HAVE_ALLOCA 1)

set(header complex.h dlfcn.h inttypes.h limits.h memory.h locale.h stdint.h
     stdlib.h strings.h string.h   sys/resource.h sys/stat.h 
	 sys/time.h sys/types.h
	unistd.h )

check_headers(header) 

set(types_presence intptr_t)
check_types_presence(types_presence)

check_c_source_compiles("
#include <sys/types.h>
#include <sys/time.h>
#include <time.h>

int
main ()
{
if ((struct tm *) 0)
return 0;
  ;
  return 0;
}"
TIME_WITH_SYS_TIME)
if(TIME_WITH_SYS_TIME)
set(TIME_WITH_SYS_TIME 1)
endif()

set(MPC_CC \"${CMAKE_C_COMPILER_ID}\")
if(${CMAKE_C_COMPILER_ID} STREQUAL "GNU")
set(MPC_GCC \"yes\")
set(MPC_GCC_VERSION \"${CMAKE_C_COMPILER_VERSION}\")
endif()

set(HAVE_MPFR_FMMA 1)

configure_file(mpc-config.h.in config.h)

set(mpc_SOURCES
src/mpc-impl.h src/mpc.h src/abs.c src/acos.c src/acosh.c src/add.c
src/add_fr.c src/add_si.c src/add_ui.c src/arg.c src/asin.c
src/asinh.c src/atan.c src/atanh.c src/clear.c src/cmp.c src/cmp_abs.c
src/cmp_si_si.c src/conj.c src/cos.c src/cosh.c src/div_2si.c
src/div_2ui.c src/div.c src/div_fr.c src/div_ui.c src/exp.c src/fma.c
src/fr_div.c src/fr_sub.c src/get_prec2.c src/get_prec.c src/get_version.c
src/get_x.c src/imag.c src/init2.c src/init3.c src/inp_str.c src/log.c
src/log10.c src/mem.c src/mul_2si.c src/mul_2ui.c src/mul.c src/mul_fr.c
src/mul_i.c src/mul_si.c src/mul_ui.c src/neg.c src/norm.c src/out_str.c
src/pow.c src/pow_fr.c src/pow_ld.c src/pow_d.c src/pow_si.c src/pow_ui.c
src/pow_z.c src/proj.c src/real.c src/rootofunity.c src/urandom.c src/set.c
src/set_prec.c src/set_str.c src/set_x.c src/set_x_x.c src/sin.c src/sin_cos.c
src/sinh.c src/sqr.c src/sqrt.c src/strtoc.c src/sub.c src/sub_fr.c src/sub_ui.c
src/swap.c src/tan.c src/tanh.c src/uceil_log2.c src/ui_div.c src/ui_ui_sub.c)

add_library(mpc STATIC ${mpc_SOURCES})
target_compile_options(mpc PRIVATE -DHAVE_CONFIG_H -O2 -pedantic -fomit-frame-pointer -m64)
target_include_directories(mpc PRIVATE ${CMAKE_CURRENT_BINARY_DIR} ${GMP_PATH}/include )
set_target_properties(mpc PROPERTIES PUBLIC_HEADER ${CMAKE_CURRENT_SOURCE_DIR}/src/mpc.h)

include(CTest)
enable_testing()
set(mpc-test_SOURCES
	tests/mpc-tests.h tests/check_data.c tests/clear_parameters.c	
  tests/close_datafile.c tests/comparisons.c tests/copy_parameter.c tests/double_rounding.c	
  tests/init_parameters.c tests/mpfr_flags.c tests/open_datafile.c tests/print_parameter.c	
  tests/random.c tests/read_data.c tests/read_description.c tests/read_line.c tests/rounding.c	
  tests/setprec_parameters.c tests/tpl_gmp.c tests/tpl_mpc.c tests/tpl_mpfr.c tests/tpl_native.c)

set(dat_files 
    abs.dat     arg.dat    cmp_abs.dat  div_fr.dat  inp_str.dat  neg.dat     pow_ui.dat       sinh.dat    sub_fr.dat
	acos.dat    asin.dat   conj.dat     exp.dat     log.dat      norm.dat    pow_z.dat        sqr.dat     tan.dat
	acosh.dat   asinh.dat  cos.dat      fma.dat     log10.dat    pow.dat     proj.dat         sqrt.dat    tanh.dat
	add.dat     atan.dat   cosh.dat     fr_div.dat  mul.dat      pow_fr.dat  rootofunity.dat  strtoc.dat
	add_fr.dat  atanh.dat  div.dat      fr_sub.dat  mul_fr.dat   pow_si.dat  sin.dat   sub.dat)

set(dsc_files
	abs.dsc     arg.dsc      cos.dsc      exp.dsc     mul.dsc      neg.dsc     pow_z.dsc        sqr.dsc     ui_div.dsc
	acos.dsc    asin.dsc     cosh.dsc     fma.dsc     mul_2si.dsc  norm.dsc    proj.dsc         sqrt.dsc    ui_ui_sub.dsc
	acosh.dsc   asinh.dsc    div.dsc      fr_div.dsc  mul_2ui.dsc  pow.dsc     real.dsc         sub.dsc
	add.dsc     atan.dsc     div_2si.dsc  fr_sub.dsc  mul_fr.dsc   pow_d.dsc   rootofunity.dsc  sub_fr.dsc
	add_fr.dsc  atanh.dsc    div_2ui.dsc  imag.dsc    mul_i.dsc    pow_fr.dsc  sin.dsc          sub_ui.dsc
	add_si.dsc  cmp_abs.dsc  div_fr.dsc   log.dsc     mul_si.dsc   pow_si.dsc  sin_cos.dsc      tan.dsc
	add_ui.dsc  conj.dsc     div_ui.dsc   log10.dsc   mul_ui.dsc   pow_ui.dsc  sinh.dsc         tanh.dsc)

foreach(i ${dat_files})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/tests/${i}
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/tests/${i} ${CMAKE_CURRENT_BINARY_DIR}/tests/${i})
	list(APPEND cpdat ${CMAKE_CURRENT_BINARY_DIR}/tests/${i})
endforeach()

foreach(i ${dsc_files})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/tests/${i}
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/tests/${i} ${CMAKE_CURRENT_BINARY_DIR}/tests/${i})
	list(APPEND cpdsc ${CMAKE_CURRENT_BINARY_DIR}/tests/${i})
endforeach()

add_custom_target(res DEPENDS ${cpdat} ${cpdsc})
add_library(mpc-tests STATIC ${mpc-test_SOURCES})
add_dependencies(mpc-tests mpc res)
target_include_directories(mpc-tests PRIVATE ${CMAKE_CURRENT_BINARY_DIR} ${GMP_PATH}/include ${MPFR_PATH}/include )

set(tests
	tabs tacos tacosh tadd tadd_fr tadd_si tadd_ui targ	
  tasin tasinh tatan tatanh tcmp_abs tconj tcos tcosh                   
  tdiv tdiv_2si tdiv_2ui	                                        
  tdiv_fr tdiv_ui texp tfma tfr_div tfr_sub timag tio_str tlog tlog10	
  tmul tmul_2si tmul_2ui tmul_fr tmul_i tmul_si tmul_ui tneg tnorm tpow	
  tpow_d tpow_fr tpow_ld tpow_si tpow_ui tpow_z tprec tproj treal	
  treimref trootofunity                                                
  tset tsin tsin_cos tsinh tsqr tsqrt tstrtoc tsub tsub_fr	        
  tsub_ui tswap ttan ttanh tui_div tui_ui_sub tget_version exceptions)

foreach(t ${tests})
	add_executable(${t} tests/${t}.c)
	add_dependencies(${t} mpc-tests)
	target_compile_options(${t} PRIVATE -DHAVE_CONFIG_H -O2 -pedantic -fomit-frame-pointer -m64)
	target_include_directories(${t} PRIVATE ${CMAKE_CURRENT_BINARY_DIR} ${GMP_PATH}/include ${MPFR_PATH}/include )
	target_link_directories(${t} PRIVATE ${GMP_PATH}/lib ${MPFR_PATH}/lib)
	target_link_libraries(${t} mpc-tests mpc mpfr gmp)
	set_target_properties(${t} PROPERTIES
							RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tests")
	add_test(NAME ${t} COMMAND ${CMAKE_CURRENT_BINARY_DIR}/tests/${t}
			WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/tests)
endforeach()


INSTALL(TARGETS mpc
		LIBRARY DESTINATION lib
		PUBLIC_HEADER DESTINATION include)