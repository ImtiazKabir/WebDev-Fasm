#include <asm-generic/socket.h>
#include <stdio.h>
#include <stdlib.h>

#include <netinet/in.h>
#include <stdio.h> 
#include <stdlib.h> 
#include <sys/socket.h>
#include <sys/types.h> 
#include <fcntl.h>

#define PRINT(x) (void)printf(#x " equ %d\n", x);

#define CR '\r'
#define LF '\n'
#define SPACE ' '

#define STDIN 0
#define STDOUT 1
#define STDERR 2

#define IPROTO_IP 0

extern int main(register int const argc, register char const *const *const argv) {
  (void)argc;
  (void)argv;

  PRINT(STDIN);
  PRINT(STDOUT);
  PRINT(STDERR);

  PRINT(CR);
  PRINT(LF);
  PRINT(SPACE);

  PRINT(EXIT_SUCCESS);
  PRINT(EXIT_FAILURE);

  PRINT(AF_INET);
  PRINT(SOCK_STREAM);
  PRINT(IPROTO_IP);

  PRINT(INADDR_ANY);

  PRINT(AT_FDCWD);
  PRINT(O_RDONLY);

  PRINT(SOL_SOCKET);
  PRINT(SO_REUSEADDR);


  return EXIT_SUCCESS;
}


