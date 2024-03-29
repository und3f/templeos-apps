$SP,"<X>",BI=1$




$SP,"<O>",BI=2$




Cd(__DIR__);;
#include "TicTacToe"
#include "TicTacToeAI"
GameState gameState;

#define glblSize 351
#define SPRITE_SIZE33.0
#define FIELD_LINE_THICK (glblSize / 50)
#define STRIKETHROUGHT_LINE_THICK (glblSize / 30)
#define STRIKETHROUGHT_LINE_GAP (STRIKETHROUGHT_LINE_THICK * 2)

U8 *marks[2] = {$IB,"<X>",BI=1$, $IB,"<O>",BI=2$};
Bool controlledByPlayer[NUM_OF_PLAYERS] = {TRUE, FALSE};

class Point
{$ID,2$
I64 x, y;
$ID,-2$};


class Rectangle
{
$ID,2$Point tl, br;
$ID,-2$};

// Scaled sprites
class Sprites
{
  U8**marks;
} sprites;

Bool IsPointInRect(Point *p, Rectangle *rect){$ID,2$
return rect->tl.x <p->x < rect->br.x
	&& rect->tl.y <p->y<rect->br.y;
$ID,-2$}

U0 GetMousePosition(CTask *task, Point *p){$ID,2$
p->x = ms.pos.x - task->pix_left;
p->y = ms.pos.y - task->pix_top;
$ID,-2$}

U8 GetMouseBoardPosition(CTask *task, Rectangle*board){
  I64 w_width = board->br.x - board->tl.x;
  I64 step = (w_width + 1) / BOARD_SIZE;
  Point msPos;
  GetMousePosition(task, &msPos);

  if (!IsPointInRect(&msPos, board)){
    return 0xff;
 }

  return ((msPos.y - board->tl.y) / step)*BOARD_SIZE
	+(msPos.x - board->tl.x) / step;
}

U0 DrawBoard(Rectangle *p, CDC*dc, U8 activeCell = 0xff) {
  I64 size = p->br.x - p->tl.x;
  I64 step = size/BOARD_SIZE;
  dc->dither_probability_u16=65536>>1;


  I64 x, y;
  for (x = 0; x <BOARD_SIZE; x++) {
    for (y = 0; y <BOARD_SIZE; y++){
      Rectangle r;
      r.tl.x = p->tl.x +x *step;
      r.tl.y = p->tl.y +y *step;
      r.br.x = r.tl.x + step;
      r.br.y = r.tl.y +step;

      if (x +y *BOARD_SIZE== activeCell) {
        dc->color = LTGRAY;
        GrRect(dc, r.tl.x +1, r.tl.y +1, step - 1, step - 1);
      }

      I64 cellState = gameState.board[y *BOARD_SIZE +x];
      if (cellState < NUM_OF_PLAYERS){
        dc->color=ROPF_PROBABILITY_DITHER+LTGRAY<<16+TRANSPARENT;
        Sprite3(dc, r.tl.x, r.tl.y, 0, sprites.marks[cellState]);
      }
   
      dc->color = DKGRAY;

      I64 i;
      for (i = -FIELD_LINE_THICK / 2; i <= FIELD_LINE_THICK/2; i++) {
        if (y > 0)
          GrHLine(dc, r.tl.x, r.br.x, r.tl.y + i);

        if (y <BOARD_SIZE - 1)
          GrHLine(dc, r.tl.x, r.br.x, r.br.y +i);
      
        if (x >0)
          GrVLine(dc, r.tl.x + i, r.tl.y, r.br.y);
      
        if (x <BOARD_SIZE - 1)
          GrVLine(dc, r.br.x +i, r.tl.y, r.br.y);      
      }
    }
  }
}

U0 DrawStrokeLine(Rectangle *board, CDC*dc){
  Point start, end;
  I64 cellSize = (board->br.x - board->tl.x) / BOARD_SIZE;

  if (gameState.winLine.xInc != 0
      &&gameState.winLine.yInc != 0) {
    // Diagonal win line
    start.x = board->tl.x;
    end.x = board->br.x;

    if (gameState.winLine.yInc > 0) {
      start.y = board->tl.y;
      end.y = board->br.y;
    } else {
      start.y = board->br.y;
      end.y = board->tl.y;
    }
  } else if (gameState.winLine.xInc != 0) {
    // Horizontal win line
    start.x = board->tl.x - STRIKETHROUGHT_LINE_GAP;
    end.x = board->br.x + STRIKETHROUGHT_LINE_GAP;
    start.y = board->tl.y + cellSize *gameState.winLine.yStart +cellSize >> 1;
    end.y = start.y;

    start.y -= STRIKETHROUGHT_LINE_GAP >>1;
    end.y += STRIKETHROUGHT_LINE_GAP >>1;
  } else if (gameState.winLine.yInc != 0) {
    // Vertical win line
    start.y = board->tl.y - STRIKETHROUGHT_LINE_GAP;
    end.y = board->br.y + STRIKETHROUGHT_LINE_GAP;
    start.x = board->tl.x + cellSize *gameState.winLine.xStart +cellSize >> 1;
    end.x = start.x;

    start.x -= STRIKETHROUGHT_LINE_GAP >>1;
    end.x += STRIKETHROUGHT_LINE_GAP >>1;
  } else {
    "Can't handle stroke path";
    throw;
  }
 
  dc->color=ROPF_PROBABILITY_DITHER+LTGRAY<<16+TRANSPARENT;
  dc->dither_probability_u16=65536>>1;
  dc->thick = STRIKETHROUGHT_LINE_THICK;

  GrLine3(dc, start.x, start.y, 0, end.x, end.y, 0);
}


