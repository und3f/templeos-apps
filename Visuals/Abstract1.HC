#define WIDTH 640
#define HEIGHT 480


U16 color = 0;
U8 DrawIt(CTask*,CDC*dst){
  U16 i, j;
  for(i=0;i<WIDTH;i++){
    for (j=0; j<HEIGHT; j++) {
      F64 off = ATan(Arg(i+ms.pos.y%5, j+ms.pos.x%5))*311.0;
      dst->color = ((color + j + off)/2) % 16;
      GrPlot(dst, i, j);
    }
  }
  return 0;
}


U0 Abstract1(){
  SettingsPush;

  StrCpy(Fs->task_title, "Abstract #1");
  WinMax;
  AutoComplete;
  Fs->draw_it=&DrawIt;

  Bool run = TRUE;
  I64 ch, sc;
  while (run) {
    if (ScanKey(&ch, &sc)) {
      if (ch == CH_ESC || ch == CH_SHIFT_ESC) {
        run = FALSE;
      }
    };

    color+=3;
    Sleep(11);
  }


  SettingsPop;
};


Abstract1;