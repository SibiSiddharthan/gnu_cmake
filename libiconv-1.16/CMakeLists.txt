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

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../gcc/cmake-modules)

INCLUDE(UtilityFunctions)

#is true for gcc,clang and msvc on windows
set(STDC_HEADERS 1)

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

check_functions_declarations(clearerr_unlocked feof_unlocked ferror_unlocked fflush_unlocked fgets_unlocked fputc_unlocked
	fputs_unlocked fread_unlocked fwrite_unlocked getchar_unlocked getc_unlocked program_invocation_name program_invocation_short_name
	putchar_unlocked putc_unlocked setenv strerror_r __argv)

check_functions(canonicalize_file_name copy_file_range dcgettext getcwd getc_unlocked getexecname getprogname gettext iconv lstat 
	mbrtowc mbsinit memmove raise readlink readlinkat realpath setenv setlocale strerror_r symlink tsearch wcrtomb)


check_c_headers( alloca.h dlfcn.h inttypes.h limits.h mach-o/dyld.h memory.h search.h stdint.h stdlib.h strings.h string.h
	sys/bitypes.h sys/inttypes.h sys/param.h sys/socket.h sys/stat.h sys/time.h sys/types.h unistd.h wchar.h winsock2.h	)

check_types( "unsigned long long int" "long long int" wchar_t wint_t _Bool)

set(_structs st_atimensec st_atimespec.tv_nsec st_atim.st__tim.tv_nsec st_atim.tv_nsec 
	st_birthtimensec st_birthtimespec.tv_nsec st_birthtim.tv_nsec)
check_stat_struct_members(_structs)

#default options
set(ENABLE_EXTRA 1)
#set(ENABLE_NLS 1)
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
# include <stddef.h>
# include <stdio.h>
# include <time.h>
#endif
#include <wchar.h>
              int verify[sizeof (wint_t) < sizeof (int) ? -1 : 1];

int
main ()
{

  ;
  return 0;
}"
GNULIB_OVERRIDES_WINT_T)
if(NOT GNULIB_OVERRIDES_WINT_T)
set(BITSIZEOF_WINT_T 32)
endif()

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


if ("${CMAKE_C_COMPILER_ID}" STREQUAL "GNU" OR "${CMAKE_C_COMPILER_ID}" STREQUAL "Clang")
set(HAVE_VISIBILITY 1)
set(restrict __restrict)
set(INCLUDE_NEXT include_next)
endif()

#Not building a shared library
#if(WIN32)
#set(DLL_VARIABLE "__declspec\ (dllimport)")
#endif()


configure_file(libiconv-config.in config.h)
configure_file(libcharset/include/localcharset.h.build.in localcharset.h @ONLY)
configure_file(libcharset/include/localcharset.h.in ${CMAKE_CURRENT_BINARY_DIR}/install/localcharset.h @ONLY)
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
configure_file(include/iconv.h.in ${CMAKE_CURRENT_BINARY_DIR}/install/iconv.h @ONLY)


