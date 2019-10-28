# Sections
# 1. libiberty
# 2. lto-plugin
# 3. libbacktrace
# 4. libdecnumber
# 5. libcpp
# 6. gcc (gcc,g++,cc1,cc1plus,gcov)
# 7. libgcc
# 8. libstdc++
# 9. libatomic
# 10. libgomp
# 11. libquadmath
# 12. libssp


cmake_minimum_required(VERSION 3.14)
PROJECT(gcc C CXX ASM)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../cmake-modules)
INCLUDE(UtilityFunctions)
INCLUDE(CommonChecks)
INCLUDE(GCCChecks)
INCLUDE(CheckCSourceCompiles)
INCLUDE(CheckCXXSourceCompiles)
INCLUDE(CheckCXXSourceRuns)
INCLUDE(CheckCSourceRuns)
INCLUDE(CheckCXXSymbolExists)
INCLUDE(CheckStructHasMember)

include(CTest)
enable_testing()

#need to eloborate
if(NOT DEFINED DEP_PATH)
message(FATAL_ERROR "add root of gmp,mpfr,mpc,isl")
endif()

if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
	message(FATAL_ERROR "In-source builds not allowed. Please make a new directory")
endif()

set(PACKAGE \"gcc\")
set(PACKAGE_BUGREPORT \"isl-development@googlegroups.com\")
set(PACKAGE_NAME \"isl\")
set(PACKAGE_STRING \"isl 0.21\")
set(PACKAGE_TARNAME "isl")
set(PACKAGE_URL \"\")
set(PACKAGE_VERSION \"0.21\")
set(VERSION \"0.21\")

#[[
if(WIN32)
if(NOT DEFINED GCC-PATCHED)
execute_process(
	COMMAND patch -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0002-Relocate-libintl.patch
	COMMAND patch -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0003-Windows-Follow-Posix-dir-exists-semantics-more-close.patch
	COMMAND patch -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0004-Windows-Use-not-in-progpath-and-leave-case-as-is.patch
	COMMAND patch -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0006-Windows-New-feature-to-allow-overriding.patch
	COMMAND patch -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0009-gcc-make-xmmintrin-header-cplusplus-compatible-depre.patch
	COMMAND patch -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0010-Fix-using-large-PCH.patch
	COMMAND patch -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0012-Handle-spaces-in-path-for-default-manifest.patch
	COMMAND patch -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0014-gcc-9-branch-clone_function_name_1-Retain-any-stdcall-suffix.patch
	COMMAND patch -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0130-libstdc++-in-out.patch
	COMMAND patch -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0140-gcc-8.2.0-diagnostic-color.patch
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
set(GCC-PATCHED TRUE CACHE BOOL "Apply patch only once")
endif()
endif()
]]

#is true for gcc,clang and msvc on windows
set(STDC_HEADERS 1)

#check
set(HAVE_isl 1)

if(WIN32)
add_compile_definitions(__USE_MINGW_ACCESS)
endif()

#################################################
#      libiberty
################################################


check_c_headers(alloca.h fcntl.h inttypes.h limits.h malloc.h memory.h process.h stdint.h stdlib.h
			stdio_ext.h strings.h string.h sys/file.h sys/param.h sys/prctl.h sys/mman.h
			sys/pstat.h sys/resource.h sys/sysctl.h sys/sysinfo.h sys/sysmp.h sys/systemcfg.h
			sys/table.h sys/time.h sys/wait.h sys/stat.h sys/types.h time.h unistd.h vfork.h machine/hal_sysinfo.h)

check_types(int long "long long" size_t intptr_t uintptr_t)

check_functions(asprintf atexit basename bcmp bcopy bsearch bzero calloc canonicalize_file_name clock
				dup3 ffs fork getcwd getpagesize getrlimit getrusage getsysinfo gettimeofday index
				insque memchr memcmp memcpy memmem memmove memset mkstemps mmap on_exit pipe2 psignal
				pstat_getdynamic pstat_getstatic putenv random realpath rename rindex sbrk
				setproctitle setrlimit sigsetmask snprintf spawnve spawnvpe stpcpy stpncpy strcasecmp
				strchr strdup strerror strncasecmp strndup strnlen strrchr strsignal strstr strtod
				strtol strtoll strtoul strtoull strverscmp sysconf sysctl sysmp table times tmpnam
				vasprintf vfork vfprintf vprintf vsprintf wait3 wait4 waitpid _doprnt __fsetlocking mempcpy vsnprintf)

check_functions_declarations(asprintf basename calloc ffs getenv getopt malloc realloc sbrk 
							snprintf strnlen strtol strtoll strtoul strtoull strverscmp vasprintf vsnprintf)

set(UNSIGNED_64BIT_TYPE uint64_t)
if(NOT HAVE_CANONICALIZE_FILE_NAME)
set(NEED_DECLARATION_CANONICALIZE_FILE_NAME 1)
endif()

check_c_source_compiles("
#include <errno.h>
int
main ()
{
int x = errno;
  ;
  return 0;
}"
DECLARATION_ERRNO)
if(NOT DECLARATION_ERRNO)
set(NEED_DECLARATION_ERRNO 1)
endif()

check_c_source_compiles("
#include <sys/systemcfg.h>
int
main ()
{
double x = _system_configuration.physmem;
  ;
  return 0;
}"
HAVE__SYSTEM_CONFIGURATION)

list(APPEND _c_include stdio.h)
if(HAVE_SYS_TYPES_H)
list(APPEND _c_include sys/types.h)
endif()
if(HAVE_SYS_STAT_H)
list(APPEND _c_include sys/stat.h)
endif()
if( HAVE_STDLIB_H)
list(APPEND _c_include stdlib.h)
endif()
if(HAVE_STDDEF_H)
list(APPEND _c_include stddef.h)
endif()
if( HAVE_STRING_H)
list(APPEND _c_include string.h)
endif()
if( HAVE_STRINGS_H)
list(APPEND _c_include strings.h)
endif()
if( HAVE_INTTYPES_H)
list(APPEND _c_include inttypes.h)
endif()
if( HAVE_STDINT_H)
list(APPEND _c_include stdint.h)
endif()
if( HAVE_UNISTD_H)
list(APPEND _c_include unistd.h)
endif()

list(TRANSFORM _c_include PREPEND "#include<")
list(TRANSFORM _c_include APPEND ">\n")

check_c_source_runs("
${_c_include}
int
main ()
{

	  /* By Ruediger Kuhlmann. */
	  return fork () < 0;

  ;
  return 0;
}"
HAVE_WORKING_FORK)

check_c_source_runs("
${_c_include}
#include <sys/wait.h>
#ifdef HAVE_VFORK_H
# include <vfork.h>
#endif
/* On some sparc systems, changes by the child to local and incoming
   argument registers are propagated back to the parent.  The compiler
   is told about this with #include <vfork.h>, but some compilers
   (e.g. gcc -O) don't grok <vfork.h>.  Test for this by using a
   static variable whose address is put into a register that is
   clobbered by the vfork.  */
static void
#ifdef __cplusplus
sparc_address_test (int arg)
# else
sparc_address_test (arg) int arg;
#endif
{
  static pid_t child;
  if (!child) {
    child = vfork ();
    if (child < 0) {
      perror (\"vfork\");
      _exit(2);
    }
    if (!child) {
      arg = getpid();
      write(-1, \"\", 0);
      _exit (arg);
    }
  }
}

int
main ()
{
  pid_t parent = getpid ();
  pid_t child;

  sparc_address_test (0);

  child = vfork ();

  if (child == 0) {
    /* Here is another test for sparc vfork register problems.  This
       test uses lots of local variables, at least as many local
       variables as main has allocated so far including compiler
       temporaries.  4 locals are enough for gcc 1.40.3 on a Solaris
       4.1.3 sparc, but we use 8 to be safe.  A buggy compiler should
       reuse the register of parent for one of the local variables,
       since it will think that parent can't possibly be used any more
       in this routine.  Assigning to the local variable will thus
       munge parent in the parent process.  */
    pid_t
      p = getpid(), p1 = getpid(), p2 = getpid(), p3 = getpid(),
      p4 = getpid(), p5 = getpid(), p6 = getpid(), p7 = getpid();
    /* Convince the compiler that p..p7 are live; otherwise, it might
       use the same hardware register for all 8 local variables.  */
    if (p != p1 || p != p2 || p != p3 || p != p4
	|| p != p5 || p != p6 || p != p7)
      _exit(1);

    /* On some systems (e.g. IRIX 3.3), vfork doesn't separate parent
       from child file descriptors.  If the child closes a descriptor
       before it execs or exits, this munges the parent's descriptor
       as well.  Test for this by closing stdout in the child.  */
    _exit(close(fileno(stdout)) != 0);
  } else {
    int status;
    struct stat st;

    while (wait(&status) != child)
      ;
    return (
	 /* Was there some problem with vforking?  */
	 child < 0

	 /* Did the child fail?  (This shouldn't happen.)  */
	 || status

	 /* Did the vfork/compiler bug occur?  */
	 || parent != getpid()

	 /* Did the file descriptor bug occur?  */
	 || fstat(fileno(stdout), &st) != 0
	 );
  }
}"
HAVE_WORKING_VFORK)

if(NOT HAVE_WORKING_FORK)
set(vfork fork)
endif()

#No Idea
set(HAVE_SYS_ERRLIST 1)
set(HAVE_SYS_NERR 1)

configure_file(libiberty-config.h.in ${CMAKE_BINARY_DIR}/libiberty/config.h)

set(libiberty_SOURCES
	regex.c cplus-dem.c cp-demangle.c md5.c sha1.c alloca.c		
	argv.c	choose-temp.c concat.c	cp-demint.c crc32.c d-demangle.c	
	dwarfnames.c dyn-string.c fdmatch.c fibheap.c				
	filename_cmp.c floatformat.c fnmatch.c fopen_unlocked.c			
	getopt.c getopt1.c getpwd.c	getruntime.c hashtab.c hex.c	
	lbasename.c lrealpath.c	make-relative-prefix.c make-temp-file.c	
	objalloc.c	obstack.c partition.c pexecute.c physmem.c	
	pex-common.c pex-one.c	vprintf-support.c		
	rust-demangle.c	safe-ctype.c simple-object.c simple-object-coff.c	
	simple-object-elf.c simple-object-mach-o.c	simple-object-xcoff.c					
	sort.c spaces.c	splay-tree.c stack-limit.c	strerror.c strsignal.c			
	timeval-utils.c unlink-if-ordinary.c xasprintf.c xatexit.c xexit.c	
	xmalloc.c xmemdup.c xstrdup.c xstrerror.c xstrndup.c			
	xvasprintf.c)
if(WIN32)
list(APPEND libiberty_SOURCES pex-win32.c)
else()
list(APPEND libiberty_SOURCES pex-unix.c)
endif()

set(libiberty_extra_OBJS
	asprintf atexit basename bcmp bcopy bsearch bzero calloc
 	clock ffs getcwd getpagesize gettimeofday index insque
 	memchr memcmp memcpy memmem memmove mempcpy	memset 	mkstemps
	putenv random rename rindex	setenv snprintf sigsetmask stpcpy stpncpy
 	strcasecmp 	strchr 	strdup 	strncasecmp strndup	strnlen	strrchr	strstr
	strtod 	strtol	strtoul	strtoll strtoull strverscmp	tmpnam
 	vasprintf vfprintf vprintf vsnprintf vsprintf waitpid setproctitle vfork)
foreach(i ${libiberty_extra_OBJS})
	string(TOUPPER ${i} v)
	if(NOT HAVE_${v})
	list(APPEND libiberty_SOURCES ${i}.c)
	endif()
endforeach()


list(TRANSFORM libiberty_SOURCES PREPEND "libiberty/")
add_library(iberty STATIC ${libiberty_SOURCES})
target_compile_definitions(iberty PRIVATE HAVE_CONFIG_H _GNU_SOURCE)
target_include_directories(iberty PUBLIC include
								  PRIVATE ${CMAKE_BINARY_DIR}/libiberty)

#TESTS
set(libiberty_tests
	test-pexecute test-expandargv test-strtol demangler-fuzzer)

foreach(tt ${libiberty_tests})
	add_executable(${tt} libiberty/testsuite/${tt}.c)
	add_dependencies(${tt} iberty)
	target_compile_definitions(${tt} PRIVATE HAVE_CONFIG_H)
	target_include_directories(${tt} PRIVATE ${CMAKE_BINARY_DIR}/libiberty)
	target_link_libraries(${tt} iberty)
	set_target_properties(${tt} PROPERTIES
							RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tests/libiberty")
	add_test(${tt} ${CMAKE_CURRENT_BINARY_DIR}/tests/libiberty/${tt})
endforeach()
	add_executable(test-demangle libiberty/testsuite/test-demangle.c)
	add_dependencies(test-demangle iberty)
	target_compile_definitions(test-demangle PRIVATE HAVE_CONFIG_H)
	target_include_directories(test-demangle PRIVATE ${CMAKE_BINARY_DIR}/libiberty)
	target_link_libraries(test-demangle iberty)
	set_target_properties(test-demangle PROPERTIES
							RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tests/libiberty")
	if(WIN32)
	add_test(test-demangle "${CMAKE_CURRENT_BINARY_DIR}/tests/libiberty/test-demangle.exe < ${CMAKE_CURRENT_SOURCE_DIR}/libiberty/testsuite/demangle-expected")
	else()
	add_test(test-demangle "${CMAKE_CURRENT_BINARY_DIR}/tests/libiberty/test-demangle < ${CMAKE_CURRENT_SOURCE_DIR}/libiberty/testsuite/demangle-expected")
	endif()
#########################################################################################

#######################################################################################
####              LTO-PLUGIN
#######################################################################################

check_c_headers(inttypes.h memory.h stdint.h stdlib.h strings.h string.h sys/stat.h sys/types.h
				sys/wait.h unistd.h)
configure_file(lto-plugin-config.h.in ${CMAKE_CURRENT_BINARY_DIR}/lto-plugin/config.h)
add_library(lto_plugin SHARED lto-plugin/lto-plugin.c)
target_compile_definitions(lto_plugin PRIVATE HAVE_CONFIG_H PIC)
if(WIN32)
target_compile_definitions(lto_plugin PRIVATE DLL_EXPORT)
endif()
target_compile_options(lto_plugin PRIVATE -static-libstdc++ -static-libgcc)
target_link_libraries(lto_plugin iberty)
add_dependencies(lto_plugin iberty)
target_include_directories(lto_plugin PRIVATE /lto-plugin /include ${CMAKE_BINARY_DIR}/lto-plugin)
set_target_properties(lto_plugin PROPERTIES RUNTIME_OUTPUT_NAME "lto_plugin-0")


#######################################################################################
####                   LIBCPP
#######################################################################################

INCLUDE(ICONVChecks)

check_c_headers(alloca.h fcntl.h inttypes.h limits.h locale.h memory.h stddef. stdint.h 
				stdlib.h strings.h string.h sys/file.h sys/stat.h sys/types.h unistd.h)

check_functions(clearerr_unlocked feof_unlocked  ferror_unlocked fflush_unlocked 
				fgetc_unlocked fgets_unlocked  fileno_unlocked fprintf_unlocked 
				fputc_unlocked fputs_unlocked  fread_unlocked fwrite_unlocked 
				getchar_unlocked getc_unlocked   putchar_unlocked putc_unlocked)

check_functions_declarations(abort asprintf basename clearerr_unlocked errno
							 feof_unlocked ferror_unlocked fflush_unlocked fgetc_unlocked fgets_unlocked
							 fileno_unlocked fprintf_unlocked fputc_unlocked fputs_unlocked
							 fread_unlocked fwrite_unlocked	getchar_unlocked getc_unlocked
							 putchar_unlocked putc_unlocked getopt vasprintf)

check_types(int long uintptr_t)

check_include_file(langinfo.h HAVE_LANGINFO_CODESET)

set(ENABLE_ASSERT_CHECKING 1)
set(ENABLE_CANONICAL_SYSTEM_HEADERS 1)

check_c_source_compiles("
int
main ()
{
asm (\"pcmpestri %0, %%xmm0, %%xmm1\" : : \"i\"(0))
  ;
  return 0;
}"
HAVE_SSE4)

configure_file(libcpp-config.h.in ${CMAKE_CURRENT_BINARY_DIR}/libcpp/config.h)
set(libcpp_SOURCES
	charset.c directives.c directives-only.c errors.c expr.c files.c identifiers.c
	init.c lex.c line-map.c macro.c mkdeps.c pch.c symtab.c traditional.c)

#localdir.h is for nls, not needed here
set(libcpp_HEADERS
	include/cpplib.h include/line-map.h include/mkdeps.h include/symtab.h system.h)
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libcpp/localedir.h
					COMMAND echo "#define LOCALEDIR \"/mingw64/share/locale\"" > ${CMAKE_CURRENT_BINARY_DIR}/libcpp/localedir.h)	
#set(libcpp_gen_HEADER)
#set_source_files_properties(${libcpp_gen_HEADER} PROPERTIES GENERATED TRUE)
add_custom_target(libcpp_gen DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/libcpp/localedir.h)

list(TRANSFORM libcpp_SOURCES PREPEND "libcpp/")
list(TRANSFORM libcpp_HEADERS PREPEND "libcpp/")
set_source_files_properties(${libcpp_SOURCES} PROPERTIES LANGUAGE CXX)

add_library(cpp STATIC ${libcpp_SOURCES} ${libcpp_HEADERS} ${libcpp_gen_HEADER})
target_include_directories(cpp PRIVATE  libcpp ${CMAKE_BINARY_DIR}/libcpp libcpp/include )
#target_compile_options(cpp PRIVATE -IC:/Development/mingw64/x86_64-w64-mingw32/include)
target_link_libraries(cpp iberty)
add_dependencies(cpp libcpp_gen)

##############################################################################
#####      LIBBACKTRACE
##############################################################################
check_c_headers(dlfcn.h inttypes.h link.h memory.h stdint.h 
				stdlib.h strings.h string.h sys/stat.h sys/types.h unistd.h sys/ldr.h
				sys/mman.h)

check_functions(clock_gettime fcntl lstat readlink)

check_functions_declarations(strnlen)

check_types(char int long short "void *")

#[[
set(CMAKE_REQUIRED_LIBRARIES z)
check_c_source_compiles("
char compress ();
int
main ()
{
return compress ();
  ;
  return 0;
}"
HAVE_ZLIB )
unset(CMAKE_REQUIRED_LIBRARIES)
]]

check_c_source_compiles("
#include \"unwind.h\"
	struct _Unwind_Context *context;
	int ip_before_insn = 0;
int
main ()
{
return _Unwind_GetIPInfo (context, &ip_before_insn);
  ;
  return 0;
}"
HAVE_GETIPINFO)

set(HAVE_ZLIB 1)
if(WIN32)
set(BACKTRACE_ELF_SIZE unused)
set(BACKTRACE_XCOFF_SIZE unused)
endif()

if(HAVE_LINK_H)
set(HAVE_DL_ITERATE_PHDR 1)
endif()

if(HAVE_SYS_LDR_H)
set(HAVE_LOADQUERY 1)
endif()

check_c_source_compiles("
int i;
int
main ()
{
__atomic_load_n (&i, __ATOMIC_ACQUIRE);
		       __atomic_store_n (&i, 1, __ATOMIC_RELEASE);
  ;
  return 0;
}"
HAVE_ATOMIC_FUNCTIONS)


configure_file(libbacktrace-config.h.in ${CMAKE_CURRENT_BINARY_DIR}/libbacktrace/config.h)

check_c_source_compiles("
#include <sys/mman.h>
#if !defined(MAP_ANONYMOUS) && !defined(MAP_ANON)
  #error no MAP_ANONYMOUS
#endif"
BACKTRACE_MALLOC)
if(BACKTRACE_MALLOC)
set(BACKTRACE_USES_MALLOC 0)
else()
set(BACKTRACE_USES_MALLOC 1)
endif()

if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
set(BACKTRACE_SUPPORTED 1)
endif()

check_c_source_compiles("
int i;
int
main ()
{
__sync_bool_compare_and_swap (&i, i, i);
                       __sync_lock_test_and_set (&i, 1);
                       __sync_lock_release (&i);
  ;
  return 0;
}"
HAVE_SYNC_FUNCTIONS)
if(HAVE_SYNC_FUNCTIONS)
set(HAVE_SYNC_FUNCTIONS 1)
set(BACKTRACE_SUPPORTS_THREADS 1)
else()
set(BACKTRACE_SUPPORTS_THREADS 0)
endif()

if(WIN32)
set(BACKTRACE_SUPPORTS_DATA 0)
else()
set(BACKTRACE_SUPPORTS_DATA 1)
endif()

configure_file(libbacktrace/backtrace-supported.h.in ${CMAKE_CURRENT_BINARY_DIR}/libbacktrace/backtrace-supported.h @ONLY)

set(libbacktrace_SOURCES
	backtrace.h atomic.c dwarf.c fileline.c internal.h posix.c print.c 
	sort.c state.c backtrace.c simple.c nounwind.c)
if(WIN32)
set(libbacktrace_FORMAT pecoff.c)
elseif(UNIX)
set(libbacktrace_FORMAT elf.c)
endif()

set(libbacktrace_VIEW_UNIX mmapio.c mmap.c)
set(libbacktrace_VIEW_WIN32 read.c alloc.c)

if(BACKTRACE_USES_MALLOC EQUAL 0)
set(libbacktrace_VIEW ${libbacktrace_VIEW_UNIX})
elseif(BACKTRACE_USES_MALLOC EQUAL 1)
set(libbacktrace_VIEW ${libbacktrace_VIEW_WIN32})
endif()

list(TRANSFORM libbacktrace_SOURCES PREPEND "libbacktrace/")
list(TRANSFORM libbacktrace_FORMAT PREPEND "libbacktrace/")
list(TRANSFORM libbacktrace_VIEW PREPEND "libbacktrace/")
list(TRANSFORM libbacktrace_VIEW_UNIX PREPEND "libbacktrace/")
list(TRANSFORM libbacktrace_VIEW_WIN32 PREPEND "libbacktrace/")


add_library(backtrace STATIC ${libbacktrace_SOURCES} ${libbacktrace_FORMAT} ${libbacktrace_VIEW})
target_compile_options(backtrace PRIVATE -funwind-tables -W -Wall -Wwrite-strings -Wstrict-prototypes -Wmissing-prototypes -Wold-style-definition -Wmissing-format-attribute -Wcast-qual)
target_include_directories(backtrace PRIVATE include libgcc libbacktrace ${CMAKE_CURRENT_BINARY_DIR}/libbacktrace)
target_compile_definitions(backtrace PRIVATE HAVE_CONFIG_H PIC)
if(WIN32)
target_compile_definitions(backtrace PRIVATE DLL_EXPORT)
endif()

#####
##TESTS
#####
add_library(backtrace_alloc STATIC ${libbacktrace_SOURCES} ${libbacktrace_FORMAT} ${libbacktrace_VIEW_WIN32})
target_compile_options(backtrace_alloc PUBLIC -funwind-tables -W -Wall -Wwrite-strings -Wstrict-prototypes -Wmissing-prototypes -Wold-style-definition -Wmissing-format-attribute -Wcast-qual)
target_include_directories(backtrace_alloc PUBLIC include libgcc libbacktrace ${CMAKE_CURRENT_BINARY_DIR}/libbacktrace)
target_compile_definitions(backtrace_alloc PUBLIC HAVE_CONFIG_H PIC)
if(WIN32)
target_compile_definitions(backtrace_alloc PUBLIC DLL_EXPORT)
endif()

add_library(backtrace_noformat STATIC ${libbacktrace_SOURCES} ${libbacktrace_VIEW})
target_compile_options(backtrace_noformat PUBLIC -funwind-tables -W -Wall -Wwrite-strings -Wstrict-prototypes -Wmissing-prototypes -Wold-style-definition -Wmissing-format-attribute -Wcast-qual)
target_include_directories(backtrace_noformat PUBLIC include libgcc libbacktrace ${CMAKE_CURRENT_BINARY_DIR}/libbacktrace)
target_compile_definitions(backtrace_noformat PUBLIC HAVE_CONFIG_H PIC)
if(WIN32)
target_compile_definitions(backtrace_noformat PUBLIC DLL_EXPORT)
endif()

add_library(backtrace_instrumented_alloc STATIC ${libbacktrace_SOURCES} ${libbacktrace_FORMAT} libbacktrace/read.c libbacktrace/instrumented_alloc.c)
target_compile_options(backtrace_instrumented_alloc PUBLIC -funwind-tables -W -Wall -Wwrite-strings -Wstrict-prototypes -Wmissing-prototypes -Wold-style-definition -Wmissing-format-attribute -Wcast-qual)
target_include_directories(backtrace_instrumented_alloc PUBLIC include libgcc libbacktrace ${CMAKE_CURRENT_BINARY_DIR}/libbacktrace)
target_compile_definitions(backtrace_instrumented_alloc PUBLIC HAVE_CONFIG_H PIC)
if(WIN32)
target_compile_definitions(backtrace_instrumented_alloc PUBLIC DLL_EXPORT)
endif()

add_executable(allocfail libbacktrace/allocfail.c libbacktrace/testlib.c)
target_link_libraries(allocfail backtrace_instrumented_alloc)

add_executable(unittest libbacktrace/testlib.c libbacktrace/unittest.c)
target_link_libraries(unittest backtrace)
target_compile_options(unittest PRIVATE -funwind-tables -W -Wall -Wwrite-strings -Wstrict-prototypes -Wmissing-prototypes -Wold-style-definition -Wmissing-format-attribute -Wcast-qual)
target_include_directories(unittest PRIVATE include libgcc libbacktrace ${CMAKE_CURRENT_BINARY_DIR}/libbacktrace)
target_compile_definitions(unittest PRIVATE HAVE_CONFIG_H PIC)
if(WIN32)
target_compile_definitions(unittest PRIVATE DLL_EXPORT)
endif()

add_executable(unittest_alloc libbacktrace/testlib.c libbacktrace/unittest.c)
target_link_libraries(unittest_alloc backtrace_alloc)

if(WIN32)
add_executable(test_format libbacktrace/testlib.c libbacktrace/test_format.c)
target_link_libraries(test_format backtrace_noformat)
elseif(UNIX)
add_executable(test_format libbacktrace/testlib.c libbacktrace/test_format.c)
target_link_libraries(test_format backtrace_noformat)
endif()

#add_test(unittest)
###########################################################################################
#############   LIBDECNUMBER
###########################################################################################

check_c_headers(ctype.h inttypes.h memory.h stddef.h stdint.h stdio.h stdlib.h
				strings.h string.h sys/stat.h sys/types.h unistd.h)

check_types(int long char short "void *")

configure_file(libdecnumber-config.h.in ${CMAKE_CURRENT_BINARY_DIR}/libdecnumber/config.h)
configure_file(gstdint.h ${CMAKE_CURRENT_BINARY_DIR}/libdecnumber/gstdint.h)
set(libdecnumber_common_SOURCES
	decContext.c decContext.h decDPD.h decNumber.c decNumber.h decNumberLocal.h 
	decContextSymbols.h decDPDSymbols.h decNumberSymbols.h)

set(libdecnumber_arch_SOURCES
	bid2dpd_dpd2bid.c  decimal128.c       decimal128Symbols.h  decimal32Symbols.h  decimal64Symbols.h  host-ieee64.c
	bid2dpd_dpd2bid.h  decimal128.h       decimal32.c          decimal64.c         host-ieee128.c
	bid-dpd.h          decimal128Local.h  decimal32.h          decimal64.h         host-ieee32.c )

list(TRANSFORM libdecnumber_common_SOURCES PREPEND "libdecnumber/")
list(TRANSFORM libdecnumber_arch_SOURCES PREPEND "libdecnumber/bid/")

add_library(decnumber STATIC ${libdecnumber_common_SOURCES} ${libdecnumber_arch_SOURCES})
target_compile_options(decnumber PRIVATE -W -Wall -Wwrite-strings -Wstrict-prototypes -Wmissing-prototypes -Wold-style-definition -Wmissing-format-attribute -Wcast-qual -pedantic -Wno-long-long  -fno-lto)
target_include_directories(decnumber PRIVATE libdecnumber ${CMAKE_CURRENT_BINARY_DIR}/libdecnumber)
if(WIN32)
target_compile_definitions(decnumber PRIVATE )
endif()

############################################################################################
#############    GCC-BACKEND
###########################################################################################


####################
##  Configuring
###################

if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
set(AS_COMPRESS_DEBUG_OPTION \"--compress-debug-sections\")
set(AS_NO_COMPRESS_DEBUG_OPTION \"--nocompress-debug-sections\")
set(HAVE_AS_COMPRESS_DEBUG 1)
set(HAVE_AS_DEBUG_PREFIX_MAP 1)
set(HAVE_AS_DWARF2_DEBUG_LINE 1)
set(HAVE_AS_DWARF2_DEBUG_VIEW 1)
set(HAVE_AS_GDWARF2_DEBUG_FLAG 1)
set(HAVE_AS_GSTABS_DEBUG_FLAG 1)
set(HAVE_GNU_AS 1)
set(HAVE_GNU_INDIRECT_FUNCTION "0 ")
set(HAVE_GNU_LD 1)
set(LD_AS_NEEDED_OPTION  \"--push-state\ --as-needed\")
set(LD_COMPRESS_DEBUG_OPTION \"--compress-debug-sections\")
set(LD_DYNAMIC_OPTION \"-Bdynamic\")
set(LD_NO_AS_NEEDED_OPTION \"--pop-state\")
set(LD_STATIC_OPTION \"-Bstatic\")
set(LTOPLUGINSONAME \"liblto_plugin-0.dll\")
set(HAVE_COMDAT_GROUP "0 ")

set(HAVE_LD_ALIGNED_SHF_MERGE 1)
set(HAVE_LD_AS_NEEDED 1)
set(HAVE_LD_BUILDID 1)
set(HAVE_LD_COMPRESS_DEBUG 3)
set(HAVE_LD_DEMANGLE 1)
set(HAVE_LD_EH_FRAME_CIEV3 1)
set(HAVE_LD_PIE 1)
set(HAVE_LD_PIE_COPYRELOC "0 ")
set(HAVE_LD_PUSHPOPSTATE_SUPPORT 1)
set(HAVE_LD_STATIC_DYNAMIC 1)
set(HAVE_LD_SYSROOT 1)
endif()

set(ENABLE_ASSERT_CHECKING 1)
set(DIAGNOSTICS_COLOR_DEFAULT DIAGNOSTICS_COLOR_YES)
set(DEFAULT_STK_CLASH_GUARD_SIZE 0)
set(DEFAULT_USE_CXA_ATEXIT 2)
set(ENABLE_DECIMAL_BID_FORMAT 1)
set(ENABLE_DECIMAL_FLOAT 1)
set(ENABLE_FIXED_POINT "0 ")
set(ENABLE_LIBQUADMATH_SUPPORT 1)
set(ENABLE_LTO 1)
set(ENABLE_OFFLOADING "0 ")
set(ENABLE_RUNTIME_CHECKING 1)
set(ENABLE_VTABLE_VERIFY "0 ")
set(EXTRA_MODES_FILE \"config/i386/i386-modes.def\")
set(GATHER_STATISTICS "0 ")
set(HAVE_LTO_PLUGIN 2)
set(ENABLE_PLUGIN 1)

set(caddr_t char*)
set(rlim_t long)

set(OFFLOAD_TARGETS \"\")
set(PACKAGE_BUGREPORT \"\")
set(PACKAGE_NAME \"\")
set(PACKAGE_STRING \"\")
set(PACKAGE_TARNAME \"\")
set(PACKAGE_URL \"\")
set(PACKAGE_VERSION \"\")
set(PLUGIN_LD_SUFFIX \"ld\")
if(WIN32)
set(TARGET_GLIBC_MAJOR "0 ")
set(TARGET_GLIBC_MINOR "0 ")
endif()


set(tls_section_flag T)

check_c_headers(direct.h dlfcn.h fcntl.h ftw.h iconv.h inttypes.h langinfo.h
				ldfcn.h limits.h locale.h malloc.h memcheck.h memory.h stddef.h 
				stdint.h stdlib.h strings.h string.h sys/file.h sys/mman.h
				sys/param.h sys/resource.h sys/sdt.h sys/stat.h sys/times.h sys/time.h
				sys/types.h sys/wait.h time.h unistd.h valgrind/memcheck.h vfork.h wchar.h)
check_cxx_headers(ext/hash_map tr1/unordered_map unordered_map)

check_types(int long "long long" short "void *" intmax_t intptr_t "long long int" uintmax_t
			uintptr_t "unsigned long long int")

check_functions(atoq clearerr_unlocked clock feof_unlocked ferror_unlocked fflush_unlocked 
				fgetc_unlocked fgets_unlocked fileno_unlocked fork fprintf_unlocked fputc_unlocked
				fputs_unlocked fread_unlocked fwrite_unlocked getchar_unlocked getc_unlocked
				getrlimit getrusage gettimeofday kill madvise mbstowcs mmap nl_langinfo popen
				putchar_unlocked putc_unlocked setlocale setrlimit strsignal sysconf times vfork wcswidth)

check_functions_declarations(abort asprintf atof atol atoll basename calloc clearerr_unlocked clock
							errno feof_unlocked ferror_unlocked fflush_unlocked ffs fgetc_unlocked fgets_unlocked
							fileno_unlocked fputc_unlocked fputs_unlocked fread_unlocked free fwrite_unlocked getchar_unlocked
							getc_unlocked getcwd getenv getopt getpagesize getrlimit getrusage getwd ldgetname
							madvise malloc putchar_unlocked putc_unlocked realloc sbrk setenv setrlimit signaltstack
							snprintf stpcpy strnlen strsignal strstr strtol strtoll strtoul strtoull strverscmp
							times unsetenv vasprintf vsnprintf)

#[[
check_cxx_source_compiles("
#include <sys/cdefs.h>
#include <sys/signal.h>
#include <ucontext.h>
int main() { mcontext_t m; if (m->ss.srr0) return 0; return 0; }
"
MCONTEXT_T_UNDERSCORES)
if(NOT MCONTEXT_T_UNDERSCORES)
set(HAS_MCONTEXT_T_UNDERSCORES 1)
endif()
]]
INCLUDE(CheckASMSourceCompiles)

check_asm_source_compiles("
.gnu_attribute 4,1"
HAVE_AS_GNU_ATTRIBUTE)

check_asm_source_compiles("
.text
.L0:
nop
.data
.long .L0@GOTOFF"
HAVE_AS_GOTOFF_IN_DATA)

check_asm_source_compiles("
cmovl.l %edx, %eax"
HAVE_AS_IX86_CMOV_SUN_SYNTAX)

check_asm_source_compiles("
.section .rodata
.L1:
        .long .L2-.L1
        .long .L3-.L1
        .text
.L3:    nop
.L2:    nop"
HAVE_AS_IX86_DIFF_SECT_DELTA)

check_asm_source_compiles("
ffreep %st(1)"
HAVE_AS_IX86_FFREEP)

check_asm_source_compiles("
fildq (%ebp); fistpq (%ebp)"
HAVE_AS_IX86_FILDQ)

check_asm_source_compiles("
filds (%ebp); fists (%ebp)"
HAVE_AS_IX86_FILDS)

check_asm_source_compiles("
.data
bar:
	.byte 1
	.text
	.global _start
_start:
	 cmpl $0, bar@GOT
	 jmp *_start@GOT"
HAVE_AS_IX86_GOT32X)

check_asm_source_compiles("
lock xacquire cmpxchg %esi, (%ecx)"
HAVE_AS_IX86_HLE)

check_asm_source_compiles("
.code64
       movq %mm0, %rax
       movq %rax, %xmm0"
HAVE_AS_IX86_INTERUNIT_MOVQ)

check_asm_source_compiles("
.quad 0"
HAVE_AS_IX86_QUAD)

check_asm_source_compiles("
rep movsl
	 rep ret
	 rep nop
	 rep bsf %ecx, %eax
	 rep bsr %ecx, %eax
	 lock addl %edi, (%eax,%esi)
	 lock orl $0, (%esp)"
HAVE_AS_IX86_REP_LOCK_PREFIX)

check_asm_source_compiles("
.code64
       sahf"
HAVE_AS_IX86_SAHF)

check_asm_source_compiles("
movl.s %esp, %ebp"
HAVE_AS_IX86_SWAP)

check_asm_source_compiles("
call    tls_gd@tlsgdplt"
HAVE_AS_IX86_TLSGDPLT)

check_asm_source_compiles("
.section .text,\"ax\",@progbits
        .globl  _start
        .type   _start, @function
_start:
	leal	value@tlsldm(%ebx), %eax
	call	___tls_get_addr@plt

        .section .tdata,\"aw'${tls_section_flag}'\",@progbits
        .type	value, @object
value:"
HAVE_AS_IX86_TLSLDM)

check_asm_source_compiles("
.section .tdata,\"aw'${tls_section_flag}'\",@progbits
tls_ld:
	.section .text,\"ax\",@progbits
	 call    tls_ld@tlsldmplt"
HAVE_AS_IX86_TLSLDMPLT)

check_asm_source_compiles("
.section .text,\"ax\",@progbits
	.globl  _start
	.type   _start, @function
_start:
	leal	ld@tlsldm(%ecx), %eax
	call	*___tls_get_addr@GOT(%ecx)
	leal	gd@tlsgd(%ecx), %eax
	call	*___tls_get_addr@GOT(%ecx)

	.section .tdata,\"aw'${tls_section_flag}'\",@progbits
	.type	ld, @object
ld:
	.byte 0
	.globl  gd
	.type	gd, @object
gd:
	.byte 0"
HAVE_AS_IX86_TLS_GET_ADDR_GOT)

check_asm_source_compiles("
ud2"
HAVE_AS_IX86_UD2)

check_asm_source_compiles("
.set nomacro
	.text
	ldq	$27, a($29)	!literal!1
	jsr	$26, ($27), a	!lituse_jsrdirect!1"
HAVE_AS_JSRDIRECT_RELOCS)

check_asm_source_compiles("
.data
	.uleb128 L2 - L1
L1:
	.uleb128 1280
	.sleb128 -1010
L2:"
HAVE_AS_LEB128)

check_asm_source_compiles("
.text
       .register %g2, #scratch
       .register %g3, #scratch
       .align 4
       smac %g2, %g3, %g1
       umac %g2, %g3, %g1
       casa [%g2] 0xb, %g3, %g1"
HAVE_AS_LEON)

check_asm_source_compiles("
# 1 \"test.s\" 1
# 0 \"\" 2
"
HAVE_AS_LINE_ZERO)

check_asm_source_compiles("
.text
	addl r15 = @ltoffx(x#), gp
	;;
	ld8.mov r16 = [r15], x#"
HAVE_AS_LTOFFX_LDXMOV_RELOCS)

check_asm_source_compiles("
	.machinemode push
	.machinemode pop
	.machine push
	.machine pop"
HAVE_AS_MACHINE_MACHINEMODE)

check_asm_source_compiles("
.stabs \"gcc2_compiled.\",60,0,0,0"
HAVE_AS_STABS_DIRECTIVE)

check_asm_source_compiles("
.comm foo,1,32"
HAVE_GAS_ALIGNED_COMM)

check_asm_source_compiles("
.balign 4
.p2align 2"
HAVE_GAS_BALIGN_AND_P2ALIGN)

check_asm_source_compiles("
.text
	.cfi_startproc
	.cfi_adjust_cfa_offset 64
	.skip 75040, 0
	.cfi_adjust_cfa_offset 128
	.cfi_endproc"
HAVE_GAS_CFI_DIRECTIVE)

check_asm_source_compiles("
.text
	.cfi_startproc
	.cfi_personality 0, symbol
	.cfi_endproc"
HAVE_GAS_CFI_PERSONALITY_DIRECTIVE)

check_asm_source_compiles("
.text
	.cfi_sections .debug_frame, .eh_frame
	.cfi_startproc
	.cfi_endproc"
HAVE_GAS_CFI_SECTIONS_DIRECTIVE)

check_asm_source_compiles("
	.text
	.file 1 \"conf.c\"
	.loc 1 1 0 discriminator 1"
HAVE_GAS_DISCRIMINATOR)

check_asm_source_compiles("
.lcomm bar,4,16"
HAVE_GAS_LCOMM_WITH_ALIGNMENT)

check_asm_source_compiles("
.literal16"
HAVE_GAS_LITERAL16)

check_asm_source_compiles("
	.text
	.file 1 \"conf.c\"
	.loc 1 1 0 is_stmt 1"
HAVE_GAS_LOC_STMT)

check_asm_source_compiles("
.p2align 4,,7"
HAVE_GAS_MAX_SKIP_P2ALIGN)

check_asm_source_compiles("
	.SPACE $TEXT$
	.NSUBSPA $CODE$,COMDAT"
HAVE_GAS_NSUBSPA_COMDAT)

check_asm_source_compiles("
.text
foo:	nop
.data
	.secrel32 foo"
HAVE_GAS_PE_SECREL32_RELOC)

check_asm_source_compiles("
.byte 0,0,0,0"
HAVE_GAS_SECTION_EXCLUDE)

check_asm_source_compiles("
.section .rodata.str, \"aMS\", %progbits, 1"
HAVE_GAS_SHF_MERGE)

check_asm_source_compiles("
conftest_label1: .word 0
.subsection -1
conftest_label2: .word 0
.previous"
HAVE_GAS_SUBSECTION_ORDERING)

check_asm_source_compiles("
	.weak foobar"
HAVE_GAS_WEAK)

check_asm_source_compiles("
.weakref foobar, barfnot"
HAVE_GAS_WEAKREF)

#check_symbol_exists(clock_t "time.h" HAVE_CLOCK_T)
set(HAVE_CLOCK_T 1)
set(HAVE_SWAP_IN_UTILITY 1)
check_symbol_exists(tms "sys/times.h" HAVE_STRUCT_TMS)
#check_cxx_symbol_exists(swap "utility" HAVE_SWAP_IN_UTILITYi)
#check_struct_has_member(tms )

check_cxx_source_runs("
#include <stdlib.h>
int main()
{
  mbstowcs(0, \"\", 0);
  return 0;
}"
HAVE_WORKING_MBSTOWCS)

#[[
check_cxx_source_compiles("
#include <sys/types.h>
#ifdef HAVE_SYS_STAT_H
# include <sys/stat.h>
#endif
#ifdef HAVE_UNISTD_H
# include <unistd.h>
#endif
#ifdef HAVE_DIRECT_H
# include <direct.h>
#endif
int
main ()
{
mkdir (\"foo\", 0);
  ;
  return 0;
}"
MKDIR_TAKES_ONE_ARG)
]]
set(MKDIR_TAKES_ONE_ARG 1)
set(USE_LONG_LONG_FOR_WIDEST_FAST_INT 1)
set(PREFIX_INCLUDE_DIR \"/mingw64/include\")

configure_file(gcc-config.h.in ${CMAKE_CURRENT_BINARY_DIR}/gcc/auto-host.h )

#if(WIN32)
#set(EXTRA_INCLUDES "#include\ \"config/i386/xm-mingw32.h\"")
#endif()
#configure_file(gcc.in ${CMAKE_CURRENT_BINARY_DIR}/gcc/config.h )
configure_file(bversion.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/bversion.h )
configure_file(plugin-version.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/plugin-version.h )
configure_file(configargs.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/configargs.h )
configure_file(gcc-driver-name.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/gcc-driver-name.h )
configure_file(multilib.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/multilib.h )

#########################################
## Building Generators
#########################################



if(WIN32)
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/config.h
				COMMAND set TARGET_CPU_DEFAULT=
				COMMAND set HEADERS=auto-host.h ansidecl.h config/i386/xm-mingw32.h
				COMMAND set DEFINES=
				COMMAND sh ${CMAKE_CURRENT_SOURCE_DIR}/gcc/mkconfig.sh config.h
				COMMAND mv ${CMAKE_CURRENT_BINARY_DIR}/config.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/config.h)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/bconfig.h
				COMMAND set TARGET_CPU_DEFAULT=
				COMMAND set HEADERS=auto-host.h ansidecl.h config/i386/xm-mingw32.h
				COMMAND set DEFINES=
				COMMAND sh ${CMAKE_CURRENT_SOURCE_DIR}/gcc/mkconfig.sh bconfig.h
				COMMAND mv ${CMAKE_CURRENT_BINARY_DIR}/bconfig.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/bconfig.h)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/tconfig.h
				COMMAND set TARGET_CPU_DEFAULT=
				COMMAND set HEADERS=auto-host.h ansidecl.h config/i386/xm-mingw32.h
				COMMAND set DEFINES=USED_FOR_TARGET
				COMMAND sh ${CMAKE_CURRENT_SOURCE_DIR}/gcc/mkconfig.sh tconfig.h
				COMMAND mv ${CMAKE_CURRENT_BINARY_DIR}/tconfig.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/tconfig.h)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/tm.h
				COMMAND set TARGET_CPU_DEFAULT=
				COMMAND set HEADERS=options.h insn-constants.h config/vxworks-dummy.h config/i386/biarch64.h config/i386/i386.h config/i386/unix.h config/i386/bsd.h config/i386/gas.h config/dbxcoff.h config/i386/cygming.h config/i386/mingw-pthread.h config/i386/mingw32.h config/i386/mingw-w64.h config/i386/mingw-stdint.h config/initfini-array.h defaults.h
				COMMAND set DEFINES=LIBC_GLIBC=1 LIBC_UCLIBC=2 LIBC_BIONIC=3 LIBC_MUSL=4
				COMMAND sh ${CMAKE_CURRENT_SOURCE_DIR}/gcc/mkconfig.sh tm.h
				COMMAND mv ${CMAKE_CURRENT_BINARY_DIR}/tm.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/tm.h)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/tm_d.h
				COMMAND set TARGET_CPU_DEFAULT=
				COMMAND set HEADERS=options.h insn-constants.h config/i386/i386.h config/i386/i386-protos.h defaults.h
				COMMAND set DEFINES=
				COMMAND sh ${CMAKE_CURRENT_SOURCE_DIR}/gcc/mkconfig.sh tm_d.h
				COMMAND mv ${CMAKE_CURRENT_BINARY_DIR}/tm_d.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/tm_d.h)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/tm_p.h
				COMMAND set TARGET_CPU_DEFAULT=
				COMMAND set HEADERS=config/i386/i386-protos.h tm-preds.h
				COMMAND set DEFINES=
				COMMAND sh ${CMAKE_CURRENT_SOURCE_DIR}/gcc/mkconfig.sh tm_p.h
				COMMAND mv ${CMAKE_CURRENT_BINARY_DIR}/tm_p.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/tm_p.h)

elseif(UNIX)
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/config.h
				COMMAND TARGET_CPU_DEFAULT=
				COMMAND HEADERS=\"auto-host.h ansidecl.h \"
				COMMAND DEFINES=\"\"
				COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/gcc/mkconfig.sh  config.h
				COMMAND mv ${CMAKE_CURRENT_BINARY_DIR}/config.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/config.h)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/bconfig.h
				COMMAND TARGET_CPU_DEFAULT=
				COMMAND HEADERS=\"auto-host.h ansidecl.h \"
				COMMAND DEFINES=\"\"
				COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/gcc/mkconfig.sh bconfig.h
				COMMAND mv ${CMAKE_CURRENT_BINARY_DIR}/bconfig.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/bconfig.h)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/tconfig.h
				COMMAND TARGET_CPU_DEFAULT=
				COMMAND HEADERS=\"auto-host.h ansidecl.h config/i386/xm-mingw32.h\"
				COMMAND DEFINES=\"USED_FOR_TARGET\"
				COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/gcc/mkconfig.sh tconfig.h
				COMMAND mv ${CMAKE_CURRENT_BINARY_DIR}/tconfig.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/tconfig.h)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/tm.h
				COMMAND TARGET_CPU_DEFAULT=
				COMMAND HEADERS=\"options.h insn-constants.h config/vxworks-dummy.h config/i386/biarch64.h config/i386/i386.h config/i386/unix.h config/i386/att.h config/dbxelf.h config/elfos.h config/gnu-user.h config/glibc-stdint.h config/i386/x86-64.h config/i386/gnu-user-common.h config/i386/gnu-user64.h config/linux.h config/linux-android.h config/i386/linux-common.h config/i386/linux64.h config/initfini-array.h defaults.h\"
				COMMAND DEFINES=\"LIBC_GLIBC=1 LIBC_UCLIBC=2 LIBC_BIONIC=3 LIBC_MUSL=4 DEFAULT_LIBC=LIBC_GLIBC ANDROID_DEFAULT=0\"
				COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/gcc/mkconfig.sh  tm.h
				COMMAND mv ${CMAKE_CURRENT_BINARY_DIR}/tm.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/tm.h)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/tm_d.h
				COMMAND TARGET_CPU_DEFAULT=
				COMMAND HEADERS=\"options.h insn-constants.h config/i386/i386.h config/i386/i386-protos.h defaults.h\"
				COMMAND DEFINES=\"\"
				COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/gcc/mkconfig.sh tm_d.h
				COMMAND mv ${CMAKE_CURRENT_BINARY_DIR}/tm_d.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/tm_d.h)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/tm_p.h
				COMMAND TARGET_CPU_DEFAULT=
				COMMAND HEADERS=\"config/i386/i386-protos.h tm-preds.h\"
				COMMAND DEFINES=
				COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/gcc/mkconfig.sh tm_p.h
				COMMAND mv ${CMAKE_CURRENT_BINARY_DIR}/tm_p.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/tm_p.h)
endif()

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/tmp-limits.h
					COMMAND cat ${CMAKE_CURRENT_SOURCE_DIR}/gcc/limitx.h ${CMAKE_CURRENT_SOURCE_DIR}/gcc/glimits.h ${CMAKE_CURRENT_SOURCE_DIR}/gcc/limity.h > ${CMAKE_CURRENT_BINARY_DIR}/gcc/tmp-limits.h)

add_custom_target(gen_deps DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/gcc/tmp-limits.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/config.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/bconfig.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/tconfig.h
							${CMAKE_CURRENT_BINARY_DIR}/gcc/tm.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/tm_d.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/tm_p.h)

add_library(gen-helper INTERFACE )
target_include_directories(gen-helper INTERFACE gcc gcc/build include libcpp/include ${CMAKE_BINARY_DIR}/gcc)
target_compile_definitions(gen-helper INTERFACE IN_GCC HAVE_CONFIG_H GENERATOR_FILE)
target_compile_options(gen-helper INTERFACE -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -W -Wall -Wno-narrowing -Wwrite-strings -Wcast-qual -Wmissing-format-attribute -Woverloaded-virtual -pedantic -Wno-long-long -Wno-variadic-macros -Wno-overlength-strings)
target_link_options(gen-helper INTERFACE -static-libstdc++ -static-libgcc)
target_link_libraries(gen-helper INTERFACE iberty)
add_dependencies(gen-helper gen_deps)

set(genmodes_SOURCES
	gcc/genmodes.c gcc/errors.c)

set_source_files_properties(${genmodes_SOURCES} PROPERTIES LANGUAGE CXX)
add_executable(genmodes ${genmodes_SOURCES})
target_link_libraries(genmodes gen-helper )
set_target_properties(genmodes PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/build)

set(genconstants_SOURCES
	gcc/genconstants.c gcc/errors.c gcc/read-md.c )
set_source_files_properties(${genconstants_SOURCES} PROPERTIES LANGUAGE CXX)
add_executable(genconstants ${genconstants_SOURCES})
target_link_libraries(genconstants gen-helper )
set_target_properties(genconstants PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/build)


add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/gcc/insn-modes.h
				COMMAND ${CMAKE_BINARY_DIR}/build/genmodes -h > ${CMAKE_BINARY_DIR}/gcc/insn-modes.h
				DEPENDS genmodes)

add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/gcc/insn-modes-inline.h
				COMMAND ${CMAKE_BINARY_DIR}/build/genmodes -i > ${CMAKE_BINARY_DIR}/gcc/insn-modes-inline.h
				DEPENDS genmodes)

add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/gcc/min-insn-modes.c
				COMMAND ${CMAKE_BINARY_DIR}/build/genmodes -m > ${CMAKE_BINARY_DIR}/gcc/min-insn-modes.c
				DEPENDS genmodes)

add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/gcc/insn-modes.c
				COMMAND ${CMAKE_BINARY_DIR}/build/genmodes  > ${CMAKE_BINARY_DIR}/gcc/insn-modes.c
				DEPENDS genmodes)

add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/gcc/optionslist
				COMMAND gawk -f ${CMAKE_CURRENT_SOURCE_DIR}/gcc/opt-gather.awk ${CMAKE_CURRENT_SOURCE_DIR}/gcc/ada/gcc-interface/lang.opt ${CMAKE_CURRENT_SOURCE_DIR}/gcc/brig/lang.opt ${CMAKE_CURRENT_SOURCE_DIR}/gcc/d/lang.opt ${CMAKE_CURRENT_SOURCE_DIR}/gcc/fortran/lang.opt ${CMAKE_CURRENT_SOURCE_DIR}/gcc/go/lang.opt ${CMAKE_CURRENT_SOURCE_DIR}/gcc/lto/lang.opt ${CMAKE_CURRENT_SOURCE_DIR}/gcc/c-family/c.opt ${CMAKE_CURRENT_SOURCE_DIR}/gcc/common.opt ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/fused-madd.opt ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386.opt ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/cygming.opt ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/mingw.opt ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/mingw-w64.opt >${CMAKE_BINARY_DIR}/gcc/optionslist)

add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/gcc/options.h
				COMMAND gawk -f ${CMAKE_CURRENT_SOURCE_DIR}/gcc/opt-functions.awk -f ${CMAKE_CURRENT_SOURCE_DIR}/gcc/opt-read.awk  -f ${CMAKE_CURRENT_SOURCE_DIR}/gcc/opth-gen.awk  < ${CMAKE_BINARY_DIR}/gcc/optionslist > ${CMAKE_BINARY_DIR}/gcc/options.h
				DEPENDS ${CMAKE_BINARY_DIR}/gcc/optionslist)


add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/gcc/insn-constants.h
				COMMAND ${CMAKE_BINARY_DIR}/build/genconstants ${CMAKE_CURRENT_SOURCE_DIR}/gcc/common.md ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386.md  > ${CMAKE_BINARY_DIR}/gcc/insn-constants.h
				DEPENDS genconstants)

add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/gcc/all-tree.def
				COMMAND echo "#include \"tree.def\"" > ${CMAKE_BINARY_DIR}/gcc/all-tree.def
				COMMAND echo "END_OF_BASE_TREE_CODES" >> ${CMAKE_BINARY_DIR}/gcc/all-tree.def
				COMMAND echo "#include \"c-family/c-common.def\"" >> ${CMAKE_BINARY_DIR}/gcc/all-tree.def
				COMMAND echo "#include \"ada/gcc-interface/ada-tree.def\"" >> ${CMAKE_BINARY_DIR}/gcc/all-tree.def
				COMMAND echo "#include \"cp/cp-tree.def\"" >> ${CMAKE_BINARY_DIR}/gcc/all-tree.def
				COMMAND echo "#include \"d/d-tree.def\"" >> ${CMAKE_BINARY_DIR}/gcc/all-tree.def
				COMMAND echo "#include \"objc/objc-tree.def\"" >> ${CMAKE_BINARY_DIR}/gcc/all-tree.def)

add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/gcc/case-cfn-macros.h
					COMMAND ${CMAKE_BINARY_DIR}/build/gencfn-macros -c > ${CMAKE_BINARY_DIR}/gcc/case-cfn-macros.h
					DEPENDS gencfn-macros)

add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/gcc/gencondmd.c
				COMMAND COMMAND ${CMAKE_BINARY_DIR}/build/genconditions ${CMAKE_CURRENT_SOURCE_DIR}/gcc/common.md ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386.md >  ${CMAKE_BINARY_DIR}/gcc/gencondmd.c
				DEPENDS genconditions)

add_custom_target(generated_sources_1 DEPENDS ${CMAKE_BINARY_DIR}/gcc/insn-modes.h ${CMAKE_BINARY_DIR}/gcc/insn-modes-inline.h
					${CMAKE_BINARY_DIR}/gcc/min-insn-modes.c ${CMAKE_BINARY_DIR}/gcc/insn-modes.c ${CMAKE_BINARY_DIR}/gcc/options.h)
add_custom_target(generated_sources_2 DEPENDS ${CMAKE_BINARY_DIR}/gcc/insn-constants.h)
add_custom_target(generated_sources_3 DEPENDS ${CMAKE_BINARY_DIR}/gcc/all-tree.def)
add_custom_target(generated_sources_4 DEPENDS ${CMAKE_BINARY_DIR}/gcc/case-cfn-macros.h)
add_custom_target(generated_sources_cond DEPENDS ${CMAKE_BINARY_DIR}/gcc/gencondmd.c)

set(version_c gcc/version.c)
set_source_files_properties(${gen-helper_SOURCES} PROPERTIES LANGUAGE CXX)
add_library(version OBJECT ${version_c})
target_link_libraries(version gen-helper)
target_compile_options(version PRIVATE -DPREFIX=\"/c/Development/mingw64\" -DBASEVER=\"9.2.0\" -DDATESTAMP=\"\" -DREVISION=\"\" -DDEVPHASE=\"\" -DPKGVERSION=\"\(GCC\)\" -DBUGURL=\"<https://gcc.gnu.org/bugs/>\" -DLOCALEDIR=\"/mingw64/share/locale\")

file(RELATIVE_PATH gcc_src ${CMAKE_CURRENT_BINARY_DIR}/gcc ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt)
string(REPLACE "/CMakeLists.txt" "" gcc_src ${gcc_src})

#cheating
if(WIN32)
configure_file(gtyp-input-win.list ${CMAKE_CURRENT_BINARY_DIR}/gcc/gtyp-input.list @ONLY)
elseif(UNIX)
configure_file(gtyp-input-linux.list ${CMAKE_CURRENT_BINARY_DIR}/gcc/gtyp-input.list @ONLY)
endif()
configure_file(gstdint.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/gstdint.h)
set(gengtype_SOURCES
	gcc/gengtype.c gcc/gengtype-lex.c gcc/gengtype-parse.c gcc/gengtype-state.c gcc/errors.c)
set_source_files_properties(${gengtype_SOURCES} PROPERTIES LANGUAGE CXX)
add_executable(gengtype ${gengtype_SOURCES})
set_target_properties(gengtype PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/build)
target_link_libraries(gengtype version gen-helper iberty)

file(RELATIVE_PATH gcc_src ${CMAKE_CURRENT_BINARY_DIR}/gcc ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt)
string(REPLACE "/CMakeLists.txt" "" gcc_src ${gcc_src})
#message("${gcc_src}")

add_custom_COMMAND(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/gtype.state
					COMMAND cd ${CMAKE_CURRENT_BINARY_DIR}/gcc && ${CMAKE_BINARY_DIR}/build/gengtype -S ${gcc_src}/gcc -I gtyp-input.list -w gtype.state
					&& ${CMAKE_BINARY_DIR}/build/gengtype -r gtype.state
					DEPENDS gengtype)	

add_custom_target(gtype
				DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/gcc/gtype.state)	

set(gen-helper_SOURCES
	errors.c rtl.c read-rtl.c ggc-none.c vec.c gensupport.c print-rtl.c hash-table.c sort.cc read-md.c)
list(TRANSFORM gen-helper_SOURCES PREPEND "gcc/")
list(APPEND gen-helper_SOURCES ${CMAKE_BINARY_DIR}/gcc/min-insn-modes.c)
set_source_files_properties(${gen-helper_SOURCES} PROPERTIES LANGUAGE CXX)

add_library(gen-helper_objs OBJECT ${gen-helper_SOURCES})
target_link_libraries(gen-helper_objs gen-helper )
add_dependencies(gen-helper_objs generated_sources_1 generated_sources_2 gtype)

set(genmdeps_SOURCES
	gcc/genmddeps.c )

set(gengenrtl_SOURCES
	gcc/gengenrtl.c)

set(genpreds_SOURCES
	gcc/genpreds.c )

set(genflags_SOURCES
	gcc/genflags.c )

set(genconditions_SOURCES
	gcc/genconditions.c )

set(gencondmd_SOURCES
	${CMAKE_BINARY_DIR}/gcc/gencondmd.c)

set(genattr_SOURCES
	gcc/genattr.c )

set(genattr-common_SOURCES
	gcc/genattr-common.c )

set(gencodes_SOURCES
	gcc/gencodes.c )

set(genconfig_SOURCES
	gcc/genconfig.c )

set(gentarget-def_SOURCES
	gcc/gentarget-def.c )

set(gencheck_SOURCES
	gcc/gencheck.c)

set(genhooks_SOURCES
	gcc/genhooks.c)

set(genopinit_SOURCES
	gcc/genopinit.c )

set(gencfn-macros_SOURCES
	gcc/gencfn-macros.c )

set(genchecksum_SOURCES
	gcc/genchecksum.c)

set(genattrtab_SOURCES
	gcc/genattrtab.c )

set(genautomata_SOURCES
	gcc/genautomata.c )

set(genemit_SOURCES
	gcc/genemit.c )

set(genextract_SOURCES
	gcc/genextract.c )

set(genoutput_SOURCES
	gcc/genoutput.c )

set(genpeep_SOURCES
	gcc/genpeep.c )

set(genrecog_SOURCES
	gcc/genrecog.c gcc/inchash.c)

set(genenums_SOURCES
	gcc/genenums.c )

set(gcov-iov_SOURCES
	gcc/gcov-iov.c)

set(gens_all
	genattr genattr-common genattrtab genautomata gencfn-macros
	gencheck genchecksum gencodes genconditions gencondmd
	 genconfig
	#genconstants
	 genemit genenums genextract genflags gengenrtl
	#gengtype
	 genhooks #genmatch
	 genmdeps genopinit genoutput genpeep
	genpreds genrecog gentarget-def gcov-iov)

foreach(g ${gens_all})
	set_source_files_properties(${${g}_SOURCES} PROPERTIES LANGUAGE CXX)
	add_executable(${g} ${${g}_SOURCES})
	set_target_properties(${g} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/build)
	target_link_libraries(${g} gen-helper_objs)
endforeach()

set(genmatch_SOURCES
	gcc/genmatch.c  gcc/errors.c gcc/vec.c gcc/hash-table.c gcc/sort.cc)
set_source_files_properties(${genmatch_SOURCES} PROPERTIES LANGUAGE CXX)
add_executable(genmatch ${genmatch_SOURCES})
set_target_properties(genmatch PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/build)
target_link_libraries(genmatch cpp gen-helper iconv)

add_dependencies(gencheck generated_sources_3)
add_dependencies(genmatch generated_sources_4)
add_dependencies(gencondmd generated_sources_cond)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/gimple-match.c
					COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genmatch --gimple ${CMAKE_CURRENT_SOURCE_DIR}/gcc/match.pd > ${CMAKE_CURRENT_BINARY_DIR}/gcc/gimple-match.c
					DEPENDS genmatch)	

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/generic-match.c
					COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genmatch --generic ${CMAKE_CURRENT_SOURCE_DIR}/gcc/match.pd > ${CMAKE_CURRENT_BINARY_DIR}/gcc/generic-match.c
					DEPENDS genmatch)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/genrtl.h
					COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/gengenrtl > ${CMAKE_CURRENT_BINARY_DIR}/gcc/genrtl.h
					DEPENDS gengenrtl)	

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/tree-check.h
					COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/gencheck > ${CMAKE_CURRENT_BINARY_DIR}/gcc/tree-check.h
					DEPENDS gencheck)	

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-enums.c
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genenums ${CMAKE_CURRENT_SOURCE_DIR}/gcc/common.md ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386.md  > ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-enums.c
				DEPENDS genenums )

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/gencondmd > ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md
				DEPENDS gencondmd)
	

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-flags.h
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genflags ${CMAKE_CURRENT_SOURCE_DIR}/gcc/common.md ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386.md ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md > ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-flags.h
				DEPENDS genflags ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-attr.h
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genattr ${CMAKE_CURRENT_SOURCE_DIR}/gcc/common.md ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386.md ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md > ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-attr.h
				DEPENDS genattr ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-attr-common.h
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genattr-common ${CMAKE_CURRENT_SOURCE_DIR}/gcc/common.md ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386.md ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md > ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-attr-common.h
				DEPENDS genattr-common ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-codes.h
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/gencodes ${CMAKE_CURRENT_SOURCE_DIR}/gcc/common.md ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386.md ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md > ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-codes.h
				DEPENDS gencodes ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-config.h
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genconfig ${CMAKE_CURRENT_SOURCE_DIR}/gcc/common.md ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386.md ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md > ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-config.h
				DEPENDS genconfig ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-target-def.h
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/gentarget-def ${CMAKE_CURRENT_SOURCE_DIR}/gcc/common.md ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386.md ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md > ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-target-def.h
				DEPENDS gentarget-def ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-emit.c
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genemit ${CMAKE_CURRENT_SOURCE_DIR}/gcc/common.md ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386.md ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md > ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-emit.c
				DEPENDS genemit ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-automata.c
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genautomata ${CMAKE_CURRENT_SOURCE_DIR}/gcc/common.md ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386.md ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md > ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-automata.c
				DEPENDS genautomata ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-output.c
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genoutput ${CMAKE_CURRENT_SOURCE_DIR}/gcc/common.md ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386.md ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md > ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-output.c
				DEPENDS genoutput ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-peep.c
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genpeep ${CMAKE_CURRENT_SOURCE_DIR}/gcc/common.md ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386.md ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md > ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-peep.c
				DEPENDS genpeep ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-preds.c
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genpreds ${CMAKE_CURRENT_SOURCE_DIR}/gcc/common.md ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386.md ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md > ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-preds.c
				DEPENDS genpreds ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-recog.c
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genrecog ${CMAKE_CURRENT_SOURCE_DIR}/gcc/common.md ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386.md ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md > ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-recog.c
				DEPENDS genrecog ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md)				

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-extract.c
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genextract ${CMAKE_CURRENT_SOURCE_DIR}/gcc/common.md ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386.md ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md > ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-extract.c
				DEPENDS genextract ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-attrtab.c ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-dfatab.c ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-latencytab.c
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genattrtab ${CMAKE_CURRENT_SOURCE_DIR}/gcc/common.md ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386.md ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md
						 -A${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-attrtab.c -D${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-dfatab.c -L${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-latencytab.c
				DEPENDS genattrtab ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-opinit.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-opinit.c 
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genopinit ${CMAKE_CURRENT_SOURCE_DIR}/gcc/common.md ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386.md ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md
						 -h${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-opinit.h -c${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-opinit.c 
				DEPENDS genopinit ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-conditions.md)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/gcov-iov.h
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/gcov-iov '9.2.0' '' > ${CMAKE_CURRENT_BINARY_DIR}/gcc/gcov-iov.h
				DEPENDS gcov-iov)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/target-hooks-def.h
					COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genhooks "Target Hook" > ${CMAKE_CURRENT_BINARY_DIR}/gcc/target-hooks-def.h
					DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/build/genhooks)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/common/common-target-hooks-def.h
					COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genhooks "Common Target Hook" > ${CMAKE_CURRENT_BINARY_DIR}/gcc/common/common-target-hooks-def.h
					DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/build/genhooks)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/c-family/c-target-hooks-def.h
					COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genhooks "C Target Hook" > ${CMAKE_CURRENT_BINARY_DIR}/gcc/c-family/c-target-hooks-def.h
					DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/build/genhooks)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/pass-instances.def
					COMMAND gawk -f ${CMAKE_CURRENT_SOURCE_DIR}/gcc/gen-pass-instances.awk  ${CMAKE_CURRENT_SOURCE_DIR}/gcc/passes.def ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386-passes.def > ${CMAKE_CURRENT_BINARY_DIR}/gcc/pass-instances.def)
