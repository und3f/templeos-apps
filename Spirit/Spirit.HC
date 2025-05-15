#define COMM_PORT_NUM 1
#define BAUD 115200
#define MAX_LINE 200
#define TICK_TIMEOUT 100
#define WAIT_TIMEOUT 300
#define WAIT_TICKS WAIT_TIMEOUT / TICK_TIMEOUT

#define ST_SPIRIT_CMD "SPIRIT_COMMANDS"

#define PROMPT "Spirit"

U0 (*logger)(U8 fmt, ...) = &Print;

U8 CommGetChar(I64 port, I64 abortTicks = 0, Bool *abort = NULL)
{
  U8 b;
  I64 spentTicks = 0;
  if(abort) {
    *abort = FALSE;
  }

  
  while (!(FifoU8Rem(comm_ports[port].RX_fifo, &b))) {
    Sleep TICK_TIMEOUT;
    if (abortTicks > 0) {
      if (++spentTicks >= abortTicks) {
        *abort = TRUE;
        return 0xFF;
      }
    }
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

U8 *SpiritRecv()
{
  Bool abort;
  U8 *cmd;
  U16 size;

  size.u8[0] = CommGetChar(COMM_PORT_NUM, WAIT_TICKS, &abort);
  if (abort) { return NULL; }
  size.u8[1] = CommGetChar(COMM_PORT_NUM, WAIT_TICKS, &abort);
  if (abort) { return NULL; }
  cmd = MAlloc(size +1);

  I64 i;
  for (i = 0; i < size; i++) {
    cmd[i] = CommGetChar(COMM_PORT_NUM, WAIT_TICKS, &abort);
    if (abort) {
      Free(cmd);
      return NULL;
    }
  }

  cmd[size] = 0;
  return cmd;
}

U0 SpiritSend(U8 *data, U16 size)
{
  CommPutMessage(COMM_PORT_NUM, data, size);
}

U0 SpiritSendStr(U8 *str)
{
  SpiritSend(str, StrLen(str));
}

U8* stdout = NULL;

Bool StubPutKey(I64 ch, I64)
{
  U8 *buf = MStrPrint("%s%c", stdout, ch);
  Free(stdout);
  stdout = buf;

  return TRUE;
}

Bool GrabPutS(U8 *str)
{
  U8 *buf = MStrPrint("%s%s", stdout, str);
  Free(stdout);
  stdout = buf;

  return TRUE;
}


#define CMD_USER_TASK "User"
#define CMD_EXECUTE   "Exec"
#define CMD_CLIP_SET  "ClipSet"
#define CMD_CLIP_GET  "ClipGet"
#define CMD_PING      "Ping"

#define LINE_END "\r\n"
#define RESP_UNKNOWN_CMD "Unknown command" LINE_END
#define RESP_PONG "Pong" LINE_END

U8* SpiritDefaultHandler()
{
  return MStrPrint(RESP_UNKNOWN_CMD);
}


U8* SpiritCmdUserTask()
{
  U8 *in = SpiritRecv();

  User("%s\n", in);

  Free(in);
  return NULL;
}

U8* SpiritCmdExecute()
{
  U8 *in = SpiritRecv();

  stdout = MStrPrint("");
  CKeyDevEntry *kdev = KeyDevAdd(&StubPutKey, &GrabPutS, 0x1000000);

  CCmpCtrl *cc=CmpCtrlNew(in);
  Lex(cc);

  try {
    ExeCmdLine(cc);
  } catch {
    Fs->catch_except = TRUE;
  }

  KeyDevRem(kdev);
  CmpCtrlDel(cc);

  return stdout;
}

U8* SpiritCmdClipSet()
{
  U8 *in = SpiritRecv();

  CDoc *doc=sys_clip_doc;

  ClipDel;
  DocPrint(doc, "%s", in);
  
  Free(in);
  return NULL;
}

U8*SpiritCmdClipGet()
{
  I64 len;
  U8* clip = DocSave(sys_clip_doc, &len);  
  return clip;
}

U8* SpiritCmdPing()
{
  return MStrPrint(RESP_PONG);
}

U8* (*handlers)()[5] = {
  &SpiritCmdUserTask,
  &SpiritCmdExecute,
  &SpiritCmdClipSet,
  &SpiritCmdClipGet,
  &SpiritCmdPing
};

U0 LoadCommands()
{
  DefineLstLoad(
 	ST_SPIRIT_CMD,
	CMD_USER_TASK "\0"
        CMD_EXECUTE "\0"
        CMD_CLIP_SET "\0"
        CMD_CLIP_GET "\0"
        CMD_PING "\0"
  );
}

U0 WaitCommand(){
  U8 *cmd = SpiritRecv();

  if (cmd == NULL) {
    return;
  }

  logger("Spiritremote cmd: %s\n", cmd);
  U8* (*handler)();
  handler = &SpiritDefaultHandler;

  I64 i = DefineMatch(cmd, ST_SPIRIT_CMD, LMF_IGNORE_CASE);
  if (i >= 0)
    handler = handlers[i];

  U8* resp = handler();
  SpiritSendStr(resp);

  Free(resp);
  Free(cmd);
}

U0 InitSpirit(){
  logger("Spirit started on %s%d\n\n", "COM", COMM_PORT_NUM);
  LoadCommands;
  CommInit8n1(COMM_PORT_NUM, BAUD);

  while (TRUE) {
    SpiritSendStr(PROMPT);

    Sleep(3*WAIT_TIMEOUT);
    WaitCommand;
  }
}

U0 StartUpSpirit()
{
  logger = &AdamLog;
  Spawn(
    &InitSpirit,
    ,
    "Spirit guest agent"
  );
}
 
