cmake_minimum_required(VERSION 3.13)
project(genlib C)
INCLUDE(CheckIncludeFile)
INCLUDE(CheckFunctionExists)
INCLUDE(CheckLibraryExists)
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
	message(FATAL_ERROR "In-source builds not allowed. Please make a new directory")
endif()

set(PACKAGE \"mingw-w64-genlib\")
set(PACKAGE_BUGREPORT \"mingw-w64-public@lists.sourceforge.net\")
set(PACKAGE_NAME \"genlib\")
set(PACKAGE_STRING \"genlib 1.0\")
set(PACKAGE_TARNAME "")
set(PACKAGE_URL \"mingw-w64-public@lists.sourceforge.net\")
set(PACKAGE_VERSION \"1.0\")
set(VERSION \"1.0\")

function(check_headers headers) 
foreach(i ${${headers}})
set(var ${i})
string(REPLACE "/" "_" var ${var})
string(REPLACE "." "_" var ${var})
string(TOUPPER ${var} var)
string(PREPEND var "HAVE_")
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


#is true for gcc,clang and msvc on windows
set(STDC_HEADERS 1)


set(header inttypes.h memory.h malloc.h stdint.h stdlib.h strings.h string.h sys/stat.h sys/types.h unistd.h)
check_headers(header)

set(functions memset strdup strrchr strlwr )
check_functions(functions)

check_library_exists(m "floor" "" HAVE_LIBM)
if(HAVE_LIBM)
set(HAVE_LIBM 1)
endif()

configure_file(genlib-config.h.in config.h)

set(genlib_SOURCES
  src/genlib.h src/genlib.c src/deffun.c src/deflex.c src/defparse.c 
   src/deflex.h src/defparse.h)

add_executable(genlib ${genlib_SOURCES})
target_include_directories(genlib PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
target_compile_definitions(genlib PRIVATE HAVE_CONFIG_H)
#target_compile_options(genlib PRIVATE -Wshadow -Wformat -Wpacked -Wredundant-decls -Winline -pedantic -Wno-pedantic-ms-format -Wmissing-declarations -Wredundant-decls -Wimplicit-function-declaration -Wmissing-noreturn -Wmissing-prototypes -Wstrict-aliasing=2)