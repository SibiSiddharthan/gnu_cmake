cmake_minimum_required(VERSION 3.13)
PROJECT(gnu-binutils C CXX)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../gcc/cmake-modules)

INCLUDE(UtilityFunctions)
INCLUDE(CommonChecks)
INCLUDE(GCCChecks)
INCLUDE(CheckCSourceRuns)
INCLUDE(CheckCXXSourceCompiles)

set(VERSION \"2.32\")

#is true for gcc,clang and msvc on windows
set(STDC_HEADERS 1)

#check
set(HAVE_isl 1)

#[[
if(WIN32)
if(NOT DEFINED BINUTILS-PATCHED)
execute_process(
			COMMAND patch -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0002-check-for-unusual-file-harder.patch
			COMMAND patch -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0010-bfd-Increase-_bfd_coff_max_nscns-to-65279.patch
			COMMAND patch -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0020-binutils_2.31_mkdtemp_impl.patch
			COMMAND patch -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/0110-binutils-mingw-gnu-print.patch
			COMMAND patch -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/1000-plugin-target-handling.patch
			 WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
set(BINUTILS-PATCHED TRUE CACHE BOOL "Apply patch only once")
endif()
endif()
]]

if(WIN32)
set(HOST_TARGET x86_64-w64-mingw32)
add_compile_definitions(__USE_MINGW_ACCESS)
elseif(UNIX)
set(HOST_TARGET x86_64-pc-linux-gnu)
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


##############################################################################
##############   BFD
##############################################################################

check_c_headers(alloca.h dirent.h dlfcn.h fcntl.h inttypes.h memory.h ndir.h stddef.h stdint.h 
				stdlib.h strings.h string.h sys/dir.h sys/file.h sys/ndir.h sys/param.h sys/procfs.h 
				sys/resource.h sys/stat.h sys/time.h sys/types.h time.h unistd.h wchar.h wctype.h windows.h)

check_functions(fcntl fdopen fileno fls fopen64 fseeko fseeko64 ftello ftello64 getgid
				 getpagesize getrlimit getuid madvise mprotect setitimer strtoull sysconf)

check_functions_declarations(asprintf basename ffs free fseeko fseeko64 ftello ftello64
							 getenv malloc realloc snprintf stpcpy strnlen strstr vasprintf vsnprintf)

check_types(char int long "long long" off_t short "void *" "long double")

function(sys_procfs_decls ...)
	math(EXPR STOP "${ARGC} -1" )
	foreach(i RANGE ${STOP})
		set(var ${ARGV${i}})
		string(REPLACE "." "_" var ${var})
		string(TOUPPER ${var} var)
		string(PREPEND var "HAVE_")
		check_symbol_exists(${ARGV${i}} "sys/procfs.h" ${var})
	endforeach()
endfunction()

sys_procfs_decls(lwpstatus_t lwpstatus_t.pr_context lwpstatus_t.pr_fpreg lwpstatus_t.pr_reg lwpxstatus_t prpsinfo32_t 
				prpsinfo32_t.pr_pid prpsinfo_t prpsinfo_t.pr_pid prstatus32_t prstatus32_t.pr_who prstatus_t prstatus_t.pr_who 
				psinfo32_t psinfo32_t.pr_pid psinfo_t psinfo_t.pr_pid pstatus32_t pstatus_t pxstatus_t win32_pstatus_t)

