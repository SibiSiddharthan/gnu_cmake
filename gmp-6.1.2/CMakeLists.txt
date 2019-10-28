cmake_minimum_required(VERSION 3.13)
project(gmp C ASM)
INCLUDE (CheckTypeSize)
INCLUDE(CheckIncludeFile)
INCLUDE(CheckSymbolExists)
INCLUDE(CheckFunctionExists)
INCLUDE(CheckCSourceCompiles)
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
	message(FATAL_ERROR "In-source builds not allowed. Please make a new directory")
endif()

set(PACKAGE "gmp")
set(PACKAGE_BUGREPORT "gmp-bugs@gmplib.org, see https://gmplib.org/manual/Reporting-Bugs.html")
set(PACKAGE_NAME "GNU MP")
set(PACKAGE_STRING "GNU MP 6.1.2")
set(PACKAGE_TARNAME "gmp")
set(PACKAGE_URL "http://www.gnu.org/software/gmp/")
set(PACKAGE_VERSION "6.1.2")
set(VERSION "6.1.2")

if(WIN32)
set(HOST_DOS64 1)
endif()

#is true for gcc,clang and msvc on windows
set(STDC_HEADERS 1)

set(WANT_FFT 1)#default
set(WANT_TMP_ALLOCA 1) #default

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


set(function_decls fgetc fscanf optarg ungetc vfprintf sys_errlist sys_nerr)

check_functions_declaration(function_decls)

set(functions alarm attr_get clock clock_gettime cputime getpagesize getrusage
	 gettimeofday getsysinfo localeconv memset mmap mprotect nl_langinfo 
	 obstack_vprintf popen processor_info pstat_getprocessor raise 
	 read_real_time sigaction sigaltstack sigstack syssgi strchr strerror 
	 strnlen strtol strtoul sysconf sysctl sysctlbyname times vsnprintf)

check_functions(functions)

#works with gcc,clang msvc on windows
set(HAVE_ALLOCA 1)

set(header dlfcn.h fcntl.h float.h inttypes.h invent.h langinfo.h locale.h nl_types.h machine/hal_sysinfo.h memory.h
	nl_types.h sstream stdint.h stdlib.h strings.h string.h 
	sys/attributes.h sys/iograph.h sys/mman.h sys/param.h sys/processor.h sys/pstat.h sys/resource.h sys/stat.h 
	sys/sysctl.h sys/sysinfo.h sys/syssgi.h sys/systemcfg.h sys/time.h sys/times.h sys/types.h
	unistd.h time.h )

check_headers(header) 

set(types_presence "long double" "long long" stack_t ptrdiff_t quad_t uint_least32_t intmax_t intptr_t)
check_types_presence(types_presence)

set(type_sizes unsigned "unsigned long" "unsigned short" "void *" "long long int")
check_types_size(type_sizes)



#message("${CMAKE_COMMAND} ${CMAKE_C_COMPILER} ${CMAKE_SOURCE_DIR}/gen-fac.c && ./a ${GMP_LIMB_BITS} ${GMP_NAIL_BITS} >> fac-table.h")
#execute_process(COMMAND cmd /C "${CMAKE_C_COMPILER} ${CMAKE_SOURCE_DIR}/gen-fac.c && ./a ${GMP_LIMB_BITS} ${GMP_NAIL_BITS} > fac-table.h")


#true for most systems
math(EXPR SIZEOF_MP_LIMB_T "${SIZEOF_VOID_P}")

check_c_source_compiles("
#include <sys/types.h>
#include <signal.h>

int
main ()
{
return *(signal (0, 0)) (0) == 1;
  ;
  return 0;
}"
RETSIGTYPE_TMP)
if(RETSIGTYPE_TMP)
set(RETSIGTYPE "int")
else()
set(RETSIGTYPE "void")
endif()

check_c_source_compiles("
int foo (int x) __attribute__ ((const));
int
main ()
{

  ;
  return 0;
}"
HAVE_ATTRIBUTE_CONST)
if(HAVE_ATTRIBUTE_CONST)
set(HAVE_ATTRIBUTE_CONST 1)
endif()

check_c_source_compiles("
void *foo (int x) __attribute__ ((malloc));
int
main ()
{

  ;
  return 0;
}"
HAVE_ATTRIBUTE_MALLOC)
if(HAVE_ATTRIBUTE_MALLOC)
set(HAVE_ATTRIBUTE_MALLOC 1)
endif()

check_c_source_compiles("
typedef int SItype __attribute__ ((mode (SI)));
int
main ()
{

  ;
  return 0;
}"
HAVE_ATTRIBUTE_MODE)
if(HAVE_ATTRIBUTE_MODE)
set(HAVE_ATTRIBUTE_MODE 1)
endif()

check_c_source_compiles("
void foo (int x) __attribute__ ((noreturn));
int
main ()
{

  ;
  return 0;
}"
HAVE_ATTRIBUTE_NORETURN)
if(HAVE_ATTRIBUTE_NORETURN)
set(HAVE_ATTRIBUTE_NORETURN 1)
endif()

