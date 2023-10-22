#include <arpa/inet.h>
#include <ctype.h>
#include <limits.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <stddef.h>
#include <unistd.h>

void usage(int exitCode, const char *errorMsg, ...);

typedef unsigned short msg_size_t;
int spiritConnect(const char *connStr);
void spiritSendStr(int socket, const char *str);
void spiritSend(int socket, const char *str, msg_size_t size);
void spiritExec(int socket, int argc, char **argv);

int main(int argc, char **argv)
{

  char *port = NULL;
  int c;
  while ((c = getopt(argc, argv, "hc:")) != -1) {
    switch (c)
    {
      case 'h':
        usage(0, NULL);
        break;

      case 'c':
        port = optarg;
        break;

      case '?':
        if (optopt == 'c')
          usage(2, "Option -%c requires an argument.", optopt);

        usage(2, "Unknown option -%c.", optopt);
    }
  }

  if (port == NULL)
    usage(2, "Missing port connection information, specify it usign -p option.");

  if (optind >= argc)
    usage(2, "Missing operation.");

  int ssock = spiritConnect(port);
  spiritExec(ssock, argc - optind, argv + optind);
  close(ssock);
}

void usage(int exitCode, const char *errorMsg, ...)
{
  extern char *program_invocation_short_name;

  if (errorMsg != NULL) {
    va_list ap;
    va_start(ap, errorMsg);
    vfprintf(stdout, errorMsg, ap);
    va_end(ap);
    fprintf(stdout, "\n\n");
  }

  fprintf(stdout,
      "Usage: %s [options] operation ...\n"
      "Options:\n"
      "  -h\t\t\tPrint usage message.\n"
      "  -c\t\t\tSet connection information, format:\n"
      "\t\t\t<tcp:host:port>, example -p tcp:localhost:1234\n"
      "\t\t\t<unix:unix-socket.file>, example -p unix:/tmp/serial.socket\n"
      "Operations:\n"
      "  user <command>\tSpawn a task and execute the command.\n"
      "  exec <command>\tExecute the command silently and return the result.\n"
      "  clip-get\t\tSet host system's clibpoard to the TempleOS clipboard content.\n"
      "  clip-set\t\tSet TempleOS clipboard content to the host system's clipboard.\n"
      ,
      program_invocation_short_name);

  exit(exitCode);
}

#define CONN_STR_DELIMITER ':'
int spiritConnect(const char *connStr)
{
  int s;

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

    s = socket(AF_INET, SOCK_STREAM, 0);
    if (s < 0) {
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

    if (connect(s, (struct sockaddr *)&servAddr, sizeof(servAddr)) < 0)
    {
      fprintf(stderr, "Connection failed.\n");
      exit(EXIT_FAILURE);
    }
  } else if (strcasecmp(connStr, "unix") == 0) {
    struct sockaddr_un addr;

    s = socket(PF_LOCAL, SOCK_STREAM, 0);
    if (s < 0) {
      fprintf(stderr, "Socket creation error.\n");
      exit(EXIT_FAILURE);
    }

    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strncpy(addr.sun_path, hostStr, sizeof(addr.sun_path) - 1);

    if (connect(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
      fprintf(stderr, "Connection to %s failed.\n", addr.sun_path);
      exit(EXIT_FAILURE);
    }

  } else {
    *hostStr = 0;
    usage(2, "Unknown protocol: %s.", connStr);
  }

  return s;
}

void spiritSendStr(int socket, const char *str)
{
  size_t len = strlen(str);
  spiritSend(socket, str, len);
}

void spiritSend(int socket, const char *str, msg_size_t size)
{
  send(socket, &size, sizeof(msg_size_t), 0);
  send(socket, str, size, 0);
}

char* spiritRecv(int socket)
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

void spiritExec(int socket, int argc, char **argv)
{
  const char *op = argv[0];
  if (strcasecmp("user", op) == 0 || strcasecmp("exec", op) == 0) {
    if (argc < 2)
      usage(2, "Missing `%s` operation argument.", op);

    spiritSendStr(socket, argv[0]);
    spiritSendStr(socket, argv[1]);
  } else if (strcasecmp("clip-get", op) == 0) {
    spiritSendStr(socket, "clipGet");
  } else if (strcasecmp("clip-set", op) == 0) {
    if (argc < 2)
      usage(2, "Missing `%s` operation argument.", op);

    spiritSendStr(socket, "clipSet");
    spiritSendStr(socket, argv[1]);
  } else {
    usage(EXIT_FAILURE, "Unknown operation `%s`.", op);
  }

  char *r = spiritRecv(socket);
  printf(r);
  free(r);
}
