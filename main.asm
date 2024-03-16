format ELF64 executable 3

include 'macros.asm'
include 'sysid.asm'
include 'constants.asm'
include 'structs.asm'

MAX_CONN equ 5
PORT equ 3000
RESPONSE_BUFFER_SIZE equ 10240
REQUEST_BUFFER_SIZE equ 10240
CONTENT_LENGTH_STRLEN equ 10
ITEM_BUFLEN equ 100
EACH_ITEM_BUFLEN equ 10

segment readable executable
entry main

strlen:
  xor rax, rax
.loop:
  cmp byte [rdi + rax], 0
  je .done
  inc rax
  jmp .loop
.done:
  ret 0

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

itoa:
    mov rcx, 10
    xor rdx, rdx
    mov rax, rsi
.loop:
    xor rdx, rdx
    div rcx
    add dl, '0'
    dec rdi
    mov [rdi], dl
    test rax, rax
    jnz .loop
    ret 0

strneq:
  ; strneq(str1, str2, n)
  ; returns 0 if not equal
  xor rax, rax
  mov rcx, rdx
.match_loop:
  mov dl, byte[rsi + rcx - 1]
  cmp byte [rdi + rcx - 1], dl
  jne .no
  loop .match_loop
  mov rax, 1
.no:
  ret 0


parse_msg:
  mov rcx, EACH_ITEM_BUFLEN
.clear:
  mov byte [each_item + rcx - 1], SPACE
  loop .clear
  xor rcx, rcx
.search_lf:
  cmp byte [request + rcx], LF
  je .found
  inc rcx
  jmp .search_lf
.found:
  inc rcx
  sub rcx, msg_req_end_len
  sub rcx, msg_req_front_len

.write:
  mov dl, byte [request + msg_req_front_len + rcx - 1]
  mov byte [each_item + rcx - 1], dl
  loop .write

  ret 0

add_msg_to_list:
  mov rdi, list_items
  add rdi, [item_put_index]
  mov rsi, item_beg
.write_loop:
  mov al, byte [rsi]
  test al, al
  jz .done
  mov byte [rdi], al
  inc rdi
  inc rsi
  jmp .write_loop
.done:
  add [item_put_index], li_len
  ret 0

main:
  invoke_syscall SYS_WRITE, STDOUT, socket_msg, socket_msg_len

  invoke_syscall SYS_SOCKET, AF_INET, SOCK_STREAM, IPROTO_IP
  cmp rax, 0
  jl error
  mov [sockfd], rax

  
  invoke_syscall SYS_WRITE, STDOUT, socket_option_message, socket_option_message_len
  invoke_syscall SYS_SETSOCKOPT, [sockfd], SOL_SOCKET, SO_REUSEADDR, optval, optlen
  cmp rax, 0
  jl error


  invoke_syscall SYS_WRITE, STDOUT, bind_msg, bind_msg_len
  mov [servaddr.sin_family], AF_INET

  ; servaddr.sin_port = htons(PORT)
  mov ax, PORT
  xchg ah, al
  mov [servaddr.sin_port], ax

  mov [servaddr.sin_addr], INADDR_ANY
  invoke_syscall SYS_BIND, [sockfd], servaddr.sin_family, servaddr.size
  cmp rax, 0
  jl error


  invoke_syscall SYS_WRITE, STDOUT, listen_msg, listen_msg_len
  invoke_syscall SYS_LISTEN, [sockfd], MAX_CONN
  cmp rax, 0
  jl error

  invoke_syscall SYS_WRITE, STDOUT, accept_msg, accept_msg_len
  invoke_syscall SYS_ACCEPT, [sockfd], cliaddr.sa_family, cliaddr_len
  cmp rax, 0
  jl error
  mov [connfd], rax

  ;invoke_funcall write_to_buffer, form_filepath, response_buffer, RESPONSE_BUFFER_SIZE

