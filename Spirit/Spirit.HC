#define COMM_PORT_NUM 1
#define MAX_LINE 200

#define ST_SPIRIT_CMD "SPIRIT_COMMANDS"

U8 CommGetChar(I64 port)
{
  U8 b;

  
  while (!(FifoU8Rem(comm_ports[port].RX_fifo, &b))) {
    Sleep 10;
  }

  return b;
}

U0 CommReadLine(I64 port, U8 *buf)
{
  I64 len, c;
  
  for (len = 0; len < MAX_LINE - 1; len++) {
    c = CommGetChar(port);
    buf[len] = c;
    if (c == '\r' ||c == '\n') break;
  }
  buf[len] = 0;
}

CFifoI64* stdout;

Bool StubPutKey(I64, I64)
{
  return TRUE;
}

Bool GrabPutS(U8 *st)
{
  FifoI64Ins(stdout, StrNew(st));

  return TRUE;
}

U0 (*logger)(U8 fmt, ...) = &Print;

#define CMD_USER_TASK "User"
#define CMD_EXECUTE   "Exec"
#define CMD_CLIP_SET  "ClipSet"
#define CMD_CLIP_GET  "ClipGet"

#define RESP_UNKNOWN_CMD "Unknown command\r\n"
U8* SpiritDefaultHandler()
{
  return MStrPrint(RESP_UNKNOWN_CMD);
}

U8* SpiritCmdUserTask()
{
  U8 in[MAX_LINE];
  CommReadLine(COMM_PORT_NUM, in);
  User("%s\n", in);

  return NULL;
}

U8* SpiritCmdExecute()
{
  U8 in[MAX_LINE];
  CommReadLine(COMM_PORT_NUM, in);

  stdout = FifoI64New(256);
  CKeyDevEntry *kdev = KeyDevAdd(&StubPutKey, &GrabPutS, 0x1000000);

  CCmpCtrl *cc=CmpCtrlNew(in,$LK,"CCF_DONT_FREE_BUF",A="MN:CCF_DONT_FREE_BUF"$);
  Lex(cc);
  ExeCmdLine(cc);

  KeyDevRem(kdev);

  U8 *out = MStrPrint("");

  U8 *nextStr;
  
  while (FifoI64Rem(stdout, &nextStr))
  {
    U8 *tmp = MStrPrint("%s%s", out, nextStr);
    Free(out);
    out = tmp;
  }
  

  FifoI64Del(stdout);

  return out;
}

U8* SpiritCmdClipSet()
{
  U8 in[MAX_LINE];
  CommReadLine(COMM_PORT_NUM, in);

  CDoc *doc=sys_clip_doc;

  ClipDel;
  DocPrint(doc, "%s", in);

  return NULL;
}

U8*SpiritCmdClipGet()
{
  I64 len;
  U8* clip = DocSave(sys_clip_doc, &len);  
  return clip;
}

U8*SpiritCmdClipGet()
{
  I64 len;
  U8* clip = DocSave(sys_clip_doc, &len);  
  return clip;
}

U8* (*handlers)()[4] = {
  &SpiritCmdUserTask,
  &SpiritCmdExecute,
  &SpiritCmdClipSet,
  &SpiritCmdClipGet
};

U0 LoadCommands()
{
  DefineLstLoad(
 	ST_SPIRIT_CMD,
	CMD_USER_TASK "\0"
        CMD_EXECUTE "\0"
        CMD_CLIP_SET "\0"
        CMD_CLIP_GET "\0");
}

U0 WaitCommand(){
  U8 cmd[MAX_LINE];
  CommReadLine(COMM_PORT_NUM, cmd);

  logger("Spirit:%s\n", cmd);
  U8* (*handler)();
  handler = &SpiritDefaultHandler;

  I64 i = DefineMatch(cmd, ST_SPIRIT_CMD, LMF_IGNORE_CASE);
  if (i >= 0)
    handler = handlers[i];

  U8* resp = handler();
  if (resp != NULL)
    CommPrint(COMM_PORT_NUM, resp);

  Free(resp);
}

U0 InitSpirit(){
  LoadCommands;
  CommInit8n1(COMM_PORT_NUM, 115200);
  CommPrint(COMM_PORT_NUM, "Spirit v0.2\r\n");
 
  while (TRUE) {
    WaitCommand;
  }
}

U0 StartUpSpirit()
{
  logger = &AdamLog;
  CTask *guestOS = Spawn(
    &InitSpirit,
    ,
    "Spirit guest agent"
  );
}