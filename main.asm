format ELF64 executable 3

include 'macros.asm'
include 'sysid.asm'
include 'constants.asm'
include 'structs.asm'

MAX_CONN equ 5
PORT equ 8021

segment readable executable
entry main

main:
  invoke_syscall SYS_WRITE, STDOUT, socket_msg, socket_msg_len

  invoke_syscall SYS_SOCKET, AF_INET, SOCK_STREAM, IPROTO_IP
  cmp rax, 0
  jl error
  mov [sockfd], rax

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

  invoke_syscall SYS_WRITE, [connfd], response, response_len

  invoke_syscall SYS_WRITE, STDOUT, ok_msg, ok_msg_len
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

  bind_msg db "INFO: Binding the socket", LF
  bind_msg_len = $ - bind_msg

  error_msg db "INFO: ERROR!", LF
  error_msg_len = $ - error_msg

  ok_msg db "INFO: OK!", LF
  ok_msg_len = $ - ok_msg

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
           db "Connection: close", CR, LF
           db CR, LF
           db "<h1> Hello world!</h1>", CR, LF
  response_len = $ - response

