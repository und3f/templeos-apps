Cd(__DIR__);;
#include "UI"
#include "TicTacToeAI"

U0 TestDiagonalULtoBR(){
  "Test DiagonalWin ULtoBR\n";

  PrepareGame(&gameState);
  I64 i;
  for (i = 0; i <BOARD_SIZE; i++){
    gameState.board[i * BOARD_SIZE +i] = 1;
  }

  if (!checkEndGame(&gameState)){
    "Win not detected\n";
    throw;
  }

  if (gameState.state != STATE_WIN){
    "Invalid game state %d\n", gameState.state;
    throw;
  }
  DestroyGame(&gameState);
}

U0 TestDiagonalBLtoUR(){
  "Test Diagonal Win BLto UR\n";

  PrepareGame(&gameState);
  I64 i;
  for (i = 0; i <BOARD_SIZE; i++){
    gameState.board[(BOARD_SIZE - 1 - i) * BOARD_SIZE +i] = 1;
  }

  if (!checkEndGame(&gameState)){
    "Win not detected\n";
    throw;
  }

  if (gameState.state != STATE_WIN){
    "Invalid game state %d\n", gameState.state;
    throw;
  }

  DestroyGame(&gameState);
}


U0 TestVertical(U8 x){
  "Test Vertical Win\n";

  PrepareGame(&gameState);
  I64 i;
  for (i = 0; i <BOARD_SIZE; i++){
    gameState.board[i * BOARD_SIZE +x] = 0;
  }

  if (!checkEndGame(&gameState)){
    "Win not detected\n";
    throw;
  }

  if (gameState.state != STATE_WIN){
    "Invalid game state %d\n", gameState.state;
    throw;
  }


  DestroyGame(&gameState);
}


U0 TestHorizontal(U8 y){
  "Test Horizontal win\n";

  PrepareGame(&gameState);
  I64 i;
  for (i = 0; i <BOARD_SIZE; i++){
    gameState.board[y * BOARD_SIZE +i] = 0;
  }

  if (!checkEndGame(&gameState)){
    "Win not detected\n";
    throw;
  }

  if (gameState.state != STATE_WIN){
    "Invalid game state %d\n", gameState.state;
    throw;
  }

  DestroyGame(&gameState);
}


U8 board[BOARD_SIZE*BOARD_SIZE] = {
  1, 0, 1,
  0, 1, 1,
  0, 1, 0
};

U0 TestTie(){
  "Test Tie\n";
  PrepareGame(&gameState);

  MemCpy(gameState.board, board, sizeof(board));
  if (!checkEndGame(&gameState)){
    "End State not detected\n";
    throw;
  }

  if (gameState.state != STATE_TIE){
    "Invalid game state %d\n", gameState.state;
    throw;
  }
  DestroyGame(&gameState);
}

U0 TestGameState(){
  TestDiagonalULtoBR;
  TestDiagonalBLtoUR;

  TestVertical(2);
  TestHorizontal(1);
  
  TestTie;
}

U8 boardWinCross[BOARD_SIZE*BOARD_SIZE] = {
  1, 0, 1,
  0, 1, 1,
  1, 0, 0
};

U0 TestAIScore() {
  "Test AIScore\n";
  
  GameStateAI gsai;
  PrepareGame(&(gsai.state));
  MemCpy(gsai.state.board, boardWinCross, sizeof(boardWinCross));

  gsai.me = 1;
  I64 actual = MinMax(&gsai, 0, TRUE);
  if (actual != SCORE_WIN) {
    "Invalid win score%d\n", actual;
    throw;
  }

  gsai.me = 0;
  actual = MinMax(&gsai, 0, TRUE);
  if (actual != -SCORE_WIN) {
    "Invalid lose score%d\n", actual;
    throw;
  }

  DestroyGame(&(gsai.state));
}

U0 TestAIMove() {
  "Test AIMove\n";

  GameStateAI gsai;
  PrepareGame(&(gsai.state));
  MemCpy(gsai.state.board, boardWinCross, sizeof(boardWinCross));

  gsai.state.board[2 *BOARD_SIZE + 0] = 0xff;
  gsai.state.board[2 *BOARD_SIZE + 1] = 0xff;

  gsai.me = 1;
  gsai.state.curPlayer = 1;
  U8 move = FindMove(&gsai, 2);

  if (move != 2 *BOARD_SIZE + 0) {
    "Invalid move found %d\n", move;
    throw;
  }

  DestroyGame(&(gsai.state));
}


U0 TestAI() {
  TestAIScore;
  TestAIMove;
}

TestGameState;
TestAI;

"$FG,2$Tests passed successfuly$FG$\n";