#NOTE $$ for ninja build only
#TODO generate params.list
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/params.list
				COMMAND ${CMAKE_C_COMPILER} -E ${CMAKE_CURRENT_SOURCE_DIR}/gcc/params-list.h | sed "\"s/^#.*//;/^$$/d\"" > ${CMAKE_CURRENT_BINARY_DIR}/gcc/params.list)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/params.options
				COMMAND ${CMAKE_C_COMPILER} -E ${CMAKE_CURRENT_SOURCE_DIR}/gcc/params-options.h | sed "\"s/^#.*//;/^$$/d\"" > ${CMAKE_CURRENT_BINARY_DIR}/gcc/params.options)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/options-save.c
					COMMAND gawk -f ${CMAKE_CURRENT_SOURCE_DIR}/gcc/opt-functions.awk -f ${CMAKE_CURRENT_SOURCE_DIR}/gcc/opt-read.awk -f ${CMAKE_CURRENT_SOURCE_DIR}/gcc/optc-save-gen.awk 
						       -v header_name='config.h system.h coretypes.h tm.h' < ${CMAKE_CURRENT_BINARY_DIR}/gcc/optionslist > ${CMAKE_CURRENT_BINARY_DIR}/gcc/options-save.c
						DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/gcc/optionslist)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/i386-builtin-types.inc
					COMMAND gawk -f  ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386-builtin-types.awk ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386-builtin-types.def > ${CMAKE_CURRENT_BINARY_DIR}/gcc/i386-builtin-types.inc)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/options.c
					COMMAND gawk -f ${CMAKE_CURRENT_SOURCE_DIR}/gcc/opt-functions.awk -f ${CMAKE_CURRENT_SOURCE_DIR}/gcc/opt-read.awk -f ${CMAKE_CURRENT_SOURCE_DIR}/gcc/optc-gen.awk 
						       -v header_name='config.h system.h coretypes.h options.h tm.h' < ${CMAKE_CURRENT_BINARY_DIR}/gcc/optionslist > ${CMAKE_CURRENT_BINARY_DIR}/gcc/options.c
						DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/gcc/optionslist)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/tm-preds.h
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genpreds -h ${CMAKE_CURRENT_SOURCE_DIR}/gcc/common.md ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386.md >  ${CMAKE_CURRENT_BINARY_DIR}/gcc/tm-preds.h
				DEPENDS genpreds)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/tm-constrs.h
				COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genpreds -c ${CMAKE_CURRENT_SOURCE_DIR}/gcc/common.md ${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/i386.md >  ${CMAKE_CURRENT_BINARY_DIR}/gcc/tm-constrs.h
				DEPENDS genpreds)

