INCLUDE(CheckCSourceCompiles)
INCLUDE(CheckCSourceRuns)

check_c_source_runs("
find_stack_direction ()
{
  static char *addr = 0;
  auto char dummy;
  if (addr == 0)
    {
      addr = &dummy;
      return find_stack_direction ();
    }
  else
    return (&dummy > addr) ? 1 : -1;
}
main ()
{
  exit (find_stack_direction() < 0);
}"
STACK_DIRECTION)
if(STACK_DIRECTION)
set(STACK_DIRECTION 1)
else()
set(STACK_DIRECTION -1)
endif()

check_c_source_compiles("
#define _FILE_OFFSET_BITS 64
#include <sys/types.h>
 /* Check that off_t can represent 2**63 - 1 correctly.
    We can't simply define LARGE_OFF_T to be 9223372036854775807,
    since some C++ compilers masquerading as C compilers
    incorrectly reject 9223372036854775807.  */
#define LARGE_OFF_T (((off_t) 1 << 62) - 1 + ((off_t) 1 << 62))
  int off_t_is_large[(LARGE_OFF_T % 2147483629 == 721
		       && LARGE_OFF_T % 2147483647 == 1)
		      ? 1 : -1];
int
main ()
{

  ;
  return 0;
}"
_FILE_OFFSET_BITS)
if(_FILE_OFFSET_BITS)
set(_FILE_OFFSET_BITS 64)
endif()

check_c_source_compiles("
#define _LARGE_FILES 1
#include <sys/types.h>
 /* Check that off_t can represent 2**63 - 1 correctly.
    We can't simply define LARGE_OFF_T to be 9223372036854775807,
    since some C++ compilers masquerading as C compilers
    incorrectly reject 9223372036854775807.  */
#define LARGE_OFF_T (((off_t) 1 << 62) - 1 + ((off_t) 1 << 62))
  int off_t_is_large[(LARGE_OFF_T % 2147483629 == 721
		       && LARGE_OFF_T % 2147483647 == 1)
		      ? 1 : -1];
int
main ()
{

  ;
  return 0;
}"
_LARGE_FILES)