U0 DrawMouseCursor(CDC *dc, CTask *task) {
  Point msPos;
  GetMousePosition(task, &msPos); 

  dc->color=ROPF_PROBABILITY_DITHER+LTGRAY<<16+TRANSPARENT;  
  Sprite3(dc,
          msPos.x - SPRITE_SIZE/2,
          msPos.y - SPRITE_SIZE/2,
          0, marks[gameState.curPlayer]);
}

// Place board in the middle of the window
Rectangle*placeBoard(CTask *task, I64 size)
{$ID,2$
Rectangle *board = CAlloc(sizeof(Rectangle));

board->tl.x = (task->pix_width - size)>>1;
board->tl.y = (task->pix_height - size)>>1;
board->br.x = board->tl.x +size;
board->br.y = board->tl.y +size;

return board;
$ID,-2$}

U0 DrawIt(CTask *task,CDC *dc)
{$ID,2$
Rectangle *board = placeBoard(task, glblSize);
I64 activeCell = 0xff;

if (controlledByPlayer[gameState.curPlayer]) {
  activeCell = GetMouseBoardPosition(task, board);
  if (gameState.board[activeCell] != 0xff) {
    activeCell = 0xff;
  }

  // Left mouse button Released
  if (activeCell != 0xff
      &&ms_last.lb &&!ms.lb){
    gameMove(&gameState, activeCell);
  }
}

DrawBoard(board, dc, activeCell);

if (controlledByPlayer[gameState.curPlayer]) {
  DrawMouseCursor(dc, task);
}

Free(board);
$ID,-2$}

U0 PrepareGraphics(I64 cellSize){
  I64 r[4][4];
  Mat4x4IdentEqu(r);
  Mat4x4Scale(r, ToF64(cellSize) / SPRITE_SIZE);
  sprites.marks = CAlloc(sizeof(U8*)*NUM_OF_PLAYERS);
  I64 i;
  for (i = 0; i <sizeof(marks)/sizeof(U8*); i++){
    sprites.marks[i] = SpriteTransform(marks[i], r);
  }
}

U0 DestroyGraphics(){
  I64 i;
  for (i = 0; i <sizeof(marks)/sizeof(U8*); i++){
    Free(sprites.marks[i]);
  }
  Free(sprites.marks);
}

U0 CheckKeyboard(){
  I64 ch;
  if (ScanKey(&ch)){
    if (ch == CH_ESC||ch == CH_SHIFT_ESC){
      gameState.state = STATE_ABORT;
    }
  }
}

U0 MakeAIMove() {
  if (controlledByPlayer[gameState.curPlayer])
    return;

  GameStateAI g;
  g.me = gameState.curPlayer;
  MemCpy(&(g.state), &gameState, sizeof(GameState));  
  I64 move = FindMove(&g);

  gameMove(&gameState, move);
}

U8 *playerLabel[NUM_OF_PLAYERS] = {"Cross", "Nought"};

U0 TicTacToeUI(){$ID,2$
StrCpy(Fs->task_title, "Tic-Tac-Toe");
AutoComplete;
SettingsPush;
WinBorder;
DocClear;
WinMax;
PrepareGraphics(glblSize / BOARD_SIZE);
PrepareGame(&gameState);

Fs->draw_it = &DrawIt;

while (gameState.state == STATE_WAIT_PLAYER){
  CheckKeyboard;
  MakeAIMove;
  Yield;
}

Fs->draw_it = NULL;

if (gameState.state != STATE_ABORT){
  CDC*dc = DCAlias;
  DCFill(dc);
  Rectangle *board = placeBoard(Fs, glblSize);
  DrawBoard(board, dc);
  
  if (gameState.state == STATE_WIN){
    DrawStrokeLine(board, dc);
    "%s won!\n", playerLabel[gameState.curPlayer];
  } else {
    "It is a tie!\n";
  }
  PressAKey;

  Free(board);  
  DCDel(dc);
  DCFill;
}

DestroyGraphics;
DestroyGame(&gameState);

SettingsPop;
$ID,-2$}        -         
            
                    2         
            S;�0���
          