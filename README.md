# Temple OS Applications

Applications created during recreational programming sessions.

## Supplemental ISO

All applications are available in [Supplemental.ISO.C](Supplemental.ISO.C), you
may use it as CD-ROM image for TOS VM. To mount in Temple OS execute next
commands:

```
MountIDEAuto;
Drv('T');
Dir;
```

## Applications

### HexView

HexView'er is a viewer for binary files. Display HEX presentation of content
side-by-side with printable characters.

Run with:
```#include "HexView/Run";```

Programmatic usage:
```
#include "HexView/Load"
HexView("C:/Once.HC.Z", 8);
```

### Tic-Tac-Toe

Tic-Tac-Toe game with AI. Work in progress. Goals:
- [x] Draw board and game marks
- [x] Implement base UI (able to set mark, interactive board)
- [x] Detect game end states
- [ ] Implement AI opponent
- [ ] Add variations to mark sprites (rotate, shift, etc.)

- [ ] ? Implement Tic-Tac-Toe variation

You may launch Tic-Tac-Toe game by including the Run.HC:
```#include "Run";```

![TicTacToe screenshot](/tictactoe.png?raw=true "Game screenshot")

## Useful references
1. [Temple OS](https://templeos.org/)
1. [Tsoding Temple OS repo for
   AOC-2021](https://gitlab.com/tsoding/aoc-2021/-/tree/master). Take a look at
   [sync.sh](https://gitlab.com/tsoding/aoc-2021/-/blob/master/sync.sh) and
   [mount.sh](https://gitlab.com/tsoding/aoc-2021/-/blob/master/mount.sh)
   scripts that transfer files from/to TOS.
