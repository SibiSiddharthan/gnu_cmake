cmake_minimum_required(VERSION 3.13)
project(mpfr C )
INCLUDE (CheckTypeSize)
INCLUDE(CheckIncludeFile)
INCLUDE(CheckSymbolExists)
INCLUDE(CheckFunctionExists)
INCLUDE(CheckCSourceCompiles)
INCLUDE(CheckStructHasMember)

if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
	message(FATAL_ERROR "In-source builds not allowed. Please make a new directory")
endif()

if(NOT DEFINED GMP_PATH)
message(FATAL_ERROR "GMP is required\nSet GMP_PATH")
else()
find_file(GMP_HEADER gmp.h ${GMP_PATH}/include)
find_library(GMP_LIB gmp ${GMP_PATH}/lib)
if(GMP_HEADER STREQUAL "GMP_HEADER-NOTFOUND" OR GMP_LIB STREQUAL "GMP_LIB-NOTFOUND")
message(FATAL_ERROR "GMP path is invalid")
endif()
endif()

set(PACKAGE_NAME \"MPFR\")
set(PACKAGE_TARNAME \"mpfr\")
set(PACKAGE_VERSION \"4.0.2\")
set(PACKAGE_STRING \"MPFR 4.0.2\")
set(PACKAGE_BUGREPORT \"\")
set(PACKAGE_URL \"\")

#true for windows
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

function(check_struct_members structs header_file)
foreach(i ${${structs}})
set(tmp ${i})
string(REPLACE "." ";" tmp ${tmp})
list(GET tmp 0 m_struct)
list(GET tmp 1 m_member)
set(var ${i})
string(REPLACE "." "_" var ${var})
string(TOUPPER ${var} var)
string(PREPEND var "HAVE_STRUCT_")
check_struct_has_member("struct ${m_struct}" ${m_member} ${header_file} ${var} LANGUAGE C)
	if(${var})
	set(${var} 1)
	endif()	
endforeach()
endfunction()

set(header dlfcn.h float.h inttypes.h  memory.h locale.h wchar.h stdarg.h
	 stdint.h stdlib.h strings.h string.h sys/stat.h sys/types.h sys/time.h
	unistd.h limits.h sys/fpu.h alloca.h)

check_headers(header) 

check_include_file(stdarg.h HAVE_STDARG)
if(HAVE_STDARG)
set(HAVE_STDARG 1)
endif()

set(functions alloca va_list memmove memset setlocale strtol
	gettimeofday signal sigaction round trunc floor ceil nearbyint )

check_functions(functions)

set(types_presence "long double" "long long"  intmax_t size_t)
check_types_presence(types_presence)

set(struct_members lconv.decimal_point lconv.thousands_sep)
check_struct_members(struct_members locale.h)

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

if(HAVE_INTMAX_T AND HAVE_STDINT_H AND HAVE_INTTYPES_H)
set(CMAKE_REQUIRED_FLAGS "-DHAVE_INTTYPES_H;_DHAVE_STDINT_H")
endif()
check_c_source_compiles("
#include \"${CMAKE_CURRENT_SOURCE_DIR}/src/mpfr-intmax.h\"
int
main (void)
{
intmax_t x = INTMAX_MAX; (void) x;

  ;
  return 0;
}"
MPFR_HAVE_INTMAX_MAX)
if(MPFR_HAVE_INTMAX_MAX)
set(MPFR_HAVE_INTMAX_MAX 1)
endif()

check_c_source_compiles("
_Noreturn void foo(int);
int
main ()
{

  ;
  return 0;
}"
MPFR_HAVE_NORETURN)
if(MPFR_HAVE_NORETURN)
set(MPFR_HAVE_NORETURN 1)
endif()

check_c_source_compiles("
int x;
int
main (void)
{
if (x) __builtin_unreachable();

  ;
  return 0;
}"
MPFR_HAVE_BUILTIN_UNREACHABLE)
if(MPFR_HAVE_BUILTIN_UNREACHABLE)
set(MPFR_HAVE_BUILTIN_UNREACHABLE 1)
endif()

check_c_source_compiles("
#include <stdlib.h>
int x = 0;
__attribute__((constructor)) static void
call_f(void) { x = 1742; }
__attribute__((destructor)) static void
call_g(void) { x = 1448; }

int
main (void)
{

    return (x == 1742) ? 0 : 1;

  ;
  return 0;
}"
MPFR_HAVE_CONSTRUCTOR_ATTR)
if(MPFR_HAVE_CONSTRUCTOR_ATTR )
set(MPFR_HAVE_CONSTRUCTOR_ATTR 1)
endif()

check_c_source_compiles("
int main (void) {
  return 1.0 / 0.0 == 1.0 / -0.0;
}"
HAVE_SIGNEDZ )
if(HAVE_SIGNEDZ )
set(HAVE_SIGNEDZ 1)
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
HAVE_DOUBLE_IEEE_LITTLE_ENDIAN )
if(HAVE_DOUBLE_IEEE_LITTLE_ENDIAN )
set(HAVE_DOUBLE_IEEE_LITTLE_ENDIAN 1)
set(HAVE_LITTLE_ENDIAN 1)
else()
set(HAVE_DOUBLE_IEEE_BIG_ENDIAN 1)
set(HAVE_BIG_ENDIAN 1)
endif()

check_c_source_compiles("
#include <stdarg.h>

int
main (void)
{

   va_list ap1, ap2;
   __va_copy(ap1, ap2);

  ;
  return 0;
}"
HAVE_VA_COPY)
if(HAVE_VA_COPY)
set(HAVE_VA_COPY 1)
endif()


#IF CROSS-COMPILING ASSUME NO
check_c_source_compiles("
#include <stdio.h>
int main (void) {
  double x = 2.22507385850720138309e-308;
  fprintf (stderr, \"%e\", x / 2.0);
  return 2.0 * (double) (x / 2.0) != x;
}"
HAVE_DENORMS)
if(HAVE_DENORMS )
set(HAVE_DENORMS 1)
endif()

#IF CROSS-COMPILING ASSUME NO
check_c_source_compiles("
#include <stdio.h>
int main (void) {
  float x = 1.17549435082229e-38;
  fprintf (stderr, \"%e\", x / 2.0);
  return 2.0 * (float) (x / 2.0) != x;
}"
HAVE_DENORMS_FLT)
if(HAVE_DENORMS_FLT )
set(HAVE_DENORMS_FLT 1)
endif()

check_c_source_compiles("
#include <fenv.h>
int
main (void)
{
fesetround(FE_TONEAREST);
  ;
  return 0;
}"
MPFR_HAVE_FESETROUND)
if(MPFR_HAVE_FESETROUND)
set(MPFR_HAVE_FESETROUND 1)
endif()

check_c_source_compiles("
int
main (void)
{

volatile __float128 x = 0x1.fp+16383q;
return x == 0;

  ;
  return 0;
}"
MPFR_WANT_FLOAT128)
if(MPFR_WANT_FLOAT128 )
set(MPFR_WANT_FLOAT128 1)
endif()

check_c_source_compiles("
_Decimal64 x;
int
main (void)
{

  ;
  return 0;
}"
MPFR_WANT_DECIMAL_FLOATS)
if(MPFR_WANT_DECIMAL_FLOATS )
set(MPFR_WANT_DECIMAL_FLOATS 1)
endif()

check_c_source_compiles("
#define MPFR_USE_THREAD_SAFE 1
#define MPFR_USE_C11_THREAD_SAFE 1
 #include \"${CMAKE_CURRENT_SOURCE_DIR}/src/mpfr-thread.h\"
 MPFR_THREAD_ATTR int x = 17;
 int main (void) {
   return x != 17;
 }"
THREAD_SAFE)
if(THREAD_SAFE)
set(MPFR_USE_THREAD_SAFE 1)
set(MPFR_USE_C11_THREAD_SAFE 1)
endif()

#[[ works
#only works for standalone builds
check_c_source_compiles("
#include \"${GMP_PATH}/include/gmp.h\"
#include \"${CMAKE_CURRENT_SOURCE_DIR}/src/mpfr-sassert.h\"

int
main (void)
{

  MPFR_STAT_STATIC_ASSERT ((mp_limb_t) -1 >= (unsigned long) -1);
  return 0;

  ;
  return 0;
}"
MPFR_LONG_WITHIN_LIMB)
if(MPFR_LONG_WITHIN_LIMB)
set(MPFR_LONG_WITHIN_LIMB 1)
endif()
]]

set(LT_OBJDIR \".libs/\")
set(MPFR_PRINTF_MAXLM \"j\")
set(NPRINTF_L 1)
set(PRINTF_T 1)
set(HAVE___GMPN_SBPI1_DIVAPPR_Q 1)
set(HAVE___GMPN_INVERT_LIMB 1)
set(HAVE___GMPN_RSBLSH_N 1)
set(MPFR_LONG_WITHIN_LIMB 1)
set(HAVE_LDOUBLE_IEEE_EXT_LITTLE 1)
set(MPFR_USE_STATIC_ASSERT 1)

configure_file(mpfr-config.h.in config.h)

set(mpfr_SOURCES
src/mpfr.h src/mpf2mpfr.h src/mpfr-cvers.h src/mpfr-gmp.h
src/mpfr-impl.h src/mpfr-intmax.h src/mpfr-longlong.h
src/mpfr-sassert.h src/mpfr-thread.h src/exceptions.c
src/extract.c src/uceil_exp2.c src/uceil_log2.c
src/ufloor_log2.c src/add.c src/add1.c src/add_ui.c
src/agm.c src/clear.c src/cmp.c src/cmp_abs.c src/cmp_si.c
src/cmp_ui.c src/comparisons.c src/div_2exp.c src/div_2si.c
src/div_2ui.c src/div.c src/div_ui.c src/dump.c src/eq.c
src/exp10.c src/exp2.c src/exp3.c src/exp.c src/frac.c
src/frexp.c src/get_d.c src/get_exp.c src/get_str.c src/init.c
src/inp_str.c src/isinteger.c src/isinf.c src/isnan.c
src/isnum.c src/const_log2.c src/log.c src/modf.c
src/mul_2exp.c src/mul_2si.c src/mul_2ui.c src/mul.c
src/mul_ui.c src/neg.c src/next.c src/out_str.c
src/printf.c src/vasprintf.c src/const_pi.c
src/pow.c src/pow_si.c src/pow_ui.c
src/print_raw.c src/print_rnd_mode.c
src/reldiff.c src/round_prec.c
src/set.c src/setmax.c src/setmin.c src/set_d.c
src/set_dfl_prec.c src/set_exp.c src/set_rnd.c
src/set_f.c src/set_prc_raw.c src/set_prec.c src/set_q.c
src/set_si.c src/set_str.c src/set_str_raw.c src/set_ui.c
src/set_z.c src/sqrt.c src/sqrt_ui.c src/sub.c src/sub1.c
src/sub_ui.c src/rint.c src/ui_div.c src/ui_sub.c
src/urandom.c src/urandomb.c src/get_z_exp.c src/swap.c
src/factorial.c src/cosh.c src/sinh.c src/tanh.c
src/sinh_cosh.c src/acosh.c src/asinh.c src/atanh.c
src/atan.c src/cmp2.c src/exp_2.c src/asin.c src/const_euler.c
src/cos.c src/sin.c src/tan.c src/fma.c src/fms.c src/hypot.c
src/log1p.c src/expm1.c src/log2.c src/log10.c src/ui_pow.c
src/ui_pow_ui.c src/minmax.c src/dim.c src/signbit.c src/copysign.c
src/setsign.c src/gmp_op.c src/init2.c src/acos.c src/sin_cos.c
src/set_nan.c src/set_inf.c src/set_zero.c src/powerof2.c src/gamma.c
src/set_ld.c src/get_ld.c src/cbrt.c src/volatile.c src/fits_s.h
src/fits_sshort.c src/fits_sint.c src/fits_slong.c src/fits_u.h
src/fits_ushort.c src/fits_uint.c src/fits_ulong.c src/fits_uintmax.c
src/fits_intmax.c src/get_si.c src/get_ui.c src/zeta.c
src/cmp_d.c src/erf.c src/inits.c src/inits2.c src/clears.c src/sgn.c
src/check.c src/sub1sp.c src/version.c src/mpn_exp.c
src/mpfr-gmp.c src/mp_clz_tab.c src/sum.c src/add1sp.c
src/free_cache.c src/si_op.c src/cmp_ld.c src/set_ui_2exp.c
src/set_si_2exp.c src/set_uj.c src/set_sj.c src/get_sj.c
src/get_uj.c src/get_z.c src/iszero.c src/cache.c
src/sqr.c src/int_ceil_log2.c src/isqrt.c src/strtofr.c src/pow_z.c
src/logging.c src/mulders.c src/get_f.c src/round_p.c src/erfc.c
src/atan2.c src/subnormal.c src/const_catalan.c src/root.c
src/gen_inverse.h src/sec.c src/csc.c src/cot.c src/eint.c
src/sech.c src/csch.c src/coth.c src/round_near_x.c src/constant.c
src/abort_prec_max.c src/stack_interface.c src/lngamma.c src/zeta_ui.c
src/set_d64.c src/get_d64.c src/jn.c src/yn.c src/rem1.c src/get_patches.c
src/add_d.c src/sub_d.c src/d_sub.c src/mul_d.c src/div_d.c src/d_div.c
src/li2.c src/rec_sqrt.c src/min_prec.c src/buildopt.c src/digamma.c
src/bernoulli.c src/isregular.c src/set_flt.c src/get_flt.c src/scale2.c
src/set_z_exp.c src/ai.c src/gammaonethird.c src/ieee_floats.h src/grandom.c
src/fpif.c src/set_float128.c src/get_float128.c src/rndna.c src/nrandom.c
src/random_deviate.h src/random_deviate.c src/erandom.c src/mpfr-mini-gmp.c
src/mpfr-mini-gmp.h src/fmma.c src/log_ui.c src/gamma_inc.c src/ubf.c
src/invert_limb.h src/invsqrt_limb.h src/beta.c src/odd_p.c
src/get_q.c src/pool.c)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/mparam.h
					COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/src/mparam_h.in ${CMAKE_CURRENT_BINARY_DIR}/mparam.h)
add_custom_target(mparam
					DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/mparam.h)

add_library(mpfr ${mpfr_SOURCES})
#[[
target_compile_options(mpfr PRIVATE 
						-DHAVE_INTTYPES_H=1    #done  
						-DHAVE_STDINT_H=1  #done
						-DLT_OBJDIR=\".libs/\"  #done
						-DHAVE_DOUBLE_IEEE_LITTLE_ENDIAN=1  #done
						 -DHAVE_LITTLE_ENDIAN=1 #done
						 -DTIME_WITH_SYS_TIME=1  #done
						 -DHAVE_LOCALE_H=1  #done
						 -DHAVE_WCHAR_H=1 #done
						 -DHAVE_STDARG=1 #done
						 -DHAVE_SYS_TIME_H=1   #done
						  -DHAVE_STRUCT_LCONV_DECIMAL_POINT=1  #done
						  -DHAVE_STRUCT_LCONV_THOUSANDS_SEP=1 #done
						  -DHAVE_VA_COPY=1 #done
						   -DHAVE_SETLOCALE=1 #done
						 -DHAVE_GETTIMEOFDAY=1  #done
						  -DHAVE_SIGNAL=1  #done
						  -DHAVE_LONG_LONG=1    #done
						   -DHAVE_INTMAX_T=1  #done
						   -DMPFR_HAVE_INTMAX_MAX=1 #done
						 -DMPFR_PRINTF_MAXLM=\"j\" 
						 -DMPFR_HAVE_NORETURN=1 #done
						 -DMPFR_HAVE_BUILTIN_UNREACHABLE=1 #done
						 -DMPFR_HAVE_CONSTRUCTOR_ATTR=1 #done
						 -DMPFR_HAVE_FESETROUND=1 #done
						 -DHAVE_DENORMS=1 #done
						  -DHAVE_DENORMS_FLT=1 #done
						 -DHAVE_SIGNEDZ=1 #done
						 -DHAVE_ROUND=1   #done
						 -DHAVE_TRUNC=1  #done
						  -DHAVE_FLOOR=1   #done
						  -DHAVE_CEIL=1  #done
						   -DHAVE_NEARBYINT=1 #done
						    -DHAVE_LDOUBLE_IEEE_EXT_LITTLE=1
							-DMPFR_USE_THREAD_SAFE=1 #done
							-DMPFR_USE_C11_THREAD_SAFE=1 #done
						  -DMPFR_WANT_DECIMAL_FLOATS=1 #done
						  -DMPFR_WANT_FLOAT128=1 #done
						   -DMPFR_USE_STATIC_ASSERT=1 #done
						    -DHAVE_CLOCK_GETTIME=1 #done
						   -DHAVE_ATTRIBUTE_MODE=1 #done
						    -DNPRINTF_L=1
							 -DPRINTF_T=1
							  -DHAVE___GMPN_SBPI1_DIVAPPR_Q=1
							   -DHAVE___GMPN_INVERT_LIMB=1
						    -DHAVE___GMPN_RSBLSH_N=1
							 -DMPFR_LONG_WITHIN_LIMB=1
							  -Wall -Wmissing-prototypes -Wc++-compat -Wpointer-arith -O2 -fomit-frame-pointer -m64)
							  ]]
target_compile_options(mpfr PRIVATE -Wall -Wmissing-prototypes -Wc++-compat -Wpointer-arith -O2 -fomit-frame-pointer -m64 -include ${CMAKE_CURRENT_BINARY_DIR}/config.h)
target_include_directories(mpfr PUBLIC ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/src ${GMP_PATH}/include )
add_dependencies(mpfr mparam)

include(CTest)
enable_testing()

set(dat_files 
    inp_str.dat  tfpif_r1.dat  tfpif_r2.dat  tmul.dat)

foreach(i ${dat_files})
	add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/tests/${i}
						COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/tests/${i} ${CMAKE_CURRENT_BINARY_DIR}/tests/${i})
	list(APPEND cpdat ${CMAKE_CURRENT_BINARY_DIR}/tests/${i})
endforeach()

add_custom_target(res DEPENDS ${cpdat} )

set(mpfr-test_SOURCES
	tests/mpfr-test.h tests/memory.c tests/rnd_mode.c tests/tests.c tests/cmp_str.c tests/random2.c)
add_library(mpfr-tests STATIC ${mpfr-test_SOURCES})
target_compile_options(mpfr-tests PRIVATE -Wall -Wmissing-prototypes -Wc++-compat -Wpointer-arith -O2 -fomit-frame-pointer -m64 -include ${CMAKE_CURRENT_BINARY_DIR}/config.h)
target_link_libraries(mpfr-tests mpfr)
add_dependencies(mpfr-tests res)
#target_include_directories(mpfr-tests PRIVATE ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/src ${GMP_PATH}/include  )



set(tests
	 tversion tabort_prec_max tassert tabort_defalloc1	
     tabort_defalloc2 talloc tinternals tinits tisqrt tsgn tcheck	
     tisnan texceptions tset_exp tset mpf_compat mpfr_compat reuse	
     tabs tacos tacosh tadd tadd1sp tadd_d tadd_ui tagm tai		
     talloc-cache tasin tasinh tatan tatanh taway tbeta tbuildopt	
     tcan_round tcbrt tcmp tcmp2 tcmp_d tcmp_ld tcmp_ui tcmpabs	
     tcomparisons tconst_catalan tconst_euler tconst_log2 tconst_pi	
     tcopysign tcos tcosh tcot tcoth tcsc tcsch td_div td_sub tdigamma	
     tdim tdiv tdiv_d tdiv_ui teint teq terandom terandom_chisq terf	
     texp texp10 texp2 texpm1 tfactorial tfits tfma tfmma tfmod tfms	
     tfpif tfprintf tfrac tfrexp tgamma tgamma_inc tget_d tget_d_2exp	
     tget_f tget_flt tget_ld_2exp tget_q tget_set_d64 tget_sj		
     tget_str tget_z tgmpop tgrandom thyperbolic thypot tinp_str	
     tj0 tj1 tjn tl2b tlgamma tli2 tlngamma tlog tlog10 tlog1p tlog2
     tlog_ui tmin_prec tminmax tmodf tmul tmul_2exp tmul_d tmul_ui	
     tnext tnrandom tnrandom_chisq tout_str toutimpl tpow tpow3		
     tpow_all tpow_z tprintf trandom trandom_deviate trec_sqrt		
     tremquo trint trndna troot trootn_ui tround_prec tsec tsech	
     tset_d tset_f tset_float128 tset_ld tset_q tset_si tset_sj		
     tset_str tset_z tset_z_exp tsi_op tsin tsin_cos tsinh tsinh_cosh	
     tsprintf tsqr tsqrt tsqrt_ui tstckintc tstdint tstrtofr		
     tsub tsub1sp tsub_d tsub_ui tsubnormal tsum tswap ttan ttanh
     ttrunc tui_div tui_pow tui_sub turandom tvalist ty0 ty1 tyn	
     tzeta tzeta_ui)

foreach(t ${tests})
	add_executable(${t} tests/${t}.c)
	add_dependencies(${t} mpfr-tests)
	target_link_directories(${t} PRIVATE ${GMP_PATH}/lib)
	target_link_libraries(${t} PRIVATE mpfr-tests mpfr gmp)
	target_compile_options(${t} PRIVATE -Wall -Wmissing-prototypes -Wc++-compat -Wpointer-arith -O2 -fomit-frame-pointer -m64 -include ${CMAKE_CURRENT_BINARY_DIR}/config.h)
	target_include_directories(${t} PRIVATE ${GMP_PATH}/include ${CMAKE_CURRENT_SOURCE_DIR}/src)
	set_target_properties(${t} PROPERTIES
							RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tests")	
	add_test(NAME ${t} COMMAND ${CMAKE_CURRENT_BINARY_DIR}/tests/${t}
			WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/tests)
endforeach()