add_custom_target(backend_gen_sources
				DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/gcc/gimple-match.c ${CMAKE_CURRENT_BINARY_DIR}/gcc/generic-match.c ${CMAKE_CURRENT_BINARY_DIR}/gcc/genrtl.h
						${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-enums.c ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-flags.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-attr.h
						${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-attr-common.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-config.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-codes.h
						${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-target-def.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-emit.c ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-automata.c
						${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-output.c ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-peep.c ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-preds.c
						${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-recog.c ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-extract.c 
						${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-attrtab.c ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-dfatab.c ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-latencytab.c
						${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-opinit.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/insn-opinit.c ${CMAKE_CURRENT_BINARY_DIR}/gcc/tree-check.h
						${CMAKE_CURRENT_BINARY_DIR}/gcc/pass-instances.def ${CMAKE_CURRENT_BINARY_DIR}/gcc/gcov-iov.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/params.list
						${CMAKE_CURRENT_BINARY_DIR}/gcc/params.options ${CMAKE_CURRENT_BINARY_DIR}/gcc/options-save.c
						${CMAKE_CURRENT_BINARY_DIR}/gcc/target-hooks-def.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/common/common-target-hooks-def.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/c-family/c-target-hooks-def.h
						${CMAKE_CURRENT_BINARY_DIR}/gcc/i386-builtin-types.inc ${CMAKE_CURRENT_BINARY_DIR}/gcc/options.c ${CMAKE_CURRENT_BINARY_DIR}/gcc/tm-preds.h ${CMAKE_CURRENT_BINARY_DIR}/gcc/tm-constrs.h)

set(libbackend_generated_SOURCES
	gimple-match.c generic-match.c insn-attrtab.c insn-dfatab.c
	insn-emit.c insn-extract.c insn-latencytab.c insn-modes.c 
	insn-opinit.c insn-output.c insn-peep.c insn-preds.c insn-automata.c
	insn-recog.c insn-enums.c gtype-desc.c options-save.c)

list(TRANSFORM libbackend_generated_SOURCES PREPEND "${CMAKE_CURRENT_BINARY_DIR}/gcc/")

set(libbackend_SOURCES
	ggc-page.c alias.c alloc-pool.c 
	auto-inc-dec.c auto-profile.c bb-reorder.c bitmap.c 
	bt-load.c builtins.c caller-save.c calls.c ccmp.c 
	cfg.c cfganal.c cfgbuild.c cfgcleanup.c cfgexpand.c 
	cfghooks.c cfgloop.c cfgloopanal.c cfgloopmanip.c cfgrtl.c 
	symtab.c cgraph.c cgraphbuild.c cgraphunit.c cgraphclones.c 
	combine.c combine-stack-adj.c compare-elim.c context.c 
	convert.c coverage.c  
	cprop.c cse.c cselib.c data-streamer.c data-streamer-in.c 
	data-streamer-out.c dbxout.c dbgcnt.c dce.c ddg.c 
	debug.c df-core.c df-problems.c df-scan.c dfp.c 
	dojump.c dominance.c domwalk.c double-int.c dse.c 
	dumpfile.c dwarf2asm.c dwarf2cfi.c dwarf2out.c early-remat.c 
	emit-rtl.c et-forest.c except.c explow.c expmed.c 
	expr.c fibonacci_heap.c file-prefix-map.c final.c 
	fixed-value.c fold-const.c fold-const-call.c function.c 
	function-tests.c fwprop.c gcc-rich-location.c gcse.c 
	gcse-common.c ggc-common.c ggc-tests.c gimple.c 
	gimple-builder.c gimple-expr.c gimple-iterator.c 
	gimple-fold.c gimple-laddress.c gimple-loop-interchange.cc
	gimple-loop-jam.c gimple-loop-versioning.cc gimple-low.c 
	gimple-pretty-print.c gimple-ssa-backprop.c gimple-ssa-evrp.c 
	gimple-ssa-evrp-analyze.c gimple-ssa-isolate-paths.c gimple-ssa-nonnull-compare.c 
	gimple-ssa-split-paths.c gimple-ssa-store-merging.c gimple-ssa-strength-reduction.c 
	gimple-ssa-sprintf.c gimple-ssa-warn-alloca.c gimple-ssa-warn-restrict.c 
	gimple-streamer-in.c gimple-streamer-out.c gimple-walk.c 
	gimplify.c gimplify-me.c godump.c graph.c graphds.c 
	graphite.c graphite-isl-ast-to-gimple.c graphite-dependences.c 
	graphite-optimize-isl.c graphite-poly.c graphite-scop-detection.c 
	graphite-sese-to-poly.c haifa-sched.c hash-map-tests.c 
	hash-set-tests.c hsa-common.c hsa-gen.c hsa-regalloc.c 
	hsa-brig.c hsa-dump.c hw-doloop.c hwint.c ifcvt.c 
	ree.c inchash.c incpath.c init-regs.c internal-fn.c 
	ipa-cp.c ipa-devirt.c ipa-fnsummary.c ipa-polymorphic-call.c 
	ipa-split.c ipa-inline.c ipa-comdats.c ipa-visibility.c 
	ipa-inline-analysis.c ipa-inline-transform.c ipa-predicate.c 
	ipa-profile.c ipa-prop.c ipa-param-manipulation.c 
	ipa-pure-const.c ipa-icf.c ipa-icf-gimple.c ipa-reference.c 
	ipa-hsa.c ipa-ref.c ipa-utils.c ipa.c ira.c ira-build.c 
	ira-costs.c ira-conflicts.c ira-color.c ira-emit.c 
	ira-lives.c jump.c langhooks.c lcm.c lists.c loop-doloop.c 
	loop-init.c loop-invariant.c loop-iv.c loop-unroll.c lower-subreg.c 
	lra.c lra-assigns.c lra-coalesce.c lra-constraints.c lra-eliminations.c 
	lra-lives.c lra-remat.c lra-spills.c lto-cgraph.c lto-streamer.c 
	lto-streamer-in.c lto-streamer-out.c lto-section-in.c lto-section-out.c 
	lto-opts.c lto-compress.c mcf.c mode-switching.c modulo-sched.c 
	multiple_target.c omp-offload.c omp-expand.c omp-general.c 
	omp-grid.c omp-low.c omp-simd-clone.c opt-problem.cc 
	optabs.c optabs-libfuncs.c optabs-query.c optabs-tree.c 
	optinfo.cc 
	 opts-global.c passes.c plugin.c 
	postreload-gcse.c postreload.c predict.c print-rtl.c 
	print-rtl-function.c print-tree.c profile.c profile-count.c 
	read-md.c read-rtl.c read-rtl-function.c real.c 
	realmpfr.c recog.c reg-stack.c regcprop.c reginfo.c 
	regrename.c regstat.c reload.c reload1.c reorg.c 
	resource.c rtl-error.c rtl-tests.c rtl.c rtlhash.c 
	rtlanal.c rtlhooks.c rtx-vector-builder.c run-rtl-passes.c 
	sched-deps.c sched-ebb.c sched-rgn.c sel-sched-ir.c 
	sel-sched-dump.c sel-sched.c selftest-rtl.c selftest-run-tests.c 
	sese.c shrink-wrap.c simplify-rtx.c sparseset.c 
	spellcheck.c spellcheck-tree.c sreal.c stack-ptr-mod.c 
	statistics.c stmt.c stor-layout.c store-motion.c 
	streamer-hooks.c stringpool.c substring-locations.c 
	target-globals.c targhooks.c timevar.c 
	tracer.c trans-mem.c tree-affine.c asan.c 
	tsan.c ubsan.c sanopt.c sancov.c 
	tree-call-cdce.c tree-cfg.c tree-cfgcleanup.c 
	tree-chrec.c tree-complex.c tree-data-ref.c 
	tree-dfa.c tree-diagnostic.c tree-dump.c 
	tree-eh.c tree-emutls.c tree-if-conv.c 
	tree-inline.c tree-into-ssa.c tree-iterator.c 
	tree-loop-distribution.c tree-nested.c tree-nrv.c 
	tree-object-size.c tree-outof-ssa.c tree-parloops.c 
	tree-phinodes.c tree-predcom.c tree-pretty-print.c tree-profile.c 
	tree-scalar-evolution.c tree-sra.c tree-switch-conversion.c 
	tree-ssa-address.c tree-ssa-alias.c tree-ssa-ccp.c 
	tree-ssa-coalesce.c tree-ssa-copy.c tree-ssa-dce.c 
	tree-ssa-dom.c tree-ssa-dse.c tree-ssa-forwprop.c 
	tree-ssa-ifcombine.c tree-ssa-live.c tree-ssa-loop-ch.c 
	tree-ssa-loop-im.c tree-ssa-loop-ivcanon.c tree-ssa-loop-ivopts.c 
	tree-ssa-loop-manip.c tree-ssa-loop-niter.c tree-ssa-loop-prefetch.c 
	tree-ssa-loop-split.c tree-ssa-loop-unswitch.c tree-ssa-loop.c 
	tree-ssa-math-opts.c tree-ssa-operands.c tree-ssa-phiopt.c 
	tree-ssa-phiprop.c tree-ssa-pre.c tree-ssa-propagate.c 
	tree-ssa-reassoc.c tree-ssa-sccvn.c tree-ssa-scopedtables.c 
	tree-ssa-sink.c tree-ssa-strlen.c tree-ssa-structalias.c 
	tree-ssa-tail-merge.c tree-ssa-ter.c tree-ssa-threadbackward.c 
	tree-ssa-threadedge.c tree-ssa-threadupdate.c tree-ssa-uncprop.c 
	tree-ssa-uninit.c tree-ssa.c tree-ssanames.c 
	tree-stdarg.c tree-streamer.c tree-streamer-in.c 
	tree-streamer-out.c tree-tailcall.c tree-vect-generic.c 
	tree-vect-patterns.c tree-vect-data-refs.c tree-vect-stmts.c 
	tree-vect-loop.c tree-vect-loop-manip.c tree-vect-slp.c 
	tree-vectorizer.c tree-vector-builder.c tree-vrp.c 
	tree.c typed-splay-tree.c unique-ptr-tests.cc 
	valtrack.c value-prof.c var-tracking.c 
	varasm.c varpool.c vec-perm-indices.c vmsdbgout.c 
	vr-values.c vtable-verify.c web.c wide-int.cc
	wide-int-print.cc wide-int-range.cc xcoffout.c)

set(libbackend_custom_SOURCES
	cppbuiltin.c cppdefault.c optinfo-emit-json.cc toplev.c)

list(TRANSFORM libbackend_custom_SOURCES PREPEND "gcc/")


add_library(backend_custom OBJECT ${libbackend_custom_SOURCES})
set_source_files_properties(${libbackend_custom_SOURCES} PROPERTIES LANGUAGE CXX)
target_compile_definitions(backend_custom PUBLIC IN_GCC HAVE_CONFIG_H)
target_compile_options(backend_custom PRIVATE -DGCC_INCLUDE_DIR=\"/c/Development/mingw64/lib/gcc/x86_64-w64-mingw32/9.2.0/include\" -DFIXED_INCLUDE_DIR=\"/c/Development/mingw64/lib/gcc/x86_64-w64-mingw32/9.2.0/include-fixed\" -DGPLUSPLUS_INCLUDE_DIR=\"/c/Development/mingw64/lib/gcc/x86_64-w64-mingw32/9.2.0/../../../../include/c++/9.2.0\")
target_compile_options(backend_custom PRIVATE -DGPLUSPLUS_INCLUDE_DIR_ADD_SYSROOT=0 -DGPLUSPLUS_TOOL_INCLUDE_DIR=\"/c/Development/mingw64/lib/gcc/x86_64-w64-mingw32/9.2.0/../../../../include/c++/9.2.0/x86_64-w64-mingw32\" -DGPLUSPLUS_BACKWARD_INCLUDE_DIR=\"/c/Development/mingw64/lib/gcc/x86_64-w64-mingw32/9.2.0/../../../../include/c++/9.2.0/backward\")
target_compile_options(backend_custom PRIVATE -DLOCAL_INCLUDE_DIR=\"/c/Development/mingw64/lib/gcc/x86_64-w64-mingw32/9.2.0/../../../../include\" -DCROSS_INCLUDE_DIR=\"/c/Development/mingw64/lib/gcc/x86_64-w64-mingw32/9.2.0/../../../../x86_64-w64-mingw32/sys-include\" -DTOOL_INCLUDE_DIR=\"/c/Development/mingw64/lib/gcc/x86_64-w64-mingw32/9.2.0/../../../../x86_64-w64-mingw32/include\")
target_compile_options(backend_custom PRIVATE -DNATIVE_SYSTEM_HEADER_DIR=\"/c/Development/mingw64/x86_64-w64-mingw32/include\" -DPREFIX=\"/c/Development/mingw64/\" -DSTANDARD_EXEC_PREFIX=\"/c/Development/mingw64/lib/gcc/\" -DBASEVER=\"9.2.0\")
target_compile_options(backend_custom PRIVATE -DTARGET_NAME=\"x86_64-w64-mingw32\")
target_include_directories(backend_custom PUBLIC include libdecnumber libbacktrace libiberty ${CMAKE_BINARY_DIR}/gcc gcc ${DEP_PATH}/include libcpp/include libdecnumber/bid)
target_compile_options(backend_custom PUBLIC -fno-PIE -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -W -Wall -Wno-narrowing -Wwrite-strings -Wcast-qual -Wmissing-format-attribute -Woverloaded-virtual -pedantic -Wno-long-long -Wno-variadic-macros -Wno-overlength-strings)

add_dependencies(backend_custom backend_gen_sources)

#Target specific sources
list(APPEND libbackend_SOURCES config/i386/i386.c config/i386/x86-tune-sched.c config/i386/x86-tune-sched-bd.c
								config/i386/x86-tune-sched-atom.c config/i386/x86-tune-sched-core.c)

#OS specific sources
if(WIN32)
list(APPEND libbackend_SOURCES config/i386/winnt.c config/i386/winnt-stubs.c config/i386/host-mingw32.c)
elseif(UNIX)
list(APPEND libbackend_SOURCES config/i386/cet.c config/i386/linux.c config/i386/host-linux.c)
endif()

list(TRANSFORM libbackend_SOURCES PREPEND "gcc/")
set_source_files_properties(${libbackend_SOURCES} PROPERTIES LANGUAGE CXX)
set_source_files_properties(${libbackend_generated_SOURCES} PROPERTIES LANGUAGE CXX)
set_source_files_properties(${libbackend_generated_SOURCES} PROPERTIES GENERATED TRUE)

add_library(backend STATIC ${libbackend_SOURCES} ${libbackend_generated_SOURCES})
target_link_libraries(backend backend_custom)
add_dependencies(backend backend_gen_sources gtype)

set(libcommon-target_SOURCES
	prefix.c params.c opts.c opts-common.c  vec.c hooks.c
	common/common-targhooks.c hash-table.c file-find.c spellcheck.c selftest.c opt-suggestions.c)

#Target specific sources
list(APPEND libcommon-target_SOURCES common/config/i386/i386-common.c)

list(TRANSFORM libcommon-target_SOURCES PREPEND "gcc/")
list(APPEND libcommon-target_SOURCES ${CMAKE_BINARY_DIR}/gcc/options.c)

add_library(common-target STATIC ${libcommon-target_SOURCES})
set_source_files_properties(${libcommon-target_SOURCES} PROPERTIES LANGUAGE CXX)
target_compile_definitions(common-target PRIVATE IN_GCC HAVE_CONFIG_H )
target_include_directories(common-target PRIVATE include libdecnumber libbacktrace libiberty ${CMAKE_BINARY_DIR}/gcc gcc ${DEP_PATH}/include libcpp/include libdecnumber/bid)
target_compile_options(common-target PRIVATE -fno-PIE -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -W -Wall -Wno-narrowing -Wwrite-strings -Wcast-qual -Wmissing-format-attribute -Woverloaded-virtual -pedantic -Wno-long-long -Wno-variadic-macros -Wno-overlength-strings)
target_compile_options(common-target PRIVATE -DPREFIX=\"/c/Development/mingw64\" -DBASEVER=\"9.2.0\" -DDATESTAMP=\"\" -DREVISION=\"\" -DDEVPHASE=\"\" -DPKGVERSION=\"\(GCC\)\" -DBUGURL=\"<https://gcc.gnu.org/bugs/>\" -DLOCALEDIR=\"/mingw64/share/locale\")
add_dependencies(common-target backend)

set(libcommon_SOURCES
	diagnostic.c diagnostic-color.c diagnostic-show-locus.c diagnostic-format-json.cc 
	json.cc edit-context.c pretty-print.c intl.c sbitmap.c vec.c 
	input.c version.c hash-table.c ggc-none.c memory-block.cc selftest.c selftest-diagnostic.c sort.cc)

list(TRANSFORM libcommon_SOURCES PREPEND "gcc/")
set_source_files_properties(${libcommon_SOURCES} PROPERTIES LANGUAGE CXX)
add_library(common STATIC ${libcommon_SOURCES})
target_compile_definitions(common PRIVATE IN_GCC HAVE_CONFIG_H )
target_include_directories(common PRIVATE include libdecnumber libbacktrace libiberty ${CMAKE_BINARY_DIR}/gcc gcc ${DEP_PATH}/include libcpp/include libdecnumber/bid)
target_compile_options(common PRIVATE -fno-PIE -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -W -Wall -Wno-narrowing -Wwrite-strings -Wcast-qual -Wmissing-format-attribute -Woverloaded-virtual -pedantic -Wno-long-long -Wno-variadic-macros -Wno-overlength-strings)
target_compile_options(common PRIVATE -DPREFIX=\"/c/Development/mingw64\" -DBASEVER=\"9.2.0\" -DDATESTAMP=\"\" -DREVISION=\"\" -DDEVPHASE=\"\" -DPKGVERSION=\"\(GCC\)\" -DBUGURL=\"<https://gcc.gnu.org/bugs/>\" -DLOCALEDIR=\"/mingw64/share/locale\")
add_dependencies(common backend)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/checksum-options
				COMMAND echo IN_GCC HAVE_CONFIG_H IN_GCC_FRONTEND fno-PIE -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -Wno-narrowing -static-libstdc++ -static-libgcc > ${CMAKE_CURRENT_BINARY_DIR}/gcc/checksum-options)

#not advisable
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/cc1-checksum.c
					COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genchecksum ${CMAKE_CURRENT_BINARY_DIR}/gcc/checksum-options > ${CMAKE_CURRENT_BINARY_DIR}/gcc/cc1-checksum.c
					DEPENDS genchecksum ${CMAKE_CURRENT_BINARY_DIR}/gcc/checksum-options)

add_custom_target(cc1_checksum DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/gcc/cc1-checksum.c)

set(cc1_SOURCES
	c/c-lang.c c-family/stub-objc.c attribs.c c/c-errors.c c/c-decl.c c/c-typeck.c 
c/c-convert.c c/c-aux-info.c c/c-objc-common.c c/c-parser.c c/c-fold.c c/gimple-parser.c c-family/c-common.c 
c-family/c-cppbuiltin.c c-family/c-dump.c c-family/c-format.c c-family/c-gimplify.c c-family/c-indentation.c 
c-family/c-lex.c c-family/c-omp.c c-family/c-opts.c c-family/c-pch.c c-family/c-ppoutput.c 
c-family/c-pragma.c c-family/c-pretty-print.c c-family/c-semantics.c c-family/c-ada-spec.c c-family/c-ubsan.c 
c-family/known-headers.cc c-family/c-attribs.c c-family/c-warn.c c-family/c-spellcheck.cc main.c)

#Target Specific
list(APPEND cc1_SOURCES config/i386/i386-c.c)
if(WIN32)
list(APPEND cc1_SOURCES config/winnt-c.c config/i386/msformat-c.c)
elseif(UNIX)
list(APPEND cc1_SOURCES config/glibc-c.c)
endif()



list(TRANSFORM cc1_SOURCES PREPEND "gcc/")
list(APPEND cc1_SOURCES ${CMAKE_CURRENT_BINARY_DIR}/gcc/cc1-checksum.c)

add_executable(cc1 ${cc1_SOURCES})
add_dependencies(cc1 cc1_checksum)
set_source_files_properties(${cc1_SOURCES} PROPERTIES LANGUAGE CXX)
target_compile_definitions(cc1 PRIVATE IN_GCC HAVE_CONFIG_H IN_GCC_FRONTEND)
target_compile_options(cc1 PRIVATE -fno-PIE -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -Wno-narrowing -static-libstdc++ -static-libgcc)
target_compile_options(cc1 PRIVATE -DHOST_MACHINE=\"x86_64-w64-mingw32\" -DTARGET_MACHINE=\"x86_64-w64-mingw32\")
target_link_libraries(cc1 backend common-target common cpp decnumber iconv iberty backtrace decnumber isl mpc mpfr gmp z)
target_link_directories(cc1 PRIVATE ${DEP_PATH}/lib)
add_dependencies(cc1 backend common-target common cpp iberty backtrace decnumber)
target_include_directories(cc1 PRIVATE include libdecnumber libbacktrace libiberty ${CMAKE_BINARY_DIR}/gcc gcc ${DEP_PATH}/include
							libcpp/include libdecnumber/bid	${CMAKE_BINARY_DIR}/gcc/c-family gcc/c-family)


#not advisable
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/cc1plus-checksum.c
					COMMAND ${CMAKE_CURRENT_BINARY_DIR}/build/genchecksum ${CMAKE_CURRENT_BINARY_DIR}/gcc/checksum-options > ${CMAKE_CURRENT_BINARY_DIR}/gcc/cc1plus-checksum.c
					DEPENDS genchecksum ${CMAKE_CURRENT_BINARY_DIR}/gcc/checksum-options)

add_custom_target(cc1plus_checksum DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/gcc/cc1plus-checksum.c)

set(cc1plus_SOURCES
cp/cp-lang.c c-family/stub-objc.c cp/call.c cp/class.c cp/constexpr.c 
cp/constraint.cc cp/cp-gimplify.c cp/cp-objcp-common.c cp/cp-ubsan.c cp/cvt.c 
cp/cxx-pretty-print.c cp/decl.c cp/decl2.c cp/dump.c cp/error.c cp/except.c
cp/expr.c cp/friend.c cp/init.c cp/lambda.c cp/lex.c cp/logic.cc cp/mangle.c 
cp/method.c cp/name-lookup.c cp/optimize.c cp/parser.c cp/pt.c cp/ptree.c cp/repo.c
cp/rtti.c cp/search.c cp/semantics.c cp/tree.c cp/typeck.c cp/typeck2.c 
cp/vtable-class-hierarchy.c attribs.c incpath.c c-family/c-common.c 
c-family/c-cppbuiltin.c c-family/c-dump.c c-family/c-format.c c-family/c-gimplify.c 
c-family/c-indentation.c c-family/c-lex.c c-family/c-omp.c c-family/c-opts.c 
c-family/c-pch.c c-family/c-ppoutput.c c-family/c-pragma.c c-family/c-pretty-print.c
c-family/c-semantics.c c-family/c-ada-spec.c c-family/c-ubsan.c 
c-family/known-headers.cc c-family/c-attribs.c c-family/c-warn.c c-family/c-spellcheck.cc main.c)
 
#Target Specific
list(APPEND cc1plus_SOURCES config/i386/i386-c.c)
if(WIN32)
list(APPEND cc1plus_SOURCES config/winnt-c.c config/i386/winnt-cxx.c config/i386/msformat-c.c)
elseif(UNIX)
list(APPEND cc1plus_SOURCES config/glibc-c.c)
endif()

list(TRANSFORM cc1plus_SOURCES PREPEND "gcc/")
list(APPEND cc1plus_SOURCES ${CMAKE_CURRENT_BINARY_DIR}/gcc/cc1plus-checksum.c)

add_executable(cc1plus ${cc1plus_SOURCES})
add_dependencies(cc1plus cc1plus_checksum)
set_source_files_properties(${cc1plus_SOURCES} PROPERTIES LANGUAGE CXX)
target_compile_definitions(cc1plus PRIVATE IN_GCC HAVE_CONFIG_H IN_GCC_FRONTEND)
target_compile_options(cc1plus PRIVATE -fno-PIE -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -Wno-narrowing -static-libstdc++ -static-libgcc)
target_compile_options(cc1plus PRIVATE -DHOST_MACHINE=\"x86_64-w64-mingw32\" -DTARGET_MACHINE=\"x86_64-w64-mingw32\")
target_link_libraries(cc1plus backend common-target common cpp decnumber iconv iberty backtrace decnumber isl mpc mpfr gmp z)
target_link_directories(cc1plus PRIVATE ${DEP_PATH}/lib)
add_dependencies(cc1plus backend common-target common cpp iberty backtrace decnumber)
target_include_directories(cc1plus PRIVATE include libdecnumber libbacktrace libiberty ${CMAKE_BINARY_DIR}/gcc gcc ${DEP_PATH}/include
							libcpp/include libdecnumber/bid	${CMAKE_BINARY_DIR}/gcc/c-family gcc/c-family gcc/cp)


set(gcov_SOURCES
gcc/gcov.c gcc/json.cc gcc/hash-table.c gcc/ggc-none.c)

add_executable(gcov ${gcov_SOURCES})
set_source_files_properties(${gcov_SOURCES} PROPERTIES LANGUAGE CXX)
target_compile_definitions(gcov PRIVATE IN_GCC HAVE_CONFIG_H )
target_compile_options(gcov PRIVATE -fno-PIE -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -Wno-narrowing -static-libstdc++ -static-libgcc)
target_link_libraries(gcov common cpp iconv iberty backtrace decnumber z)
target_link_directories(gcov PRIVATE /../f/lib)
target_include_directories(gcov PRIVATE include libdecnumber libbacktrace libiberty ${CMAKE_CURRENT_BINARY_DIR}/gcc libcpp/include libdecnumber/bid gcc ${DEP_PATH}/include)

set(gcov-dump_SOURCES
gcc/gcov-dump.c gcc/hash-table.c gcc/ggc-none.c)

add_executable(gcov-dump ${gcov-dump_SOURCES})
set_source_files_properties(${gcov-dump_SOURCES} PROPERTIES LANGUAGE CXX)
target_compile_definitions(gcov-dump PRIVATE IN_GCC HAVE_CONFIG_H )
target_compile_options(gcov-dump PRIVATE -fno-PIE -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -Wno-narrowing -static-libstdc++ -static-libgcc)
target_link_libraries(gcov-dump common cpp iconv iberty backtrace decnumber )
target_include_directories(gcov-dump PRIVATE PRIVATE include libdecnumber libbacktrace libiberty ${CMAKE_CURRENT_BINARY_DIR}/gcc libcpp/include libdecnumber/bid gcc ${DEP_PATH}/include)

#auto-target.h generation libgcc_tm.h
set(gcov-tool_SOURCES
gcc/gcov-tool.c libgcc/libgcov-util.c libgcc/libgcov-driver.c libgcc/libgcov-merge.c)

add_executable(gcov-tool ${gcov-tool_SOURCES})
set_source_files_properties(${gcov-tool_SOURCES} PROPERTIES LANGUAGE CXX)
target_compile_definitions(gcov-tool PRIVATE IN_GCC HAVE_CONFIG_H IN_GCOV_TOOL=1)
target_compile_options(gcov-tool PRIVATE -fno-PIE -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -Wno-narrowing -static-libstdc++ -static-libgcc)
target_link_libraries(gcov-tool common cpp iconv iberty backtrace decnumber)
target_include_directories(gcov-tool PRIVATE include libdecnumber libbacktrace libiberty ${CMAKE_CURRENT_BINARY_DIR}/gcc libcpp/include libdecnumber/bid gcc ${DEP_PATH}/include)

set(collect2_SOURCES
gcc/collect2.c  gcc/collect2-aix.c gcc/tlink.c gcc/vec.c gcc/ggc-none.c 
gcc/collect-utils.c gcc/file-find.c gcc/hash-table.c gcc/selftest.c)


add_executable(collect2 ${collect2_SOURCES})
set_source_files_properties(${collect2_SOURCES} PROPERTIES LANGUAGE CXX)
target_compile_definitions(collect2 PRIVATE IN_GCC HAVE_CONFIG_H )
target_compile_options(collect2 PRIVATE -fno-PIE -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -Wno-narrowing -static-libstdc++ -static-libgcc)
target_link_libraries(collect2 common cpp iconv iberty backtrace decnumber )
target_link_directories(collect2 PRIVATE /../f/lib)
target_include_directories(collect2 PRIVATE include libdecnumber libbacktrace libiberty ${CMAKE_CURRENT_BINARY_DIR}/gcc libcpp/include libdecnumber/bid gcc ${DEP_PATH}/include)

set(lto-wrapper_SOURCES
gcc/lto-wrapper.c gcc/collect-utils.c gcc/ggc-none.c)

add_executable(lto-wrapper ${lto-wrapper_SOURCES})
set_source_files_properties(${lto-wrapper_SOURCES} PROPERTIES LANGUAGE CXX)
target_compile_definitions(lto-wrapper PRIVATE IN_GCC HAVE_CONFIG_H )
target_compile_options(lto-wrapper PRIVATE -fno-PIE -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -Wno-narrowing -static-libstdc++ -static-libgcc)
target_link_libraries(lto-wrapper common-target common cpp iconv iberty backtrace decnumber )
target_include_directories(lto-wrapper PRIVATE include libdecnumber libbacktrace libiberty ${CMAKE_CURRENT_BINARY_DIR}/gcc libcpp/include libdecnumber/bid gcc ${DEP_PATH}/include)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc/specs.h
					COMMAND echo "#include \"cp/lang-specs.h\"" > ${CMAKE_CURRENT_BINARY_DIR}/gcc/specs.h
					COMMAND echo "#include \"lto/lang-specs.h\"" >> ${CMAKE_CURRENT_BINARY_DIR}/gcc/specs.h)		
add_custom_target(specs DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/gcc/specs.h)

set(gcc_driver_SOURCES
	gcc/gcc.c gcc/gcc-main.c gcc/config/i386/driver-i386.c gcc/ggc-none.c) 
if(WIN32)
list(APPEND gcc_driver_SOURCES gcc/config/i386/driver-mingw32.c)
endif()
add_library(gcc_driver OBJECT ${gcc_driver_SOURCES})
add_dependencies(gcc_driver specs)
set_source_files_properties(${gcc_driver_SOURCES} PROPERTIES LANGUAGE CXX)
target_compile_definitions(gcc_driver PUBLIC IN_GCC HAVE_CONFIG_H )
target_compile_options(gcc_driver PUBLIC -fno-PIE -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -Wno-narrowing -static-libstdc++ -static-libgcc)
target_compile_options(gcc_driver PUBLIC -DSTANDARD_STARTFILE_PREFIX=\"../../../\" -DSTANDARD_EXEC_PREFIX=\"/mingw64/lib/gcc/\" -DSTANDARD_LIBEXEC_PREFIX=\"/mingw64/libexec/gcc/\"
						 -DDEFAULT_TARGET_VERSION=\"9.2.0\" -DDEFAULT_REAL_TARGET_MACHINE=\"x86_64-w64-mingw32\" -DDEFAULT_TARGET_MACHINE=\"x86_64-w64-mingw32\" 
						 -DSTANDARD_BINDIR_PREFIX=\"/mingw64/bin/\" -DTOOLDIR_BASE_PREFIX=\"../../../../\" -DACCEL_DIR_SUFFIX=\"\"  -DENABLE_SHARED_LIBGCC -DCONFIGURE_SPECS="\"\"" 
						 -DTOOL_INCLUDE_DIR=\"/mingw64/lib/gcc/x86_64-w64-mingw32/9.2.0/../../../../x86_64-w64-mingw32/include\" 
						 -DNATIVE_SYSTEM_HEADER_DIR=\"/c/Development/mingw64/x86_64-w64-mingw32/include\" -DBASEVER=\"9.2.0\")
target_link_libraries(gcc_driver common-target common cpp iconv iberty backtrace decnumber)
target_include_directories(gcc_driver PUBLIC include libdecnumber libbacktrace libiberty ${CMAKE_CURRENT_BINARY_DIR}/gcc libcpp/include libdecnumber/bid gcc ${DEP_PATH}/include)

set(lto1_SOURCES
lto/lto-lang.c lto/lto.c lto/lto-object.c 
attribs.c lto/lto-partition.c lto/lto-symtab.c main.c) 

list(TRANSFORM lto1_SOURCES PREPEND "gcc/")

add_executable(lto1 ${lto1_SOURCES})
set_source_files_properties(${lto1_SOURCES} PROPERTIES LANGUAGE CXX)
target_compile_definitions(lto1 PRIVATE IN_GCC HAVE_CONFIG_H IN_GCC_FRONTEND)
target_compile_options(lto1 PRIVATE -fno-PIE -fno-exceptions -fno-rtti -fasynchronous-unwind-tables -Wno-narrowing -static-libstdc++ -static-libgcc)
target_link_libraries(lto1 backend common-target common cpp iconv iberty backtrace decnumber isl mpc mpfr gmp z)
target_link_directories(lto1 PRIVATE ${DEP_PATH}/lib)
add_dependencies(lto1 backend common-target common cpp iberty backtrace decnumber)
target_include_directories(lto1 PRIVATE PRIVATE include libdecnumber libbacktrace libiberty ${CMAKE_CURRENT_BINARY_DIR}/gcc libcpp/include libdecnumber/bid ${DEP_PATH}/include)

set(gcc_SOURCES gcc/c/gccspec.c)
set_source_files_properties(${gcc_SOURCES} PROPERTIES LANGUAGE CXX)
add_executable(gcc ${gcc_SOURCES})
target_link_libraries(gcc gcc_driver)
add_dependencies(gcc cc1)

set(g++_SOURCES gcc/cp/g++spec.c)
set_source_files_properties(${g++_SOURCES} PROPERTIES LANGUAGE CXX)
add_executable(g++ ${g++_SOURCES})
target_link_libraries(g++ gcc_driver)
add_dependencies(g++ cc1plus)

#linux add libcc1
#[[
set(fixincl_SOURCES
	fixincludes/fixincl.c fixincludes/fixlib.c fixincludes/fixtests.c fixincludes/fixopts.c)

set(applyfix_SOURCES
	fixincludes/fixfixes.c fixincludes/fixlib.c  fixincludes/fixopts.c)

add_executable(fixincl ${fixincl_SOURCES})
#add_dependencies(fixincl iberty)
target_compile_definitions(fixincl PRIVATE HAVE_CONFIG_H)
target_include_directories(fixincl PRIVATE /include ${CMAKE_BINARY_DIR}/fix)
target_link_libraries(fixincl PRIVATE iberty)
add_executable(applyfix ${applyfix_SOURCES})
#add_dependencies( iberty)
target_compile_definitions(applyfix PRIVATE HAVE_CONFIG_H)
target_include_directories(applyfix PRIVATE /include ${CMAKE_BINARY_DIR}/fix)
target_link_libraries(applyfix PRIVATE iberty)
]]

#building libgcc and libstdc++. Should be built with compiled compiler.

######################################################################################
##############     LIBGCC
######################################################################################

#TODO libgcc-map.def

check_c_headers(ftw.h inttypes.h memory.h stdint.h stdlib.h strings.h string.h sys/stat.h
	sys/types.h unistd.h)

check_types(double "long double")

set(HAVE_AS_CFI_SECTIONS 1)
set(HAVE_AS_AVX 1)

check_c_source_compiles("
__thread int a; int b; int main() { return a = b; }"
HAVE_CC_TLS)

if(HAVE_CC_TLS)
set(USE_EMUTLS 1)
endif()

configure_file(libgcc-config.h.in ${CMAKE_CURRENT_BINARY_DIR}/libgcc/auto-target.h)
#cheating
if(WIN32)
configure_file(libgcc-win.map ${CMAKE_CURRENT_BINARY_DIR}/libgcc/libgcc.map)
elseif(UNIX)
configure_file(libgcc-linux.map ${CMAKE_CURRENT_BINARY_DIR}/libgcc/libgcc.map)
endif()


set(C_COMPILER ${CMAKE_CURRENT_BINARY_DIR}/gcc -B${CMAKE_CURRENT_BINARY_DIR})
set(CXX_COMPILER ${CMAKE_CURRENT_BINARY_DIR}/g++ -B${CMAKE_CURRENT_BINARY_DIR})

if(WIN32)
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc/libgcc_tm.h
					COMMAND set DEFINES=
					COMMAND set HEADERS=
					COMMAND sh ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/mkheader.sh libgcc_tm.h
					COMMAND mv ${CMAKE_CURRENT_BINARY_DIR}/libgcc_tm.h ${CMAKE_CURRENT_BINARY_DIR}/libgcc/libgcc_tm.h )
elseif(UNIX)
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc/libgcc_tm.h
					COMMAND DEFINES=\"\"
					COMMAND HEADERS=\"${CMAKE_CURRENT_SOURCE_DIR}/libgcc/config/i386/elf-lib.h ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/config/i386/value-unwind.h\"
					COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/mkheader.sh libgcc_tm.h
					COMMAND mv ${CMAKE_CURRENT_BINARY_DIR}/libgcc_tm.h ${CMAKE_CURRENT_BINARY_DIR}/libgcc/libgcc_tm.h )
endif()

set(libgcc_SOURCES
  _muldi3 _negdi2 _lshrdi3 _ashldi3 _ashrdi3
 _cmpdi2 _ucmpdi2 _clear_cache _trampoline
 __main _absvsi2 _absvdi2 _addvsi3 _addvdi3
 _subvsi3 _subvdi3 _mulvsi3 _mulvdi3 _negvsi2
 _negvdi2 _ctors _ffssi2 _ffsdi2 _clz
 _clzsi2 _clzdi2 _ctzsi2 _ctzdi2 _popcount_tab
 _popcountsi2 _popcountdi2 _paritysi2 _paritydi2
 _powisf2 _powidf2 _powixf2 _powitf2 _mulhc3
 _mulsc3 _muldc3 _mulxc3 _multc3 _divhc3 _divsc3
 _divdc3 _divxc3 _divtc3 _bswapsi2 _bswapdi2 _clrsbsi2
 _clrsbdi2 _fixunssfsi _fixunsdfsi _fixunsxfsi _fixsfdi
 _fixdfdi _fixxfdi _fixunssfdi _fixunsdfdi _fixunsxfdi
 _floatdisf _floatdidf _floatdixf _floatundisf _floatundidf
 _floatundixf _eprintf __gcc_bcmp)

 set(libgcc_excep_SOURCES 
 _divdi3 _moddi3 _divmoddi4
 _udivdi3 _umoddi3 _udivmoddi4 _udiv_w_sdiv)

set(libgcc_bid_SOURCES
 bid_decimal_globals.c bid_decimal_data.c bid_binarydecimal.c bid_convert_data.c
  _isinfd32.c _isinfd64.c _isinfd128.c bid64_noncomp.c bid128_noncomp.c bid128_fma.c
 bid_round.c bid_from_int.c bid64_add.c bid128_add.c bid64_div.c
 bid128_div.c bid64_mul.c bid128_mul.c bid64_compare.c bid128_compare.c
 bid128.c bid32_to_bid64.c bid32_to_bid128.c bid64_to_bid128.c
 bid64_to_int32.c bid64_to_int64.c bid64_to_uint32.c bid64_to_uint64.c
 bid128_to_int32.c bid128_to_int64.c bid128_to_uint32.c bid128_to_uint64.c)

set(libgcc_32_SOURCES
 _addsub_sd.c _div_sd.c _mul_sd.c _eq_sd.c
 _ne_sd.c _lt_sd.c _gt_sd.c _le_sd.c
 _ge_sd.c _sd_to_si.c _sd_to_di.c _sd_to_usi.c
 _sd_to_udi.c _si_to_sd.c _di_to_sd.c _usi_to_sd.c
 _udi_to_sd.c _sd_to_sf.c _sd_to_df.c
 _sd_to_xf.c _sd_to_tf.c _sf_to_sd.c
 _df_to_sd.c _xf_to_sd.c _tf_to_sd.c
 _sd_to_dd.c _sd_to_td.c _unord_sd.c)

set(libgcc_64_SOURCES
  _addsub_dd.c _div_dd.c
 _mul_dd.c _eq_dd.c _ne_dd.c _lt_dd.c _gt_dd.c _le_dd.c _ge_dd.c
 _dd_to_si.c _dd_to_di.c _dd_to_usi.c _dd_to_udi.c _si_to_dd.c
 _di_to_dd.c _usi_to_dd.c _udi_to_dd.c _dd_to_sf.c _dd_to_df.c _dd_to_xf.c
 _dd_to_tf.c _sf_to_dd.c _df_to_dd.c _xf_to_dd.c _tf_to_dd.c _dd_to_sd.c
 _dd_to_td.c _unord_dd.c)
 
set(libgcc_128_SOURCES
 _addsub_td.c _div_td.c _mul_td.c _eq_td.c _ne_td.c
 _lt_td.c _gt_td.c _le_td.c _ge_td.c _td_to_si.c _td_to_di.c _td_to_usi.c
 _td_to_udi.c _si_to_td.c _di_to_td.c _usi_to_td.c _udi_to_td.c _td_to_sf.c
 _td_to_df.c _td_to_xf.c _td_to_tf.c _sf_to_td.c _df_to_td.c _xf_to_td.c
 _tf_to_td.c _td_to_sd.c _td_to_dd.c _unord_td.c)

set(libgcc_arch_SOURCES libgcc/config/i386/cpuinfo.c libgcc/config/i386/sfp-exceptions.c)
if(UNIX)
list(APPEND libgcc_arch_SOURCES libgcc/config/i386/32/tf-signs.c)
endif()

set(libgcc_common_SOURCES
 addtf3.c divtf3.c eqtf2.c getf2.c letf2.c multf3.c negtf2.c subtf3.c
 unordtf2.c fixtfsi.c fixunstfsi.c floatsitf.c floatunsitf.c fixtfdi.c
 fixunstfdi.c floatditf.c floatunditf.c fixtfti.c fixunstfti.c
 floattitf.c floatuntitf.c extendsftf2.c extenddftf2.c extendxftf2.c
 trunctfsf2.c trunctfdf2.c trunctfxf2.c) 

list(TRANSFORM libgcc_bid_SOURCES PREPEND "libgcc/config/libbid/")
list(TRANSFORM libgcc_32_SOURCES PREPEND "libgcc/config/libbid/")
list(TRANSFORM libgcc_64_SOURCES PREPEND "libgcc/config/libbid/")
list(TRANSFORM libgcc_128_SOURCES PREPEND "libgcc/config/libbid/")
list(TRANSFORM libgcc_common_SOURCES PREPEND "libgcc/soft-fp/")

 #libgcc/enable-execute-stack.c cp this
if(WIN32)
list(APPEND libgcc_common_SOURCES libgcc/config/i386/enable-execute-stack-mingw32.c)
elseif(UNIX)
list(APPEND libgcc_common_SOURCES libgcc/enable-execute-stack-empty.c
						libgcc/generic-morestack.c libgcc/generic-morestack-thread.c) 
endif()

if(UNIX)
set(libgcc_asm_sources
	avx_savms64.S avx_resms64.S avx_resms64x.S avx_savms64f.S avx_resms64f.S avx_resms64fx.S sse_savms64.S sse_resms64.S
	sse_resms64x.S sse_savms64f.S sse_resms64f.S sse_resms64fx.S morestack.S)
#libgcc/config/i386
endif()

set(libgcc_FLAGS -O2 -DIN_GCC -W -Wall -Wno-narrowing -Wwrite-strings -Wcast-qual -Wstrict-prototypes -Wmissing-prototypes -Wold-style-definition
	-DIN_LIBGCC2 -fbuilding-libgcc -fno-stack-protector	-DENABLE_DECIMAL_BID_FORMAT -DHAVE_CC_TLS -DUSE_EMUTLS)

if(UNIX)
set(libgcc_extra_FLAGS -DUSE_ELF_SYMVER -fvisibility=hidden -DHIDE_EXPORTS)
endif()

set(libgcc_INCLUDES -I${CMAKE_CURRENT_SOURCE_DIR}/libgcc/config/libbid -I${CMAKE_CURRENT_SOURCE_DIR}/include/ -I${CMAKE_CURRENT_SOURCE_DIR}/gcc/
	-I${CMAKE_CURRENT_BINARY_DIR}/gcc/ -I${CMAKE_CURRENT_BINARY_DIR}/libgcc -I${CMAKE_CURRENT_SOURCE_DIR}/libgcc -IC:/Development/mingw64/x86_64-w64-mingw32/include
	-IC:/Development/mingw64/lib/gcc/x86_64-w64-mingw32/8.1.0/include)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc/unwind.h ${CMAKE_CURRENT_BINARY_DIR}/libgcc/sfp-machine.h ${CMAKE_CURRENT_BINARY_DIR}/libgcc/md-unwind-support.h ${CMAKE_CURRENT_BINARY_DIR}/libgcc/gthr-default.h
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/unwind-generic.h ${CMAKE_CURRENT_BINARY_DIR}/libgcc/unwind.h
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/config/no-unwind.h ${CMAKE_CURRENT_BINARY_DIR}/libgcc/md-unwind-support.h
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/config/i386/sfp-machine.h ${CMAKE_CURRENT_BINARY_DIR}/libgcc/sfp-machine.h
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/gthr-posix.h ${CMAKE_CURRENT_BINARY_DIR}/libgcc/gthr-default.h
					DEPENDS gcc)	

add_custom_target(libgcc_cp DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/libgcc/unwind.h ${CMAKE_CURRENT_BINARY_DIR}/libgcc/sfp-machine.h ${CMAKE_CURRENT_BINARY_DIR}/libgcc/md-unwind-support.h ${CMAKE_CURRENT_BINARY_DIR}/libgcc/gthr-default.h)

if(WIN32)
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc/_chkstk.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} ${libgcc_INCLUDES} -xassembler-with-cpp -DL_chkstk -c ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/config/i386/cygwin.S -o ${CMAKE_CURRENT_BINARY_DIR}/libgcc/_chkstk.o)
list(APPEND libgcc_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc/_chkstk.o)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc/_chkstk_ms.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} ${libgcc_INCLUDES} -xassembler-with-cpp -DL_chkstk_ms -c ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/config/i386/cygwin.S -o ${CMAKE_CURRENT_BINARY_DIR}/libgcc/_chkstk_ms.o)
list(APPEND libgcc_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc/_chkstk_ms.o)
endif()

#add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc/libgcc_tm.h
#					COMMAND sh -c "DEFINES='' HEADERS='' ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/mkheader.sh > ")

foreach(i ${libgcc_SOURCES})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc/${i}.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} ${libgcc_INCLUDES} -DL${i} -c ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/libgcc2.c -o ${CMAKE_CURRENT_BINARY_DIR}/libgcc/${i}.o
					DEPENDS libgcc_cp)
	list(APPEND libgcc_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc/${i}.o)
endforeach()

foreach(i ${libgcc_excep_SOURCES})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc/${i}.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} -fexceptions -fnon-call-exceptions ${libgcc_INCLUDES} -DL${i} -c ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/libgcc2.c -o ${CMAKE_CURRENT_BINARY_DIR}/libgcc/${i}.o
					DEPENDS libgcc_cp)
	list(APPEND libgcc_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc/${i}.o)
