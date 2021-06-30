module ScriptObjects.Server;

import iscriptsystem;
import Script._ScriptableEx;

import GameServer.XServer;
import game;
import common;

//////////////////////////////////////////////////////////////////////
class CScriptObjectServer :
_ScriptableEx!CScriptObjectServer
{
public:

	this();
	~this();

	bool Create(IScriptSystem *pScriptSystem,IXSystem *pCSystem,CXGame *pGame);
	void SetServer(CXServer *pServer){m_pServer=pServer;}

	int Unban(IFunctionHandler *pH);
	int ListBans(IFunctionHandler *pH);
	int GetServerSlotBySSId(IFunctionHandler *pH);
	int GetServerSlotByEntityId(IFunctionHandler *pH);
	int GetServerSlotMap(IFunctionHandler *pH);
	int GetNumPlayers(IFunctionHandler *pH);
	int BroadcastText(IFunctionHandler *pH);
	int SpawnEntity(IFunctionHandler *pH);
	int RemoveEntity(IFunctionHandler *pH);

	int AddTeam(IFunctionHandler *pH);
	int RemoveTeam(IFunctionHandler *pH);
	int AddToTeam(IFunctionHandler *pH);
	int RemoveFromTeam(IFunctionHandler *pH);
	int SetTeamScoreByEntity(IFunctionHandler *pH);
	int SetTeamScore(IFunctionHandler *pH);
	int GetTeamMemberCount(IFunctionHandler *pH);
	int SetTeamFlags(IFunctionHandler *pH);

	int GetRespawnPoint(IFunctionHandler *pH);
	int GetFirstRespawnPoint(IFunctionHandler *pH);
	int GetNextRespawnPoint(IFunctionHandler *pH);
	int GetPrevRespawnPoint(IFunctionHandler *pH);
	int GetRandomRespawnPoint(IFunctionHandler *pH);
	int GetName(IFunctionHandler *pH);
	int DebugTest(IFunctionHandler *pH);

	int BroadcastCommand(IFunctionHandler *pH);
  static void InitializeTemplate(IScriptSystem *pSS);

private:

	static void MakeTagScriptObject(ITagPoint* pInTagPoint, ref _SmartScriptObject rOut);

	CXServer *m_pServer;
	IScriptObject *m_pSlotMap;
	IXSystem *m_pXSystem;
	CXGame *m_pGame;
};
