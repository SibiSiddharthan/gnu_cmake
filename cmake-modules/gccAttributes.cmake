INCLUDE(CheckCSourceCompiles)

check_c_source_compiles("
int foo (int x) __attribute__ ((const));
int
main ()
{

  ;
  return 0;
}"
HAVE_ATTRIBUTE_CONST)

check_c_source_compiles("
void *foo (int x) __attribute__ ((malloc));
int
main ()
{

  ;
  return 0;
}"
HAVE_ATTRIBUTE_MALLOC)

check_c_source_compiles("
typedef int SItype __attribute__ ((mode (SI)));
int
main ()
{

  ;
  return 0;
}"
HAVE_ATTRIBUTE_MODE)

check_c_source_compiles("
void foo (int x) __attribute__ ((noreturn));
int
main ()
{

  ;
  return 0;
}"
HAVE_ATTRIBUTE_NORETURN)

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