#include <unistd.h>
#include <stdbool.h>
#include <stdlib.h>

#include "spirit.h"
#include "app.h"

int main(int argc, char **argv)
{

  char *port = NULL;
  int c;
  bool sync = true;
  int baud = DEFAULT_BAUD;
  while ((c = getopt(argc, argv, "hc:nb:")) != -1) {
    switch (c)
    {
      case 'h':
        usage(0, NULL);
        break;

      case 'c':
        port = optarg;
        break;

      case 'n':
        sync = false;
        break;

      case 'b':
        baud = atoi(optarg);
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

  struct SpiritConnection ssock = spiritConnect(port, baud);
  if (sync) {
    spiritWaitSync(ssock);
  }
  spiritExec(ssock, argc - optind, argv + optind);
  spiritClose(ssock);
}
