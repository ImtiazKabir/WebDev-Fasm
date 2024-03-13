#include <stdio.h>
#include <stdlib.h>

#include <netinet/in.h>
#include <stdio.h> 
#include <stdlib.h> 
#include <sys/socket.h>
#include <sys/types.h> 

#define PRINT(x) (void)printf(#x " equ %d\n", x);

#define CR '\r'
#define LF '\n'

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

  PRINT(EXIT_SUCCESS);
  PRINT(EXIT_FAILURE);

  PRINT(AF_INET);
  PRINT(SOCK_STREAM);
  PRINT(IPROTO_IP);

  PRINT(INADDR_ANY);

  return EXIT_SUCCESS;
}


