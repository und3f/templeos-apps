#define GR_PTRN "B:/Tmp/*.GR"
U0 Record(U8 filename, I64 recordMs){
  DelTree(GR_PTRN);
  DocClear;

  ScrnCast(TRUE);
  Sleep(recordMs);
  ScrnCast(FALSE);

  GR2MV(filename, GR_PTRN);
}