check_c_source_compiles("
const char hw[] __attribute__ ((__visibility__ (\"hidden\"))) = \"Hello, World\n\";
extern void print (const char *) __attribute__ ((__visibility__ (\"hidden\")));
int
main ()
{
print (hw);
  ;
  return 0;
}"
HAVE_HIDDEN)

if(WIN32)
set(USE_BINARY_FOPEN 1)
endif()

set(USE_SECUREPLT 1)
set(PACKAGE \"\")
set(PACKAGE_VERSION \"\")
configure_file(bfd-config.h.in ${CMAKE_CURRENT_BINARY_DIR}/bfd/config.h)
set(supports_plugins 1)
set(wordsize 64)
set(bfd_default_target_size 64)
if(SIZEOF_VOID_P EQUAL 8)
set(BFD_HOST_64BIT_LONG 1)
endif()
if(SIZEOF_LONG_LONG EQUAL 8)
set(BFD_HOST_64BIT_LONG_LONG 1)
endif()
set(BFD_HOST_64_BIT "long\ long")
set(BFD_HOST_U_64_BIT "unsigned\ long\ long")
set(BFD_HOST_64_BIT_DEFINED 1)
configure_file(bfd/bfd-in2.h ${CMAKE_CURRENT_BINARY_DIR}/bfd/bfd.h @ONLY)
set(bfd_version 232000000)
set(bfd_version_package  \"(GNU Binutils) \")
set(bfd_version_string \"2.32\")
set(report_bugs_to \"<http://www.sourceware.org/bugzilla/>\")
configure_file(bfd/version.h ${CMAKE_CURRENT_BINARY_DIR}/bfd/bfdver.h @ONLY)
configure_file(gstdint.h ${CMAKE_CURRENT_BINARY_DIR}/bfd/bfd_stdint.h)

set(bfd_SOURCES
	archive.c archures.c bfd.c bfdio.c bfdwin.c cache.c coff-bfd.c 
	compress.c corefile.c elf-properties.c format.c hash.c 
	init.c libbfd.c linker.c merge.c opncls.c reloc.c 
	section.c simple.c stab-syms.c stabs.c syms.c targets.c 
	binary.c ihex.c srec.c tekhex.c verilog.c archive64.c)
if(WIN32)
list(APPEND bfd_SOURCES pe-x86_64.c  cofflink.c coffgen.c dwarf2.c pei-x86_64.c elf64-x86-64.c 
		elfxx-x86.c elf-ifunc.c elf-nacl.c elf64.c elf.c elflink.c elf-attrs.c elf-strtab.c elf-eh-frame.c
		dwarf1.c pe-i386.c peigen.c pei-i386.c elf32-i386.c elf-vxworks.c elf32.c elf64-gen.c elf32-gen.c
		plugin.c cpu-i386.c cpu-iamcu.c cpu-l1om.c cpu-k1om.c cpu-plugin.c)
endif()
list(TRANSFORM bfd_SOURCES PREPEND "bfd/")

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/bfd/targmatch.h
					COMMAND sed -f ${CMAKE_CURRENT_SOURCE_DIR}/bfd/targmatch.sed < ${CMAKE_CURRENT_SOURCE_DIR}/bfd/config.bfd > ${CMAKE_CURRENT_BINARY_DIR}/bfd/targmatch.h)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/bfd/elf64-target.h
					COMMAND sed -e s/NN/64/g < ${CMAKE_CURRENT_SOURCE_DIR}/bfd/elfxx-target.h > ${CMAKE_CURRENT_BINARY_DIR}/bfd/elf64-target.h)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/bfd/elf32-target.h
					COMMAND sed -e s/NN/32/g < ${CMAKE_CURRENT_SOURCE_DIR}/bfd/elfxx-target.h > ${CMAKE_CURRENT_BINARY_DIR}/bfd/elf32-target.h)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/bfd/pex64igen.c
					COMMAND sed -e s/XX/pex64/g < ${CMAKE_CURRENT_SOURCE_DIR}/bfd/peXXigen.c > ${CMAKE_CURRENT_BINARY_DIR}/bfd/pex64igen.c)
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/bfd/peigen.c
					COMMAND sed -e s/XX/pe/g < ${CMAKE_CURRENT_SOURCE_DIR}/bfd/peXXigen.c > ${CMAKE_CURRENT_BINARY_DIR}/bfd/peigen.c)
#add_custom_command()	

add_custom_target(bfd_deps DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/bfd/targmatch.h ${CMAKE_CURRENT_BINARY_DIR}/bfd/pex64igen.c ${CMAKE_CURRENT_BINARY_DIR}/bfd/peigen.c
					${CMAKE_CURRENT_BINARY_DIR}/bfd/elf32-target.h ${CMAKE_CURRENT_BINARY_DIR}/bfd/elf64-target.h)

list(APPEND bfd_SOURCES ${CMAKE_CURRENT_BINARY_DIR}/bfd/pex64igen.c ${CMAKE_CURRENT_BINARY_DIR}/bfd/peigen.c)

add_library(bfd STATIC ${bfd_SOURCES})
target_compile_definitions(bfd PRIVATE HAVE_CONFIG_H HAVE_x86_64_pe_vec HAVE_x86_64_pei_vec HAVE_x86_64_pe_be_vec HAVE_x86_64_elf64_vec
 							HAVE_l1om_elf64_vec HAVE_k1om_elf64_vec HAVE_i386_pe_vec HAVE_i386_pei_vec HAVE_i386_elf32_vec HAVE_iamcu_elf32_vec HAVE_elf64_le_vec
							HAVE_elf64_be_vec HAVE_elf32_le_vec HAVE_elf32_be_vec DEBUGDIR=\"\" BINDIR=\"\")
target_compile_options(bfd PRIVATE -W -Wall -Wstrict-prototypes -Wmissing-prototypes -Wshadow -Wstack-usage=262144 -Wno-format -Wno-implicit-int)
							#for archures.c targets.c
if(WIN32)
target_compile_options(-DDEFAULT_VECTOR=x86_64_pe_vec "-DSELECT_VECS=&x86_64_pe_vec,&x86_64_pei_vec,&x86_64_pe_be_vec,&x86_64_elf64_vec,&l1om_elf64_vec,&k1om_elf64_vec,&i386_pe_vec,&i386_pei_vec,&i386_elf32_vec,&iamcu_elf32_vec,&elf64_le_vec,&elf64_be_vec,&elf32_le_vec,&elf32_be_vec" "-DSELECT_ARCHITECTURES=&bfd_i386_arch,&bfd_iamcu_arch,&bfd_l1om_arch,&bfd_k1om_arch")
elseif(UNIX)
target_compile_options(-DDEFAULT_VECTOR=x86_64_elf64_vec "-DSELECT_VECS=&x86_64_elf64_vec,&i386_elf32_vec,&iamcu_elf32_vec,&x86_64_elf32_vec,&i386_pei_vec,&x86_64_pei_vec,&l1om_elf64_vec,&k1om_elf64_vec,&elf64_le_vec,&elf64_be_vec,&elf32_le_vec,&elf32_be_vec,&plugin_vec" "-DSELECT_ARCHITECTURES=&bfd_i386_arch,&bfd_iamcu_arch,&bfd_l1om_arch,&bfd_k1om_arch,&bfd_plugin_arch")
endif()
target_include_directories(bfd PRIVATE bfd include ${CMAKE_CURRENT_BINARY_DIR}/bfd)
add_dependencies(bfd bfd_deps)
set_target_properties(bfd PROPERTIES 
						PUBLIC_HEADER "${CMAKE_CURRENT_BINARY_DIR}/bfd/bfd.h;${CMAKE_CURRENT_BINARY_DIR}/bfd/bfd_stdint.h;include/bfdlink.h;include/dis-asm.h;include/plugin-api.h;include/symcat.h;include/diagnostics.h;include/ansidecl.h")

##############################################################################
##############   OPCODES
##############################################################################

check_functions_declarations(basename stpcpy)

check_c_headers(dlfcn.h inttypes.h limits.h memory.h stdint.h stdlib.h strings.h string.h sys/stat.h sys/types.h unistd.h)

configure_file(opcodes-config.h.in ${CMAKE_CURRENT_BINARY_DIR}/opcodes/config.h)

set(opcodes_SOURCES dis-buf.c dis-init.c disassemble.c)
#target_sources
list(APPEND opcodes_SOURCES i386-dis.c i386-opc.c)
list(TRANSFORM opcodes_SOURCES PREPEND "opcodes/")

add_library(opcodes STATIC ${opcodes_SOURCES})
target_compile_definitions(opcodes PRIVATE ARCH_i386 ARCH_iamcu ARCH_l1om ARCH_k1om HAVE_CONFIG_H)
target_compile_options(opcodes PRIVATE -Wstrict-prototypes -Wmissing-prototypes -Wshadow -Wstack-usage=262144 -Wno-format)
target_include_directories(opcodes PRIVATE opcodes include ${CMAKE_CURRENT_BINARY_DIR}/opcodes ${CMAKE_CURRENT_BINARY_DIR}/bfd)
##############################################################################
##############   BINUTILS
##############################################################################

check_c_headers(dlfcn.h fcntl.h inttypes.h limits.h locale.h memory.h stdint.h stdlib.h 
				strings.h string.h sys/file.h sys/param.h sys/stat.h sys/types.h unistd.h wchar.h windows.h)

check_functions_declarations(asprintf environ fprintf getc_unlocked getenv sbrk snprintf stpcpy strnlen strstr vsnprintf)

check_functions(getc_unlocked getpagesize mkdtemp mkstemp sbrk setlocale setmode strcoll utimes)

if(WIN32)
set(EXECUTABLE_SUFFIX \".exe\")
set(HAVE_EXECUTABLE_SUFFIX 1)
endif()

set(HAVE_ICONV 1)
set(ICONV_CONST " ")

if(HAVE_TIME_H)
set(ut_inc "#include<time.h>")
endif()
check_c_source_compiles("
#include <sys/types.h>
${ut_inc}
#include <utime.h>
int
main ()
{
struct utimbuf s;
  ;
  return 0;
}"
HAVE_GOOD_UTIME_H)

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

check_c_source_compiles("
#include <time.h>
int
main ()
{
time_t i;
  ;
  return 0;
}"
HAVE_TIME_T_IN_TIME_H)

check_c_source_compiles("
#include <sys/types.h>
int
main ()
{
time_t i;
  ;
  return 0;
}"
HAVE_TIME_T_IN_TYPES_H)

set(TARGET \"${HOST_TARGET}\")
set(DEFAULT_AR_DETERMINISTIC "0 ")
set(DEFAULT_STRINGS_ALL 1)
configure_file(binutils-config.h.in ${CMAKE_CURRENT_BINARY_DIR}/binutils/config.h)

set(binutils_common_SOURCES
	binutils/bucomm.c binutils/version.c binutils/filemode.c)

add_library(binutils_common OBJECT ${binutils_common_SOURCES})
target_include_directories(binutils_common PUBLIC include bfd ${CMAKE_CURRENT_BINARY_DIR}/binutils ${CMAKE_CURRENT_BINARY_DIR}/bfd)
target_compile_options(binutils_common PUBLIC -Wstrict-prototypes -Wmissing-prototypes -Wshadow -Wstack-usage=262144 -Wno-format)
target_compile_definitions(binutils_common PUBLIC HAVE_CONFIG_H bin_dummy_emulation=bin_vanilla_emulation)
target_link_libraries(binutils_common opcodes bfd iberty z)
target_link_options(binutils_common PUBLIC -static-libstdc++ -static-libgcc)


add_executable(size binutils/size.c )
target_link_libraries(size binutils_common)

add_executable(strings binutils/strings.c )
target_link_libraries(strings binutils_common)

add_executable(nm binutils/nm.c )
target_link_libraries(nm binutils_common)

add_executable(c++filt binutils/cxxfilt.c )
target_link_libraries(c++filt binutils_common)

add_executable(dllwrap binutils/dllwrap.c )
target_link_libraries(dllwrap binutils_common)

add_executable(addr2line binutils/addr2line.c )
target_link_libraries(addr2line binutils_common)

set(ar_common_SOURCES binutils/arparse.c  binutils/arlex.c 
		binutils/rename.c binutils/binemul.c binutils/emul_vanilla.c binutils/arsup.c)

add_library(ar_common OBJECT ${ar_common_SOURCES})
target_link_libraries(ar_common binutils_common)

set(other_common_SOURCES 
	binutils/prdbg.c binutils/rddbg.c binutils/debug.c 
	binutils/stabs.c binutils/rdcoff.c binutils/elfcomm.c binutils/wrstabs.c)

add_library(other_common OBJECT ${other_common_SOURCES})
target_link_libraries(other_common binutils_common)

add_executable(ar binutils/ar.c binutils/not-ranlib.c)
target_link_libraries(ar ar_common binutils_common)

add_executable(ranlib binutils/ar.c binutils/is-ranlib.c)
target_link_libraries(ranlib ar_common binutils_common)

add_executable(objdump binutils/objdump.c  binutils/dwarf.c)
target_compile_options(objdump PRIVATE -DOBJDUMP_PRIVATE_VECTORS=NULL)
target_link_libraries(objdump other_common binutils_common)

add_executable( objcopy binutils/objcopy.c binutils/not-strip.c binutils/rename.c)
target_link_libraries(objcopy other_common binutils_common)

add_executable(strip binutils/objcopy.c binutils/is-strip.c binutils/rename.c )
target_link_libraries(strip other_common binutils_common)

add_executable(dlltool binutils/dlltool.c binutils/defparse.c binutils/deflex.c )
target_compile_definitions(dlltool PRIVATE DLLTOOL_MX86_64 DLLTOOL_DEFAULT_MX86_64)
target_link_libraries(dlltool binutils_common)

add_executable(windres	binutils/windres.c binutils/resrc.c binutils/rescoff.c 
			binutils/resbin.c binutils/rcparse.c binutils/rclex.c binutils/winduni.c binutils/resres.c )
target_link_libraries(windres binutils_common)
target_compile_definitions(windres PRIVATE DLLTOOL_MX86_64 DLLTOOL_DEFAULT_MX86_64)


add_executable(windmc binutils/windmc.c binutils/mcparse.c binutils/mclex.c binutils/winduni.c )
target_link_libraries(windmc binutils_common)

add_executable(readelf	binutils/readelf.c binutils/unwind-ia64.c binutils/dwarf.c)
target_link_libraries(readelf other_common binutils_common)

add_executable(elfedit binutils/elfedit.c )
target_link_libraries(elfedit other_common binutils_common)



##############################################################################
##############   GAS
##############################################################################

check_functions_declarations(asprintf free getenv malloc mempcpy realloc stpcpy strstr vsnprintf environ errno ffs sbrk )
check_functions(remove sbrk setlocale strsignal unlink)
check_c_headers(dlfcn.h errno.h inttypes.h limits.h locale.h memory.h stdint.h stdlib.h strings.h string.h sys/stat.h sys/types.h time.h unistd.h windows.h)

set(TARGET_ALIAS \"${HOST_TARGET}\")
set(TARGET_CANONICAL \"${HOST_TARGET}\")
set(TARGET_CPU \"x86_64\")
if(WIN32)
set(TARGET_OS "windows")
else()
set(TARGET_OS "linux")
endif()

set(TARGET_VENDOR \"mingw\")

set(need_decls environ errno ffs free malloc sbrk strstr)
foreach(n ${need_decls})
	string(TOUPPER ${n} var)
	if(NOT HAVE_DECL_${var})
	set(NEED_DECLARATION_${var} 1)
	endif()
endforeach()

set(I386COFF 1)
set(DEFAULT_ARCH \"x86_64\")
set(DEFAULT_EMULATION \"\")
set(EMULATIONS " ")
set(DEFAULT_GENERATE_X86_RELAX_RELOCATIONS 1)

configure_file(gas-config.h.in ${CMAKE_CURRENT_BINARY_DIR}/gas/config.h)

set(as_SOURCES 
	app.c as.c atof-generic.c compress-debug.c 	cond.c 
	depend.c dwarf2dbg.c dw2gencfi.c ecoff.c ehopt.c 
	expr.c flonum-copy.c flonum-konst.c flonum-mult.c 
	frags.c hash.c input-file.c input-scrub.c listing.c 
	literal.c macro.c messages.c output-file.c read.c 
	remap.c sb.c stabs.c subsegs.c symbols.c write.c)
#cpu	
list(APPEND as_SOURCES config/tc-i386.c)
#format
list(APPEND as_SOURCES config/obj-coff.c)
#atof
list(APPEND as_SOURCES config/atof-ieee.c)

list(TRANSFORM as_SOURCES PREPEND "gas/")

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gas/targ-env.h
					COMMAND echo "#include\ \"te-pep.h\"" > ${CMAKE_CURRENT_BINARY_DIR}/gas/targ-env.h)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gas/targ-cpu.h
					COMMAND echo "#include\ \"tc-i386.h\"" > ${CMAKE_CURRENT_BINARY_DIR}/gas/targ-cpu.h)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gas/obj-format.h
					COMMAND echo "#include\ \"obj-coff.h\"" > ${CMAKE_CURRENT_BINARY_DIR}/gas/obj-format.h)

add_custom_target(gas_deps DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/gas/targ-env.h ${CMAKE_CURRENT_BINARY_DIR}/gas/targ-cpu.h ${CMAKE_CURRENT_BINARY_DIR}/gas/obj-format.h)

add_executable(as ${as_SOURCES})
target_compile_options(as PRIVATE -Wstrict-prototypes -Wmissing-prototypes -Wshadow -Wstack-usage=262144 -Wno-format -Wwrite-strings)
target_compile_definitions(as PRIVATE HAVE_CONFIG_H )
target_link_libraries(as opcodes bfd iberty z)
target_include_directories(as PRIVATE include gas gas/config ${CMAKE_CURRENT_BINARY_DIR}/gas ${CMAKE_CURRENT_BINARY_DIR}/bfd ${CMAKE_CURRENT_SOURCE_DIR})
target_link_options(as PRIVATE -static-libstdc++ -static-libgcc)
add_dependencies(as gas_deps)


##############################################################################
##############   GOLD
##############################################################################

check_c_headers(byteswap.h dlfcn.h inttypes.h locale.h memory.h stdint.h 
				stdlib.h strings.h string.h sys/mman.h sys/stat.h sys/types.h  unistd.h windows.h)

check_cxx_headers(tr1/unordered_map tr1/unordered_set unordered_map unordered_set ext/hash_map ext/hash_set)

check_functions(chsize fallocate ffsll ftruncate link mallinfo mkdtemp mmap posix_fallocate pread readv setlocale sysconf times)

check_functions_declarations(asprintf basename ffs memmem snprintf strndup strverscmp vasprintf vsnprintf)

set(DEFAULT_HASH_STYLE \"sysv\")
set(DEFAULT_LD_Z_RELRO 1)
set(ENABLE_PLUGINS 1)
set(ENABLE_THREADS 1)
set(GOLD_DEFAULT_BIG_ENDIAN false)
set(GOLD_DEFAULT_MACHINE EM_X86_64)
set(GOLD_DEFAULT_OSABI ELFOSABI_NONE)
set(GOLD_DEFAULT_SIZE 64)

set(HAVE_TARGET_32_BIG 1)
set(HAVE_TARGET_32_LITTLE 1)
set(HAVE_TARGET_64_BIG 1)
set(HAVE_TARGET_64_LITTLE 1)
set(NATIVE_LINKER 1)
set(TARGET_SYSTEM_ROOT_RELOCATABLE "0 ")
set(TARGET_SYSTEM_ROOT \"\")


set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
check_c_source_compiles("
#include <omp.h>
int i;
#pragma omp threadprivate (i)"
HAVE_OMP_SUPPORT)

check_cxx_source_compiles("
template<typename T> extern void foo(const char*, ...)
  __attribute__ ((__format__ (gnu_printf, 1, 2)));
template<typename T> void foo(const char* format, ...) {}
void bar() { foo<int>(\"%s\", \"foo\"); }"
HAVE_TEMPLATE_ATTRIBUTES)

check_cxx_source_compiles("
#include <sys/types.h>
#include <tr1/unordered_map>
std::tr1::hash<off_t> h;"
HAVE_TR1_HASH_OFF_T)

unset(CMAKE_TRY_COMPILE_TARGET_TYPE)

check_c_source_compiles("
#include <pthread.h>
int
main ()
{
int i = PTHREAD_PRIO_INHERIT;
  ;
  return 0;
}"
HAVE_PTHREAD_PRIO_INHERIT)


check_cxx_source_compiles("
#include <tr1/unordered_map>
void bar() { ::std::tr1::unordered_map<int, int> x; x.rehash(10); }

int
main ()
{

  ;
  return 0;
}"
HAVE_TR1_UNORDERED_MAP_REHASH)

set(LIB_PATH \"::DEFAULT::\")

configure_file(gold-config.h.in ${CMAKE_CURRENT_BINARY_DIR}/gold/config.h)

set(gold_SOURCES
	archive.cc attributes.cc binary.cc common.cc compressed_output.cc 
	copy-relocs.cc cref.cc defstd.cc descriptors.cc dirsearch.cc 
	dynobj.cc dwarf_reader.cc ehframe.cc errors.cc expression.cc 
	fileread.cc gc.cc gdb-index.cc gold.cc gold-threads.cc 
	icf.cc incremental.cc int_encoding.cc layout.cc mapfile.cc 
	merge.cc nacl.cc object.cc options.cc output.cc parameters.cc 
	plugin.cc readsyms.cc reduced_debug_output.cc reloc.cc 
	resolve.cc script-sections.cc script.cc stringpool.cc 
	symtab.cc target.cc target-select.cc timer.cc version.cc 
	workqueue.cc workqueue-threads.cc
	yyscript.c #pread.c ffsll.c mremap.c
	#target
	i386.cc x86_64.cc sparc.cc powerpc.cc arm.cc arm-reloc-property.cc tilegx.cc 
	mips.cc aarch64.cc aarch64-reloc-property.cc s390.cc)

if(NOT HAVE_PREAD)
list(APPEND gold_SOURCES pread.c)
endif()
if(NOT HAVE_FFSLL)
list(APPEND gold_SOURCES ffsll.c)
endif()
if(NOT HAVE_MREMAP)
list(APPEND gold_SOURCES mremap.c)
endif()
list(TRANSFORM gold_SOURCES PREPEND "gold/")

add_library(gold_objs OBJECT ${gold_SOURCES})
target_include_directories(gold_objs PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/gold gold include elfcpp)
target_compile_definitions(gold_objs PUBLIC HAVE_CONFIG_H _LARGEFILE_SOURCE _FILE_OFFSET_BITS=${_FILE_OFFSET_BITS}
									LOCALEDIR="" BINDIR="" TOOLBINDIR="" TOOLLIBDIR="")

add_executable(ld-gold gold/main.cc)
target_link_libraries(ld-gold gold_objs iberty z)
target_link_options(ld-gold PRIVATE -static-libstdc++ -static-libgcc)

add_executable(ld-incremental gold/incremental-dump.cc)
target_link_libraries(ld-incremental gold_objs iberty z)
target_link_options(ld-incremental PRIVATE -static-libstdc++ -static-libgcc)

##############################################################################
##############   GPROF
##############################################################################

check_functions(setmode)

check_c_headers(dlfcn.h inttypes.h memory.h stdint.h stdlib.h strings.h string.h sys/gmon_out.h sys/stat.h sys/types.h unistd.h windows.h)
configure_file(gprof-config.h.in ${CMAKE_CURRENT_BINARY_DIR}/gprof/gconfig.h)

set(gprof_SOURCES
	basic_blocks.c call_graph.c cg_arcs.c cg_dfn.c 
	cg_print.c corefile.c gmon_io.c gprof.c hertz.c hist.c source.c 
	search_list.c symtab.c sym_ids.c utils.c 
	i386.c alpha.c vax.c sparc.c mips.c aarch64.c flat_bl.c bsd_callg_bl.c fsf_callg_bl.c)
list(TRANSFORM gprof_SOURCES PREPEND "gprof/")

add_executable(gprof ${gprof_SOURCES})
target_compile_definitions(gprof PRIVATE HAVE_CONFIG_H LOCALEDIR="" DEBUG)
target_include_directories(gprof PRIVATE gprof ${CMAKE_CURRENT_BINARY_DIR}/gprof include bfd ${CMAKE_CURRENT_BINARY_DIR}/bfd)
target_link_libraries(gprof bfd iberty z)
target_link_options(gprof PRIVATE -static-libstdc++ -static-libgcc)


##############################################################################
##############   LD
##############################################################################

check_c_headers(dirent.h dlfcn.h elf-hints.h fcntl.h inttypes.h limits.h locale.h 
				memory.h ndir.h stdint.h stdlib.h strings.h string.h sys/dir.h sys/file.h sys/ndir.h
				sys/param.h sys/stat.h sys/time.h sys/types.h unistd.h windows.h)

check_functions_declarations(environ free getenv sbrk strstr)

check_functions(close getpagesize glob lseek mkstemp open realpath sbrk setlocale waitpid)

set(HAVE_INITFINI_ARRAY 1)
set(DEFAULT_LD_Z_RELRO "0 ")
set(DEFAULT_EMIT_GNU_HASH "0 ")
set(DEFAULT_LD_Z_SEPARATE_CODE "0 ")
set(DEFAULT_NEW_DTAGS "0 ")
set(DEFAULT_EMIT_SYSV_HASH 1)
set(GOT_HANDLING_DEFAULT GOT_HANDLING_TARGET_DEFAULT)


configure_file(ld-config.h.in ${CMAKE_CURRENT_BINARY_DIR}/ld/config.h )

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/stringify.sed
				COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/ld/emultempl/astring.sed ${CMAKE_CURRENT_BINARY_DIR}/stringify.sed)	

set(ld_SOURCES
	ldgram.c ldctor.c ldemul.c ldexp.c ldfile.c ldlang.c 
	ldmain.c ldmisc.c ldver.c ldwrite.c lexsup.c 
	mri.c ldcref.c  ldlex-wrapper.c 
	plugin.c ldbuildid.c deffilep.c
	#Target
	)
if(WIN32)
list(APPEND ld_SOURCES pe-dll.c pep-dll.c)
endif()

if(WIN32)
set(target_objs ei386pep.o ei386pe.o)
elseif(UNIX)
set(target_objs eelf_x86_64.o eelf32_x86_64.o eelf_i386.o eelf_iamcu.o eelf_l1om.o eelf_k1om.o)
endif()
string(REPLACE ";" " " target_objs "${target_objs}")
configure_file(mktarget.sh.in ${CMAKE_CURRENT_BINARY_DIR}/mktarget.sh @ONLY)
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/ld/ldemul-list.h
				COMMAND sh ${CMAKE_CURRENT_BINARY_DIR}/mktarget.sh )

add_custom_target(ld_deps DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/ld/ldemul-list.h )

list(TRANSFORM ld_SOURCES PREPEND "ld/")

if(WIN32)
set(target_scripts i386pep i386pe)
elseif(UNIX)
set(target_scripts elf_x86_64 elf32_x86_64 elf_i386 elf_iamcu elf_l1om elf_k1om)
endif()

#NEED to polish
foreach(i ${target_scripts})
	if(WIN32)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/ld/e${i}.c
					COMMAND sh ${CMAKE_CURRENT_SOURCE_DIR}/ld/genscripts.sh ${CMAKE_CURRENT_SOURCE_DIR}/ld "lib" "libexec" x86_64-w64-mingw32 x86_64-w64-mingw32 x86_64-w64-mingw32 "i386pep"  "/usr/local/lib /lib /usr/lib" no yes ${i} ${i}
					COMMAND mv ${CMAKE_CURRENT_BINARY_DIR}/e${i}.c ${CMAKE_CURRENT_BINARY_DIR}/ld/e${i}.c
					DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/stringify.sed)
	elseif(UNIX)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/ld/e${i}.c
					COMMAND sh ${CMAKE_CURRENT_SOURCE_DIR}/ld/genscripts.sh ${CMAKE_CURRENT_SOURCE_DIR}/ld "lib" "libexec" x86_64-pc-linux-gnu x86_64-pc-linux-gnu x86_64-pc-linux-gnu "elf_x86_64 elf_i386 elf32_x86_64 elf_l1om elf_k1om"  "/usr/local/lib /lib /usr/lib" no yes ${i} ${i}
					COMMAND mv ${CMAKE_CURRENT_BINARY_DIR}/e${i}.c ${CMAKE_CURRENT_BINARY_DIR}/ld/e${i}.c
					DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/stringify.sed)
	list(APPEND ld_target_SOURCES ${CMAKE_CURRENT_BINARY_DIR}/ld/e${i}.c)
endforeach()

add_custom_target(ld_deps_c DEPENDS ${ld_target_SOURCES})

add_executable(ld ${ld_SOURCES} ${ld_target_SOURCES})
target_compile_definitions(ld PRIVATE HAVE_CONFIG_H ENABLE_PLUGINS LOCALEDIR="" DEFAULT_EMULATION=\"i386pep\" 
  									BINDIR="" TOOLBINDIR="" TARGET="${HOST_TARGET}" TARGET_SYSTEM_ROOT="" SCRIPTDIR="")
if(WIN32)
target_compile_definitions(ELF_LIST_OPTIONS=FALSE ELF_SHLIB_LIST_OPTIONS=FALSE ELF_PLT_UNWIND_LIST_OPTIONS=FALSE)
elseif(UNIX)
target_compile_definitions(ELF_LIST_OPTIONS=TRUE ELF_SHLIB_LIST_OPTIONS=TRUE ELF_PLT_UNWIND_LIST_OPTIONS=TRUE)
endif()
target_compile_options(ld PRIVATE -Wno-implicit-int)
target_include_directories(ld PRIVATE ld ${CMAKE_CURRENT_BINARY_DIR}/ld include bfd ${CMAKE_CURRENT_BINARY_DIR}/bfd)
target_link_libraries(ld bfd iberty z)
target_link_options(ld PRIVATE -static-libstdc++ -static-libgcc)
add_dependencies(ld ld_deps ld_deps_c)

install(TARGETS as ld ld-gold ld-incremental gprof ar ranlib strip objdump objcopy size strings
				 nm readelf elfedit dlltool windres windmc dllwrap addr2line 
				 iberty bfd opcodes
		RUNTIME DESTINATION bin
		ARCHIVE DESTINATION lib
		PUBLIC_HEADER DESTINATION include)