check_c_source_compiles("
void hid() __attribute__ ((visibility(\"hidden\")));
void hid() {}
void pub() __attribute__ ((alias(\"hid\")));
int
main ()
{

  ;
  return 0;
}"
HAVE_HIDDEN_ALIAS)
if(HAVE_HIDDEN_ALIAS)
set(HAVE_HIDDEN_ALIAS 1)
endif()

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

#works with gcc and clang and msvc
set(restrict "__restrict")
set(LSYM_PREFIX "L")

set(mpn_REQUIRED_FILES
add add_1 add_n sub sub_1 sub_n cnd_add_n cnd_sub_n cnd_swap neg com	   
  mul_1 addmul_1 submul_1						   
  lshift rshift dive_1 diveby3 divis divrem divrem_1 divrem_2		  
  fib2_ui mod_1 mod_34lsub1 mode1o  pre_mod_1 dump	   
  mod_1_1 mod_1_2 mod_1_3 mod_1_4 lshiftc				   
  mul mul_fft mul_n sqr mul_basecase sqr_basecase nussbaumer_mul	   
  mulmid_basecase toom42_mulmid mulmid_n mulmid				   
  random random2 pow_1							   
  rootrem sqrtrem sizeinbase get_str set_str				   
  scan0 scan1 popcount hamdist cmp zero_p				   
  perfsqr perfpow							   
  gcd_1 gcd gcdext_1 gcdext gcd_subdiv_step			  
  gcdext_lehmer								   
  div_q tdiv_qr jacbase jacobi_2 jacobi get_d				   
  matrix22_mul matrix22_mul1_inverse_vector				   
  hgcd_matrix hgcd2 hgcd_step hgcd_reduce hgcd hgcd_appr		   
  hgcd2_jacobi hgcd_jacobi						   
  mullo_n mullo_basecase sqrlo sqrlo_basecase				   
  toom22_mul toom32_mul toom42_mul toom52_mul toom62_mul		   
  toom33_mul toom43_mul toom53_mul toom54_mul toom63_mul		   
  toom44_mul								   
  toom6h_mul toom6_sqr toom8h_mul toom8_sqr				   
  toom_couple_handling							   
  toom2_sqr toom3_sqr toom4_sqr						   
  toom_eval_dgr3_pm1 toom_eval_dgr3_pm2					   
  toom_eval_pm1 toom_eval_pm2 toom_eval_pm2exp toom_eval_pm2rexp	   
  toom_interpolate_5pts toom_interpolate_6pts toom_interpolate_7pts	  
  toom_interpolate_8pts toom_interpolate_12pts toom_interpolate_16pts	   
  invertappr invert binvert mulmod_bnm1 sqrmod_bnm1			   
  div_qr_1  div_qr_2 div_qr_2n_pi1 sbpi1_div_q sbpi1_div_qr sbpi1_divappr_q				   
  dcpi1_div_q dcpi1_div_qr dcpi1_divappr_q				   
  mu_div_qr mu_divappr_q mu_div_q					   
  bdiv_q_1								   
  sbpi1_bdiv_q sbpi1_bdiv_qr						   
  dcpi1_bdiv_q dcpi1_bdiv_qr						   
  mu_bdiv_q mu_bdiv_qr							   
  bdiv_q bdiv_qr broot brootinv bsqrt bsqrtinv				   
  divexact bdiv_dbm1c redc_1 redc_2 redc_n powm powlo sec_powm		   
  sec_mul sec_sqr sec_div_qr sec_div_r sec_pi1_div_qr sec_pi1_div_r	   
  sec_add_1 sec_sub_1 sec_invert					   
  trialdiv remove							   
  and_n andn_n nand_n ior_n iorn_n nior_n xor_n xnor_n			   
  copyi copyd zero sec_tabselect					   
  comb_tables)

set(mpn_ERROR_FILES
add_err1_n add_err2_n add_err3_n sub_err1_n sub_err2_n sub_err3_n
div_qr_1n_pi1 div_qr_2u_pi1)

set(mpn_OPTIONAL_FILES
umul udiv					
  invert_limb sqr_diagonal sqr_diag_addlsh1				
  mul_2 mul_3 mul_4 mul_5 mul_6						
  addmul_2 addmul_3 addmul_4 addmul_5 addmul_6 addmul_7 addmul_8	
  addlsh1_n sublsh1_n rsblsh1_n rsh1add_n rsh1sub_n			
  addlsh2_n sublsh2_n rsblsh2_n						
  addlsh_n sublsh_n rsblsh_n						
  add_n_sub_n )

set(mpn_HEADER gmp-mparam.h)

if(NOT DEFINED HOST_ARCHITECTURE)
message(FATAL_ERROR "Set HOST_ARCHITECTURE
					Supported host architectures are x86_64, core2, nehalem, westmere,
					sandybridge, ivybridge, haswell, broadwell, skylake, kabylake
					athlon64, k8, k10, bobcat, jaguar, bulldozer, piledriver, steamroller, excavator")
endif()

#works for intel x86_64
#need to test on amd platforms
set(HAVE_DOUBLE_IEEE_LITTLE_ENDIAN 1)
set(HAVE_HOST_CPU_FAMILY_x86_64 1)
set(HAVE_LIMB_LITTLE_ENDIAN 1)
set(HAVE_SPEED_CYCLECOUNTER 2)
list(APPEND mpn_REQUIRED_FILES invert_limb_table)

#set(HOST_ARCHITECTURE "ivybridge")

if(${HOST_ARCHITECTURE} STREQUAL "x86_64")

set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64")
set(native "x86_64")
set(DIRECTORIES mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "core2")

set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/core2")
set(native "core2")
set(DIRECTORIES mpn/x86_64/core2 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "nehalem" OR ${HOST_ARCHITECTURE} STREQUAL "westmere")

set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/coreinhm")
set(native "coreinhm")
set(DIRECTORIES mpn/x86_64/coreinhm mpn/x86_64/core2 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "sandybridge" OR ${HOST_ARCHITECTURE} STREQUAL "ivybridge")

set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/coreisbr")
set(native "coreisbr")
set(DIRECTORIES mpn/x86_64/coreisbr mpn/x86_64/coreinhm mpn/x86_64/core2 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "haswell")

set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/coreihwl")
set(native "coreihwl")
set(DIRECTORIES mpn/x86_64/coreihwl mpn/x86_64/coreisbr mpn/x86_64/coreinhm mpn/x86_64/core2 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "broadwell")

set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/coreibwl")
set(native "coreibwl")
set(DIRECTORIES mpn/x86_64/coreibwl mpn/x86_64/coreihwl mpn/x86_64/coreisbr mpn/x86_64/coreinhm mpn/x86_64/core2 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "skylake" OR ${HOST_ARCHITECTURE} STREQUAL "kabylake")

set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/skylake")
set(native "skylake")
set(DIRECTORIES mpn/x86_64/skylake mpn/x86_64/coreibwl mpn/x86_64/coreihwl mpn/x86_64/coreisbr mpn/x86_64/coreinhm mpn/x86_64/core2 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "athlon64" OR ${HOST_ARCHITECTURE} STREQUAL "k8")

set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/k8")
set(native "k8")
set(DIRECTORIES mpn/x86_64/k8 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "k10")

set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/k10")
set(native "k10")
set(DIRECTORIES mpn/x86_64/k10 mpn/x86_64/k8 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "bobcat")

set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/bobcat")
set(native "bobcat")
set(DIRECTORIES mpn/x86_64/bobcat mpn/x86_64/k10 mpn/x86_64/k8 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "jaguar")

set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/jaguar")
set(native "jaguar")
set(DIRECTORIES mpn/x86_64/jaguar mpn/x86_64/bobcat mpn/x86_64/k10 mpn/x86_64/k8 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "bulldozer")

set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/bd1")
set(native "bd1")
set(DIRECTORIES mpn/x86_64/bd1 mpn/x86_64/k10 mpn/x86_64/k8 mpn/x86_64)

elseif(${HOST_ARCHITECTURE} STREQUAL "piledriver" OR ${HOST_ARCHITECTURE} STREQUAL "steamroller" OR ${HOST_ARCHITECTURE} STREQUAL "excavator")

set(GMP_MPARAM_H_SUGGEST "${CMAKE_SOURCE_DIR}/mpn/x86_64/bd2")
set(native "bd2")
set(DIRECTORIES mpn/x86_64/bd2 mpn/x86_64/bd1 mpn/x86_64/k10 mpn/x86_64/k8 mpn/x86_64)

else()
message(FATAL_ERROR "Host architecture not supported
					Supported host architectures are x86_64, core2, nehalem, westmere,
					sandybridge, ivybridge, haswell, broadwell, skylake, kabylake
					athlon64, k8, k10, bobcat, jaguar, bulldozer, piledriver, steamroller, excavator")

endif()

list(APPEND DIRECTORIES mpn/generic)

#choosing gmp-mparam.h
foreach(d ${DIRECTORIES})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/gmp-mparam.h)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gmp-mparam.h
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/gmp-mparam.h ${CMAKE_CURRENT_BINARY_DIR}/gmp-mparam.h)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/gmp-mparam.h)
	break()
	endif()
endforeach()


#choosing error files
foreach(f ${mpn_ERROR_FILES})
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/mpn/generic/${f}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/mpn/generic/${f}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	endif()
endforeach()



#choosing mpn required files

foreach(f ${mpn_REQUIRED_FILES})
set(tf ${f})
string(FIND ${tf} "add" a)
string(FIND ${tf} "sub" s)
string(FIND ${tf} "rsb" r)
foreach(d ${DIRECTORIES})

	if(NOT ${a}  EQUAL -1 )
	string(REPLACE "add" "aors" ttf1 ${tf})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()

	string(REPLACE "add" "aorr" ttf2 ${tf})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf2}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf2}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()

	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf2}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf2}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	endif()

	if(NOT ${s}  EQUAL -1 )
	string(REPLACE "sub" "aors" ttf1 ${tf})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()

	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	endif()

	if(NOT ${r}  EQUAL -1 )
	string(REPLACE "rsb" "aorr" ttf1 ${tf})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	endif()


	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${f}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${f}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${f}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${f}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
endforeach()
endforeach()

#mpn optional files
foreach(f ${mpn_OPTIONAL_FILES})
set(tf ${f})
string(FIND ${tf} "add" a)
string(FIND ${tf} "sub" s)
string(FIND ${tf} "rsb" r)
foreach(d ${DIRECTORIES})
	if(NOT ${a}  EQUAL -1 )
	string(REPLACE "add" "aors" ttf1 ${tf})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_OPTIONAL_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_OPTIONAL_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()

	string(REPLACE "add" "aorr" ttf2 ${tf})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf2}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf2}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_OPTIONAL_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf2}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf2}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_OPTIONAL_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	endif()

	if(NOT ${s}  EQUAL -1 )
	string(REPLACE "sub" "aors" ttf1 ${tf})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_OPTIONAL_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_OPTIONAL_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	endif()

	if(NOT ${r}  EQUAL -1 )
	string(REPLACE "rsb" "aorr" ttf1 ${tf})
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_OPTIONAL_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${ttf1}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_OPTIONAL_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	endif()

	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${f}.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${f}.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.asm)
	list(REMOVE_ITEM mpn_OPTIONAL_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${f}.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/${d}/${f}.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${f}.c)
	list(REMOVE_ITEM mpn_OPTIONAL_FILES ${f})
	string(FIND ${d} ${native} n)
	if(NOT ${n} EQUAL -1)
	set(HAVE_NATIVE_mpn_${f} 1)
	endif()
	break()
	endif()