endforeach()

foreach(i ${libgcc_bid_SOURCES})
string(REPLACE ".c" "" var ${i})
string(REPLACE "libgcc/config/libbid/" "" var ${var})
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc/bid-${var}.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} ${libgcc_INCLUDES} -c ${CMAKE_CURRENT_SOURCE_DIR}/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libgcc/bid-${var}.o
					DEPENDS libgcc_cp)
	list(APPEND libgcc_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc/bid-${var}.o)	
endforeach()

foreach(i ${libgcc_32_SOURCES})
string(REPLACE ".c" "" var ${i})
string(REPLACE "libgcc/config/libbid/" "" var ${var})
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc/bid32-${i}.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} ${libgcc_INCLUDES} -DFINE_GRAINED_LIBRARIES -DL${var} -DWIDTH=32 -c ${CMAKE_CURRENT_SOURCE_DIR}/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libgcc/bid32-${i}.o
					DEPENDS libgcc_cp)
	list(APPEND libgcc_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc/bid32-${i}.o)	
endforeach()

foreach(i ${libgcc_64_SOURCES})
string(REPLACE ".c" "" var ${i})
string(REPLACE "libgcc/config/libbid/" "" var ${var})
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc/bid64-${i}.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} ${libgcc_INCLUDES} -DFINE_GRAINED_LIBRARIES -DL${var} -DWIDTH=64 -c ${CMAKE_CURRENT_SOURCE_DIR}/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libgcc/bid64-${i}.o
					DEPENDS libgcc_cp)
	list(APPEND libgcc_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc/bid64-${i}.o)	
