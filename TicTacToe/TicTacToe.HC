#define BOARD_SIZE 3
#define NUM_OF_PLAYERS 2

#define STATE_WAIT_PLAYER 0
#define STATE_TIE 1
#define STATE_WIN 2
#define STATE_ABORT 3

class BoardVector {
  U8 xStart, yStart;
  I8 xInc, yInc;
};

class GameState
{
  U8 state;
  U8 curPlayer;

  U8 board[BOARD_SIZE*BOARD_SIZE];
  BoardVector winLine;
};

Bool checkBoardLine(U8 *board, BoardVector *v){
  I64 i;
  I64 value = board[v->yStart * BOARD_SIZE + v->xStart];
  if (value == 0xff){
    return FALSE;
  }
  
  for (i = 1; i <BOARD_SIZE; i++){
    I64 x = v->xStart +v->xInc *i;
    I64 y = v->yStart +v->yInc * i;

    I64 curValue = board[y *BOARD_SIZE+x];
    if (curValue != value){
      return FALSE;
    }
  }
  return TRUE;
}

Bool isBoardFilled(GameState *g){
  I64 i;
  for (i = 0; i <BOARD_SIZE *BOARD_SIZE; i++){
    if (g->board[i] >= NUM_OF_PLAYERS){
      return FALSE;
    }
  }
  return TRUE;
}

#define macroCheckBoardLine if (checkBoardLine(g->board, v)){ return TRUE; }
Bool findWin(GameState *g){
  BoardVector *v = &(g->winLine);

  // Check diagonals
  v->xStart = 0; v->xInc = 1;
  v->yInc = 1; v->yStart = 0;
  macroCheckBoardLine

  v->yStart = BOARD_SIZE - 1;
  v->yInc = -1;
  macroCheckBoardLine

  // Check grid lines
  I64 i;
  for (i = 0; i <BOARD_SIZE; i++){
    // Vertical line
    v->xStart = i; v->xInc = 0;
    v->yStart = 0; v->yInc = 1;
    macroCheckBoardLine

    // Horizontal line
    v->xStart = 0; v->xInc = 1;
    v->yStart = i; v->yInc = 0;
    macroCheckBoardLine
  }

  return FALSE;
}

Bool checkEndGame(GameState *g){
  if (findWin(g)){
    U64 winner = g->board[g->winLine.yStart *BOARD_SIZE+g->winLine.xStart];
   
    g->state = STATE_WIN;
    g->curPlayer = winner;    
    return TRUE;
  }

  if (isBoardFilled(g)) {
    g->state = STATE_TIE;
    g->curPlayer = 0xff;
    return TRUE;
  }

  return FALSE;
}

U0 gameMove(GameState *g, U8 cell){
  g->board[cell] = g->curPlayer;
  g->curPlayer = (g->curPlayer +1)%NUM_OF_PLAYERS;

  checkEndGame(g);
}


U0 PrepareGame(GameState *gameState){
  I64 boardLength = BOARD_SIZE*BOARD_SIZE;
  MemSetU8(gameState->board, -1, boardLength);

  gameState->curPlayer = 0;
  gameState->state = STATE_WAIT_PLAYER;
}

U0 DestroyGame(GameState *gameState){
}
