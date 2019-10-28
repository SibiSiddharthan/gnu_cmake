INCLUDE(CheckCSourceCompiles)
INCLUDE(CheckCXXSourceCompiles)


set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
#set(CMAKE_REQUIRED_LINK_OPTIONS iconv )
check_c_source_compiles("
#include <stdlib.h>
#include <iconv.h>
int
main ()
{
iconv_t cd = iconv_open(\"\",\"\");
         iconv(cd,NULL,NULL,NULL,NULL);
         iconv_close(cd);
  ;
  return 0;
}"
HAVE_ICONV)
#unset(CMAKE_REQUIRED_LIBRARIES)

check_cxx_source_compiles("
#include <stdlib.h>
#include <iconv.h>
extern
#ifdef __cplusplus
\"C\"
#endif
#if defined(__STDC__) || defined(__cplusplus)
size_t iconv (iconv_t cd, char * *inbuf, size_t *inbytesleft, char * *outbuf, size_t *outbytesleft);
#else
size_t iconv();
#endif

int
main ()
{

  ;
  return 0;
}"
ICONV)
if(ICONV)
set(ICONV_CONST " ")
else()
set(ICONV_CONST const)
endif()

unset(CMAKE_TRY_COMPILE_TARGET_TYPE )