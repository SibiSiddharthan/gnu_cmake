cmake_minimum_required(VERSION 3.13)
project(libiconv C)
INCLUDE (CheckTypeSize)
INCLUDE(CheckIncludeFile)
INCLUDE(CheckSymbolExists)
INCLUDE(CheckFunctionExists)
INCLUDE(CheckCSourceCompiles)
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
	message(FATAL_ERROR "In-source builds not allowed. Please make a new directory")
endif()

set(PACKAGE \"libiconv\")
set(PACKAGE_BUGREPORT \"\")
set(PACKAGE_NAME \"libiconv\")
set(PACKAGE_STRING \"libiconv 1.16\")
set(PACKAGE_TARNAME \"libiconv\")
set(PACKAGE_URL \"\")
set(PACKAGE_VERSION \"1.16\")
set(VERSION \"1.16\")


#is true for gcc,clang and msvc on windows
set(STDC_HEADERS 1)
set(HAVE_ALLOCA 1)


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

function(check_functions_declaration funcs) 
foreach(i ${${funcs}})
set(var ${i})
string(TOUPPER ${var} var)
string(PREPEND var "HAVE_DECL_")
check_symbol_exists(${i} "stdio.h" ${var})
	if(${var})
	set(${var} 1)
	else()
	set(${var} 0)
	endif()	
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

function(check_stat_struct_members structs )
foreach(i ${${structs}})
set(st ${i})
set(var ${i})
string(REPLACE "." "_" var ${var})
string(TOUPPER ${var} var)
string(PREPEND var "HAVE_STRUCT_STAT_")
check_c_source_compiles("
#include<sys/types.h>
#include<sys/stat.h>
int
main ()
{
static struct stat ac_aggr;
if (ac_aggr.${st})
return 0;
  ;
  return 0;
}"
${var})
	if(${var})
	set(${var} 1)
	endif()	
endforeach()
endfunction()

set(function_decls clearerr_unlocked feof_unlocked ferror_unlocked fflush_unlocked fgets_unlocked fputc_unlocked
	fputs_unlocked fread_unlocked fwrite_unlocked getchar_unlocked getc_unlocked program_invocation_name program_invocation_short_name
	putchar_unlocked putc_unlocked setenv strerror_r __argv)

check_functions_declaration(function_decls)

set(functions canonicalize_file_name copy_file_range dcgettext getcwd getc_unlocked getexecname getprogname gettext iconv lstat 
	mbrtowc mbsinit memmove raise readlink readlinkat realpath setenv setlocale strerror_r symlink tsearch wcrtomb)

check_functions(functions)

set(header alloca.h dlfcn.h inttypes.h limits.h mach-o/dyld.h memory.h search.h stdint.h stdlib.h strings.h string.h
	sys/bitypes.h sys/inttypes.h sys/param.h sys/socket.h sys/stat.h sys/time.h sys/types.h unistd.h wchar.h winsock2.h
	)

check_headers(header) 

set(types_presence "unsigned long long int" "long long int" wchar_t wint_t _Bool)
check_types_presence(types_presence)

set(_structs st_atimensec st_atimespec.tv_nsec st_atim.st__tim.tv_nsec st_atim.tv_nsec 
	st_birthtimensec st_birthtimespec.tv_nsec st_birthtim.tv_nsec)
check_stat_struct_members(_structs)

#default options
set(ENABLE_EXTRA 1)
set(ENABLE_NLS 1)
set(ENABLE_RELOCATABLE 1)

set(ICONV_CONST ICONV_CONST)
set(USER_LABEL_PREFIX USER_LABEL_PREFIX)

if(NOT WIN32)
set(FUNC_REALPATH_WORKS 1)
set(HAVE_MALLOC_POSIX 1)
#cheating
set(HAVE_WORKING_O_NOATIME 1)
set(HAVE_WORKING_O_NOFOLLOW 1)
set(LSTAT_FOLLOWS_SLASHED_SYMLINK 1)
endif()

if(WIN32)
set(HAVE_MSVC_INVALID_PARAMETER_HANDLER 1)
if ("${CMAKE_C_COMPILER_ID}" STREQUAL "GNU")
set(__USE_MINGW_ANSI_STDIO 1)
endif()
endif()


set(GNULIB_CANONICALIZE_LGPL 1)
set(GNULIB_MSVC_NOTHROW 1)

set(GNULIB_FSCANF 1)
set(GNULIB_SCANF 1)
set(GNULIB_SIGPIPE 1)
set(GNULIB_STRERROR 1)
set(GNULIB_TEST_CANONICALIZE_FILE_NAME 1)
set(GNULIB_TEST_ENVIRON 1)
set(GNULIB_TEST_LSTAT 1)
set(GNULIB_TEST_MALLOC_POSIX 1)
set(GNULIB_TEST_RAISE 1)
set(GNULIB_TEST_READ 1)
set(GNULIB_TEST_READLINK 1)
set(GNULIB_TEST_REALPATH 1)
set(GNULIB_TEST_SIGPROCMASK 1)
set(GNULIB_TEST_STAT 1)
set(GNULIB_TEST_STRERROR 1)
set(LT_OBJDIR \".libs/\")


check_c_source_compiles("
int
main (void)
{
union ieee_double_extract
{
  double d;
  unsigned char x[8];
} t;
t.d = 2.877939254133025759330166692961938679218292236328125; /* exact */
if (sizeof (double) != 8)
   return 0;
if (sizeof (unsigned char) != 1)
   return 0;
if (t.x[0] == 1 && t.x[1] == 2 && t.x[2] == 3 && t.x[3] == 4 &&
    t.x[4] == 5 && t.x[5] == 6 && t.x[6] == 7 && t.x[7] == 64)
   return 1; /* little endian */
else if (t.x[7] == 1 && t.x[6] == 2 && t.x[5] == 3 && t.x[4] == 4 &&
    t.x[3] == 5 && t.x[2] == 6 && t.x[1] == 7 && t.x[0] == 64)
   return 2; /* big endian */
else
   return 0; /* unknown */
  ;
  return 0;
}"
WORDS_LITTLEENDIAN )
if(WORDS_LITTLEENDIAN )
set(WORDS_LITTLEENDIAN 1)
endif()

check_c_source_compiles("
#include <unistd.h>
#include <stdlib.h>

            extern struct { int foo; } environ;
int
main ()
{
environ.foo = 1;
  ;
  return 0;
}"
 HAVE_ENVIRON_DECL)
if(HAVE_ENVIRON_DECL )
set(HAVE_ENVIRON_DECL 1)
endif()

check_c_source_compiles("
#include <stddef.h>
#include <stdio.h>
#include <time.h>
#include <wchar.h>
int
main ()
{
mbstate_t x; return sizeof x;
  ;
  return 0;
}"
HAVE_MBSTATE_T)
if(HAVE_MBSTATE_T)
set(HAVE_MBSTATE_T 1)
endif() 

check_c_source_compiles("
#include <langinfo.h>
int
main ()
{
char* cs = nl_langinfo(CODESET); return !cs;
  ;
  return 0;
}"
HAVE_LANGINFO_CODESET)
if(HAVE_LANGINFO_CODESET)
set(HAVE_LANGINFO_CODESET 1)
endif()

check_c_source_compiles("
# include <stdlib.h>

int
main ()
{
char *p = malloc (0);
            int result = !p;
            free (p);
            return result;
  ;
  return 0;
}"
MALLOC_0_IS_NONNULL)
if(MALLOC_0_IS_NONNULL)
set(MALLOC_0_IS_NONNULL 1)
endif()

check_c_source_compiles("
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
int
main ()
{

	  char buf[100];
	  char x = *strerror_r (0, buf, sizeof buf);
	  char *p = strerror_r (0, buf, sizeof buf);
	  return !p || x;

  ;
  return 0;
}"
STRERROR_R_CHAR_P)
if(STRERROR_R_CHAR_P)
set(STRERROR_R_CHAR_P 1)
endif()


if ("${CMAKE_C_COMPILER_ID}" STREQUAL "GNU" OR "${CMAKE_C_COMPILER_ID}" STREQUAL "Clang")
set(HAVE_VISIBILITY 1)
set(restrict __restrict)
endif()

configure_file(libiconv-config.h.in config.h)
configure_file(libcharset/include/localcharset.h.build.in localcharset.h @ONLY)
configure_file(libcharset/include/libcharset.h.in libcharset.h)

if(HAVE_WCRTOMB EQUAL 1 OR HAVE_MBRTOWC EQUAL 1)
set(USE_MBSTATE_T 1)
else()
set(USE_MBSTATE_T 0)
endif()
if(HAVE_WCHAR_H EQUAL 1)
set(BROKEN_WCHAR_H 0)
else()
set(BROKEN_WCHAR_H 1)
endif()
set(ICONV_CONST)
configure_file(include/iconv.h.build.in iconv.h @ONLY)

if(WIN32)
if(NOT DEFINED PATCHED)
execute_process(COMMAND patch -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/fix-pointer-buf.patch
				WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
set(PATCHED TRUE CACHE BOOL "Apply patch only once")
endif()
endif()

set(charset_SOURCES 
	libcharset/lib/localcharset.c libcharset/lib/relocatable-stub.c ${CMAKE_CURRENT_BINARY_DIR}/libcharset.h )
add_library(charset STATIC ${charset_SOURCES})
target_compile_definitions(charset PRIVATE BUILDING_LIBCHARSET HAVE_CONFIG_H)
target_include_directories(charset PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
set_target_properties(charset PROPERTIES PUBLIC_HEADER ${CMAKE_CURRENT_BINARY_DIR}/libcharset.h)


set(iconv_SOURCES
	libcharset/lib/localcharset.c lib/iconv.c lib/relocatable.c ${CMAKE_CURRENT_BINARY_DIR}/iconv.h ${CMAKE_CURRENT_BINARY_DIR}/localcharset.h)
add_library(iconv STATIC ${iconv_SOURCES})
target_compile_definitions(iconv PRIVATE BUILDING_LIBICONV HAVE_CONFIG_H ENABLE_RELOCATABLE=1 IN_LIBRARY NO_XMALLOC set_relocation_prefix=libiconv_set_relocation_prefix relocate=libiconv_relocate relocate2=libiconv_relocate2)
target_include_directories(iconv PRIVATE ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/gnulib-local/lib)
set_target_properties(iconv PROPERTIES PUBLIC_HEADER "${CMAKE_CURRENT_BINARY_DIR}/iconv.h;${CMAKE_CURRENT_BINARY_DIR}/localcharset.h")


set(icrt_SOURCES 
	srclib/allocator.c srclib/areadlink.c srclib/binary-io.c srclib/careadlinkat.c srclib/dirname-lgpl.c
	srclib/basename-lgpl.c srclib/stripslash.c srclib/getprogname.c srclib/malloca.c srclib/progname.c 
	srclib/safe-read.c srclib/stat-time.c srclib/unistd.c srclib/uniwidth/width.c srclib/xmalloc.c srclib/xstrdup.c 
	srclib/xreadlink.c srclib/progreloc.c srclib/relocatable.c)

INSTALL(TARGETS charset iconv
		LIBRARY DESTINATION lib
		PUBLIC_HEADER DESTINATION include)

