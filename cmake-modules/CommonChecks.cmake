INCLUDE(CheckCSourceCompiles)

check_c_source_compiles("
#ifdef __GNUC__
# define alloca __builtin_alloca
#else
# ifdef _MSC_VER
#  include <malloc.h>
#  define alloca _alloca
# else
#  ifdef HAVE_ALLOCA_H
#   include <alloca.h>
#  else
#   ifdef _AIX
 #pragma alloca
#   else
#    ifndef alloca /* predefined by HP cc +Olibcalls */
void *alloca (size_t);
#    endif
#   endif
#  endif
# endif
#endif

int
main ()
{
char *p = (char *) alloca (1);
				    if (p) return 0;
  ;
  return 0;
}"
HAVE_ALLOCA)

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

check_c_source_compiles("
#include <string.h>
#include <strings.h>
int
main ()
{

  ;
  return 0;
}"
STRING_WITH_STRINGS)