endforeach()

foreach(i ${libgcc_128_SOURCES})
string(REPLACE ".c" "" var ${i})
string(REPLACE "libgcc/config/libbid/" "" var ${var})
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc/bid128-${i}.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} ${libgcc_INCLUDES} -DFINE_GRAINED_LIBRARIES -DL${var} -DWIDTH=128 -c ${CMAKE_CURRENT_SOURCE_DIR}/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libgcc/bid128-${i}.o
					DEPENDS libgcc_cp)
	list(APPEND libgcc_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc/bid128-${i}.o)	
endforeach()

foreach(i ${libgcc_common_SOURCES})
string(REPLACE ".c" "" var ${i})
string(REPLACE "libgcc/soft-fp/" "soft-fp-" var ${var})
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc/${var}.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} ${libgcc_INCLUDES} -c ${CMAKE_CURRENT_SOURCE_DIR}/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libgcc/${var}.o
					DEPENDS libgcc_cp)
	list(APPEND libgcc_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc/${var}.o)	
endforeach()

foreach(i ${libgcc_arch_SOURCES})
string(REPLACE ".c" "" var ${i})
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc/${var}.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} ${libgcc_INCLUDES} -c ${CMAKE_CURRENT_SOURCE_DIR}/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libgcc/${var}.o
					DEPENDS libgcc_cp)
	list(APPEND libgcc_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc/${var}.o)	
endforeach()

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc-libs/libgcc.a
					COMMAND ar rcs ${CMAKE_CURRENT_BINARY_DIR}/gcc-libs/libgcc.a ${libgcc_objs}
					DEPENDS ${libgcc_objs})	

add_custom_target(libgcc ALL
				DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/gcc-libs/libgcc.a)	



set(libgcov_merge_objs
	_gcov_merge_add _gcov_merge_single _gcov_merge_ior _gcov_merge_time_profile _gcov_merge_icall_topn)
set(libgcov_profiler_objs
	_gcov_interval_profiler _gcov_interval_profiler_atomic _gcov_pow2_profiler _gcov_pow2_profiler_atomic
	_gcov_one_value_profiler _gcov_one_value_profiler_atomic _gcov_average_profiler
	_gcov_average_profiler_atomic _gcov_ior_profiler _gcov_ior_profiler_atomic _gcov_indirect_call_profiler_v3
	_gcov_time_profiler _gcov_indirect_call_topn_profiler)
set(libgcov_interface_objs
	_gcov_dump _gcov_flush _gcov_fork _gcov_execl _gcov_execlp _gcov_execle _gcov_execv
	_gcov_execvp _gcov_execve _gcov_reset )


foreach(i ${libgcov_merge_objs})
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcov/${i}.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} ${libgcc_INCLUDES} -DL${i} -c ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/libgcov-merge.c -o ${CMAKE_CURRENT_BINARY_DIR}/libgcov/${i}.o
					DEPENDS libgcc_cp)
	list(APPEND libgcov_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcov/${i}.o)	
endforeach()

foreach(i ${libgcov_profiler_objs})
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcov/${i}.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} ${libgcc_INCLUDES} -DL${i} -c ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/libgcov-profiler.c -o ${CMAKE_CURRENT_BINARY_DIR}/libgcov/${i}.o
					DEPENDS libgcc_cp)
	list(APPEND libgcov_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcov/${i}.o)	
endforeach()

foreach(i ${libgcov_interface_objs})
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcov/${i}.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} ${libgcc_INCLUDES} -DL${i} -c ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/libgcov-interface.c -o ${CMAKE_CURRENT_BINARY_DIR}/libgcov/${i}.o
					DEPENDS libgcc_cp)
	list(APPEND libgcov_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcov/${i}.o)	
endforeach()

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcov/_gcov.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} ${libgcc_INCLUDES} -DL_gcov -c ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/libgcov-driver.c -o ${CMAKE_CURRENT_BINARY_DIR}/libgcov/_gcov.o
					DEPENDS libgcc_cp)
list(APPEND libgcov_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcov/_gcov.o)	

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc-libs/libgcov.a
					COMMAND ar rcs ${CMAKE_CURRENT_BINARY_DIR}/gcc-libs/libgcov.a ${libgcov_objs}
					DEPENDS ${libgcov_objs})	

add_custom_target(libgcov ALL
				DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/gcc-libs/libgcov.a)


set(gcc_eh_SOURCES
	libgcc/unwind-sjlj.c libgcc/unwind-c.c libgcc/emutls.c)
if(WIN32)
list(APPEND gcc_eh_SOURCES libgcc/unwind-seh.c)
elseif(UNIX)
list(APPEND gcc_eh_SOURCES libgcc/unwind-dw2.c libgcc/unwind-dw2-fde-dip.c)
endif()

foreach(i ${gcc_eh_SOURCES})
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc_eh/${i}.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} ${libgcc_INCLUDES} -fexceptions -c ${CMAKE_CURRENT_SOURCE_DIR}/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libgcc_eh/${i}.o
					DEPENDS libgcc_cp)
	list(APPEND libgcc_eh_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc_eh/${i}.o)	
endforeach()

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc-libs/libgcc_eh.a
					COMMAND ar rcs ${CMAKE_CURRENT_BINARY_DIR}/gcc-libs/libgcc_eh.a ${libgcc_eh_objs}
					DEPENDS ${libgcc_eh_objs})
		
add_custom_target(libgcc_eh ALL
				DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/gcc-libs/libgcc_eh.a)



set(win32_special
	libgcc/config/i386/cygming-crtbegin.c libgcc/config/i386/cygming-crtend.c)
if(WIN32)
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/_chkstk_s.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} ${libgcc_INCLUDES} -xassembler-with-cpp -DSHARED -DL_chkstk -c ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/config/i386/cygwin.S -o ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/_chkstk_s.o
					DEPENDS libgcc_cp)
list(APPEND libgcc_s_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/_chkstk_s.o)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/_chkstk_ms_s.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} ${libgcc_INCLUDES} -xassembler-with-cpp -DSHARED -DL_chkstk_ms -c ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/config/i386/cygwin.S -o ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/_chkstk_ms_s.o
					DEPENDS libgcc_cp)
list(APPEND libgcc_s_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/_chkstk_ms_s.o)
endif()

foreach(i ${libgcc_SOURCES})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/${i}_s.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} ${libgcc_INCLUDES} -DSHARED -DL${i} -c ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/libgcc2.c -o ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/${i}_s.o
					DEPENDS libgcc_cp)
	list(APPEND libgcc_s_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/${i}_s.o)
endforeach()

foreach(i ${libgcc_excep_SOURCES})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/${i}_s.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} -fexceptions -fnon-call-exceptions ${libgcc_INCLUDES} -DSHARED -DL${i} -c ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/libgcc2.c -o ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/${i}_s.o
					DEPENDS libgcc_cp)
	list(APPEND libgcc_s_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/${i}_s.o)
endforeach()

foreach(i ${gcc_eh_SOURCES})
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/${i}.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} ${libgcc_INCLUDES} -DSHARED -fexceptions -c ${CMAKE_CURRENT_SOURCE_DIR}/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/${i}.o
					DEPENDS libgcc_cp)
	list(APPEND libgcc_s_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/${i}.o)	
endforeach()

foreach(i ${libgcc_common_SOURCES})
string(REPLACE ".c" "" var ${i})
string(REPLACE "libgcc/soft-fp/" "soft-fp-" var ${var})
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/${var}.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} ${libgcc_INCLUDES} -DSHARED  -c ${CMAKE_CURRENT_SOURCE_DIR}/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/${var}.o
					DEPENDS libgcc_cp)
	list(APPEND libgcc_s_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/${var}.o)	
endforeach()

foreach(i ${libgcc_arch_SOURCES})
string(REPLACE ".c" "" var ${i})
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/${var}.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} ${libgcc_INCLUDES} -DSHARED -c ${CMAKE_CURRENT_SOURCE_DIR}/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/${var}.o
					DEPENDS libgcc_cp)
	list(APPEND libgcc_s_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/${var}.o)	
endforeach()

#[[
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/crtbegin.o
					COMMAND ${C_COMPILER} ${libgcc_s_FLAGS} ${libgcc_INCLUDES} -finhibit-size-directive -fno-inline -fno-exceptions -fno-zero-initialized-in-bss -fno-toplevel-reorder -fno-tree-vectorize -fno-omit-frame-pointer -Wno-error -c ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/config/i386/cygming-crtbegin.c -o ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/crtbegin.o
					DEPENDS libgcc_cp)
list(APPEND libgcc_s_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/crtbegin.o)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/crtend.o
					COMMAND ${C_COMPILER} ${libgcc_s_FLAGS} ${libgcc_INCLUDES} -finhibit-size-directive -fno-inline -fno-exceptions -fno-zero-initialized-in-bss -fno-toplevel-reorder -fno-tree-vectorize -fno-omit-frame-pointer -Wno-error -c ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/config/i386/cygming-crtend.c -o ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/crtend.o
					DEPENDS libgcc_cp)
list(APPEND libgcc_s_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/crtend.o)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/crtfastmath.o
					COMMAND ${C_COMPILER} ${libgcc_FLAGS} ${libgcc_INCLUDES} -DSHARED -c ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/config/i386/crtfastmath.c -o ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/crtfastmath.o
					DEPENDS libgcc_cp)
list(APPEND libgcc_s_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/crtfastmath.o)	
]]

#linux crtstuff crtprec

list(REMOVE_ITEM libgcc_s_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/__gcc_bcmp_s.o)
list(REMOVE_ITEM libgcc_s_objs ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/_eprintf_s.o)
#add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/libgcc.map.def
#					COMMAND gawk -f ${CMAKE_CURRENT_SOURCE_DIR}/libgcc/mkmap-flat.awk -v pe_dll=libgcc_s_seh-1.dll > ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/libgcc.map.def)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gcc-libs/libgcc_s_seh-1.dll
					COMMAND ${C_COMPILER} -BC:/Development/mingw64/bin -BC:/Development/mingw64/x86_64-w64-mingw32/lib -LC:/Development/mingw64/x86_64-w64-mingw32/lib -pthread -shared -nodefaultlibs ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/libgcc.map -Wl,--out-implib,${CMAKE_CURRENT_BINARY_DIR}/gcc-libs/libgcc_s.a -o ${CMAKE_CURRENT_BINARY_DIR}/gcc-libs/libgcc_s_seh-1.dll  ${libgcc_s_objs}
							${CMAKE_CURRENT_BINARY_DIR}/libgcc.a -Wl,-lpthread -lmingwthrd -lmingw32 -lmingwex -lmoldname -lmsvcrt -ladvapi32 -lshell32 -luser32 -lkernel32
					DEPENDS ${libgcc_s_objs} )#${CMAKE_CURRENT_BINARY_DIR}/libgcc_s/libgcc.map.def)
		
add_custom_target(libgcc_s ALL
				DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/gcc-libs/libgcc_s_seh-1.dll)

#######################################################################################
################        LIBSTDC++
#######################################################################################

check_functions(acosf acosl aligned_alloc asinf asinl atan2f atan2l atanf atanl at_quick_exit
				ceilf ceill cosf coshf coshl cosl expf expl fabsf fabsl finite finitef finitel
				floorf floorl fmodf fmodl fpclass frexpf frexpl hypot hypotf hypotl #the iconv() function
				isinf isinff isinfl isnan isnanf isnanl ldexpf ldexpl log10f log10l logf logl
 				memalign modf modff modfl posix_memalign powf powl qfpclass quick_exit setenv
				sincos sincosf sincosl sinf sinhf sinhl sinl sockatmark sqrtf sqrtl strtof
				strtold tanf tanhf tanhl tanl timespec_get _acosf _acosl _aligned_malloc _asinf
				_asinl _atan2f _atan2l _atanf _atanl _ceilf _ceill _cosf _coshf _coshl _cosl
				_expf _expl _fabsf _fabsl _finite _finitef _finitel _floorf _floorl _fmodf
				_fmodl _fpclass _frexpf _frexpl _hypot _hypotf _hypotl _isinf _isinff _isinfl
				_isnan _isnanf _isnanl _ldexpf _ldexpl _log10f _log10l _logf _logl _modf _modff
				_modfl _powf _powl _qfpclass _sincos _sincosf _sincosl _sinf _sinhf _sinhl _sinl
				_sqrtf _sqrtl _tanf _tanhf _tanhl _tanl _wfopen __cxa_thread_atexit __cxa_thread_atexit_impl)

check_c_headers(arpa/inet.h complex.h dirent.h dlfcn.h endian.h execinfo.h fcntl.h fenv.h float.h fp.h
				ieeefp.h inttypes.h libintl.h linux/random.h linux/types.h locale.h machine/endian.h machine/param.h
				memory.h nan.h netdb.h netinet/in.h netinet/tcp.h poll.h stdalign.h stdbool.h stdint.h stdlib.h
				strings.h string.h sys/filio.h sys/ioctl.h sys/ipc.h sys/isa_defs.h sys/machine.h sys/param.h
				sys/resource.h sys/sem.h sys/socket.h sys/statvfs.h sys/stat.h sys/sysinfo.h sys/time.h sys/types.h
				sys/uio.h tgmath.h uchar.h unistd.h utime.h wchar.h wctype.h)

check_types(int64_t long "long long" char int short "void *")

