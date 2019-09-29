cmake_minimum_required(VERSION 3.13)
project(isl C )

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

set(PACKAGE \"isl\")
set(PACKAGE_BUGREPORT \"isl-development@googlegroups.com\")
set(PACKAGE_NAME \"isl\")
set(PACKAGE_STRING \"isl 0.21\")
set(PACKAGE_TARNAME "isl")
set(PACKAGE_URL \"\")
set(PACKAGE_VERSION \"0.21\")
set(VERSION \"0.21\")


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


function(check_functions_declaration func header) 
set(var ${func})
string(TOUPPER ${var} var)
string(PREPEND var "HAVE_DECL_")
check_symbol_exists(${func} ${header} ${var})
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


set(function_decls ffs snprintf strcasecmp strncasecmp
	_BitScanForward _snprintf _stricmp _strnicmp __builtin_ffs)


check_functions_declaration(ffs strings.h)
check_functions_declaration(snprintf stdio.h)
check_functions_declaration(_snprintf stdio.h)
check_functions_declaration(strcasecmp strings.h)
check_functions_declaration(strncasecmp strings.h)
check_functions_declaration(_BitScanForward intrin.h)
check_functions_declaration(_stricmp string.h)
check_functions_declaration(_strnicmp string.h)

if(CMAKE_C_COMPILER_ID STREQUAL "GNU" OR CMAKE_C_COMPILER_ID STREQUAL "Clang")
set(HAVE_DECL___BUILTIN_FFS 1)
else()
set(HAVE_DECL___BUILTIN_FFS 0)
endif()
#set(CMAKE_REQUIRED_INCLUDES ${GMP_PATH}/include)
#check_functions_declaration(mp_get_memory_functions gmp.h)

set(header dlfcn.h inttypes.h memory.h
	stdint.h stdlib.h strings.h string.h 
	sys/stat.h sys/types.h unistd.h )

check_headers(header) 

set(type_sizes char int long short "void *" )
check_types_size(type_sizes)

check_c_source_compiles("
__attribute__((__warn_unused_result__))
 int f(int i) { return i; }
int
main ()
{

  ;
  return 0;
}"
GCC_WARN_UNUSED_RESULT)
if(GCC_WARN_UNUSED_RESULT)
set(GCC_WARN_UNUSED_RESULT __attribute__\(\(__warn_unused_result__\)\))
endif()

check_c_source_compiles("
#include <stdlib.h>
	  static void foo(void) __attribute__ ((unused));
	  static void
	  foo(void) {
	      exit(1);
	  }

int
main ()
{

  ;
  return 0;
}"
HAVE___ATTRIBUTE__)
if(HAVE___ATTRIBUTE__)
set(HAVE___ATTRIBUTE__ 1)
endif()

#default
set(USE_GMP_FOR_MP 1)
set(HAVE_LIBGMP 1)
set(HAVE_DECL_MP_GET_MEMORY_FUNCTIONS 1)

configure_file(isl-config.h.in isl_config.h)
set(OS_SRCDIR ${CMAKE_CURRENT_SOURCE_DIR})
configure_file(isl_srcdir.c.in isl_srcdir.c @ONLY)


set(isl_SOURCES
	isl_int_gmp.h isl_gmp.c isl_val_gmp.c isl_aff.c isl_aff_map.c 
	isl_aff_private.h isl_affine_hull.c isl_arg.c isl_ast.c isl_ast_private.h 
	isl_ast_build.c isl_ast_build_private.h isl_ast_build_expr.c isl_ast_build_expr.h 
	isl_ast_codegen.c isl_ast_graft.c isl_ast_graft_private.h isl_basis_reduction.h 
	basis_reduction_tab.c isl_bernstein.c isl_bernstein.h isl_blk.c isl_blk.h 
	isl_bound.c isl_bound.h isl_box.c isl_coalesce.c isl_constraint.c isl_constraint_private.h 
	isl_convex_hull.c isl_ctx.c isl_ctx_private.h isl_deprecated.c isl_dim_map.h 
	isl_dim_map.c isl_equalities.c isl_equalities.h isl_factorization.c isl_factorization.h 
	isl_farkas.c isl_ffs.c isl_flow.c isl_fold.c isl_hash.c isl_hash_private.h isl_id_to_ast_expr.c 
	isl_id_to_id.c isl_id_to_pw_aff.c isl_ilp.c isl_ilp_private.h isl_input.c isl_int.h 
	isl_local_private.h isl_local.h isl_local.c isl_local_space_private.h isl_local_space.c 
	isl_lp.c isl_lp_private.h isl_map.c isl_map_list.c isl_map_simplify.c isl_map_subtract.c 
	isl_map_private.h isl_map_to_basic_set.c isl_mat.c isl_mat_private.h isl_morph.c isl_morph.h 
	isl_id.c isl_id_private.h isl_obj.c isl_options.c isl_options_private.h isl_output.c 
	isl_output_private.h isl_point_private.h isl_point.c isl_polynomial_private.h isl_polynomial.c 
	isl_printer_private.h isl_printer.c print.c isl_range.c	isl_range.h isl_reordering.c 
	isl_reordering.h isl_sample.h isl_sample.c isl_scan.c isl_scan.h isl_schedule.c 
	isl_schedule_band.c isl_schedule_band.h isl_schedule_node.c isl_schedule_node_private.h 
	isl_schedule_read.c isl_schedule_tree.c isl_schedule_tree.h isl_schedule_private.h 
	isl_schedule_constraints.c isl_schedule_constraints.h isl_scheduler.c isl_set_list.c 
	isl_sort.c isl_sort.h isl_space.c isl_space_private.h isl_stream.c isl_stream_private.h 
	isl_seq.c isl_seq.h isl_stride.c isl_tab.c isl_tab.h isl_tab_pip.c isl_tarjan.c 
	isl_tarjan.h isl_transitive_closure.c isl_union_map.c isl_union_map_private.h 
	isl_union_set_private.h isl_val.c isl_val_private.h isl_vec_private.h isl_vec.c 
	isl_version.c isl_vertices_private.h isl_vertices.c isl_yaml.h)

set(isl_HEADERS
	include/isl/aff.h include/isl/aff_type.h include/isl/arg.h 
	include/isl/ast.h include/isl/ast_type.h include/isl/ast_build.h 
	include/isl/constraint.h include/isl/ctx.h include/isl/fixed_box.h 
	include/isl/flow.h include/isl/id.h include/isl/id_type.h 
	include/isl/id_to_ast_expr.h include/isl/id_to_id.h include/isl/id_to_pw_aff.h 
	include/isl/ilp.h include/isl/hash.h include/isl/hmap.h #include/isl/hmap_templ.c 
	include/isl/list.h include/isl/local_space.h include/isl/lp.h 
	include/isl/mat.h include/isl/map.h include/isl/map_to_basic_set.h 
	include/isl/map_type.h include/isl/maybe.h include/isl/maybe_ast_expr.h 
	include/isl/maybe_basic_set.h include/isl/maybe_id.h include/isl/maybe_pw_aff.h 
	include/isl/maybe_templ.h include/isl/multi.h include/isl/obj.h include/isl/options.h 
	include/isl/point.h include/isl/polynomial.h include/isl/polynomial_type.h 
	include/isl/printer.h include/isl/printer_type.h include/isl/schedule.h 
	include/isl/schedule_node.h include/isl/schedule_type.h include/isl/set.h 
	include/isl/set_type.h include/isl/space.h include/isl/space_type.h 
	include/isl/stream.h include/isl/stride_info.h include/isl/union_map.h 
	include/isl/union_map_type.h include/isl/union_set.h include/isl/union_set_type.h 
	include/isl/val.h include/isl/val_type.h include/isl/vec.h include/isl/version.h 
	include/isl/vertices.h)

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/gitversion.h
					COMMAND echo "#define GIT_HEAD_ID \"isl-0.21\"" > gitversion.h)
add_custom_target(gitversion DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/gitversion.h)

add_library(isl STATIC ${isl_SOURCES} ${isl_HEADERS})
target_compile_options(isl PRIVATE -DHAVE_CONFIG_H -O3 -fomit-frame-pointer -malign-double -fstrict-aliasing -ffast-math)
target_include_directories(isl PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR} ${GMP_PATH}/include )
add_dependencies(isl gitversion)
set_target_properties(isl PROPERTIES PUBLIC_HEADER "${isl_HEADERS}")

INSTALL(TARGETS isl
		LIBRARY DESTINATION lib
		PUBLIC_HEADER DESTINATION include/isl)

include(CTest)
enable_testing()

if(WIN32)
set(EXEEXT .exe)
else()
set(EXEEXT )
endif()
set(srcdir ${CMAKE_CURRENT_SOURCE_DIR})
set(GREP grep)
set(SED sed)
configure_file(codegen_test.sh.in ${CMAKE_CURRENT_BINARY_DIR}/tests/codegen_test.sh @ONLY)
configure_file(pip_test.sh.in ${CMAKE_CURRENT_BINARY_DIR}/tests/pip_test.sh @ONLY)
configure_file(bound_test.sh.in ${CMAKE_CURRENT_BINARY_DIR}/tests/bound_test.sh @ONLY)
configure_file(flow_test.sh.in ${CMAKE_CURRENT_BINARY_DIR}/tests/flow_test.sh @ONLY)
configure_file(schedule_test.sh.in ${CMAKE_CURRENT_BINARY_DIR}/tests/schedule_test.sh @ONLY)

set(test_helpers_1 
	isl_test isl_test_int  )

set(test_helpers_2
	polyhedron_sample pip 
	polyhedron_minimize polytope_scan 
	polyhedron_detect_equalities cat 
	closure bound schedule codegen 
	flow flow_cmp schedule_cmp)

foreach(i ${test_helpers_1})
	add_executable(${i} ${i}.c)
	add_dependencies(${i} isl)
	target_compile_options(${i} PRIVATE -DHAVE_CONFIG_H -O3 -fomit-frame-pointer -malign-double -fstrict-aliasing -ffast-math)
	target_include_directories(${i} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR} ${GMP_PATH}/include )
	target_link_directories(${i} PRIVATE ${GMP_PATH}/lib )
	target_link_libraries(${i} isl gmp)
	set_target_properties(${i} PROPERTIES
							RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tests")
endforeach()

foreach(i ${test_helpers_2})
	add_executable(isl_${i} ${i}.c)
	add_dependencies(isl_${i} isl)
	target_compile_options(isl_${i} PRIVATE -DHAVE_CONFIG_H -O3 -fomit-frame-pointer -malign-double -fstrict-aliasing -ffast-math)
	target_include_directories(isl_${i} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR} ${GMP_PATH}/include )
	target_link_directories(isl_${i} PRIVATE ${GMP_PATH}/lib )
	target_link_libraries(isl_${i} isl gmp)
	set_target_properties(isl_${i} PROPERTIES
							RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tests")
endforeach()

add_test(isl_test ${CMAKE_CURRENT_BINARY_DIR}/tests/isl_test)
add_test(isl_test_int ${CMAKE_CURRENT_BINARY_DIR}/tests/isl_test_int)
add_test(NAME codegen-test COMMAND sh ${CMAKE_CURRENT_BINARY_DIR}/tests/codegen_test.sh
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/tests)
add_test(NAME pip-test COMMAND sh ${CMAKE_CURRENT_BINARY_DIR}/tests/pip_test.sh
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/tests)
add_test(NAME bound-test COMMAND sh ${CMAKE_CURRENT_BINARY_DIR}/tests/bound_test.sh
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/tests)
add_test(NAME flow-test COMMAND sh ${CMAKE_CURRENT_BINARY_DIR}/tests/flow_test.sh
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/tests)
add_test(NAME schedule-test COMMAND sh ${CMAKE_CURRENT_BINARY_DIR}/tests/schedule_test.sh
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/tests)



