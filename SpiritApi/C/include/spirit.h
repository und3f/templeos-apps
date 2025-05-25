#ifndef SPIRIT_H
#define SPIRIT_H

#define SPIRIT_PROMPT "Spirit"
#define SPIRIT_PROMPT_MESSAGE "\6\0" SPIRIT_PROMPT

struct SpiritConnection {
  int socket;
  int baud;
};

typedef unsigned short msg_size_t;

struct SpiritConnection spiritConnect(const char *connStr, int baudControl);

void spiritExec(struct SpiritConnection conn, int argc, char **argv);
void spiritClose(struct SpiritConnection conn);

void rs232SendPackage(struct SpiritConnection conn, const char *str, msg_size_t size);
char* spiritRecvString(struct SpiritConnection conn);
void spiritWaitSync(struct SpiritConnection spirit);

#endif