check_c_source_compiles("
void foo (void); __asm (\".symver foo, bar@SYMVER\");
int
main ()
{

  ;
  return 0;
}"
HAVE_AS_SYMVER_DIRECTIVE)

set(err_checks 
	EBADMSG ECANCELLED ECHILD EIDRM ENODATA ENOLINK ENOSPC ENOSR ENOSTR ENOTRECOVERABLE ENOTSUP 
	EOVERFLOW EOWNERDEAD EPERM EPROTO ETIME ETIMEOUT ETXTBSY EWOULDBLOCK)
foreach(e ${err_checks})
	check_c_source_compiles("
/* end confdefs.h.  */
#include <errno.h>
int
main ()
{
int i = ${e};
  ;
  return 0;
}"
HAVE_${e})
endforeach()

check_cxx_source_compiles("
#include <stdio.h>
	   namespace test
	   {
              using ::gets;
	   }"
	   HAVE_GETS)

check_cxx_source_compiles("
#include <wctype.h>
int
main ()
{
wint_t t; int i = iswblank(t);
  ;
  return 0;
}"
HAVE_ISWBLANK)

check_c_source_compiles("
#include <locale.h>
int
main ()
{
return LC_MESSAGES
  ;
  return 0;
}"
HAVE_LC_MESSAGES)

check_cxx_source_compiles("
#include <unistd.h>
int
main ()
{
link(\"\", \"\");
  ;
  return 0;
}"
HAVE_LINK)

set(limit_checks AS DATA FSIZE RSS VMEM)
foreach(l ${limit_checks})
check_c_source_compiles("
#include <unistd.h>
     #include <sys/time.h>
     #include <sys/resource.h>

int
main ()
{
 int f = RLIMIT_${l} ;
  ;
  return 0;
}"
HAVE_LIMIT_${l})
endforeach()

if(UNIX)
check_c_source_compiles("
#ifndef _GNU_SOURCE
	     #define _GNU_SOURCE 1
	     #endif
	     #include <pthread.h>
	     pthread_t th; void *status;
int
main ()
{
pthread_tryjoin_np (th, &status);
  ;
  return 0;
}"
HAVE_LINUX_FUTEX)
endif()

check_c_source_compiles("
#include <wchar.h>
int
main ()
{
mbstate_t teststate;
  ;
  return 0;
}"
HAVE_MBSTATE_T)

check_cxx_source_compiles("
#include <poll.h>
int
main ()
{
struct pollfd pfd[1];
       pfd[0].events = POLLIN;
       poll(pfd, 1, 0);
  ;
  return 0;
}"
HAVE_POLL)

check_cxx_source_compiles("
#include <unistd.h>
int
main ()
{
sleep(1)
  ;
  return 0;
}"
HAVE_SLEEP)

check_cxx_source_compiles("
#include <unistd.h>
int
main ()
{
sleep(1)
  ;usleep(100);
  return 0;
}"
HAVE_USLEEP)

check_cxx_source_compiles("
#include <unistd.h>
int
main ()
{
symlink(\"\", \"\");
  ;
  return 0;
}"
HAVE_SYMLINK)

check_c_source_compiles("
#define _GNU_SOURCE 1
     		    #include <string.h>
		    #include <locale.h>
int
main ()
{
char s[128]; __locale_t loc; strxfrm_l(s, \"C\", 5, loc);
  ;
  return 0;
}"
HAVE_STRXFRM_L)

check_cxx_source_compiles("
#include <dirent.h>
int
main ()
{

         struct dirent d;
         if (sizeof d.d_type) return 0;

  ;
  return 0;
}"
HAVE_STRUCT_DIRENT_D_TYPE)

check_cxx_source_compiles("
#include <unistd.h>
int
main ()
{
truncate(\"\", 99);
  ;
  return 0;
}"
HAVE_TRUNCATE)

set(scanf_checks vfwscanf cswscanf vwscanf wcstof)

foreach(s ${scanf_checks})
	string(TOUPPER ${s} var) 
check_cxx_source_compiles("
#include <wchar.h>
        namespace test { using ::${s}; }
int
main ()
{

  ;
  return 0;
}"
HAVE_${var})
endforeach()

check_cxx_source_compiles("
#include <windows.h>
int
main ()
{
Sleep(1)
  ;
  return 0;
}"
HAVE_WIN32_SLEEP)

check_cxx_source_compiles("
#include <sys/uio.h>
int
main ()
{
struct iovec iov[2];
       writev(0, iov, 0);
  ;
  return 0;
}"
HAVE_WRITEV)

####################
## GLIBCXX checks
###################

check_cxx_source_compiles("
#include <complex.h>
           typedef __complex__ float float_type;
           typedef __complex__ double double_type;
           typedef __complex__ long double ld_type;
           volatile float_type tmpf;
           volatile double_type tmpd;
           volatile ld_type tmpld;
           volatile float f;
           volatile double d;
           volatile long double ld;
int
main ()
{
f = cabsf(tmpf);
           f = cargf(tmpf);
           tmpf = ccosf(tmpf);
           tmpf = ccoshf(tmpf);
           tmpf = cexpf(tmpf);
           tmpf = clogf(tmpf);
           tmpf = csinf(tmpf);
           tmpf = csinhf(tmpf);
           tmpf = csqrtf(tmpf);
           tmpf = ctanf(tmpf);
           tmpf = ctanhf(tmpf);
           tmpf = cpowf(tmpf, tmpf);
           tmpf = cprojf(tmpf);
           d = cabs(tmpd);
           d = carg(tmpd);
           tmpd = ccos(tmpd);
           tmpd = ccosh(tmpd);
           tmpd = cexp(tmpd);
           tmpd = clog(tmpd);
           tmpd = csin(tmpd);
           tmpd = csinh(tmpd);
           tmpd = csqrt(tmpd);
           tmpd = ctan(tmpd);
           tmpd = ctanh(tmpd);
           tmpd = cpow(tmpd, tmpd);
           tmpd = cproj(tmpd);
           ld = cabsl(tmpld);
           ld = cargl(tmpld);
           tmpld = ccosl(tmpld);
           tmpld = ccoshl(tmpld);
           tmpld = cexpl(tmpld);
           tmpld = clogl(tmpld);
           tmpld = csinl(tmpld);
           tmpld = csinhl(tmpld);
           tmpld = csqrtl(tmpld);
           tmpld = ctanl(tmpld);
           tmpld = ctanhl(tmpld);
           tmpld = cpowl(tmpld, tmpld);
           tmpld = cprojl(tmpld);

  ;
  return 0;
}"
_GLIBCXX11_USE_C99_COMPLEX)

check_cxx_source_compiles("
#include <math.h>
         volatile double d1, d2;
         volatile int i;
int
main ()
{
i = fpclassify(d1);
         i = isfinite(d1);
         i = isinf(d1);
         i = isnan(d1);
         i = isnormal(d1);
         i = signbit(d1);
         i = isgreater(d1, d2);
         i = isgreaterequal(d1, d2);
         i = isless(d1, d2);
         i = islessequal(d1, d2);
         i = islessgreater(d1, d2);
         i = islessgreater(d1, d2);
         i = isunordered(d1, d2);

  ;
  return 0;
}"
_GLIBCXX11_USE_C99_MATH)

check_cxx_source_compiles("
#include <stdio.h>
         #include <stdarg.h>
         void foo(char* fmt, ...)
         {
           va_list args; va_start(args, fmt);
           vfscanf(stderr, \"%i\", args);
           vscanf(\"%i\", args);
           vsnprintf(fmt, 0, \"%i\", args);
           vsscanf(fmt, \"%i\", args);
           snprintf(fmt, 0, \"%i\");
         }
int
main ()
{

  ;
  return 0;
}"
_GLIBCXX11_USE_C99_STDIO)

check_cxx_source_compiles("
#include <stdlib.h>
         volatile float f;
         volatile long double ld;
         volatile unsigned long long ll;
         lldiv_t mydivt;
int
main ()
{
char* tmp;
         f = strtof(\"gnu\", &tmp);
         ld = strtold(\"gnu\", &tmp);
         ll = strtoll(\"gnu\", &tmp, 10);
         ll = strtoull(\"gnu\", &tmp, 10);
         ll = llabs(10);
         mydivt = lldiv(10,1);
         ll = mydivt.quot;
         ll = mydivt.rem;
         ll = atoll(\"10\");
         _Exit(0);

  ;
  return 0;
}"
_GLIBCXX11_USE_C99_STDLIB)

check_cxx_source_compiles("
#include <wctype.h>
int
main ()
{
wint_t t; int i = iswblank(t);
  ;
  return 0;
}"
_GLIBCXX11_USE_C99_WCHAR)

if(_GLIBCXX11_USE_C99_COMPLEX)
set(_GLIBCXX98_USE_C99_COMPLEX 1)
endif()

if(_GLIBCXX11_USE_C99_MATH)
set(_GLIBCXX98_USE_C99_MATH 1)
endif()

if(_GLIBCXX11_USE_C99_STDIO)
set(_GLIBCXX98_USE_C99_STDIO 1)
endif()

if(_GLIBCXX11_USE_C99_STDLIB)
set(_GLIBCXX98_USE_C99_STDLIB 1)
endif()

if(_GLIBCXX11_USE_C99_WCHAR)
set(_GLIBCXX98_USE_C99_WCHAR 1)
endif()

check_cxx_source_compiles("
int main()
{
  typedef long long atomic_type;
  atomic_type c1;
  atomic_type c2;
  atomic_type c3(0);
  __atomic_fetch_add(&c1, c2, __ATOMIC_RELAXED);
  __atomic_compare_exchange_n(&c1, &c2, c3, true, __ATOMIC_ACQ_REL,
			      __ATOMIC_RELAXED);
  __atomic_test_and_set(&c1, __ATOMIC_RELAXED);
  __atomic_load_n(&c1, __ATOMIC_RELAXED);

  return 0;
}"
_GLIBCXX_ATOMIC_BUILTINS)

set(_GLIBCXX_FULLY_DYNAMIC_STRING 1)
set(_GLIBCXX_HOSTED 1)

check_cxx_source_compiles("
#include \"gthr.h\"
int
main ()
{

      #ifndef __GTHREADS_CXX0X
      #error
      #endif

  ;
  return 0;
}"
_GLIBCXX_HAS_GTHREADS)

check_cxx_source_compiles("
int
main ()
{

#if !defined __LONG_DOUBLE_128__ || (defined(__sparc__) && defined(__arch64__))
#error no need for long double compatibility
#endif

  ;
  return 0;
}"
_GLIBCXX_LONG_DOUBLE_COMPAT)

#check
set(_GLIBCXX_MANGLE_SIZE_T y)

check_cxx_source_compiles("
#include <math.h>
int
main ()
{
llrint(0.0);
		  llrintf(0.0f);
		  llrintl(0.0l);
		  llround(0.0);
		  llroundf(0.0f);
		  llroundl(0.0l);

  ;
  return 0;
}"
_GLIBCXX_C99_ROUNDING_FUNCS)
if(_GLIBCXX_C99_ROUNDING_FUNCS)
set(_GLIBCXX_NO_C99_ROUNDING_FUNCS 1)
endif()

check_cxx_source_compiles("
int
main ()
{
__PTRDIFF_TYPE__* ptp; int* ip; ptp = ip;
  ;
  return 0;
}"
_GLIBCXX_PTRDIFF_T_IS_INT)

check_cxx_source_compiles("
#include <unistd.h>
	 #include <sys/time.h>
	 #include <sys/resource.h>

int
main ()
{
struct rlimit r;
	 setrlimit(0, &r);
  ;
  return 0;
}"
_GLIBCXX_RES_LIMITS)

check_cxx_source_compiles("
int
main ()
{
__SIZE_TYPE__* stp; unsigned int* uip; stp = uip;
  ;
  return 0;
}"
_GLIBCXX_SIZE_T_IS_UINT)

#check
set(_GLIBCXX_STDIO_EOF -1)
set(_GLIBCXX_STDIO_SEEK_CUR 1)
set(_GLIBCXX_STDIO_SEEK_END 2)

check_cxx_source_compiles("
#include <uchar.h>
		    #ifdef __STDC_UTF_16__
		    long i = __STDC_UTF_16__;
		    #endif
		    #ifdef __STDC_UTF_32__
		    long j = __STDC_UTF_32__;
		    #endif
		    namespace test
		    {
		      using ::c16rtomb;
		      using ::c32rtomb;
		      using ::mbrtoc16;
		      using ::mbrtoc32;
		    }

int
main ()
{

  ;
  return 0;
}"
_GLIBCXX_USE_C11_UCHAR_CXX11)

if(_GLIBCXX11_USE_C99_COMPLEX AND _GLIBCXX11_USE_C99_MATH AND _GLIBCXX11_USE_C99_STDIO
	AND _GLIBCXX11_USE_C99_STDLIB AND _GLIBCXX11_USE_C99_WCHAR)
set(_GLIBCXX_USE_C99 1)
endif()


check_cxx_source_compiles("
#include <complex.h>
int
main ()
{
typedef __complex__ float float_type; float_type tmpf;
		    cacosf(tmpf);
		    casinf(tmpf);
		    catanf(tmpf);
		    cacoshf(tmpf);
		    casinhf(tmpf);
		    catanhf(tmpf);
		    typedef __complex__ double double_type; double_type tmpd;
		    cacos(tmpd);
		    casin(tmpd);
		    catan(tmpd);
		    cacosh(tmpd);
		    casinh(tmpd);
		    catanh(tmpd);
		    typedef __complex__ long double ld_type; ld_type tmpld;
		    cacosl(tmpld);
		    casinl(tmpld);
		    catanl(tmpld);
		    cacoshl(tmpld);
		    casinhl(tmpld);
		    catanhl(tmpld);

  ;
  return 0;
}"
_GLIBCXX_USE_C99_COMPLEX_TR1)

check_cxx_source_compiles("
#include <ctype.h>
int
main ()
{
int ch;
		  int ret;
		  ret = isblank(ch);

  ;
  return 0;
}"
_GLIBCXX_USE_C99_CTYPE_TR1)

check_cxx_source_compiles("
#include <fenv.h>
int
main ()
{
int except, mode;
		    fexcept_t* pflag;
		    fenv_t* penv;
		    int ret;
		    ret = feclearexcept(except);
		    ret = fegetexceptflag(pflag, except);
		    ret = feraiseexcept(except);
		    ret = fesetexceptflag(pflag, except);
		    ret = fetestexcept(except);
		    ret = fegetround();
		    ret = fesetround(mode);
		    ret = fegetenv(penv);
		    ret = feholdexcept(penv);
		    ret = fesetenv(penv);
		    ret = feupdateenv(penv);

  ;
  return 0;
}"
_GLIBCXX_USE_C99_FENV_TR1)

check_cxx_source_compiles("
#include <inttypes.h>
int
main ()
{
intmax_t i, numer, denom, base;
		    const char* s;
		    char** endptr;
		    intmax_t ret = imaxabs(i);
		    imaxdiv_t dret = imaxdiv(numer, denom);
		    ret = strtoimax(s, endptr, base);
		    uintmax_t uret = strtoumax(s, endptr, base);

  ;
  return 0;
}"
_GLIBCXX_USE_C99_INTTYPES_TR1)

check_cxx_source_compiles("
#include <inttypes.h>
int
main ()
{
intmax_t base;
		    const wchar_t* s;
		    wchar_t** endptr;
		    intmax_t ret = wcstoimax(s, endptr, base);
		    uintmax_t uret = wcstoumax(s, endptr, base);

  ;
  return 0;
}"
_GLIBCXX_USE_C99_INTTYPES_WCHAR_T_TR1)

check_cxx_source_compiles("
#include <math.h>
int
main ()
{
typedef double_t  my_double_t;
		  typedef float_t   my_float_t;
		  acosh(0.0);
		  acoshf(0.0f);
		  acoshl(0.0l);
		  asinh(0.0);
		  asinhf(0.0f);
		  asinhl(0.0l);
		  atanh(0.0);
		  atanhf(0.0f);
		  atanhl(0.0l);
		  cbrt(0.0);
		  cbrtf(0.0f);
		  cbrtl(0.0l);
		  copysign(0.0, 0.0);
		  copysignf(0.0f, 0.0f);
		  copysignl(0.0l, 0.0l);
		  erf(0.0);
		  erff(0.0f);
		  erfl(0.0l);
		  erfc(0.0);
		  erfcf(0.0f);
		  erfcl(0.0l);
		  exp2(0.0);
		  exp2f(0.0f);
		  exp2l(0.0l);
		  expm1(0.0);
		  expm1f(0.0f);
		  expm1l(0.0l);
		  fdim(0.0, 0.0);
		  fdimf(0.0f, 0.0f);
		  fdiml(0.0l, 0.0l);
		  fma(0.0, 0.0, 0.0);
		  fmaf(0.0f, 0.0f, 0.0f);
		  fmal(0.0l, 0.0l, 0.0l);
		  fmax(0.0, 0.0);
		  fmaxf(0.0f, 0.0f);
		  fmaxl(0.0l, 0.0l);
		  fmin(0.0, 0.0);
		  fminf(0.0f, 0.0f);
		  fminl(0.0l, 0.0l);
		  hypot(0.0, 0.0);
		  hypotf(0.0f, 0.0f);
		  hypotl(0.0l, 0.0l);
		  ilogb(0.0);
		  ilogbf(0.0f);
		  ilogbl(0.0l);
		  lgamma(0.0);
		  lgammaf(0.0f);
		  lgammal(0.0l);
		  #ifndef __APPLE__ /* see below */
		  llrint(0.0);
		  llrintf(0.0f);
		  llrintl(0.0l);
		  llround(0.0);
		  llroundf(0.0f);
		  llroundl(0.0l);
		  #endif
		  log1p(0.0);
		  log1pf(0.0f);
		  log1pl(0.0l);
		  log2(0.0);
		  log2f(0.0f);
		  log2l(0.0l);
		  logb(0.0);
		  logbf(0.0f);
		  logbl(0.0l);
		  lrint(0.0);
		  lrintf(0.0f);
		  lrintl(0.0l);
		  lround(0.0);
		  lroundf(0.0f);
		  lroundl(0.0l);
		  nan(0);
		  nanf(0);
		  nanl(0);
		  nearbyint(0.0);
		  nearbyintf(0.0f);
		  nearbyintl(0.0l);
		  nextafter(0.0, 0.0);
		  nextafterf(0.0f, 0.0f);
		  nextafterl(0.0l, 0.0l);
		  nexttoward(0.0, 0.0);
		  nexttowardf(0.0f, 0.0f);
		  nexttowardl(0.0l, 0.0l);
		  remainder(0.0, 0.0);
		  remainderf(0.0f, 0.0f);
		  remainderl(0.0l, 0.0l);
		  remquo(0.0, 0.0, 0);
		  remquof(0.0f, 0.0f, 0);
		  remquol(0.0l, 0.0l, 0);
		  rint(0.0);
		  rintf(0.0f);
		  rintl(0.0l);
		  round(0.0);
		  roundf(0.0f);
		  roundl(0.0l);
		  scalbln(0.0, 0l);
		  scalblnf(0.0f, 0l);
		  scalblnl(0.0l, 0l);
		  scalbn(0.0, 0);
		  scalbnf(0.0f, 0);
		  scalbnl(0.0l, 0);
		  tgamma(0.0);
		  tgammaf(0.0f);
		  tgammal(0.0l);
		  trunc(0.0);
		  truncf(0.0f);
		  truncl(0.0l);

  ;
  return 0;
}"
_GLIBCXX_USE_C99_MATH_TR1)

check_cxx_source_compiles("
#define __STDC_LIMIT_MACROS
		  #define __STDC_CONSTANT_MACROS
		  #include <stdint.h>
int
main ()
{
typedef int8_t          my_int8_t;
		  my_int8_t               i8 = INT8_MIN;
		  i8 = INT8_MAX;
		  typedef int16_t         my_int16_t;
		  my_int16_t              i16 = INT16_MIN;
		  i16 = INT16_MAX;
		  typedef int32_t         my_int32_t;
		  my_int32_t              i32 = INT32_MIN;
		  i32 = INT32_MAX;
		  typedef int64_t         my_int64_t;
		  my_int64_t              i64 = INT64_MIN;
		  i64 = INT64_MAX;
		  typedef int_fast8_t     my_int_fast8_t;
		  my_int_fast8_t          if8 = INT_FAST8_MIN;
		  if8 = INT_FAST8_MAX;
		  typedef int_fast16_t    my_int_fast16_t;
		  my_int_fast16_t         if16 = INT_FAST16_MIN;
		  if16 = INT_FAST16_MAX;
		  typedef int_fast32_t    my_int_fast32_t;
		  my_int_fast32_t         if32 = INT_FAST32_MIN;
		  if32 = INT_FAST32_MAX;
		  typedef int_fast64_t    my_int_fast64_t;
		  my_int_fast64_t         if64 = INT_FAST64_MIN;
		  if64 = INT_FAST64_MAX;
		  typedef int_least8_t    my_int_least8_t;
		  my_int_least8_t         il8 = INT_LEAST8_MIN;
		  il8 = INT_LEAST8_MAX;
		  typedef int_least16_t   my_int_least16_t;
		  my_int_least16_t        il16 = INT_LEAST16_MIN;
		  il16 = INT_LEAST16_MAX;
		  typedef int_least32_t   my_int_least32_t;
		  my_int_least32_t        il32 = INT_LEAST32_MIN;
		  il32 = INT_LEAST32_MAX;
		  typedef int_least64_t   my_int_least64_t;
		  my_int_least64_t        il64 = INT_LEAST64_MIN;
		  il64 = INT_LEAST64_MAX;
		  typedef intmax_t        my_intmax_t;
		  my_intmax_t             im = INTMAX_MAX;
		  im = INTMAX_MIN;
		  typedef intptr_t        my_intptr_t;
		  my_intptr_t             ip = INTPTR_MAX;
		  ip = INTPTR_MIN;
		  typedef uint8_t         my_uint8_t;
		  my_uint8_t              ui8 = UINT8_MAX;
		  ui8 = UINT8_MAX;
		  typedef uint16_t        my_uint16_t;
		  my_uint16_t             ui16 = UINT16_MAX;
		  ui16 = UINT16_MAX;
		  typedef uint32_t        my_uint32_t;
		  my_uint32_t             ui32 = UINT32_MAX;
		  ui32 = UINT32_MAX;
		  typedef uint64_t        my_uint64_t;
		  my_uint64_t             ui64 = UINT64_MAX;
		  ui64 = UINT64_MAX;
		  typedef uint_fast8_t    my_uint_fast8_t;
		  my_uint_fast8_t         uif8 = UINT_FAST8_MAX;
		  uif8 = UINT_FAST8_MAX;
		  typedef uint_fast16_t   my_uint_fast16_t;
		  my_uint_fast16_t        uif16 = UINT_FAST16_MAX;
		  uif16 = UINT_FAST16_MAX;
		  typedef uint_fast32_t   my_uint_fast32_t;
		  my_uint_fast32_t        uif32 = UINT_FAST32_MAX;
		  uif32 = UINT_FAST32_MAX;
		  typedef uint_fast64_t   my_uint_fast64_t;
		  my_uint_fast64_t        uif64 = UINT_FAST64_MAX;
		  uif64 = UINT_FAST64_MAX;
		  typedef uint_least8_t   my_uint_least8_t;
		  my_uint_least8_t        uil8 = UINT_LEAST8_MAX;
		  uil8 = UINT_LEAST8_MAX;
		  typedef uint_least16_t  my_uint_least16_t;
		  my_uint_least16_t       uil16 = UINT_LEAST16_MAX;
		  uil16 = UINT_LEAST16_MAX;
		  typedef uint_least32_t  my_uint_least32_t;
		  my_uint_least32_t       uil32 = UINT_LEAST32_MAX;
		  uil32 = UINT_LEAST32_MAX;
		  typedef uint_least64_t  my_uint_least64_t;
		  my_uint_least64_t       uil64 = UINT_LEAST64_MAX;
		  uil64 = UINT_LEAST64_MAX;
		  typedef uintmax_t       my_uintmax_t;
		  my_uintmax_t            uim = UINTMAX_MAX;
		  uim = UINTMAX_MAX;
		  typedef uintptr_t       my_uintptr_t;
		  my_uintptr_t            uip = UINTPTR_MAX;
		  uip = UINTPTR_MAX;

  ;
  return 0;
}"
_GLIBCXX_USE_C99_STDINT_TR1)

check_cxx_source_compiles("
#include <unistd.h>
	   #include <time.h>
	   #include <sys/syscall.h>

int
main ()
{
#if _POSIX_TIMERS > 0 && defined(_POSIX_MONOTONIC_CLOCK)
	    timespec tp;
	   #endif
	   syscall(SYS_clock_gettime, CLOCK_MONOTONIC, &tp);
	   syscall(SYS_clock_gettime, CLOCK_REALTIME, &tp);

  ;
  return 0;
}"
_GLIBCXX_USE_CLOCK_GETTIME_SYSCALL)

if(_GLIBCXX_USE_CLOCK_GETTIME_SYSCALL)
set(_GLIBCXX_USE_CLOCK_MONOTONIC 1)
set(_GLIBCXX_USE_CLOCK_REALTIME 1)
endif()


check_cxx_source_compiles("
int main()
{
  _Decimal32 d1;
  _Decimal64 d2;
  _Decimal128 d3;
  return 0;
}"
_GLIBCXX_USE_DECIMAL_FLOAT)

check_cxx_source_compiles("

          #include <fcntl.h>
          #include <sys/stat.h>

int
main ()
{
fchmodat(AT_FDCWD, \"\", 0, AT_SYMLINK_NOFOLLOW);
  ;
  return 0;
}"
_GLIBCXX_USE_FCHMODAT)

check_cxx_source_compiles("
#include <sys/stat.h>
int
main ()
{
fchmod(1, S_IWUSR);
  ;
  return 0;
}"
_GLIBCXX_USE_FCHMOD)

check_cxx_source_compiles("
#include <sys/time.h>
int
main ()
{
timeval tv; gettimeofday(&tv, 0);
  ;
  return 0;
}"
_GLIBCXX_USE_GETTIMEOFDAY)

check_cxx_source_compiles("
#include <sys/sysinfo.h>
int
main ()
{
int n = get_nprocs();
  ;
  return 0;
}"
_GLIBCXX_USE_GET_NPROCS)

check_cxx_source_compiles("
template<typename T1, typename T2>
  struct same
  { typedef T2 type; };

template<typename T>
  struct same<T, T>;

int main()
{
  typename same<long, __int128>::type                i1;
  typename same<long long, __int128>::type           i2;
}"
_GLIBCXX_USE_INT128)

check_cxx_source_compiles("
#include <unistd.h>
       #include <stdio.h>
       #include <sys/stat.h>

int
main ()
{
FILE* fp;
       fopen64(\"t\", \"w\");
       fseeko64(fp, 0, SEEK_CUR);
       ftello64(fp);
       lseek64(1, 0, SEEK_CUR);
       struct stat64 buf;
       fstat64(1, &buf);
  ;
  return 0;
}"
_GLIBCXX_USE_LFS)

set(_GLIBCXX_USE_LONG_LONG 1)

check_cxx_source_compiles("
 #include <sys/stat.h>
int
main ()
{

          struct stat st;
          int i = lstat(\"path\", &st);

  ;
  return 0;
}"
_GLIBCXX_USE_LSTAT)

check_cxx_source_compiles("
#include <unistd.h>
	 #include <time.h>

int
main ()
{
#if _POSIX_TIMERS > 0
	  timespec tp;
	 #endif
	  nanosleep(&tp, 0);

  ;
  return 0;
}"
_GLIBCXX_USE_NANOSLEEP)

check_cxx_source_compiles("
#include <pthread.h>
int
main ()
{
int n = pthread_num_processors_np();
  ;
  return 0;
}"
_GLIBCXX_USE_PTHREADS_NUM_PROCESSORS_NP)

if(_GLIBCXX_USE_PTHREADS_NUM_PROCESSORS_NP)
set(_GLIBCXX_USE_PTHREAD_RWLOCK_T 1) #check
endif()

check_cxx_source_compiles("

         #include <limits.h>
         #include <stdlib.h>
         #include <unistd.h>

int
main ()
{

         #if _XOPEN_VERSION < 500
         #error
         #elif _XOPEN_VERSION >= 700 || defined(PATH_MAX)
         char *tmp = realpath((const char*)NULL, (char*)NULL);
         #else
         #error
         #endif

  ;
  return 0;
}"
_GLIBCXX_USE_REALPATH)

check_cxx_source_compiles("
#ifdef __cplusplus
extern \"C\"
#endif
char sched_yield ();
int
main ()
{
return sched_yield ();
  ;
  return 0;
}"
_GLIBCXX_USE_SCHED_YIELD)

check_cxx_source_compiles("
#include <unistd.h>
int
main ()
{
int n = sysconf(_SC_NPROCESSORS_ONLN);
  ;
  return 0;
}"
_GLIBCXX_USE_SC_NPROCESSORS_ONLN)

check_cxx_source_compiles("
#include <unistd.h>
int
main ()
{
int n = sysconf(_SC_NPROC_ONLN);
  ;
  return 0;
}"
_GLIBCXX_USE_SC_NPROC_ONLN)

check_cxx_source_compiles("
#include <sys/sendfile.h>
int
main ()
{
sendfile(1, 2, (off_t*)0, sizeof 1);
  ;
  return 0;
}"
_GLIBCXX_USE_SENDFILE)

check_cxx_source_compiles("
#include <sys/stat.h>
int
main ()
{

          struct stat st;
          return st.st_mtim.tv_nsec;

  ;
  return 0;
}"
_GLIBCXX_USE_ST_MTIM)

check_cxx_source_compiles("
      #include <stddef.h>
       #include <sys/sysctl.h>

int
main ()
{

       int count;
       size_t size = sizeof(count);
       int mib[] = { CTL_HW, HW_NCPU };
       sysctl(mib, 2, &count, &size, NULL, 0);

  ;
  return 0;"
_GLIBCXX_USE_SYSCTL_HW_NCPU)

check_cxx_source_compiles("
#include <stdio.h>
int
main ()
{
char *tmp = tmpnam(NULL);
  ;
  return 0;
}"
_GLIBCXX_USE_TMPNAM)

check_cxx_source_compiles("

          #include <utime.h>

int
main ()
{

          struct utimbuf t = { 1, 1 };
          int i = utime(\"path\", &t);

  ;
  return 0;
}"
_GLIBCXX_USE_UTIME)

check_cxx_source_compiles("
         #include <fcntl.h>
          #include <sys/stat.h>

int
main ()
{

          struct timespec ts[2] = { { 0, UTIME_OMIT }, { 1, 1 } };
          int i = utimensat(AT_FDCWD, \"path\", ts, 0);

  ;
  return 0;
}"
_GLIBCXX_USE_UTIMENSAT)

check_cxx_source_compiles("
#include <wchar.h>
		      #include <stddef.h>
		      wint_t i;
		      long l = WEOF;
		      long j = WCHAR_MIN;
		      long k = WCHAR_MAX;
		      namespace test
		      {
			using ::btowc;
			using ::fgetwc;
			using ::fgetws;
			using ::fputwc;
			using ::fputws;
			using ::fwide;
			using ::fwprintf;
			using ::fwscanf;
			using ::getwc;
			using ::getwchar;
 			using ::mbrlen;
			using ::mbrtowc;
			using ::mbsinit;
			using ::mbsrtowcs;
			using ::putwc;
			using ::putwchar;
			using ::swprintf;
			using ::swscanf;
			using ::ungetwc;
			using ::vfwprintf;
			using ::vswprintf;
			using ::vwprintf;
			using ::wcrtomb;
			using ::wcscat;
			using ::wcschr;
			using ::wcscmp;
			using ::wcscoll;
			using ::wcscpy;
			using ::wcscspn;
			using ::wcsftime;
			using ::wcslen;
			using ::wcsncat;
			using ::wcsncmp;
			using ::wcsncpy;
			using ::wcspbrk;
			using ::wcsrchr;
			using ::wcsrtombs;
			using ::wcsspn;
			using ::wcsstr;
			using ::wcstod;
			using ::wcstok;
			using ::wcstol;
			using ::wcstoul;
			using ::wcsxfrm;
			using ::wctob;
			using ::wmemchr;
			using ::wmemcmp;
			using ::wmemcpy;
			using ::wmemmove;
			using ::wmemset;
			using ::wprintf;
			using ::wscanf;
		      }

int
main ()
{

  ;
  return 0;
}"
_GLIBCXX_USE_WCHAR_T)

set(_GLIBCXX_VERBOSE 1)

check_cxx_source_compiles("
int
main ()
{
asm(\"rdrand %eax\");
  ;
  return 0;
}"
_GLIBCXX_X86_RDRAND)

check_cxx_source_compiles("
#include <unistd.h>
int
main ()
{

      // In case of POSIX threads check _POSIX_TIMEOUTS.
      #if (defined(_PTHREADS) \
	  && (!defined(_POSIX_TIMEOUTS) || _POSIX_TIMEOUTS <= 0))
      #error
      #endif

  ;
  return 0;
}"
_GTHREAD_USE_MUTEX_TIMEDLOCK)

check_cxx_source_compiles("
#include <math.h>
	   #undef isfinite
	   namespace std {
	     inline bool isfinite(float __x)
	     { return __builtin_isfinite(__x); }
	   }"
	   __CORRECT_ISO_CPP11_MATH_H_PROTO_FP)

check_cxx_source_compiles("#include <math.h>
	   namespace std {
	     template<typename _Tp>
	       struct __is_integer;
	     template<>
	       struct __is_integer<int>
	       {
	         enum { __value = 1 };
	       };
	   }
	   namespace __gnu_cxx {
	     template<bool, typename>
	       struct __enable_if;
	     template<typename _Tp>
	       struct __enable_if<true, _Tp>
	       { typedef _Tp __type; };
	   }
	   namespace std {
	     template<typename _Tp>
	       constexpr typename __gnu_cxx::__enable_if
	       		 <__is_integer<_Tp>::__value, double>::__type
	       log2(_Tp __x)
	       { return __builtin_log2(__x); }
	   }
	   int
	   main (void)
	   {
	     int i = 1000;
	     return std::log2(i);
	   }"
	   __CORRECT_ISO_CPP11_MATH_H_PROTO_INT)


if(SIZEOF_LONG EQUAL SIZEOF_INT64_T)
set(HAVE_INT64_T_LONG 1)
elseif(SIZEOF_LONG_LONG EQUAL SIZEOF_INT64_T)
set(HAVE_INT64_T_LONG_LONG 1)
endif()

set(HAVE_ATOMIC_LOCK_POLICY 1)
set(HAVE_ICONV 1)
set(ICONV_CONST " ")

configure_file(libstdc++-config.h.in ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/config.h)

file(RELATIVE_PATH CMAKE_CURRENT_SOURCE_DIR_RELATIVE ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/CMakelists.txt)
string(REPLACE "/CMakeLists.txt" "" CMAKE_CURRENT_SOURCE_DIR_RELATIVE ${CMAKE_CURRENT_SOURCE_DIR_RELATIVE})
configure_file(make_headers.sh.in ${CMAKE_CURRENT_BINARY_DIR}/make_headers.sh)

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/backward/ ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/decimal/
		${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/debug/ ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/experimental/ ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/parallel/
		${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/ext/ ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/profile/ ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/pstl/
		${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/tr1/ ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/tr2/ ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/bits/)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/mingw/bits/c++config.h#plus others
					COMMAND sh make_headers.sh)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/iostream
					COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/include/std/* ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/include/backward/* ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/backward/
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/include/c_global/* ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/include/decimal/* ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/decimal/
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/include/debug/* ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/debug/
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/include/experimental/* ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/experimental/
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/include/parallel/* ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/parallel/
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/include/ext/* ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/ext/
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/include/profile/* ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/profile/
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/include/pstl/* ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/pstl/
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/include/tr1/* ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/tr1/
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/include/tr2/* ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/tr2/
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/include/bits/*.h ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/bits/
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/include/bits/*.tcc ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/bits/
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/libsupc++/*.h ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/bits/
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/libsupc++/exception ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/exception
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/libsupc++/new ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/new
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/libsupc++/typeinfo ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/typeinfo
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/libsupc++/initializer_list ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/initializer_list
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/include/precompiled/* ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/mingw/bits/
					##config copies
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/config/os/mingw32-w64/*.h ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/mingw/bits/
					COMMAND cp  ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/config/abi/compatibility.h ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/mingw/bits/compatibility.h
					COMMAND cp -pR ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/config/cpu/i486/opt/* ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/mingw/
					COMMAND cp  ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/config/cpu/generic/*.h ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/mingw/bits/
					COMMAND cp  ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/config/locale/generic/c_locale.h ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/mingw/bits/c++locale.h
					COMMAND cp  ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/config/locale/generic/c++locale_internal.h ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/mingw/bits/c++locale_internal.h
					COMMAND cp  ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/config/locale/generic/messages_members.h ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/mingw/bits/messages_members.h
					COMMAND cp  ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/config/locale/generic/time_members.h ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/mingw/bits/time_members.h
					COMMAND cp  ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/config/io/c_io_stdio.h ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/mingw/bits/c++io.h
					COMMAND cp  ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/config/io/basic_file_stdio.h ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/mingw/bits/basic_file.h
					COMMAND cp 	${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/config/allocator/*.h ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/mingw/ext/
					COMMAND cp 	${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/config/allocator/new_allocator_base.h ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/mingw/bits/c++allocator.h)
add_custom_target(c++-headers DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/mingw/bits/c++config.h ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/iostream)

set(libsupc_OBJS
	array_type_info atexit_arm atexit_thread bad_alloc bad_array_length
	bad_array_new bad_cast bad_typeid class_type_info del_op del_ops
	del_opnt del_opv del_opvs del_opvnt dyncast eh_alloc eh_arm eh_aux_runtime
	eh_call eh_catch eh_exception eh_globals eh_personality eh_ptr
	eh_term_handler eh_terminate eh_tm eh_throw eh_type eh_unex_handler
	enum_type_info function_type_info fundamental_type_info guard guard_error hash_bytes
	nested_exception new_handler new_op new_opnt new_opv new_opvnt new_opa new_opant new_opva new_opvant
	del_opa del_opant del_opsa del_opva del_opvant del_opvsa pbase_type_info pmem_type_info pointer_type_info
	pure si_class_type_info tinfo tinfo2 vec vmi_class_type_info vterminate)

set(libstdc++_FLAGS
	-shared-libgcc -nostdinc++ -D_GLIBCXX_SHARED -fno-implicit-templates -Wall -Wextra -Wwrite-strings -Wcast-qual -Wabi=2 -fdiagnostics-show-location=once -ffunction-sections -fdata-sections -O2)

set(libstdc++_INCLUDES
	-I${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include  -I${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/mingw -I${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/libsupc++ -I${CMAKE_CURRENT_SOURCE_DIR}/libgcc -I${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/config -I${CMAKE_CURRENT_BINARY_DIR}/libstdc++
	-IC:/Development/mingw64/x86_64-w64-mingw32/include	-IC:/Development/mingw64/lib/gcc/x86_64-w64-mingw32/8.1.0/include)

foreach(i ${libsupc_OBJS})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libsupc/${i}.o
					COMMAND ${CXX_COMPILER} ${libstdc++_FLAGS} ${libstdc++_INCLUDES} -c -std=gnu++1z ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/libsupc++/${i}.cc -o ${CMAKE_CURRENT_BINARY_DIR}/libsupc/${i}.o
					DEPENDS g++ c++-headers)
	list(APPEND libsupc_objs ${CMAKE_CURRENT_BINARY_DIR}/libsupc/${i}.o)
endforeach()

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libsupc/cp-demangle.o
					COMMAND ${C_COMPILER} -DHAVE_CONFIG_H -D_GLIBCXX_SHARED -O2  -DIN_GLIBCPP_V3 -Wno-error -c -I${CMAKE_CURRENT_BINARY_DIR}/libiberty ${libstdc++_INCLUDES} -I${CMAKE_CURRENT_SOURCE_DIR}/include ${CMAKE_CURRENT_SOURCE_DIR}/libiberty/cp-demangle.c -o ${CMAKE_CURRENT_BINARY_DIR}/libsupc/cp-demangle.o
					DEPENDS gcc)
list(APPEND libsupc_objs ${CMAKE_CURRENT_BINARY_DIR}/libsupc/cp-demangle.o)

#generate atomicty.cc
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/atomicity.cc
					COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/config/cpu/generic/atomicity_builtins/atomicity.h ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/atomicity.cc)
	

set(c++98_SOURCES
	bitmap_allocator.cc pool_allocator.cc mt_allocator.cc codecvt.cc complex_io.cc 
	globals_io.cc hash_tr1.cc hashtable_tr1.cc ios_failure.cc ios_init.cc ios_locale.cc 
	list.cc list-aux.cc list-aux-2.cc list_associated.cc list_associated-2.cc locale.cc 
	locale_facets.cc  math_stubs_float.cc math_stubs_long_double.cc 
	stdexcept.cc strstream.cc tree.cc istream.cc istream-string.cc streambuf.cc valarray.cc 
	cow-istream-string.cc allocator-inst.cc concept-inst.cc ext-inst.cc misc-inst.cc)
	#compatibility.cc compatibility-debug_list.cc  compatibility-debug_list-2.cc)

set(c++98_host_SOURCES_abi
	collate_members.cc 
	messages_members.cc 
	monetary_members.cc 
	numeric_members.cc)

if(WIN32)
set(c++98_host_SOURCES	
	locale/generic/codecvt_members.cc 
	locale/generic/collate_members.cc 
	locale/generic/messages_members.cc 
	locale/generic/monetary_members.cc 
	locale/generic/numeric_members.cc 
	locale/generic/time_members.cc
	#extra
	io/basic_file_stdio.cc 
	locale/generic/c_locale.cc)

elseif(UNIX)
set(c++98_host_SOURCES	
	locale/gnu/codecvt_members.cc 
	locale/gnu/collate_members.cc 
	locale/gnu/messages_members.cc 
	locale/gnu/monetary_members.cc 
	locale/gnu/numeric_members.cc 
	locale/gnu/time_members.cc
	#extra
	io/basic_file_stdio.cc 
	locale/gnu/c_locale.cc)
endif()


set(c++98_parallel_SOURCES
	parallel_settings.cc)

foreach(i ${c++98_SOURCES})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++98/${i}.o
						COMMAND ${CXX_COMPILER} ${libstdc++_FLAGS} ${libstdc++_INCLUDES} -std=gnu++98 -I${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/backward -c ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/src/c++98/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++98/${i}.o
						DEPENDS g++ c++-headers)
	list(APPEND c++98_objs ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++98/${i}.o)	
endforeach()

foreach(i ${c++98_host_SOURCES})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++98/${i}.o
						COMMAND ${CXX_COMPILER} ${libstdc++_FLAGS} ${libstdc++_INCLUDES} -std=gnu++98 -c ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/config/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++98/${i}.o
						DEPENDS g++ c++-headers)
	list(APPEND c++98_objs ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++98/${i}.o)		
endforeach()

foreach(i ${c++98_host_SOURCES_abi})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++98/${i}_abi.o
						COMMAND ${CXX_COMPILER} ${libstdc++_FLAGS} ${libstdc++_INCLUDES} -D_GLIBCXX_USE_CXX11_ABI=0 -std=gnu++98 -c ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/config/locale/generic/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++98/${i}_abi.o
						DEPENDS g++ c++-headers)
	list(APPEND c++98_objs ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++98/${i}_abi.o)		
endforeach()

foreach(i ${c++98_parallel_SOURCES})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++98/${i}.o
						COMMAND ${CXX_COMPILER} ${libstdc++_FLAGS} ${libstdc++_INCLUDES} -std=gnu++98 -c ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/src/c++98/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++98/${i}.o
						DEPENDS g++ c++-headers)
	list(APPEND c++98_objs ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++98/${i}.o)		
endforeach()

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++98/atomicity.o
					COMMAND ${CXX_COMPILER} ${libstdc++_FLAGS} ${libstdc++_INCLUDES} -std=gnu++98 -c ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/atomicity.cc -o ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++98/atomicity.o
					DEPENDS g++ c++-headers ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/atomicity.cc)
				list(APPEND c++98_objs ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++98/atomicity.o)	



set(c++11_SOURCES
	chrono.cc condition_variable.cc cow-stdexcept.cc 
	ctype.cc debug.cc functexcept.cc functional.cc 
	futex.cc future.cc hash_c++0x.cc ios.cc mutex.cc 
	placeholders.cc random.cc regex.cc  shared_ptr.cc 
	snprintf_lite.cc system_error.cc thread.cc cow-locale_init.cc 
	cow-shim_facets.cc cxx11-hash_tr1.cc cxx11-shim_facets.cc 
	cxx11-stdexcept.cc cow-fstream-inst.cc cow-sstream-inst.cc 
	cow-string-inst.cc cow-string-io-inst.cc cow-wstring-inst.cc 
	cow-wstring-io-inst.cc cxx11-locale-inst.cc cxx11-wlocale-inst.cc 
	sso_string.cc ext11-inst.cc fstream-inst.cc ios-inst.cc 
	iostream-inst.cc istream-inst.cc locale-inst.cc ostream-inst.cc 
	sstream-inst.cc streambuf-inst.cc string-inst.cc string-io-inst.cc 
	wlocale-inst.cc wstring-inst.cc wstring-io-inst.cc)


set(c++11_host_SOURCES
	os/mingw32-w64/ctype_configure_char.cc 
	locale/generic/ctype_members.cc)

set(char8_SOURCES
	c++11/codecvt.cc c++11/limits.cc c++98/locale_init.cc c++98/localename.cc)

set(c++11_hash_SOURCES hashtable_c++0x.cc )

foreach(i ${c++11_SOURCES})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++11/${i}.o
						COMMAND ${CXX_COMPILER} ${libstdc++_FLAGS} ${libstdc++_INCLUDES} -std=gnu++11 -c ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/src/c++11/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++11/${i}.o
						DEPENDS g++ c++-headers)
	list(APPEND c++11_objs ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++11/${i}.o)	
endforeach()

foreach(i ${c++11_host_SOURCES})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++11/${i}.o
						COMMAND ${CXX_COMPILER} ${libstdc++_FLAGS} ${libstdc++_INCLUDES} -std=gnu++11 -c ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/config/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++11/${i}.o
						DEPENDS g++ c++-headers)
	list(APPEND c++11_objs ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++11/${i}.o)	
endforeach()

foreach(i ${char8_SOURCES})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/${i}.o
						COMMAND ${CXX_COMPILER} ${libstdc++_FLAGS} ${libstdc++_INCLUDES} -std=gnu++11 -fchar8_t -c ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/src/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/${i}.o
						DEPENDS g++ c++-headers)
	list(APPEND c++11_objs ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/${i}.o)	
endforeach()

foreach(i ${c++11_hash_SOURCES})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++11/${i}.o
						COMMAND ${CXX_COMPILER} ${libstdc++_FLAGS} ${libstdc++_INCLUDES} -std=gnu++11 -fimplicit-templates -c ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/src/c++11/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++11/${i}.o
						DEPENDS g++ c++-headers)
	list(APPEND c++11_objs ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++11/${i}.o)	
endforeach()


add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++11/cxx11-ios_failure.o
					COMMAND ${CXX_COMPILER} ${libstdc++_FLAGS} ${libstdc++_INCLUDES} -std=gnu++11 -S ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/src/c++11/cxx11-ios_failure.cc -o ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++11/tmp-cxx11-ios_failure.s
					&& sed -e '/^_*_ZTISt13__ios_failure:/,/_ZTVN10__cxxabiv120__si_class_type_infoE/s/_ZTVN10__cxxabiv120__si_class_type_infoE/_ZTVSt19__iosfail_type_info/' ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++11/tmp-cxx11-ios_failure.s > ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++11/cxx11-ios_failure.s
					&& ${CXX_COMPILER} ${libstdc++_FLAGS} ${libstdc++_INCLUDES} -std=gnu++11 -c ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++11/cxx11-ios_failure.s -o ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++11/cxx11-ios_failure.o)
			list(APPEND c++11_objs ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++11/cxx11-ios_failure.o)	




set(c++17_SOURCES
	fs_dir.cc fs_ops.cc fs_path.cc 
	memory_resource.cc cow-fs_dir.cc 
	cow-fs_ops.cc cow-fs_path.cc
	ostream-inst.cc string-inst.cc cow-string-inst.cc)

foreach(i ${c++17_SOURCES})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++17/${i}.o
						COMMAND ${CXX_COMPILER} ${libstdc++_FLAGS} ${libstdc++_INCLUDES} -std=gnu++17 -fimplicit-templates -c ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/src/c++17/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++17/${i}.o
						DEPENDS g++ c++-headers)
	list(APPEND c++17_objs ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/c++17/${i}.o)	
endforeach()

set(filesystem_SOURCES
	cow-dir.cc  cow-ops.cc  cow-path.cc  dir.cc  ops.cc  path.cc)

foreach(i ${filesystem_SOURCES})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/filesystem/${i}.o
						COMMAND ${CXX_COMPILER} ${libstdc++_FLAGS} ${libstdc++_INCLUDES} -std=gnu++17 -c ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/src/filesystem/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/filesystem/${i}.o
						DEPENDS g++ c++-headers)
	list(APPEND filesystem_objs ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/filesystem/${i}.o)	
endforeach()

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libstdc++fs.a
					COMMAND ar rcs ${CMAKE_CURRENT_BINARY_DIR}/libstdc++fs.a ${filesystem_objs}
					DEPENDS ${filesystem_objs})

add_custom_target(libfilesystem ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/libstdc++fs.a)

set(compatibility_98_SOURCES
	c++98/compatibility.cc c++98/compatibility-debug_list.cc  c++98/compatibility-debug_list-2.cc)
set(compatibility_11_SOURCES
	c++11/compatibility-atomic-c++0x.cc  c++11/compatibility-chrono.cc   c++11/compatibility-thread-c++0x.cc
	c++11/compatibility-c++0x.cc  c++11/compatibility-condvar.cc)

foreach(i ${compatibility_98_SOURCES})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/compatibility/${i}.o
						COMMAND ${CXX_COMPILER} ${libstdc++_FLAGS} ${libstdc++_INCLUDES} -DDLL_EXPORT -DPIC -std=gnu++98 -c ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/src/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/compatibility/${i}.o
						DEPENDS g++ c++-headers)
	list(APPEND compatibility_objs ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/compatibility/${i}.o)	
endforeach()

foreach(i ${compatibility_11_SOURCES})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/compatibility/${i}.o
						COMMAND ${CXX_COMPILER} ${libstdc++_FLAGS} ${libstdc++_INCLUDES} -DDLL_EXPORT -DPIC -std=gnu++11 -c ${CMAKE_CURRENT_SOURCE_DIR}/libstdc++-v3/src/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/compatibility/${i}.o
						DEPENDS g++ c++-headers)
	list(APPEND compatibility_objs ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/compatibility/${i}.o)	
endforeach()


add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libstdc++-6.dll
				COMMAND ${CXX_COMPILER} -BC:/Development/mingw64/x86_64-w64-mingw32/lib -shared-libgcc -shared -nostdlib C:/Development/mingw64/x86_64-w64-mingw32/lib/dllcrt2.o C:/Development/mingw64/x86_64-w64-mingw32/lib/crtbegin.o #A:/Environment/mingw64/x86_64-w64-mingw32/lib/dllcrt2.o A:/my/gcc/windows-build/gcc/crtbegin.o
				 ${compatibility_objs} ${libsupc_objs} ${c++98_objs} ${c++11_objs} ${c++17_objs}
				 -lmingw32 -lgcc_s -lgcc -lmoldname -lmingwex -lmsvcrt -lpthread -ladvapi32 -lshell32 -luser32 -lkernel32 C:/Development/mingw64/x86_64-w64-mingw32/lib/crtend.o
				 -o ${CMAKE_CURRENT_BINARY_DIR}/libstdc++-6.dll -Wl,--enable-auto-image-base -Xlinker --out-implib -Xlinker ${CMAKE_CURRENT_BINARY_DIR}/libstdc++.dll.a
				 DEPENDS  ${compatibility_objs} ${libsupc_objs} ${c++98_objs} ${c++11_objs} ${c++17_objs} )

add_custom_target(libstdc++dll ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/libstdc++-6.dll)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libstdc++.a
				COMMAND ar rcs ${CMAKE_CURRENT_BINARY_DIR}/libstdc++.a
				 ${compatibility_objs} ${libsupc_objs} ${c++98_objs} ${c++11_objs} ${c++17_objs}
				 DEPENDS  ${compatibility_objs} ${libsupc_objs} ${c++98_objs} ${c++11_objs} ${c++17_objs} )

add_custom_target(libstdc++ ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/libstdc++.a)

###################################################################################
########    LIBATOMIC
###################################################################################

configure_file(gstdint.h ${CMAKE_CURRENT_BINARY_DIR}/libatomic/gstdint.h)
set(libatomic_common_SOURCES
	gload.c gstore.c gcas.c gexch.c glfree.c
	fence.c flag.c)

set(libatomic_config_SOURCES
	config/posix/lock.c config/x86/init.c config/x86/fenv.c)

set(libatomic_FLAGS -pthread  -O2 -DHAVE_CONFIG_H -DDLL_EXPORT -DPIC)
set(libatomic_INCLUDES -I${CMAKE_CURRENT_SOURCE_DIR}/libatomic/config/posix -I${CMAKE_CURRENT_SOURCE_DIR}/libatomic -I${CMAKE_CURRENT_SOURCE_DIR}/libatomic/config/x86 
	-I${CMAKE_CURRENT_BINARY_DIR}/libatomic -IC:/Development/mingw64/x86_64-w64-mingw32/include	-IC:/Development/mingw64/lib/gcc/x86_64-w64-mingw32/8.1.0/include)

set(libatomic_n_SOURCES
	load store cas exch fadd fsub fand fior fxor fnand tas )

foreach(i ${libatomic_common_SOURCES})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libatomic/${i}.o
			COMMAND ${C_COMPILER} ${libatomic_FLAGS} ${libatomic_INCLUDES} -c ${CMAKE_CURRENT_SOURCE_DIR}/libatomic/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libatomic/${i}.o
			DEPENDS gcc)
	list(APPEND libatomic_objs ${CMAKE_CURRENT_BINARY_DIR}/libatomic/${i}.o)
endforeach()

foreach(i ${libatomic_config_SOURCES})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libatomic/${i}.o
			COMMAND ${C_COMPILER} ${libatomic_FLAGS} ${libatomic_INCLUDES} -c ${CMAKE_CURRENT_SOURCE_DIR}/libatomic/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libatomic/${i}.o
			DEPENDS gcc)
	list(APPEND libatomic_objs ${CMAKE_CURRENT_BINARY_DIR}/libatomic/${i}.o)
endforeach()


foreach(i ${libatomic_n_SOURCES})
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libatomic/${i}_1.o
			COMMAND ${C_COMPILER} ${libatomic_FLAGS} ${libatomic_INCLUDES} -DN=1 -c ${CMAKE_CURRENT_SOURCE_DIR}/libatomic/${i}_n.c -o ${CMAKE_CURRENT_BINARY_DIR}/libatomic/${i}_1.o
			DEPENDS gcc)
list(APPEND libatomic_objs ${CMAKE_CURRENT_BINARY_DIR}/libatomic/${i}_1.o)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libatomic/${i}_2.o
			COMMAND ${C_COMPILER} ${libatomic_FLAGS} ${libatomic_INCLUDES} -DN=2 -c ${CMAKE_CURRENT_SOURCE_DIR}/libatomic/${i}_n.c -o ${CMAKE_CURRENT_BINARY_DIR}/libatomic/${i}_2.o
			DEPENDS gcc)
list(APPEND libatomic_objs ${CMAKE_CURRENT_BINARY_DIR}/libatomic/${i}_2.o)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libatomic/${i}_4.o
			COMMAND ${C_COMPILER} ${libatomic_FLAGS} ${libatomic_INCLUDES} -DN=4 -c ${CMAKE_CURRENT_SOURCE_DIR}/libatomic/${i}_n.c -o ${CMAKE_CURRENT_BINARY_DIR}/libatomic/${i}_4.o
			DEPENDS gcc)
list(APPEND libatomic_objs ${CMAKE_CURRENT_BINARY_DIR}/libatomic/${i}_4.o)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libatomic/${i}_8.o
			COMMAND ${C_COMPILER} ${libatomic_FLAGS} ${libatomic_INCLUDES} -DN=8 -c ${CMAKE_CURRENT_SOURCE_DIR}/libatomic/${i}_n.c -o ${CMAKE_CURRENT_BINARY_DIR}/libatomic/${i}_8.o
			DEPENDS gcc)
list(APPEND libatomic_objs ${CMAKE_CURRENT_BINARY_DIR}/libatomic/${i}_8.o)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libatomic/${i}_16.o
			COMMAND ${C_COMPILER} ${libatomic_FLAGS} ${libatomic_INCLUDES} -DN=16 -c ${CMAKE_CURRENT_SOURCE_DIR}/libatomic/${i}_n.c -o ${CMAKE_CURRENT_BINARY_DIR}/libatomic/${i}_16.o
			DEPENDS gcc)
list(APPEND libatomic_objs ${CMAKE_CURRENT_BINARY_DIR}/libatomic/${i}_16.o)
endforeach()

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libatomic-1.dll
					COMMAND ${C_COMPILER} -shared -BC:/Development/mingw64/x86_64-w64-mingw32/lib/ ${libatomic_objs} -pthread -o ${CMAKE_CURRENT_BINARY_DIR}/libatomic-1.dll -Wl,--enable-auto-image-base -Xlinker --out-implib -Xlinker ${CMAKE_CURRENT_BINARY_DIR}/libatomic.dll.a
					DEPENDS ${libatomic_objs})

#requires windows manifest
add_custom_target(libatomic ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/libatomic-1.dll)

##################################################################################
##############  LIBGOMP
##################################################################################

check_c_headers(dlfcn.h inttypes.h memory.h pthread.h semaphore.h stdint.h stdlib.h strings.h string.h 
				sys/loadavg.h sys/stat.h sys/sysctl.h sys/time.h sys/types.h unistd.h)

check_functions(aligned_alloc clock_gettime getegid geteuid getgid getloadavg getuid posix_memalign secure_getenv
				strtoull _aligned_malloc __secure_getenv)

check_types(char int long short "void *")

check_c_source_compiles("
void foo (void); __asm (\".symver foo, bar@SYMVER\");
int
main ()
{

  ;
  return 0;
}"
HAVE_AS_SYMVER_DIRECTIVE)

check_c_source_compiles("
void foo(void) { }
extern void bar(void) __attribute__((alias(\"foo\")));
int
main ()
{
bar();
  ;
  return 0;
}"
HAVE_ATTRIBUTE_ALIAS)

check_c_source_compiles("
void __attribute__((dllexport)) foo(void) { }
int
main ()
{

  ;
  return 0;
}"
HAVE_ATTRIBUTE_DLLEXPORT)

check_c_source_compiles("
oid __attribute__((visibility(\"hidden\"))) foo(void) { }
int
main ()
{

  ;
  return 0;
}"
HAVE_ATTRIBUTE_VISIBILITY)

check_c_source_compiles("
#include <unistd.h>
int
main ()
{

   char buf[256];
   if (gethostname (buf, sizeof (buf) - 1) == 0)
     buf[255] = '0';

  ;
  return 0;
}"
HAVE_GETHOSTNAME)

check_c_source_compiles("
#include <unistd.h>
int
main ()
{
int pid = getpid ();
  ;
  return 0;
}"
HAVE_GETPID)

check_c_source_compiles("
#ifdef __cplusplus
extern \"C\"
#endif
char dlopen ();
int
main ()
{
return dlopen ();
  ;
  return 0;
}"
HAVE_LIBDL)

check_c_source_compiles("
#define _GNU_SOURCE
   #include <pthread.h>
int
main ()
{
cpu_set_t cpuset;
   pthread_attr_t attr;
   pthread_getaffinity_np (pthread_self (), sizeof (cpu_set_t), &cpuset);
   if (CPU_ISSET (0, &cpuset))
     CPU_SET (1, &cpuset);
   else
     CPU_ZERO (&cpuset);
   pthread_setaffinity_np (pthread_self (), sizeof (cpu_set_t), &cpuset);
   pthread_attr_init (&attr);
   pthread_attr_getaffinity_np (&attr, sizeof (cpu_set_t), &cpuset);
   pthread_attr_setaffinity_np (&attr, sizeof (cpu_set_t), &cpuset);
  ;
  return 0;
}"
HAVE_PTHREAD_AFFINITY_NP)

check_symbol_exists( _Mutex_Control "sys/lock.h" HAVE_STRUCT__MUTEX_CONTROL)

check_c_source_compiles("
int
main ()
{
int foo; __sync_val_compare_and_swap(&foo, 0, 1);
  ;
  return 0;
}"
HAVE_SYNC_BUILTINS)

set(HAVE_TLS 1)
set(HSA_RUNTIME_LIB \"\")
set(LIBGOMP_USE_PTHREADS 1)

check_c_source_compiles("
#include <string.h>
   #include <stdlib.h>
   #include <sys/utsname.h>
int
main ()
{
struct utsname buf;
   volatile size_t len = 0;
   if (!uname (buf))
     len = strlen (buf.nodename);
  ;
  return 0;
}"
HAVE_UNAME)

configure_file(libgomp-config.h.in ${CMAKE_CURRENT_BINARY_DIR}/libgomp/config.h)
configure_file(gstdint.h ${CMAKE_CURRENT_BINARY_DIR}/libgomp/gstdint.h)

#check_type_size(omp_lock_t OMP_LOCK_SIZE)
#check_type_size("__alignof (omp_lock_t)" OMP_LOCK_ALIGN)
#check_type_size(omp_nest_lock_t OMP_NEST_LOCK_SIZE)
#check_type_size("__alignof (omp_nest_lock_t)" OMP_NEST_LOCK_ALIGN)
#check_type_size(omp_lock_25_t OMP_LOCK_25_SIZE)
#check_type_size("__alignof omp_lock_25_t" OMP_LOCK_25_ALIGN)
#check_type_size(omp_nest_lock_25_t OMP_NEST_LOCK_25_SIZE)
#check_type_size("__alignof omp_nest_lock_25_t" OMP_NEST_LOCK_25_ALIGN)

set(OMP_LOCK_SIZE 8)
set(OMP_LOCK_ALIGN 8)
set(OMP_LOCK_KIND 8)

set(OMP_NEST_LOCK_SIZE 24)
set(OMP_NEST_LOCK_ALIGN 8)
set(OMP_NEST_LOCK_KIND 8)

set(OMP_LOCK_25_KIND 8)
set(OMP_LOCK_25_SIZE 8)
set(OMP_LOCK_25_ALIGN 8)

set(OMP_NEST_LOCK_25_KIND 8)
set(OMP_NEST_LOCK_25_SIZE 16)
set(OMP_NEST_LOCK_25_ALIGN 8)

configure_file(libgomp/libgomp_f.h.in ${CMAKE_CURRENT_BINARY_DIR}/libgomp/libgomp_f.h @ONLY)
configure_file(libgomp/omp.h.in ${CMAKE_CURRENT_BINARY_DIR}/libgomp/omp.h @ONLY)



set(libgomp_SOURCES
	alloc.c atomic.c barrier.c
	critical.c env.c error.c icv.c
	icv-device.c iter.c iter_ull.c loop.c
	loop_ull.c ordered.c parallel.c sections.c
	single.c task.c team.c work.c 
	fortran.c target.c splay-tree.c libgomp-plugin.c
	oacc-parallel.c oacc-host.c oacc-init.c 
	oacc-mem.c oacc-async.c oacc-plugin.c oacc-cuda.c
	priority_queue.c teams.c )


if(WIN32)
set(libgomp_config_SOURCES
	posix/lock.c posix/mutex.c
	mingw32/proc.c posix/sem.c
	posix/bar.c posix/ptrlock.c
	mingw32/time.c mingw32/affinity-fmt.c)
list(APPEND libgomp_SOURCES affinity.c)
elseif(UNIX)
set(libgomp_config_SOURCES
	linux/lock.c linux/mutex.c
	linux/proc.c linux/sem.c
	linux/bar.c linux/ptrlock.c
	linux/time.c linux/affinity.c)
list(TRANSFORM libgomp_config_SOURCES PREPEND "libgomp/config/")
list(APPEND libgomp_SOURCES affinity-fmt.c)
endif()

set(libgomp_INCLUDES -I${CMAKE_CURRENT_SOURCE_DIR}/libgomp -I${CMAKE_CURRENT_BINARY_DIR}/libgomp -I${CMAKE_CURRENT_SOURCE_DIR}/include)

if(WIN32)
set(libgomp_INCLUDES ${libgomp_INCLUDES} -I${CMAKE_CURRENT_SOURCE_DIR}/libgomp/config/posix)
elseif(UNIX)
set(libgomp_INCLUDES ${libgomp_INCLUDES} -I${CMAKE_CURRENT_SOURCE_DIR}/libgomp/config/linux)
endif()

foreach(i ${libgomp_SOURCES})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgomp/${i}.o
					COMMAND ${C_COMPILER} -DDLL_EXPORT -DPIC -DHAVE_CONFIG_H -pthread ${libgomp_INCLUDES} -IC:/Development/mingw64/x86_64-w64-mingw32/include -IC:/Development/mingw64/lib/gcc/x86_64-w64-mingw32/8.1.0/include -c ${CMAKE_CURRENT_SOURCE_DIR}/libgomp/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libgomp/${i}.o
					DEPENDS gcc)
	list(APPEND libgomp_objs ${CMAKE_CURRENT_BINARY_DIR}/libgomp/${i}.o)
endforeach()

foreach(i ${libgomp_config_SOURCES})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgomp/${i}.o
					COMMAND ${C_COMPILER} -DDLL_EXPORT -DPIC -DHAVE_CONFIG_H -pthread ${libgomp_INCLUDES} -IC:/Development/mingw64/x86_64-w64-mingw32/include -IC:/Development/mingw64/lib/gcc/x86_64-w64-mingw32/8.1.0/include -c ${CMAKE_CURRENT_SOURCE_DIR}/libgomp/config/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libgomp/${i}.o
					DEPENDS gcc)
	list(APPEND libgomp_objs ${CMAKE_CURRENT_BINARY_DIR}/libgomp/${i}.o)
endforeach()

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libgomp-1.dll
					COMMAND ${C_COMPILER} -BC:/Development/mingw64/bin -BC:/Development/mingw64/x86_64-w64-mingw32/lib -shared -pthread -o ${CMAKE_CURRENT_BINARY_DIR}/libgomp-1.dll -Xlinker --out-implib -Xlinker ${CMAKE_CURRENT_BINARY_DIR}/libgomp.dll.a ${libgomp_objs}
					DEPENDS ${libgomp_objs})

add_custom_target(libgomp ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/libgomp-1.dll)

##################################################################################
##############  LIBQUADMATH
##################################################################################

check_c_headers(ctype.h dlfcn.h errno.h fenv.h inttypes.h langinfo.h limits.h locale.h memory.h printf.h
				stdint.h stdlib.h strings.s string.h sys/stat.h sys/types.h unistd.h wchar.h wctype.h)

check_functions(strtoull)

set(libm_check cbrtl fesetenv feholdexcept fetestexcept feupdateenv sqrtl)

foreach(m ${libm_check})
	string(TOUPPER ${m} var)
	check_c_source_compiles("
#ifdef __cplusplus
extern \"C\"
#endif
char ${m} ();
int
main ()
{
return ${m} ();
  ;
  return 0;
}"
HAVE_${var})
endforeach()


check_c_source_compiles("
#include <math.h>
void foo(void) { signgam = 1; }
int
main ()
{

  ;
  return 0;
}"
HAVE_MATH_H_SIGNGAM)

check_c_source_compiles("
#include <printf.h>
#include <stdarg.h>
#include <stdlib.h>
extern void flt128_va (void *, va_list *);
extern int flt128_ais (const struct printf_info *, size_t, int *, int *);
extern int flt128_printf_fp (FILE *, const struct printf_info *, const void *const *);

int
main ()
{

int pa_flt128 = register_printf_type (flt128_va);
int mod_Q = register_printf_modifier (L\"Q\");
int res = register_printf_specifier ('f', flt128_printf_fp, flt128_ais);
struct printf_info info = { .user = -1 };

  ;
  return 0;
}"
HAVE_PRINTF_HOOKS)

check_c_source_compiles("
#include <langinfo.h>
#include <limits.h>
#include <string.h>
#include <wchar.h>
#include <wctype.h>
int
main ()
{

const char *s;
char decimal[MB_LEN_MAX];
wctrans_t map = wctrans (\"to_outpunct\");
wint_t wdecimal = towctrans (L'.', map);
mbstate_t state;
memset (&state, '0', sizeof (state));
wcrtomb (decimal, wdecimal, &state);
s = nl_langinfo (_NL_CTYPE_OUTDIGIT0_MB);
s = nl_langinfo (_NL_CTYPE_OUTDIGIT0_WC);
s = nl_langinfo (_NL_CTYPE_MB_CUR_MAX);
(void) s;

  ;
  return 0;
}"
USE_I18N_NUMBER_H)

check_c_source_compiles("
#include <locale.h>
int
main ()
{

const struct lconv *l = localeconv ();
const char *s;
s = l->decimal_point;
s = l->mon_decimal_point;
s = l->grouping;
s = l->mon_grouping;
s = l->thousands_sep;
s = l->mon_thousands_sep;
(void) s;

  ;
  return 0;
}"
USE_LOCALECONV)

check_c_source_compiles("
#include <langinfo.h>
int
main ()
{

const char *s;
s = nl_langinfo (DECIMAL_POINT);
s = nl_langinfo (MON_DECIMAL_POINT);
s = nl_langinfo (GROUPING);
s = nl_langinfo (MON_GROUPING);
s = nl_langinfo (THOUSANDS_SEP);
s = nl_langinfo (MON_THOUSANDS_SEP);
(void) s;

  ;
  return 0;
}"
USE_NL_LANGINFO)

check_c_source_compiles("
#include <langinfo.h>
int
main ()
{

const char *s;
s = nl_langinfo (_NL_NUMERIC_DECIMAL_POINT_WC);
s = nl_langinfo (_NL_MONETARY_DECIMAL_POINT_WC);
s = nl_langinfo (_NL_NUMERIC_THOUSANDS_SEP_WC);
s = nl_langinfo (_NL_MONETARY_THOUSANDS_SEP_WC);
(void) s;

  ;
  return 0;
}"
USE_NL_LANGINFO_WC)

configure_file(libquadmath-config.h.in ${CMAKE_CURRENT_BINARY_DIR}/libquadmath/config.h)

set(libquadmath_SOURCES
  math/x2y2m1q.c math/acoshq.c math/fmodq.c 
  math/acosq.c math/frexpq.c 
  math/rem_pio2q.c math/asinhq.c math/hypotq.c math/remainderq.c 
  math/asinq.c math/rintq.c math/atan2q.c math/isinfq.c 
  math/roundq.c math/atanhq.c math/isnanq.c math/scalblnq.c math/atanq.c 
  math/j0q.c math/scalbnq.c math/cbrtq.c math/j1q.c math/signbitq.c 
  math/ceilq.c math/jnq.c math/sincos_table.c math/complex.c math/ldexpq.c 
  math/sincosq.c math/copysignq.c math/lgammaq.c math/sincosq_kernel.c 
  math/coshq.c math/llroundq.c math/sinhq.c math/cosq.c math/log10q.c 
  math/sinq.c math/cosq_kernel.c math/log1pq.c math/sinq_kernel.c 
  math/erfq.c math/logq.c math/sqrtq.c math/expm1q.c math/lroundq.c 
  math/tanhq.c math/expq.c math/modfq.c math/tanq.c math/fabsq.c 
  math/nanq.c math/tgammaq.c math/finiteq.c math/nextafterq.c 
  math/truncq.c math/floorq.c math/powq.c math/fmaq.c math/logbq.c 
  math/exp2q.c math/issignalingq.c math/lgammaq_neg.c math/lgammaq_product.c 
  math/tanq_kernel.c math/tgammaq_product.c math/casinhq_kernel.c 
  math/cacoshq.c math/cacosq.c math/casinhq.c math/casinq.c 
  math/catanhq.c math/catanq.c math/cimagq.c math/conjq.c math/cprojq.c 
  math/crealq.c math/fdimq.c math/fmaxq.c math/fminq.c math/ilogbq.c 
  math/llrintq.c math/log2q.c math/lrintq.c math/nearbyintq.c math/remquoq.c 
  math/ccoshq.c math/cexpq.c math/clog10q.c math/clogq.c math/csinq.c 
  math/csinhq.c math/csqrtq.c math/ctanq.c math/ctanhq.c 
  printf/addmul_1.c printf/add_n.c printf/cmp.c printf/divrem.c 
  printf/flt1282mpn.c printf/fpioconst.c printf/lshift.c printf/mul_1.c 
  printf/mul_n.c printf/mul.c printf/printf_fphex.c printf/printf_fp.c 
  printf/quadmath-printf.c printf/rshift.c printf/submul_1.c printf/sub_n.c 
  strtod/strtoflt128.c strtod/mpn2flt128.c strtod/tens_in_limb.c)

set(libquadmath_INCLUDES -I${CMAKE_CURRENT_SOURCE_DIR}/libquadmath -I${CMAKE_CURRENT_BINARY_DIR}/libquadmath -I${CMAKE_CURRENT_SOURCE_DIR}/include)

foreach(i ${libquadmath_SOURCES})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libquadmath/${i}.o
					COMMAND ${C_COMPILER} -DDLL_EXPORT -DPIC -DHAVE_CONFIG_H -pthread ${libquadmath_INCLUDES} -IC:/Development/mingw64/x86_64-w64-mingw32/include -IC:/Development/mingw64/lib/gcc/x86_64-w64-mingw32/8.1.0/include -c ${CMAKE_CURRENT_SOURCE_DIR}/libquadmath/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libquadmath/${i}.o
					DEPENDS gcc)
	list(APPEND libquadmath_objs ${CMAKE_CURRENT_BINARY_DIR}/libquadmath/${i}.o)
endforeach()

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libquadmath-1.dll
					COMMAND ${C_COMPILER} -BC:/Development/mingw64/bin -BC:/Development/mingw64/x86_64-w64-mingw32/lib -shared -pthread -o ${CMAKE_CURRENT_BINARY_DIR}/libquadmath-1.dll -Xlinker --out-implib -Xlinker ${CMAKE_CURRENT_BINARY_DIR}/libquadmath.dll.a ${libquadmath_objs}
					DEPENDS ${libquadmath_objs})

add_custom_target(libquadmath ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/libquadmath-1.dll)

##################################################################################
##############  LIBSSP
##################################################################################

check_c_headers(alloca.h dlfcn.h fcntl.h inttypes.h malloc.h memory.h paths.h syslog.h 
				stdio.h stdint.h stdlib.h strings.s string.h sys/stat.h sys/types.h unistd.h)

check_functions(memmove memcpy strncat strncpy)

check_c_source_compiles("
#include <stdarg.h>
#include <string.h>
#include <stdio.h>
int foo (char *buf, size_t n, const char *fmt, ...)
{
  va_list ap;
  int ret;
  va_start (ap, fmt);
  ret = vsnprintf (buf, n, fmt, ap);
  va_end (ap);
  return ret;
}
int
main ()
{
char buf[8]; memset (buf, 'A', sizeof (buf));
 if (foo (buf, 4, \".%s.\", \"CDEFG\") != 7)
   return 1;
 return memcmp (buf, \".CD0AAAA\", sizeof (buf)) != 0;
  ;
  return 0;
}"
HAVE_USABLE_VSNPRINTF)
if(HAVE_USABLE_VSNPRINTF)
set(ssp_have_usable_vsnprintf define)
else()
set(ssp_have_usable_vsnprintf undef)
endif()

configure_file(libssp-config.h.in ${CMAKE_CURRENT_BINARY_DIR}/libssp/config.h)
configure_file(libssp/ssp/ssp.h.in ${CMAKE_CURRENT_BINARY_DIR}/libssp/ssp/ssp.h)

set(libssp_SOURCES
	ssp.c gets-chk.c memcpy-chk.c memmove-chk.c mempcpy-chk.c 
	memset-chk.c snprintf-chk.c sprintf-chk.c stpcpy-chk.c 
	strcat-chk.c strcpy-chk.c strncat-chk.c strncpy-chk.c 
	vsnprintf-chk.c vsprintf-chk.c)


set(libssp_INCLUDES -I${CMAKE_CURRENT_SOURCE_DIR}/libssp -I${CMAKE_CURRENT_BINARY_DIR}/libssp -I${CMAKE_CURRENT_SOURCE_DIR}/include)

foreach(i ${libssp_SOURCES})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libssp/${i}.o
					COMMAND ${C_COMPILER} -DDLL_EXPORT -DPIC -DHAVE_CONFIG_H -pthread ${libssp_INCLUDES} -IC:/Development/mingw64/x86_64-w64-mingw32/include -IC:/Development/mingw64/lib/gcc/x86_64-w64-mingw32/8.1.0/include -c ${CMAKE_CURRENT_SOURCE_DIR}/libssp/${i} -o ${CMAKE_CURRENT_BINARY_DIR}/libssp/${i}.o
					DEPENDS gcc)
	list(APPEND libssp_objs ${CMAKE_CURRENT_BINARY_DIR}/libssp/${i}.o)
endforeach()

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/libssp-1.dll
					COMMAND ${C_COMPILER} -BC:/Development/mingw64/bin -BC:/Development/mingw64/x86_64-w64-mingw32/lib -shared -pthread -o ${CMAKE_CURRENT_BINARY_DIR}/libssp-1.dll -Xlinker --out-implib -Xlinker ${CMAKE_CURRENT_BINARY_DIR}/libssp.dll.a ${libssp_objs}
					DEPENDS ${libssp_objs})

add_custom_target(libssp ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/libssp-1.dll)

####################################################################
###########   INSTALL
####################################################################

install(TARGETS gcc g++ gcov gcov-dump gcov-tool
		RUNTIME DESTINATION bin)
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/libstdc++/include/
		DESTINATION include/c++/9.2.0
		FILES_MATCHING PATTERN "*")
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/libgcc_s_seh-1.dll ${CMAKE_CURRENT_BINARY_DIR}/libssp-1.dll
				${CMAKE_CURRENT_BINARY_DIR}/libquadmath-1.dll ${CMAKE_CURRENT_BINARY_DIR}/libgomp-1.dll
				${CMAKE_CURRENT_BINARY_DIR}/libatomic-1.dll ${CMAKE_CURRENT_BINARY_DIR}/libstdc++-6.dll
		DESTINATION bin)
install(TARGETS cc1 cc1plus collect2 lto1 lto-wrapper lto_plugin
		RUNTIME DESTINATION libexec/gcc/x86_64-w64-mingw32/9.2.0
		ARCHIVE DESTINATION libexec/gcc/x86_64-w64-mingw32/9.2.0)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/libstdc++.a ${CMAKE_CURRENT_BINARY_DIR}/libstdc++.dll.a
			${CMAKE_CURRENT_BINARY_DIR}/libquadmath.dll.a ${CMAKE_CURRENT_BINARY_DIR}/libatomic.dll.a
			${CMAKE_CURRENT_BINARY_DIR}/libgomp.dll.a ${CMAKE_CURRENT_BINARY_DIR}/libssp.dll.a 
			${CMAKE_CURRENT_BINARY_DIR}/libgcc_s.a
		DESTINATION lib)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/libgcc.a ${CMAKE_CURRENT_BINARY_DIR}/libgcov.a ${CMAKE_CURRENT_BINARY_DIR}/libgcc_eh.a
		DESTINATION lib/gcc/x86_64-w64-mingw32/9.2.0/)

set(cpu_files
 adxintrin.h            avx512vbmivlintrin.h       clzerointrin.h  mm3dnow.h        shaintrin.h    vpclmulqdqintrin.h
ammintrin.h            avx512vlbwintrin.h         cpuid.h         mmintrin.h       smmintrin.h    waitpkgintrin.h
avx2intrin.h           avx512vldqintrin.h         cross-stdarg.h  movdirintrin.h        wbnoinvdintrin.h
avx5124fmapsintrin.h   avx512vlintrin.h           emmintrin.h     mwaitxintrin.h         wmmintrin.h
avx5124vnniwintrin.h   avx512vnniintrin.h         f16cintrin.h    nmmintrin.h          x86intrin.h
avx512bitalgintrin.h   avx512vnnivlintrin.h                                xmmintrin.h
avx512bwintrin.h       avx512vpopcntdqintrin.h    fma4intrin.h                xopintrin.h
avx512cdintrin.h       avx512vpopcntdqvlintrin.h  fmaintrin.h     pconfigintrin.h      xsavecintrin.h
avx512dqintrin.h       avxintrin.h                fxsrintrin.h    pkuintrin.h          xsaveintrin.h
avx512erintrin.h       bmi2intrin.h               pmmintrin.h         xsaveoptintrin.h
avx512fintrin.h        bmiintrin.h                gfniintrin.h    popcntintrin.h     xsavesintrin.h
avx512ifmaintrin.h     bmmintrin.h                ia32intrin.h    prfchwintrin.h   tbmintrin.h    xtestintrin.h
avx512ifmavlintrin.h   cet.h                      immintrin.h           
avx512pfintrin.h       cetintrin.h                         tmmintrin.h
avx512vbmi2intrin.h    cldemoteintrin.h           lwpintrin.h     rdseedintrin.h   
avx512vbmi2vlintrin.h  clflushoptintrin.h         lzcntintrin.h   rtmintrin.h      vaesintrin.h
avx512vbmiintrin.h     clwbintrin.h                   sgxintrin.h      )

 # unwind.h  mm_malloc.h 

list(TRANSFORM cpu_files PREPEND "${CMAKE_CURRENT_SOURCE_DIR}/gcc/config/i386/")

install(FILES ${cpu_files} DESTINATION lib/gcc/x86_64-w64-mingw32/9.2.0/include)

install(FILES libgcc/gcov.h  ${CMAKE_CURRENT_BINARY_DIR}/libgomp/omp.h libgomp/openacc.h libquadmath/quadmath.h libquadmath/quadmath_weak.h
				${CMAKE_CURRENT_BINARY_DIR}/libgcc/unwind.h
		DESTINATION lib/gcc/x86_64-w64-mingw32/9.2.0/include)
install(DIRECTORY gcc/ginclude/
		DESTINATION lib/gcc/x86_64-w64-mingw32/9.2.0/include
		FILES_MATCHING PATTERN "*")
install(DIRECTORY libstdc++-v3/include/c_compatibility/
		DESTINATION include/c++/9.2.0
		FILES_MATCHING PATTERN "*")