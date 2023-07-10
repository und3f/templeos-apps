Cd(__DIR__);;
#include "UI"

U0 TestDiagonalULtoBR(){
  PrepareGame;
  U8 i;
  for (i = 0; i <BOARD_SIZE; i++){
    gameState.board[i * BOARD_SIZE +i] = 1;
  }
  if (!evaluateBoard(&gameState)){
    "ULto BR Diagonal not detected\n";
    throw;
  }
  DestroyGame;
}

U0 TestDiagonalBLtoUR(){
  PrepareGame;
  U8 i;
  for (i = 0; i <BOARD_SIZE; i++){
    gameState.board[(BOARD_SIZE - 1 - i) * BOARD_SIZE +i] = 1;
  }
  if (!evaluateBoard(&gameState)){
    "BLto URDiagonal not detected\n";
    throw;
  }
  DestroyGame;
}


U0 TestVertical(U8 x){
  PrepareGame;
  U8 i;
  for (i = 0; i <BOARD_SIZE; i++){
    gameState.board[i * BOARD_SIZE +x] = 1;
  }
  if (!evaluateBoard(&gameState)){
    "Vertical not detected\n";
    throw;
  }
  DestroyGame;
}


U0 TestHorizontal(U8 y){
  PrepareGame;
  U8 i;
  for (i = 0; i <BOARD_SIZE; i++){
    gameState.board[y * BOARD_SIZE +i] = 1;
  }
  if (!evaluateBoard(&gameState)){
    "Horizontal not detected\n";
    throw;
  }
  DestroyGame;
}


TestDiagonalULtoBR;
TestDiagonalBLtoUR;

TestVertical(2);
TestHorizontal(1);

"$FG,2$Test passed successfuly$FG$\n";