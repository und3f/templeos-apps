#include "spirit.h"
#include "app.h"

#include <unistd.h>

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

  struct SpiritConnection ssock = spiritConnect(port);
  spiritWaitSync(ssock);
  spiritExec(ssock, argc - optind, argv + optind);
  spiritClose(ssock);
}
