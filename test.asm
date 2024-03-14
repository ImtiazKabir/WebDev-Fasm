format ELF64 executable 3

include 'macros.asm'
include 'sysid.asm'
include 'constants.asm'

segment readable executable
  entry main
  include 'strings.asm'

main:
  invoke_funcall write_to_buffer, filepath, buffer, 1024
  invoke_funcall strlen, buffer
  mov r10, rax
  invoke_syscall SYS_WRITE, STDOUT, buffer, r10
  invoke_syscall SYS_EXIT, EXIT_SUCCESS

write_to_buffer:
  ; write_to_buffer(filepath, buffer, size)
  mov r10, rdi
  mov r8, rsi
  mov r9, rdx
  invoke_syscall SYS_OPENAT, AT_FDCWD, r10, O_RDONLY
  mov r10, rax
  invoke_syscall SYS_READ, r10, r8, r9
  invoke_syscall SYS_CLOSE, r10
  ret 0

segment readable writeable
  filepath db "index.html", 0
  buffer rb 1024

