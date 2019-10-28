cmake_minimum_required(VERSION 3.13)
project(winpthreads C)
INCLUDE(CheckIncludeFile)
INCLUDE(CheckFunctionExists)
INCLUDE(CheckCSourceRuns)
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
	message(FATAL_ERROR "In-source builds not allowed. Please make a new directory")
endif()

set(PACKAGE \"mingw-w64-winpthreads\")
set(PACKAGE_BUGREPORT \"mingw-w64-public@lists.sf.net\")
set(PACKAGE_NAME \"winpthreads\")
set(PACKAGE_STRING \"winpthreads 1.0\")
set(PACKAGE_TARNAME "")
set(PACKAGE_URL \"mingw-w64-public@lists.sf.net\")
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

set(header dlfcn.h limits.h inttypes.h memory.h malloc.h stdint.h stdlib.h strings.h string.h sys/stat.h sys/types.h sys/timeb.h unistd.h)
check_headers(header)

configure_file(winpthreads-config.h.in config.h)

set(winpthred_HEADERS
	include/pthread.h include/sched.h include/semaphore.h include/pthread_unistd.h include/pthread_time.h include/pthread_compat.h include/pthread_signal.h)

set(winpthreads_SOURCES
  src/barrier.h  src/cond.h  src/misc.h   src/rwlock.h  src/thread.h  src/ref.h  src/sem.h  src/wpth_ver.h 
  src/barrier.c  src/cond.c  src/misc.c  src/mutex.c  src/rwlock.c  src/spinlock.c  src/thread.c  src/ref.c  src/sem.c  src/sched.c 
  src/winpthread_internal.h  src/clock.c src/nanosleep.c src/version.rc)

add_library(pthread STATIC ${winpthreads_SOURCES} ${winpthred_HEADERS})
target_compile_definitions(pthread PRIVATE IN_WINPTHREAD WINPTHREAD_DBG=1 WIN32_LEAN_AND_MEAN)
target_include_directories(pthread PRIVATE ${CMAKE_CURRENT_BINARY_DIR} include)

add_library(libwinpthread-1 SHARED ${winpthreads_SOURCES} ${winpthred_HEADERS})
target_compile_definitions(libwinpthread-1 PRIVATE IN_WINPTHREAD WINPTHREAD_DBG=1 WIN32_LEAN_AND_MEAN DLL_EXPORT PIC)
target_include_directories(libwinpthread-1 PRIVATE ${CMAKE_CURRENT_BINARY_DIR} include)
target_link_options(libwinpthread-1 PRIVATE -no-pthread)

set(tests t_clock_getres  t_clock_gettime  t_clock_nanosleep  t_clock_settime  t_nanosleep)


include(CTest)
enable_testing()


foreach(i ${tests})
add_executable(${i} tests/${i}.c)
target_include_directories(${i} PRIVATE ${CMAKE_CURRENT_BINARY_DIR} include)
target_link_libraries(${i} PRIVATE pthread)
set_target_properties(${i} PROPERTIES
							RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/tests")
	add_test(${i} ${CMAKE_CURRENT_BINARY_DIR}/tests/${i})
endforeach()


