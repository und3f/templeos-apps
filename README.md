# Temple OS Applications

Applications created during recreational programming sessions.

## Applications

### HexView

HexView'er is a viewer for binary files. Display HEX presentation of content
side-by-side with printable characters.

Example usage:
```HexView("C:/Once.HC.Z", 8);```

### TicTacToe

TicTacToe game with AI. Work in progress. Goals:
- [x] Draw board and game marks
- [x] Implement base UI (able to set mark, interactive board)
- [ ] Detect game end states
- [ ] Implement AI to play against
- [ ] Implement resizable board

You may launch Tic Tac Toe game with command by including the `Run.HC`, e.g. ```#include "Run"```.

![TicTacToe screenshot](/tictactoe.png?raw=true "Game screenshot")

## Useful references
1. [Temple OS](https://templeos.org/)
1. [Tsoding Temple OS repo for
   AOC-2021](https://gitlab.com/tsoding/aoc-2021/-/tree/master). Take a look at
   [sync.sh](https://gitlab.com/tsoding/aoc-2021/-/blob/master/sync.sh) and
   [mount.sh](https://gitlab.com/tsoding/aoc-2021/-/blob/master/mount.sh)
   scripts that transfer files from/to TOS.
