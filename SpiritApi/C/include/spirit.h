#ifndef SPIRIT_H
#define SPIRIT_H

#include "rs232.h"

struct SpiritConnection {
  int socket;
  
  struct RS232Configuration rs232Rate;
};

typedef unsigned short msg_size_t;

struct SpiritConnection spiritConnect(const char *connStr);

void spiritSendStr(int socket, const char *str);
void spiritSend(int socket, const char *str, msg_size_t size);

void spiritExec(struct SpiritConnection conn, int argc, char **argv);
void spiritClose(struct SpiritConnection conn);

#endif
