format ELF64 executable 3

include 'macros.asm'
include 'sysid.asm'
include 'constants.asm'

segment readable executable
  entry main
  include 'strings.asm'

main:
  invoke_funcall strlen, hello
  mov r10, rax
  invoke_syscall SYS_WRITE, STDOUT, hello, r10
  invoke_syscall SYS_EXIT, EXIT_SUCCESS

segment readable writeable
  hello db "Hello everyone", LF, 0

