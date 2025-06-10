F64 yoff = 0;

U16 color = 0;
U8 DrawIt(CTask*,CDC*dst){
I64 i, j;
for(i=0;i<640;i++){
for (j=0; j<480; j++) {
F64 s = Sin(yoff) * 13.0+3;
dst->color = (Abs(ATan(Arg(ToF64(i)-71.0, ToF64(j)-211.0))*610.0*s)+yoff*30) % 16;
GrPlot(dst, i, j);
}
}
return 0;
}

U0 Abstract2() {
  SettingsPush;
  WinMax;
  AutoComplete;
  StrCpy(Fs->task_title, "Abstract #2");
  Fs->draw_it=&DrawIt;
  I64 ch, sc;
  Bool run = TRUE;
  while (run) {
    if (ScanKey(&ch, &sc)) {
      if (ch == CH_ESC || ch == CH_SHIFT_ESC) {
        run = FALSE;
      }
    };

    yoff += 11.0/101.0;
    Sleep(6000/21);
  }

  SettingsPop;
}

Abstract2;