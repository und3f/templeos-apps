// Temple OS HexViewer
// Copyright (c) 2023, Serhii Zasenko


U8 DigitToAscii(U8 byte) {
  if (byte > 0xf) {
    "Invalid number\n";
    throw;
  }

  if (byte < 0xA) {
    return '0' + byte;
  }

  return 'A' + byte - 0xA;
}


U16 ByteToAscii(U8 byte) {
$ID,2$U16 r = 0;

r.u8[0] = DigitToAscii((byte >> 4) & 0xf);
r.u8[1] = DigitToAscii(byte & 0xf);

return r;
$ID,-2$}


U8 *BytesToString(U8 *bytes, I64 size) {
  U8 *str = MAlloc(size * 2 + 1);
  U16 *strShorts = str;
  
  I64 i;
  for (i = 0; i < size; i++) {
    strShorts[i] = ByteToAscii(bytes[i]);
  }

  str[size*2] = 0;
  return str;

};

U8 *IntToString(U64 value) {
  U64 buf = 0;
  U64 i;
  for (i = 0; i < 4; i++) {
    buf.u8[i] = value.u8[3 - i];
  }

  return BytesToString(&buf, 4);
}

#define HV_SIZE3
U8 *HexViewStr(U8 *content, U64 size, U64 padding = 0){
$ID,2$$UL,0$U8 *str = MAlloc((size +padding)*HV_SIZE);
U32 hex = '00 ';
U64 j;

for (j = 0; j < size; j++) {
$ID,2$hex.i16[0] = ByteToAscii(content[j]);
MemCpy(str + j *HV_SIZE, &hex, 3);
$ID,-2$}

MemSet(str[size *HV_SIZE], ' ', padding *HV_SIZE);
str[(size +padding)*HV_SIZE - 1] = 0;
return str;
$ID,-2$}

U8 *PreviewStr(U8 *content, U64 size){
$ID,2$U64 j;
U64 sOffset = 0;
U8 *str = MAlloc(size * 2 + 1); 
U8 byte;

for (j = 0; j < size; j++) {
$ID,2$byte = content[j];    
if (!(0x20 <= byte && byte <= 0x7E)) {
  byte = '.';
}

str[sOffset++] = byte;
if (byte == $ER$'$$'){
  str[sOffset++] = '$$';
}
$ID,-2$
}
str[sOffset] = 0;

return str;
$ID,-2$}
