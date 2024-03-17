#include "rs232.h"

#include <unistd.h>

void spiritClose(struct SpiritConnection conn) {
  close(conn.socket);
}

