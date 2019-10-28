cmake_minimum_required(VERSION 3.13)
project(libmangle C)
INCLUDE(CheckIncludeFile)
INCLUDE(CheckFunctionExists)
INCLUDE(CheckCSourceRuns)
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
	message(FATAL_ERROR "In-source builds not allowed. Please make a new directory")
endif()

set(PACKAGE \"mingw-w64-libmangle\")
set(PACKAGE_BUGREPORT \"mingw-w64-public@lists.sourceforge.net\")
set(PACKAGE_NAME \"libmangle\")
set(PACKAGE_STRING \"libmangle 1.0\")
set(PACKAGE_TARNAME "")
set(PACKAGE_URL \"mingw-w64-public@lists.sourceforge.net\")
set(PACKAGE_VERSION \"1.0\")
set(VERSION \"1.0\")


#is true for gcc,clang and msvc on windows
set(STDC_HEADERS 1)


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

set(header inttypes.h memory.h malloc.h stdint.h stdlib.h strings.h string.h sys/stat.h sys/types.h unistd.h)
check_headers(header)

set(functions memset strdup strrchr strlwr strchr strstr)
check_functions(functions)

check_c_source_runs("
# include <stdlib.h>

int
main ()
{
return ! malloc (0);
  ;
  return 0;
}"
HAVE_MALLOC)
if(HAVE_MALLOC)
set(HAVE_MALLOC 1)
else()
set(malloc rpl_malloc)
endif()

check_c_source_runs("
# include <stdlib.h>

int
main ()
{
return ! realloc (0,0);
  ;
  return 0;
}"
HAVE_REALLOC)
if(HAVE_REALLOC)
set(HAVE_REALLOC 1)
else()
set(realloc rpl_realloc)
endif()

configure_file(libmangle-config.h.in config.h)

set(libmangle_SOURCES
  src/m_ms.h src/m_token.h 
  src/m_ms.c src/m_token.c include/libmangle.h)

add_library(mangle STATIC ${libmangle_SOURCES})
target_include_directories(mangle PRIVATE ${CMAKE_CURRENT_BINARY_DIR})