endforeach()
endforeach()

#message("${mpn_S}")

#exceptional cases
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/mpn/generic/sec_div.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_div_qr.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/mpn/generic/sec_div.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_div_qr.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_div_qr.c)
	list(REMOVE_ITEM mpn_REQUIRED_FILES sec_div_qr)

	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_div_r.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/mpn/generic/sec_div.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_div_r.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_div_r.c)
	list(REMOVE_ITEM mpn_REQUIRED_FILES sec_div_r)
endif()

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/mpn/generic/sec_pi1_div.c)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_pi1_div_qr.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/mpn/generic/sec_pi1_div.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_pi1_div_qr.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_pi1_div_qr.c)
	list(REMOVE_ITEM mpn_REQUIRED_FILES sec_pi1_div_qr)

	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_pi1_div_r.c
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/mpn/generic/sec_pi1_div.c ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_pi1_div_r.c)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/sec_pi1_div_r.c)
	list(REMOVE_ITEM mpn_REQUIRED_FILES sec_pi1_div_r)
endif()

foreach(i and_n;andn_n;nand_n;ior_n;iorn_n;nior_n;xor_n;xnor_n)
if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/mpn/x86_64/logops_n.asm)
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/${i}.asm
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/mpn/x86_64/logops_n.asm ${CMAKE_CURRENT_BINARY_DIR}/mpn/${i}.asm)
	list(APPEND mpn_S ${CMAKE_CURRENT_BINARY_DIR}/mpn/${i}.asm)
	list(REMOVE_ITEM mpn_REQUIRED_FILES ${i})
	set(HAVE_NATIVE_mpn_{i} 1)