.req_res_loop:
  invoke_syscall SYS_READ, [connfd], request, REQUEST_BUFFER_SIZE
  mov r10, rax
  invoke_syscall SYS_WRITE, STDOUT, request, r10

  ; handle the request here
  invoke_funcall strneq, request, msg_req_front, msg_req_front_len
  test rax, rax
  jz .skip
  invoke_funcall parse_msg
  invoke_funcall add_msg_to_list

.skip:
  invoke_funcall strlen, response_buffer
  lea r10, [content_length_str + CONTENT_LENGTH_STRLEN - 1]
  invoke_funcall itoa, r10, rax
  invoke_funcall strlen, response
  mov r10, rax
  invoke_syscall SYS_WRITE, [connfd], response, r10
  invoke_syscall SYS_WRITE, STDOUT, response, r10
  jmp .req_res_loop
  
  invoke_syscall SYS_WRITE, STDOUT, cli_close_msg, cli_close_msg_len
  invoke_syscall SYS_CLOSE, [connfd]
  invoke_syscall SYS_WRITE, STDOUT, serv_close_msg, serv_close_msg_len
  invoke_syscall SYS_CLOSE, [sockfd]
  invoke_syscall SYS_EXIT, EXIT_SUCCESS

error:
  invoke_syscall SYS_WRITE, STDERR, error_msg, error_msg_len
  invoke_syscall SYS_WRITE, STDOUT, cli_close_msg, cli_close_msg_len
  invoke_syscall SYS_CLOSE, [connfd]
  invoke_syscall SYS_WRITE, STDOUT, serv_close_msg, serv_close_msg_len
  invoke_syscall SYS_CLOSE, [sockfd]
  invoke_syscall SYS_EXIT, EXIT_FAILURE

segment readable writeable
  sockfd dq -1
  connfd dq -1

  servaddr sockaddr_in
  cliaddr sockaddr
  cliaddr_len rq 1

  socket_msg db "INFO: Creating a socket", LF
  socket_msg_len = $ - socket_msg

  optval dq 1
  optlen = $ - optval

  socket_option_message db "INFO: Setting SO_REUSEADDR", LF
  socket_option_message_len = $ - socket_option_message

  bind_msg db "INFO: Binding the socket", LF
  bind_msg_len = $ - bind_msg

  error_msg db "ERROR!", LF
  error_msg_len = $ - error_msg

  serv_close_msg db "INFO: Closing server socket", LF
  serv_close_msg_len = $ - serv_close_msg

  cli_close_msg db "INFO: Closing client socket", LF
  cli_close_msg_len = $ - cli_close_msg

  accept_msg db "INFO: Waiting for connection", LF
  accept_msg_len = $ - accept_msg

  listen_msg db "INFO: Listening to the socket", LF
  listen_msg_len = $ - listen_msg

  response db "HTTP/1.1 200 OK", CR, LF
           db "Content-Type: text/html; charset=utf-8", CR, LF
           db "Connection: keep-alive", CR, LF
           db "Content-Length: "
  content_length_str db CONTENT_LENGTH_STRLEN dup(SPACE)
  response_separator db CR, LF, CR, LF
  ;response_buffer db RESPONSE_BUFFER_SIZE dup(0)

  response_buffer db "<form action=/chat>"
                  db    "<input type=text name=msg>"
                  db    "<input type=submit value=Send>"
                  db "</form>"
  list_begin db "<ul>"
  list_items db ITEM_BUFLEN dup(SPACE)
  list_end db "</ul>", 0
  item_put_index dq 0

  request rb REQUEST_BUFFER_SIZE
  ;form_filepath db "form.html", 0

  item_beg db "<li>"
  each_item db EACH_ITEM_BUFLEN dup(SPACE)
  ;each_item db "Test"
  item_end db "</li>", 0
  li_len = $ - item_beg

  msg_req_front db "GET /chat?msg="
  msg_req_front_len = $ - msg_req_front

  msg_req_end db " HTTP/1.1", CR, LF
  msg_req_end_len = $ - msg_req_end