if(WIN32)
if(NOT DEFINED ICONV-PATCHED)
execute_process(COMMAND patch -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/fix-pointer-buf.patch
				 WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
set(ICONV-PATCHED TRUE CACHE BOOL "Apply patch only once")
endif()
endif()

set(charset_SOURCES 
	libcharset/lib/localcharset.c libcharset/lib/relocatable-stub.c ${CMAKE_CURRENT_BINARY_DIR}/libcharset.h )
add_library(charset STATIC ${charset_SOURCES})
target_compile_definitions(charset PRIVATE BUILDING_LIBCHARSET HAVE_CONFIG_H )
target_compile_options(charset PRIVATE -fvisibility=hidden)
target_include_directories(charset PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
#Not building a shared library
#if(WIN32)
#target_compile_definitions(charset_objs PRIVATE DLL_EXPORT PIC)
#endif()

#add_library(charset_static STATIC)
#set_target_properties(charset_static PROPERTIES ARCHIVE_OUTPUT_NAME "charset")
#target_link_libraries(charset_static charset_objs)
#
#add_library(charset_shared SHARED)
#set_target_properties(charset_shared PROPERTIES RUNTIME_OUTPUT_NAME "charset-1" LIBRARY_OUTPUT_NAME "charset")
#target_link_libraries(charset_shared charset_objs)

set(iconv_SOURCES
	libcharset/lib/localcharset.c lib/iconv.c lib/relocatable.c ${CMAKE_CURRENT_BINARY_DIR}/iconv.h ${CMAKE_CURRENT_BINARY_DIR}/localcharset.h)
if(WIN32)
#list(APPEND iconv_SOURCES woe32dll/iconv-exports.c)
add_custom_command(OUTPUT libiconv.res.o
					COMMAND windres -DPACKAGE_VERSION_STRING=\\\\\\\"1.16\\\\\\\" -DPACKAGE_VERSION_MAJOR=1 -DPACKAGE_VERSION_MINOR=16 -DPACKAGE_VERSION_SUBMINOR=0 -i ../windows/libiconv.rc --output-format=coff  -o libiconv.res.o)
list(APPEND iconv_SOURCES libiconv.res.o)
endif()
add_library(iconv STATIC ${iconv_SOURCES})
target_compile_definitions(iconv PRIVATE BUILDING_LIBICONV HAVE_CONFIG_H ENABLE_RELOCATABLE=1 IN_LIBRARY NO_XMALLOC set_relocation_prefix=libiconv_set_relocation_prefix relocate=libiconv_relocate relocate2=libiconv_relocate2)
target_compile_options(iconv PRIVATE -fvisibility=hidden)
target_include_directories(iconv PRIVATE ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/gnulib-local/lib ${CMAKE_CURRENT_SOURCE_DIR})
#if(WIN32)
#target_compile_definitions(iconv_objs PRIVATE DLL_EXPORT PIC)
#endif()

#add_library(iconv_static STATIC)
#set_target_properties(iconv_static PROPERTIES ARCHIVE_OUTPUT_NAME "iconv")
#target_link_libraries(iconv_static iconv_objs)
#
#add_library(iconv_shared SHARED)
#set_target_properties(iconv_shared PROPERTIES RUNTIME_OUTPUT_NAME "iconv-2" ARCHIVE_OUTPUT_NAME "iconv")
#target_link_libraries(iconv_shared iconv_objs)

INSTALL(TARGETS charset iconv 
		LIBRARY DESTINATION lib
		RUNTIME DESTINATION bin)
INSTALL(FILES ${CMAKE_CURRENT_BINARY_DIR}/install/iconv.h ${CMAKE_CURRENT_BINARY_DIR}/install/localcharset.h ${CMAKE_CURRENT_BINARY_DIR}/libcharset.h DESTINATION include)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/unitypes.h ${CMAKE_CURRENT_BINARY_DIR}/uniwidth.h
					COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/srclib/unitypes.in.h ${CMAKE_CURRENT_BINARY_DIR}/unitypes.h
					COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/srclib/uniwidth.in.h ${CMAKE_CURRENT_BINARY_DIR}/uniwidth.h)


add_custom_target(icrt_deps DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/unitypes.h ${CMAKE_CURRENT_BINARY_DIR}/uniwidth.h)

set(icrt_SOURCES
	basename-lgpl.c binary-io.c error.c getprogname.c progname.c safe-read.c uniwidth/width.c xmalloc.c)
if(WIN32)
list(APPEND icrt_SOURCES msvc-inval.c msvc-nothrow.c)
endif()
list(TRANSFORM icrt_SOURCES PREPEND "srclib/")


add_library(icrt STATIC ${icrt_SOURCES})
target_include_directories(icrt PRIVATE ${CMAKE_CURRENT_BINARY_DIR} srclib lib)
target_compile_options(icrt PRIVATE -DHAVE_CONFIG_H -DEXEEXT=\".exe\" -DDEPENDS_ON_LIBICONV=1 -DDEPENDS_ON_LIBINTL)
add_dependencies(icrt icrt_deps)


INCLUDE(Ctest)
enable_testing()

set(iconv_tests table-from table-to test-shiftseq test-to-wchar genutf8 gengb18030z)
foreach(t ${iconv_tests})
	add_executable(${t} tests/${t})
	target_link_libraries(${t} icrt iconv )
	target_include_directories(${t} PRIVATE include srclib ${CMAKE_CURRENT_BINARY_DIR})
	set_target_properties(${t} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tests")
endforeach()
add_test(test-shiftseq ${CMAKE_CURRENT_BINARY_DIR}/tests/test-shiftseq)
add_test(test-to-wchar ${CMAKE_CURRENT_BINARY_DIR}/tests/test-to-wchar)

if(WIN32)
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/res/iconv.res.o
					COMMAND windres -DPACKAGE_VERSION_STRING=\\\\\\\"1.16\\\\\\\" -DPACKAGE_VERSION_MAJOR=1 -DPACKAGE_VERSION_MINOR=16 -DPACKAGE_VERSION_SUBMINOR=0 -i ${CMAKE_CURRENT_SOURCE_DIR}/windows/iconv.rc -o ${CMAKE_CURRENT_BINARY_DIR}/res/iconv.res.o --output-format=coff)
set(iconv_win32 ${CMAKE_CURRENT_BINARY_DIR}/res/iconv.res.o)
endif()
add_executable(iconv_t src/iconv.c ${iconv_win32})
target_link_libraries(iconv_t icrt iconv)
target_include_directories(iconv_t PRIVATE include srclib ${CMAKE_CURRENT_BINARY_DIR})


set(TEST_EXE ${CMAKE_CURRENT_BINARY_DIR}/iconv_t)
configure_file(check-stateful.sh.in check-stateful.sh @ONLY) 

set(stateful_checks
	UCS-2BE UCS-2LE UCS-4BE UCS-4LE UTF-16 UTF-16BE UTF-16LE UTF-32 UTF-32BE UTF-32LE UTF-7 CP1255 CP1258 TCVN ISO-2022-JP 
	ISO-2022-JP-2 ISO-2022-JP-1 ISO-2022-JP-MS ISO-2022-CN ISO-2022-CN-EXT 
	HZ BIG5-HKSCS:1999 BIG5-HKSCS:2001 BIG5-HKSCS:2004 BIG5-HKSCS:2008 ISO-2022-KR ISO-2022-JP-3)


foreach(i ${stateful_checks})
 	add_test(${i}-stateful sh check-stateful.sh ${CMAKE_CURRENT_SOURCE_DIR}/tests ${i})
endforeach()

set(TABLE_FROM ${CMAKE_CURRENT_BINARY_DIR}/tests/table-from)
set(TABLE_TO ${CMAKE_CURRENT_BINARY_DIR}/tests/table-to)
configure_file(check-stateless.sh.in check-stateless.sh @ONLY) 

set(stateless_checks
	ASCII ISO-8859-1 ISO-8859-2 ISO-8859-3 ISO-8859-4 ISO-8859-5 ISO-8859-6 ISO-8859-7 ISO-8859-8 ISO-8859-9 ISO-8859-10 ISO-8859-11 ISO-8859-13 
	ISO-8859-14 ISO-8859-15 ISO-8859-16 KOI8-R KOI8-U KOI8-RU CP1250 CP1251 CP1252 CP1253 CP1254 CP1255 CP1256 CP1257 CP1258 CP850 CP862 CP866 
	CP1131 MacRoman MacCentralEurope MacIceland MacCroatian MacRomania MacCyrillic MacUkraine MacGreek MacTurkish MacHebrew MacArabic MacThai HP-ROMAN8
	NEXTSTEP ARMSCII-8 Georgian-Academy Georgian-PS KOI8-T PT154 RK1048 MuleLao-1 CP1133 TIS-620 CP874 VISCII TCVN ISO646-JP JIS_X0201 ISO646-CN 
	ISO-IR-165 EUC-JP SHIFT_JIS CP932 EUC-CN GBK CP936 EUC-TW BIG5 CP950 BIG5-HKSCS:1999 BIG5-HKSCS:2001 BIG5-HKSCS:2004 BIG5-HKSCS:2008 EUC-KR
	CP949 JOHAB CP856 CP922 CP1046 CP1124 CP1129 CP1161 CP1162 CP1163 DEC-KANJI DEC-HANYU CP437 CP737 CP775 CP852 CP853 CP855 CP857 CP858 CP860
	CP861 CP863 CP864 CP865 CP869 CP1125 EUC-JISX0213 SHIFT_JISX0213 BIG5-2003 TDS565 ATARIST RISCOS-LATIN1)

foreach(i ${stateless_checks})
 	add_test(${i}-stateless sh check-stateless.sh ${CMAKE_CURRENT_SOURCE_DIR}/tests ${i})
endforeach()

configure_file(check-translit.sh.in check-translit.sh @ONLY) 
configure_file(check-translitfailure.sh.in check-translitfailure.sh @ONLY) 
configure_file(check-subst.sh.in check-subst.sh @ONLY) 

 add_test(translit1 sh check-translit.sh ${CMAKE_CURRENT_SOURCE_DIR}/tests Quotes UTF-8 ISO-8859-1)
 add_test(translit2 sh check-translit.sh ${CMAKE_CURRENT_SOURCE_DIR}/tests Quotes UTF-8 ASCII)
 add_test(translit3 sh check-translit.sh ${CMAKE_CURRENT_SOURCE_DIR}/tests Translit1 ISO-8859-1 ASCII)
 add_test(translitfailure sh check-translitfailure.sh ${CMAKE_CURRENT_SOURCE_DIR}/tests TranslitFail1 ISO-8859-1 ASCII)
 add_test(subst sh check-subst.sh )

add_custom_command(OUTPUT  ${CMAKE_CURRENT_BINARY_DIR}/UTF-8.TXT ${CMAKE_CURRENT_BINARY_DIR}/GB18030.TXT ${CMAKE_CURRENT_BINARY_DIR}/GB18030.IRREVERSIBLE.TXT
					COMMAND ${CMAKE_CURRENT_BINARY_DIR}/tests/genutf8 > UTF-8.TXT
					COMMAND cat ${CMAKE_CURRENT_SOURCE_DIR}/tests/GB18030-BMP.TXT > t-GB18030.TXT && ${CMAKE_CURRENT_BINARY_DIR}/tests/gengb18030z >> t-GB18030.TXT && cat ${CMAKE_CURRENT_BINARY_DIR}/t-GB18030.TXT | sort > ${CMAKE_CURRENT_BINARY_DIR}/GB18030.TXT
					COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/tests/GB18030.IRREVERSIBLE.TXT ${CMAKE_CURRENT_BINARY_DIR}/GB18030.IRREVERSIBLE.TXT
					DEPENDS genutf8 gengb18030z)

add_custom_target(iconv_test_files ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/UTF-8.TXT ${CMAKE_CURRENT_BINARY_DIR}/GB18030.TXT ${CMAKE_CURRENT_BINARY_DIR}/GB18030.IRREVERSIBLE.TXT)

add_test(genutf8 sh check-stateless.sh ${CMAKE_CURRENT_BINARY_DIR} UTF-8)
add_test(gengb18030z sh check-stateless.sh ${CMAKE_CURRENT_BINARY_DIR} GB18030)

#PATCH error.c L 205
#PATCH progname.h L 46-48