endif()
endforeach()

set(HAVE_NATIVE_mpn_copyi 1)
set(HAVE_NATIVE_mpn_copyd 1)



list(LENGTH mpn_REQUIRED_FILES l)
if(NOT ${l} EQUAL 0)
message("${mpn_REQUIRED_FILES}")
message(FATAL_ERROR "missing required files report bug")
endif()
#message("${mpn_OPTIONAL_FILES}")




#on intel and amd
set(${CMAKE_C_FLAGS_RELEASE} " " CACHE STRING "set to nothing" FORCE)
set(GMP_COMPILE_FLAGS -O2 -fomit-frame-pointer -mtune=sandybridge -march=sandybridge)
set(GMP_DEFINES -D__GMP_WITHIN_GMP -DHAVE_CONFIG_H )
set(GMP_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})

set(HAVE_HOST_CPU_FAMILY_power 0)
set(HAVE_HOST_CPU_FAMILY_powerpc 0)
set(GMP_NAIL_BITS 0)
math(EXPR GMP_LIMB_BITS "${SIZEOF_VOID_P}*8")
set(CC "${CMAKE_C_COMPILER_ID}")
set(CFLAGS "${GMP_COMPILE_FLAGS}")#"-O2 -pedantic -fomit-frame-pointer -m64 -mtune=sandybridge -march=sandybridge")
set(_LONG_LONG_LIMB 1)
set(DEFN_LONG_LONG_LIMB "#define _LONG_LONG_LIMB 1")
set(LIBGMP_DLL 0)#Building static library only
configure_file(gmp-h.in gmp.h @ONLY)
configure_file(gmp-config.h.in config.h ESCAPE_QUOTES )
set(CONFIG_TOP_SRCDIR ${CMAKE_CURRENT_SOURCE_DIR})
configure_file(m4-config.in config.m4 @ONLY NEWLINE_STYLE LF)

set(HELPER_SOURCES
	gen-fib.c gen-fac.c gen-bases.c gen-trialdivtab.c
	gen-jacobitab.c gen-psqr.c)

if(WIN32)
set(EXE ".exe")
else()
set(EXE "")
endif()

foreach(h ${HELPER_SOURCES})
	string(REPLACE ".c" ${EXE} e ${h})
	add_custom_command(OUTPUT  ${CMAKE_CURRENT_BINARY_DIR}/${e} 
						COMMAND ${CMAKE_C_COMPILER} ${CMAKE_CURRENT_SOURCE_DIR}/${h} -o ${CMAKE_CURRENT_BINARY_DIR}/${e})
	#list(APPEND gen ${CMAKE_CURRENT_BINARY_DIR}/${e})
