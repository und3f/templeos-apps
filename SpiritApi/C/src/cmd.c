#include "app.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

#define STR_INDIR(x) #x
#define STR(x) STR_INDIR(x)

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
      "\t\t\t<tcp:host:port>, example -c tcp:localhost:1234\n"
      "\t\t\t<unix:unix-socket.file>, example -c unix:/tmp/serial.socket\n"
      "  -n\t\t\tDisable sync wait\n"
      "  -b\t\t\tLimit outgoing baud rate, defaults to " STR(DEFAULT_BAUD) "\n"
      "Operations:\n"
      "  user <command>\tSpawn a task and execute the command.\n"
      "  exec <command>\tExecute the command silently and return the result.\n"
      "  clip-get\t\tSet host system's clibpoard to the TempleOS clipboard content.\n"
      "  clip-set\t\tSet TempleOS clipboard content to the host system's clipboard.\n"
      "  ping\t\t\tPing Spirit agent.\n"
      ,
      program_invocation_short_name);

  exit(exitCode);
}

