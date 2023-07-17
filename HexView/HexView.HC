// Temple OS HexViewer
// Copyright (c) 2023, Serhii Zasenko

#include "HexStr.HC";

U0 HexView(U8 *filename, U64 blockSize = 4)
{// Display binary file content
$ID,2$U64 size, i;
U8 *content = FileRead(filename, &size);

for (i = 0; i < size; i += blockSize) {
$ID,2$U64 blkSize = Min(blockSize, size - i);

U8 *offsetStr = IntToString(i);
U8 *hexViewStr = HexViewStr(content +i, blkSize, blockSize - blkSize);
U8 *previewStr = PreviewStr(content +i, blkSize);

"$FG,7$%s:$FD$ %s $FG,0$%s$FD$\n",
 IntToString(i) +2,
 hexViewStr,
 previewStr;

Free(previewStr);
Free(hexViewStr);
Free(offsetStr);
$ID,-2$}

Free(content);
$ID,-2$}

// Hex offset, colon, and space
#define FIXED_SYMBOLS_COUNT (6 + 1 + 1)

// Hex view, space, and char
#define SYMBOLS_PER_BYTE (2 + 1 + 1)

U8 determineWidth(CTask *task = Fs){
  return (task->win_width - FIXED_SYMBOLS_COUNT) / SYMBOLS_PER_BYTE;  
}

U0 HexViewGui()
{//Asks user for filename and displays HEXcontent
$ID,2$U8*filename = FileMgr(FM_PICK_FILE);
HexView(filename, determineWidth);
Free(filename);
$ID,-2$}

// Example usage
// HexView("C:/Once.HC.Z", 8);