endforeach()

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/fac_table.h
					COMMAND ${CMAKE_CURRENT_BINARY_DIR}/gen-fac${EXE} ${GMP_LIMB_BITS} ${GMP_NAIL_BITS} > ${CMAKE_CURRENT_BINARY_DIR}/fac_table.h
					MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/gen-fac${EXE})	

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/fib_table.h ${CMAKE_CURRENT_BINARY_DIR}/fib_table.c
					COMMAND ${CMAKE_CURRENT_BINARY_DIR}/gen-fib${EXE} header ${GMP_LIMB_BITS} ${GMP_NAIL_BITS} > ${CMAKE_CURRENT_BINARY_DIR}/fib_table.h
					COMMAND ${CMAKE_CURRENT_BINARY_DIR}/gen-fib${EXE} table ${GMP_LIMB_BITS} ${GMP_NAIL_BITS} > ${CMAKE_CURRENT_BINARY_DIR}/fib_table.c
					MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/gen-fib${EXE})

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mp_bases.h ${CMAKE_CURRENT_BINARY_DIR}/mp_bases.c
					COMMAND ${CMAKE_CURRENT_BINARY_DIR}/gen-bases${EXE} header ${GMP_LIMB_BITS} ${GMP_NAIL_BITS} > ${CMAKE_CURRENT_BINARY_DIR}/mp_bases.h
					COMMAND ${CMAKE_CURRENT_BINARY_DIR}/gen-bases${EXE} table ${GMP_LIMB_BITS} ${GMP_NAIL_BITS} > ${CMAKE_CURRENT_BINARY_DIR}/mp_bases.c
					MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/gen-bases${EXE})

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/trialdivtab.h
					COMMAND ${CMAKE_CURRENT_BINARY_DIR}/gen-trialdivtab${EXE} ${GMP_LIMB_BITS} 8000 > ${CMAKE_CURRENT_BINARY_DIR}/trialdivtab.h
					MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/gen-trialdivtab${EXE})

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/jacobitab.h
					COMMAND ${CMAKE_CURRENT_BINARY_DIR}/gen-jacobitab${EXE}  > ${CMAKE_CURRENT_BINARY_DIR}/jacobitab.h
					MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/gen-jacobitab${EXE})

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn/perfsqr.h
					COMMAND ${CMAKE_CURRENT_BINARY_DIR}/gen-psqr${EXE} ${GMP_LIMB_BITS} ${GMP_NAIL_BITS} > ${CMAKE_CURRENT_BINARY_DIR}/mpn/perfsqr.h
					MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/gen-psqr${EXE})

add_custom_target(gmp-gen
				DEPENDS  ${CMAKE_CURRENT_BINARY_DIR}/fac_table.h ${CMAKE_CURRENT_BINARY_DIR}/fib_table.h ${CMAKE_CURRENT_BINARY_DIR}/fib_table.c
				${CMAKE_CURRENT_BINARY_DIR}/mp_bases.h ${CMAKE_CURRENT_BINARY_DIR}/mp_bases.c ${CMAKE_CURRENT_BINARY_DIR}/trialdivtab.h
				${CMAKE_CURRENT_BINARY_DIR}/jacobitab.h ${CMAKE_CURRENT_BINARY_DIR}/mpn/perfsqr.h )

add_custom_target(mpn
				DEPENDS ${mpn_S} gmp-gen )	


set(mpf_SOURCES 
  mpf/init.c mpf/init2.c mpf/inits.c mpf/set.c mpf/set_ui.c mpf/set_si.c mpf/set_str.c mpf/set_d.c mpf/set_z.c 
  mpf/set_q.c mpf/iset.c mpf/iset_ui.c mpf/iset_si.c mpf/iset_str.c mpf/iset_d.c mpf/clear.c mpf/clears.c
  mpf/get_str.c mpf/dump.c mpf/size.c mpf/eq.c mpf/reldiff.c mpf/sqrt.c mpf/random2.c mpf/inp_str.c mpf/out_str.c 
  mpf/add.c mpf/add_ui.c mpf/sub.c mpf/sub_ui.c mpf/ui_sub.c mpf/mul.c mpf/mul_ui.c mpf/div.c mpf/div_ui.c 
  mpf/cmp.c mpf/cmp_d.c mpf/cmp_z.c mpf/cmp_si.c mpf/cmp_ui.c mpf/mul_2exp.c mpf/div_2exp.c mpf/abs.c mpf/neg.c mpf/get_d.c 
  mpf/get_d_2exp.c mpf/set_dfl_prec.c mpf/set_prc.c mpf/set_prc_raw.c mpf/get_dfl_prec.c mpf/get_prc.c 
  mpf/ui_div.c mpf/sqrt_ui.c 
  mpf/pow_ui.c mpf/urandomb.c mpf/swap.c mpf/get_si.c mpf/get_ui.c mpf/int_p.c 
  mpf/ceilfloor.c mpf/trunc.c 
  mpf/fits_sint.c mpf/fits_slong.c mpf/fits_sshort.c 
  mpf/fits_uint.c mpf/fits_ulong.c mpf/fits_ushort.c 
  mpf/fits_s.h mpf/fits_u.h)

set(mpq_SOURCES
  mpq/abs.c mpq/aors.c mpq/canonicalize.c mpq/clear.c mpq/clears.c				
  mpq/cmp.c mpq/cmp_si.c mpq/cmp_ui.c mpq/div.c mpq/equal.c					
  mpq/get_d.c mpq/get_den.c mpq/get_num.c mpq/get_str.c					
  mpq/init.c mpq/inits.c mpq/inp_str.c mpq/inv.c mpq/md_2exp.c mpq/mul.c mpq/neg.c mpq/out_str.c	
  mpq/set.c mpq/set_den.c mpq/set_num.c mpq/set_si.c mpq/set_str.c mpq/set_ui.c mpq/set_z.c mpq/set_d.c	
  mpq/set_f.c mpq/swap.c)

