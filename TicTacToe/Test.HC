Cd(__DIR__);;
#include "UI"

U0 TestDiagonalULtoBR(){
  "Test DiagonalWin ULtoBR\n";

  PrepareGame;
  U8 i;
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
  DestroyGame;
}

U0 TestDiagonalBLtoUR(){
  "Test Diagonal Win BLto UR\n";

  PrepareGame;
  U8 i;
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

  DestroyGame;
}


U0 TestVertical(U8 x){
  "Test Vertical Win\n";

  PrepareGame;
  U8 i;
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


  DestroyGame;
}


U0 TestHorizontal(U8 y){
  "Test Horizontal win\n";

  PrepareGame;
  U8 i;
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

  DestroyGame;
}


U8 board[BOARD_SIZE*BOARD_SIZE] = {
  1, 0, 1,
  0, 1, 1,
  0, 1, 0
};

U0 TestTie(){
  "Test Tie\n";
  PrepareGame;

  U64 i;
 
  MemCpy(gameState.board, board, sizeof(board));
  if (!checkEndGame(&gameState)){
    "End State not detected\n";
    throw;
  }

  if (gameState.state != STATE_TIE){
    "Invalid game state %d\n", gameState.state;
    throw;
  }
  DestroyGame;
}

TestDiagonalULtoBR;
TestDiagonalBLtoUR;

TestVertical(2);
TestHorizontal(1);

TestTie;

"$FG,2$Tests passed successfuly$FG$\n";