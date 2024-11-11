#define INS_DIR "::/Apps/Spirit"

if (!FileFind(INS_DIR,, FUF_JUST_DIRS))
  DirMk(INS_DIR);

Cd(__DIR__);
CopyTree("*", INS_DIR, FALSE);

"\n";
"To autostart Spirit add to the %s:\n",
  "$LK+PU,"~/HomeSys.HC",A="FI:~/HomeSys.HC"$";

"$FG,5$ %s\n %s$FD$\n",
  "#include \"" INS_DIR "/Load\"",
  "StartUpSpirit;";