set(mpz_SOURCES
  mpz/aors.h mpz/aors_ui.h mpz/fits_s.h mpz/mul_i.h
  mpz/2fac_ui.c mpz/add.c mpz/add_ui.c mpz/abs.c mpz/aorsmul.c mpz/aorsmul_i.c mpz/and.c mpz/array_init.c 
  mpz/bin_ui.c mpz/bin_uiui.c mpz/cdiv_q.c 
  mpz/cdiv_q_ui.c mpz/cdiv_qr.c mpz/cdiv_qr_ui.c mpz/cdiv_r.c mpz/cdiv_r_ui.c mpz/cdiv_ui.c 
  mpz/cfdiv_q_2exp.c mpz/cfdiv_r_2exp.c 
  mpz/clear.c mpz/clears.c mpz/clrbit.c 
  mpz/cmp.c mpz/cmp_d.c mpz/cmp_si.c mpz/cmp_ui.c mpz/cmpabs.c mpz/cmpabs_d.c mpz/cmpabs_ui.c 
  mpz/com.c mpz/combit.c 
  mpz/cong.c mpz/cong_2exp.c mpz/cong_ui.c 
  mpz/divexact.c mpz/divegcd.c mpz/dive_ui.c mpz/divis.c mpz/divis_ui.c mpz/divis_2exp.c 
  mpz/dump.c mpz/export.c mpz/fac_ui.c mpz/fdiv_q.c mpz/fdiv_q_ui.c 
  mpz/fdiv_qr.c mpz/fdiv_qr_ui.c mpz/fdiv_r.c mpz/fdiv_r_ui.c mpz/fdiv_ui.c 
  mpz/fib_ui.c mpz/fib2_ui.c 
  mpz/fits_sint.c mpz/fits_slong.c mpz/fits_sshort.c 
  mpz/fits_uint.c mpz/fits_ulong.c mpz/fits_ushort.c 
  mpz/gcd.c mpz/gcd_ui.c mpz/gcdext.c mpz/get_d.c mpz/get_d_2exp.c mpz/get_si.c 
  mpz/get_str.c mpz/get_ui.c mpz/getlimbn.c mpz/hamdist.c 
  mpz/import.c mpz/init.c mpz/init2.c mpz/inits.c mpz/inp_raw.c mpz/inp_str.c 
  mpz/invert.c mpz/ior.c mpz/iset.c mpz/iset_d.c mpz/iset_si.c mpz/iset_str.c mpz/iset_ui.c 
  mpz/jacobi.c mpz/kronsz.c mpz/kronuz.c mpz/kronzs.c mpz/kronzu.c 
  mpz/lcm.c mpz/lcm_ui.c mpz/limbs_read.c mpz/limbs_write.c mpz/limbs_modify.c mpz/limbs_finish.c 
  mpz/lucnum_ui.c mpz/lucnum2_ui.c mpz/mfac_uiui.c mpz/millerrabin.c 
  mpz/mod.c mpz/mul.c mpz/mul_2exp.c mpz/mul_si.c mpz/mul_ui.c mpz/n_pow_ui.c mpz/neg.c mpz/nextprime.c 
  mpz/oddfac_1.c 
  mpz/out_raw.c mpz/out_str.c mpz/perfpow.c mpz/perfsqr.c mpz/popcount.c mpz/pow_ui.c mpz/powm.c 
  mpz/powm_sec.c mpz/powm_ui.c mpz/pprime_p.c mpz/prodlimbs.c mpz/primorial_ui.c mpz/random.c mpz/random2.c 
  mpz/realloc.c mpz/realloc2.c mpz/remove.c mpz/roinit_n.c mpz/root.c mpz/rootrem.c mpz/rrandomb.c 
  mpz/scan0.c mpz/scan1.c mpz/set.c mpz/set_d.c mpz/set_f.c mpz/set_q.c mpz/set_si.c mpz/set_str.c 
  mpz/set_ui.c mpz/setbit.c mpz/size.c mpz/sizeinbase.c mpz/sqrt.c mpz/sqrtrem.c mpz/sub.c mpz/sub_ui.c 
  mpz/swap.c mpz/tdiv_ui.c mpz/tdiv_q.c mpz/tdiv_q_2exp.c mpz/tdiv_q_ui.c mpz/tdiv_qr.c 
  mpz/tdiv_qr_ui.c mpz/tdiv_r.c mpz/tdiv_r_2exp.c mpz/tdiv_r_ui.c mpz/tstbit.c mpz/ui_pow_ui.c 
  mpz/ui_sub.c mpz/urandomb.c mpz/urandomm.c mpz/xor.c)

