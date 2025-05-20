#include "spirit.h"
#include "app.h"

#include <unistd.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/un.h>
#include <errno.h>
#include <time.h>

void spiritClose(struct SpiritConnection conn) {
  close(conn.socket);
}

void rs232SendBytes(struct SpiritConnection conn, const void *str, msg_size_t size);

#define CONN_STR_DELIMITER ':'
struct SpiritConnection spiritConnect(const char *connStr)
{
  struct SpiritConnection spirit;

  char *hostStr = strchr(connStr, CONN_STR_DELIMITER);
  if (hostStr == NULL)
    usage(2, "Invalid port string format.");

  *hostStr = 0;
  hostStr++;
  
  if (strcasecmp(connStr, "tcp") == 0) {
    struct sockaddr_in servAddr;

    char *portStr = strchr(hostStr+1, CONN_STR_DELIMITER);
    if (portStr == NULL)
      usage(2, "Missing connection port.");

    *portStr = 0;
    portStr++;

    char *parsePtr;
    long int port = strtol(portStr, &parsePtr, 10);

    if (*parsePtr != 0)
      usage(2, "Invalid port: %s", portStr + 1);

    spirit.socket = socket(AF_INET, SOCK_STREAM, 0);
    if (spirit.socket < 0) {
      fprintf(stderr, "Socket creation error\n");
      exit(1);
    }

    servAddr.sin_family = AF_INET;
    servAddr.sin_port = htons(port);

    if (inet_pton(AF_INET, hostStr, &servAddr.sin_addr) <= 0)
    {
      fprintf(stderr, "Address resolution failure: %s\n", hostStr);
      exit(EXIT_FAILURE);
    }

    if (connect(spirit.socket, (struct sockaddr *)&servAddr, sizeof(servAddr)) < 0)
    {
      fprintf(stderr, "Connection failed.\n");
      exit(EXIT_FAILURE);
    }
  } else if (strcasecmp(connStr, "unix") == 0) {
    struct sockaddr_un addr;

    spirit.socket = socket(PF_LOCAL, SOCK_STREAM, 0);
    if (spirit.socket < 0) {
      fprintf(stderr, "Socket creation error.\n");
      exit(EXIT_FAILURE);
    }

    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, hostStr, sizeof(addr.sun_path) - 1);

    if (connect(spirit.socket, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
      fprintf(stderr, "Connection to %s failed.\n", addr.sun_path);
      exit(EXIT_FAILURE);
    }

  } else {
    *hostStr = 0;
    usage(2, "Unknown protocol: %s.", connStr);
  }

  return spirit;
}

void spiritSendStr(struct SpiritConnection conn, const char *str)
{
  size_t len = strlen(str);
  if (len > 0xffff) {
    fprintf(stderr, "The data exceed maximum supported size of 65535 bytes.\n");
    exit(1);
  }
  rs232SendPackage(conn, str, len);
}

void rs232SendPackage(struct SpiritConnection conn, const char *str, msg_size_t size)
{
  rs232SendBytes(conn, &size, sizeof(msg_size_t));
  rs232SendBytes(conn, str, size);
}

void rs232SendBytes(struct SpiritConnection conn, const void *str, msg_size_t size)
{
  struct timespec start, end;
  for (int i = 0; i < size; ) {
    clock_gettime(CLOCK_MONOTONIC_RAW, &start);

    int ret = send(conn.socket, str + i, 1, 0);
    if (ret < 0) {
      fprintf(stderr,
          "Error during writing RS232 socket bytes: %s\n", strerror(errno)
      );
      exit(1);
    }
    i += ret;
  }
}


char* rs232RecvPackage(int socket)
{
  unsigned char b;
  msg_size_t size;

  // Get Size
  recv(socket, &b, 1, 0);
  size = b;
  recv(socket, &b, 1, 0);
  size += b << 8;

  // Get Message
  char *buf = malloc(size + 1);
  for (int i = 0; i < size; i++) {
    recv(socket, &b, 1, 0);
    buf[i] = b;
  }
  
  buf[size] = 0;
  
  return buf;
}

void spiritExec(struct SpiritConnection spirit, int argc, char **argv)
{
  const char *op = argv[0];
  if (strcasecmp("user", op) == 0 || strcasecmp("exec", op) == 0) {
    if (argc < 2)
      usage(2, "Missing `%s` operation argument.", op);

    spiritSendStr(spirit, argv[0]);
    spiritSendStr(spirit, argv[1]);
  } else if (strcasecmp("clip-get", op) == 0) {
    spiritSendStr(spirit, "clipGet");
  } else if (strcasecmp("clip-set", op) == 0) {
    if (argc < 2)
      usage(2, "Missing `%s` operation argument.", op);

    spiritSendStr(spirit, "clipSet");
    spiritSendStr(spirit, argv[1]);
  } else {
    for (int i = 0; i < argc; ++i) {
      spiritSendStr(spirit, argv[i]);
    }
  }

  char *r = rs232RecvPackage(spirit.socket);
  printf(r);
  free(r);
}

void spiritWaitSync(struct SpiritConnection spirit) {
  unsigned char b;

  for (int j = 0; j < sizeof(SPIRIT_PROMPT_MESSAGE); j++) {
    for (int i = 0; i < sizeof(SPIRIT_PROMPT_MESSAGE)-1; i++) {
      ssize_t s = recv(spirit.socket, &b, 1, 0);
      if (s < 1) {
        perror("Host sync failure:");
        exit(1);
      }
#ifdef DEBUG
      printf("Sync(%d): expected: %b, recv: %b\n", i, SPIRIT_PROMPT_MESSAGE[i], b);
#endif
      if (SPIRIT_PROMPT_MESSAGE[i] != b) {
        break;
      }

      if (i == sizeof(SPIRIT_PROMPT_MESSAGE)-2) {
#ifdef DEBUG
      printf("Sync success!\n");
#endif
        return;
      }
    }
  }

  printf("Host sync failed\n");
  exit(1);
}
