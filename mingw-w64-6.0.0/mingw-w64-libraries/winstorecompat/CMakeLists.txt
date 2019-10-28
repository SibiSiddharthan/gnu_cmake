cmake_minimum_required(VERSION 3.13)
project(winstorecompat C)
INCLUDE(CheckIncludeFile)
INCLUDE(CheckFunctionExists)
INCLUDE(CheckCSourceRuns)
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
	message(FATAL_ERROR "In-source builds not allowed. Please make a new directory")
endif()

set(PACKAGE \"mingw-w64-winstorecompat\")
set(PACKAGE_BUGREPORT \"mingw-w64-public@lists.sf.net\")
set(PACKAGE_NAME \"winstorecompat\")
set(PACKAGE_STRING \"winstorecompat 1.0\")
set(PACKAGE_TARNAME "")
set(PACKAGE_URL \"mingw-w64-public@lists.sf.net\")
set(PACKAGE_VERSION \"1.0\")
set(VERSION \"1.0\")

set(winstorecompat_SOURCES
 src/_wassert.c src/beginthread.c  src/GetModuleHandle.c   src/CreateEventW.c 
  src/CreateMutexW.c src/CreateSemaphoreW.c src/InitializeCriticalSection.c 
  src/GetFileAttributes.c  src/WaitForSingleObject.c  src/LoadLibraryW.c 
  src/CreateFileW.c  src/GetTickCount.c  src/SetUnhandledExceptionFilter.c 
  src/UnhandledExceptionFilter.c  src/TerminateProcess.c  src/IsDBCSLeadByteEx.c 
  src/SetErrorMode.c  src/GetACP.c src/VirtualProtect.c  src/getenv.c src/getpid.c 
  src/LocalAlloc.c   src/LocalFree.c   src/Sleep.c  src/SleepEx.c  src/SetFilePointer.c 
  src/GetFileSize.c src/Tls.c src/SHGetFolderPathW.c src/QueueTimer.c   src/Crypto.c 
  src/GetStartupInfo.c   src/GetConsoleOutputCP.c  src/EnumProcessModules.c 
  src/RtlAddFunctionTable.c   src/RtlCaptureContext.c   src/RtlVirtualUnwind.c )

add_library(winstorecompat STATIC ${winstorecompat_SOURCES} )