foreach(s ${mpn_S})
	string(REPLACE ${CMAKE_CURRENT_BINARY_DIR}/mpn/ "" s ${s})
	string(FIND ${s} ".c" c)
	string(FIND ${s} ".asm" as)
	if(NOT ${c} EQUAL -1)
	set(def ${s})
	string(REPLACE ".c" "" def ${def})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn-build/${s}.o 
						COMMAND ${CMAKE_C_COMPILER} -c ${GMP_COMPILE_FLAGS} ${GMP_DEFINES} -DOPERATION_${def} -I${CMAKE_CURRENT_BINARY_DIR} -I${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR}/mpn/${s} -o ${CMAKE_CURRENT_BINARY_DIR}/mpn-build/${s}.o)
	list(APPEND mpn_O ${CMAKE_CURRENT_BINARY_DIR}/mpn-build/${s}.o)
	endif()
	if(NOT ${as} EQUAL -1)
	set(def ${s})
	string(REPLACE ".asm" "" def ${def})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mpn-build/${s}.o
						COMMAND m4 ${GMP_DEFINES} -DOPERATION_${def} -I ${CMAKE_CURRENT_BINARY_DIR}/mpn ${CMAKE_CURRENT_BINARY_DIR}/mpn/${s} > ${CMAKE_CURRENT_BINARY_DIR}/mpn/${def}.s 
						COMMAND ${CMAKE_C_COMPILER} -c ${GMP_COMPILE_FLAGS} ${GMP_DEFINES} -DOPERATION_${def} -I${CMAKE_CURRENT_BINARY_DIR} -I${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR}/mpn/${def}.s -o ${CMAKE_CURRENT_BINARY_DIR}/mpn-build/${s}.o)
	list(APPEND mpn_O ${CMAKE_CURRENT_BINARY_DIR}/mpn-build/${s}.o)
	endif()
endforeach()

add_custom_target(mpn_obj
					DEPENDS mpn ${mpn_O})


#message(${mpn_S})

set(mpn_SOURCES
	${CMAKE_CURRENT_BINARY_DIR}/mp_bases.c ${CMAKE_CURRENT_BINARY_DIR}/fib_table.c)

set(printf_SOURCES
  printf/asprintf.c printf/asprntffuns.c printf/doprnt.c printf/doprntf.c printf/doprnti.c			 
  printf/fprintf.c printf/obprintf.c printf/obvprintf.c printf/obprntffuns.c			 
  printf/printf.c printf/printffuns.c printf/snprintf.c printf/snprntffuns.c printf/sprintf.c printf/sprintffuns.c 
  printf/vasprintf.c printf/vfprintf.c printf/vprintf.c printf/vsnprintf.c printf/vsprintf.c		 
  printf/repl-vsnprintf.c)

set(scanf_SOURCES
	scanf/doscan.c scanf/fscanf.c scanf/fscanffuns.c scanf/scanf.c scanf/sscanf.c scanf/sscanffuns.c 
  scanf/vfscanf.c scanf/vscanf.c scanf/vsscanf.c)

set(rand_SOURCES
    rand/randmt.h
	rand/rand.c rand/randclr.c rand/randdef.c rand/randiset.c rand/randlc2s.c rand/randlc2x.c rand/randmt.c	
  rand/randmts.c rand/rands.c rand/randsd.c rand/randsdui.c rand/randbui.c rand/randmui.c)

#not used here, because we are building a C library only
set(cxx_SOURCES
 cxx/isfuns.cc cxx/ismpf.cc cxx/ismpq.cc cxx/ismpz.cc cxx/ismpznw.cc cxx/limits.cc 
  cxx/osdoprnti.cc cxx/osfuns.cc cxx/osmpf.cc cxx/osmpq.cc cxx/osmpz.cc)

set(gmp_SOURCES
  gmp-impl.h longlong.h				
  assert.c compat.c errno.c extract-dbl.c invalid.c memory.c		
  mp_bpl.c mp_clz_tab.c mp_dv_tab.c mp_minv_tab.c mp_get_fns.c mp_set_fns.c 
  version.c nextprime.c primesieve.c )

if( ${WANT_TMP_ALLOCA} EQUAL 1 )
list(APPEND gmp_SOURCES tal-reent.c)
endif()

set(COMMON_HEADERS
	${CMAKE_CURRENT_BINARY_DIR}/config.h ${CMAKE_CURRENT_BINARY_DIR}/gmp.h
	 gmp-impl.h ${CMAKE_CURRENT_BINARY_DIR}/gmp-mparam.h longlong.h )

add_library(gmp STATIC ${gmp_SOURCES} ${COMMON_HEADERS} ${mpf_SOURCES} ${mpq_SOURCES} ${mpz_SOURCES} ${mpn_SOURCES} ${mpn_O} ${printf_SOURCES} ${scanf_SOURCES} ${rand_SOURCES})
add_dependencies(gmp mpn_obj gmp-gen)
target_compile_definitions(gmp PRIVATE __GMP_WITHIN_GMP HAVE_CONFIG_H )
target_include_directories(gmp PRIVATE ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR})
target_include_directories(gmp PUBLIC ${CMAKE_CURRENT_BINARY_DIR} )
target_compile_options(gmp PRIVATE ${GMP_COMPILE_FLAGS})
set_target_properties(gmp PROPERTIES PUBLIC_HEADER ${CMAKE_CURRENT_BINARY_DIR}/gmp.h)
#add_dependencies(gmp mpf mpq mpz mpn printf scanf rand)
#target_link_libraries(gmp mpf mpq mpz mpn printf scanf rand)  

include(CTest)
enable_testing()
set(gmp-test_SOURCES
	tests/memory.c tests/misc.c tests/refmpf.c 
	tests/refmpn.c tests/refmpq.c tests/refmpz.c 
	tests/spinner.c tests/trace.c)

