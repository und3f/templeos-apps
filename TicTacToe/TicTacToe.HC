#define BOARD_SIZE  3
#define NUM_OF_PLAYERS 2

class GameState
{
  U8 *board;
  U8 curPlayer;
  Bool shouldExit;
} gameState;


class BoardVector {
  U8 xStart, yStart;
  I8 xInc, yInc;
};

Bool checkBoardLine(U8 *board, BoardVector *v){
  U8 i;
  U8 value = board[v->yStart * BOARD_SIZE + v->xStart];
  if (value == 0xff){
    return FALSE;
  }
  
  for (i = 1; i <BOARD_SIZE; i++){
    U8 x = v->xStart +v->xInc *i;
    U8 y = v->yStart +v->yInc * i;

    U8 curValue = board[y *BOARD_SIZE+x];
    if (curValue != value){
      return FALSE;
    }
  }
  return TRUE;
}

Bool isBoardFilled(U8 *board){
  U8 x, y;
  for (y = 0; y <BOARD_SIZE; y++){
    for (x = 0; x <BOARD_SIZE; x++){
      if (board[y *BOARD_SIZE+x] == 0xff){
        return FALSE;
      }
    }
  }
  return TRUE;
}

#define macroCheckBoardLine if (checkBoardLine(g->board, v)){ return v; }
BoardVector *evaluateBoard(GameState *g){
  BoardVector *v = CAlloc(sizeof(BoardVector));

  // Check diagonals
  v->xStart = 0; v->xInc = 1;
  v->yInc = 1; v->yStart = 0;
  macroCheckBoardLine

  v->yStart = BOARD_SIZE - 1;
  v->yInc = -1;
  macroCheckBoardLine

  // Check grid lines
  U8 i;
  for (i = 0; i <BOARD_SIZE; i++){
    // Vertical line
    v->xStart = i; v->xInc = 0;
    v->yStart = 0; v->yInc = 1;
    macroCheckBoardLine

    // Horizontal line
    v->xStart = 0; v->xInc = 1;
    v->yStart = i; v->yInc = 0;
    macroCheckBoardLine

  }

  Free(v);
  return NULL;    
}

U0 gameMove(GameState *g, U8 cell){
  g->board[cell] = g->curPlayer;
  g->curPlayer = (g->curPlayer +1)%NUM_OF_PLAYERS;

  BoardVector *v = evaluateBoard(g);
  if(v){
    Free(v);
    gameState.shouldExit = TRUE;
  }
}


U0 PrepareGame(){
  gameState.shouldExit = FALSE;

  I64 boardLength = sizeof(U8)*BOARD_SIZE*BOARD_SIZE;
  gameState.board = CAlloc(boardLength);
  MemSetU8(gameState.board, -1, boardLength);
  gameState.curPlayer = 0;
}


U0 DestroyGame(){
  Free(gameState.board);
}
