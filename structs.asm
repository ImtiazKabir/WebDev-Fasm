  struc sockaddr_in {
    .sin_family rw 1
    .sin_port rw 1
    .sin_addr rd 1
    .sin_zero rq 1
    .size = $ - .sin_family
  }

  struc sockaddr {
    .sa_family rw 1
    .sa_data rb 14
  }
