Cd(__DIR__);;
#include "TicTacToe"

#define SCORE_WIN I8_MAX
#define SCORE_TIE0

class GameStateAI {
  GameState state;
  U8 me;
};

I64 calBoardValue(GameStateAI*s){
  GameState *g = &(s->state);
  if (!findWin(g)) {
    return SCORE_TIE;
  }

  I64 score = SCORE_WIN;

  U64 winner = g->board[g->winLine.yStart *BOARD_SIZE+g->winLine.xStart];
  if (winner != s->me) {
    score = -score;
  }

  return score;  
}

Bool bigger(I64 n1, I64 n2) {
  return n1 >n2;
}

Bool smaller(I64 n1, I64 n2){
  return n1 <n2;
}

U0 copyGameStateAI(GameStateAI *dst, GameStateAI *src) {
  MemCpy(dst, src, sizeof(GameStateAI));
}

#define EMPTY_CELL 0xff
I64 MinMax(GameStateAI *s, U8 depth, Bool maximizingPlayer, U8 *retBestMove = NULL) {
  GameStateAI move;
  I64 value;
  I64 (*comparator)(I64 a, I64 b);

  if (depth <= 0 ||s->state.state == STATE_TIE ||s->state.state == STATE_WIN) {
    return calBoardValue(s);
  }

  if (maximizingPlayer) {
    value = I$ER$64_MIN;
    comparator = &bigger;
  } else {
    value = I64_MAX;
    comparator = &smaller;
  }

  I64 i;
  for (i = 0; i <BOARD_SIZE *BOARD_SIZE; i++){
    if (s->state.board[i] == EMPTY_CELL){
       copyGameStateAI(&move, s);
       gameMove(&(move.state), i);

       I64 curValue = MinMax(&move, depth-1, !maximizingPlayer);

       if (comparator(curValue, value)) {
      	 value = curValue;
         if (retBestMove != NULL)
           *retBestMove = i.u8[0];
       }
    }
  }

  return value;
}

U8 FindMove(GameStateAI *s, U8 depth = BOARD_SIZE *BOARD_SIZE) {
  U8 move = -1;

  MinMax(s, depth, TRUE, &move);  

  return move;    
}
