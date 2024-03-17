#ifndef RSR232_H
#define RSR232_H

#include <stdbool.h>

struct RS232Configuration {
  // RS 232 running speed
  // example 9600
  int  baud;

  // Follow the start bit
  // example 8
  int  dataBits;

  // Either to add or not parity bit
  // example None (false)
  bool parity;

  // Period of time before the next bit can be transmitted
  // example 1
  int  stop_bits;
};

#endif