add_library(gmp-tests ${gmp-test_SOURCES})
target_include_directories(gmp-tests PUBLIC ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/tests)
add_dependencies(gmp-tests gmp)
target_compile_options(gmp-tests PUBLIC ${GMP_COMPILE_FLAGS})
target_compile_definitions(gmp-tests PUBLIC HAVE_CONFIG_H )

set(tests
#top-level tests
t-bswap t-constants t-count_zeros t-hightomask 
  t-modlinv t-popc t-parity t-sub
  #tests/misc
  misc/t-locale misc/t-printf misc/t-scanf
  #tests/mpf
  mpf/t-dm2exp mpf/t-conv mpf/t-add mpf/t-sub mpf/t-sqrt mpf/t-sqrt_ui mpf/t-muldiv mpf/reuse 
  mpf/t-cmp_d mpf/t-cmp_si mpf/t-div mpf/t-fits mpf/t-get_d mpf/t-get_d_2exp 
  mpf/t-get_si mpf/t-get_ui mpf/t-gsprec mpf/t-inp_str mpf/t-int_p mpf/t-mul_ui 
  mpf/t-set mpf/t-set_q mpf/t-set_si mpf/t-set_ui mpf/t-trunc mpf/t-ui_div mpf/t-eq mpf/t-pow_ui
  #tests/mpn
  mpn/t-asmtype mpn/t-aors_1 mpn/t-divrem_1 mpn/t-mod_1 mpn/t-fat mpn/t-get_d	
  mpn/t-instrument mpn/t-iord_u mpn/t-mp_bases mpn/t-perfsqr mpn/t-scan mpn/logic		
  mpn/t-toom22 mpn/t-toom32 mpn/t-toom33 mpn/t-toom42 mpn/t-toom43 mpn/t-toom44			
  mpn/t-toom52 mpn/t-toom53 mpn/t-toom54 mpn/t-toom62 mpn/t-toom63 mpn/t-toom6h mpn/t-toom8h	
  mpn/t-toom2-sqr mpn/t-toom3-sqr mpn/t-toom4-sqr mpn/t-toom6-sqr mpn/t-toom8-sqr		
  mpn/t-div mpn/t-mul mpn/t-mullo mpn/t-sqrlo mpn/t-mulmod_bnm1 mpn/t-sqrmod_bnm1 mpn/t-mulmid	
  mpn/t-hgcd mpn/t-hgcd_appr mpn/t-matrix22 mpn/t-invert mpn/t-bdiv				
  mpn/t-broot mpn/t-brootinv mpn/t-minvert mpn/t-sizeinbase
  #tests/mpq
  mpq/t-aors mpq/t-cmp mpq/t-cmp_ui mpq/t-cmp_si mpq/t-equal mpq/t-get_d mpq/t-get_str 
  mpq/t-inp_str mpq/t-inv mpq/t-md_2exp mpq/t-set_f mpq/t-set_str mpq/io mpq/reuse mpq/t-cmp_z
  #tests/mpz
  mpz/reuse mpz/t-addsub mpz/t-cmp mpz/t-mul mpz/t-mul_i mpz/t-tdiv mpz/t-tdiv_ui mpz/t-fdiv 
  mpz/t-fdiv_ui mpz/t-cdiv_ui mpz/t-gcd mpz/t-gcd_ui mpz/t-lcm mpz/t-invert mpz/dive mpz/dive_ui mpz/t-sqrtrem 
  mpz/convert mpz/io mpz/t-inp_str mpz/logic mpz/bit mpz/t-powm mpz/t-powm_ui mpz/t-pow mpz/t-div_2exp      
  mpz/t-root mpz/t-perfsqr mpz/t-perfpow mpz/t-jac mpz/t-bin mpz/t-get_d mpz/t-get_d_2exp mpz/t-get_si	
  mpz/t-set_d mpz/t-set_si							
  mpz/t-fac_ui mpz/t-mfac_uiui mpz/t-primorial_ui mpz/t-fib_ui mpz/t-lucnum_ui mpz/t-scan mpz/t-fits   
  mpz/t-divis mpz/t-divis_2exp mpz/t-cong mpz/t-cong_2exp mpz/t-sizeinbase mpz/t-set_str        
  mpz/t-aorsmul mpz/t-cmp_d mpz/t-cmp_si mpz/t-hamdist mpz/t-oddeven mpz/t-popcount mpz/t-set_f     
  mpz/t-io_raw mpz/t-import mpz/t-export mpz/t-pprime_p mpz/t-nextprime mpz/t-remove mpz/t-limbs
  #tests/rand
  rand/t-iset rand/t-lc2exp rand/t-mt rand/t-rand rand/t-urbui rand/t-urmui rand/t-urndmm)

foreach(t ${tests})
	string(REPLACE "/" "-" tt ${t})
	add_executable(${tt} tests/${t}.c)
	add_dependencies(${tt} gmp-tests)
	target_link_libraries(${tt} gmp-tests gmp)
	set_target_properties(${tt} PROPERTIES
							RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tests")
	add_test(${t} ${CMAKE_CURRENT_BINARY_DIR}/tests/${tt})
endforeach()

INSTALL(TARGETS gmp
		LIBRARY DESTINATION lib
		PUBLIC_HEADER DESTINATION include)