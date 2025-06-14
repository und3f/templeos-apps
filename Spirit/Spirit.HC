#define MAX_MSG_SIZE 0xFFFF

#define COMM_PORT_NUM 1
#define BAUD 115200

#define TICK_TIMEOUT 5
#define WAIT_TIMEOUT 500
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
    Sleep(TICK_TIMEOUT);
    if (abortTicks > 0) {
      if (++spentTicks >= abortTicks) {
        *abort = TRUE;
        return 0xFF;
      }
    }
  }

  return b;
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

U0 SpiritSend(U8 *data, U64 size)
{
  CommPutMessage(COMM_PORT_NUM, data, size);
}

U0 SpiritSendStr(U8 *str)
{
  U64 len = 0;
  if (str != NULL) {
    len = StrLen(str);
  }
  SpiritSend(str, len);
}

U8* stdout = NULL;
I32 stdoutInd = 0;

Bool StubPutKey(I64 ch, I64)
{
  if (stdoutInd >= MAX_MSG_SIZE) {
    return FALSE;
  }

  stdout[stdoutInd] = ch;
  stdoutInd++;

  return TRUE;
}

Bool GrabPutS(U8 *str)
{
  if (stdoutInd >= MAX_MSG_SIZE) {
    return FALSE;
  }

  I64 len = StrLen(str);
  len = MinI64(stdoutInd +len, MAX_MSG_SIZE);

  MemCpy(stdout+stdoutInd, str, len-stdoutInd);
  stdoutInd = len;

  return TRUE;
}


#define CMD_USER_TASK "User"
#define CMD_EXECUTE   "Exec"
#define CMD_CLIP_SET  "ClipSet"
#define CMD_CLIP_GET  "ClipGet"
#define CMD_PING      "Ping"
#define CMD_EXECUTE_RAW "ExecRaw"

#define LINE_END "\r\n"
#define RESP_UNKNOWN_CMD "Unknown command" LINE_END
#define RESP_PONG "Pong" LINE_END
#define RESP_RECV_ERR  "Failure during command transmission" LINE_END

U8* SpiritDefaultHandler()
{
  return MStrPrint(RESP_UNKNOWN_CMD);
}

U8 *StrPrintAnswer(CTask *task) {
  if (task->answer_type&~1!=RT_I0) {
    if (task->answer_type==RT_F64)
      return MStrPrint("%8.6fs ansf=%15.7g\n",task->answer_time,task->answer);
    else
      return MStrPrint("%8.6fs ans=0x%08X=%d\n",task->answer_time,task->answer,task->answer);
  } else {
    return MStrPrint("%8.6fs\n",task->answer_time);
  }


  return NULL;
}

U8* SpiritCmdUserTask()
{
  U8 *in = SpiritRecv();
  if (in == NULL) {
    return StrNew(RESP_RECV_ERR);
  }

  CTask *task = User;

  XTalkWait(task, "%s;\n", in);
  TaskExe(task,Fs,"",1<<JOBf_WAKE_MASTER|1<<JOBf_FOCUS_MASTER);
  DeathWait(task);
  
  U8 *out = StrPrintAnswer(task);

  Free(in);
  return out;
}

U8* SpiritCmdExecute()
{
  U8 *in = SpiritRecv();
  if (in == NULL) {
    return StrNew(RESP_RECV_ERR);
  }

  stdout = MAlloc(MAX_MSG_SIZE+1);
  stdoutInd = 0;

  CDoc *old = Fs->put_doc;
  Fs->put_doc = DocNew;

  CKeyDevEntry *kdev = KeyDevAdd(&StubPutKey, &GrabPutS, 0xA000000);

  CCmpCtrl *cc=CmpCtrlNew(in);
  try {
    Lex(cc);

    ExeCmdLine(cc);
  } catch {
    Fs->catch_except = TRUE;
  }

  KeyDevRem(kdev);
  CmpCtrlDel(cc);
  // CmpCtrlDel also free `in`

  U8 *docContent = DocSave(Fs->put_doc);
  GrabPutS(docContent);  
  
  Free(docContent);  
  DocDel(Fs->put_doc);

  Fs->put_doc = old;

  stdout[stdoutInd] = 0;
  return stdout;
}

U8* SpiritCmdExecuteRaw()
{
  U8 *in = SpiritRecv();
  if (in == NULL) {
    return StrNew(RESP_RECV_ERR);
  }

  CTask *task = User;

  XTalkWait(task, "%s;\n", in);
  TaskExe(task,Fs,"",1<<JOBf_WAKE_MASTER|1<<JOBf_FOCUS_MASTER);
  
  U8 *out = StrPrintAnswer(task);

  Free(in);
  return out;
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

U8* (*handlers)()[6] = {
  &SpiritCmdUserTask,
  &SpiritCmdExecute,
  &SpiritCmdClipSet,
  &SpiritCmdClipGet,
  &SpiritCmdPing,
  &SpiritCmdExecuteRaw
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
        CMD_EXECUTE_RAW "\0"
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
 
