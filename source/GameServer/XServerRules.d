module GameServer.XServerRules;

//////////////////////////////////////////////////////////////////////
enum TEAM_HAS_NOT_CHANGED = -1;
enum SPECTATORS_TEAM = 0;

import ScriptObjects.ServerSlot;
import game;
import WeaponClass;
import XNetwork;

//////////////////////////////////////////////////////////////////////
class CXServerRules
{
public:
	this();
	~this();

	//!	Load the rules set by the console variables
	bool Init(CXGame* pGame, IConsole* pConsole,
			IScriptSystem* pScriptSystem, ILog* pLog = null);
	void Update();
	//! Unload the rules
	void ShutDown();

	void CallVote(ref CScriptObjectServerSlot sss, char * command, char * arg1);
	void Vote(ref CScriptObjectServerSlot sss, int vote);
	void Kill(ref CScriptObjectServerSlot sss);
	void MapChanged();
	//! \return 0 if the class is not initialized (e.g. during loading)
	const char* GetGameType();
	IScriptObject* GetScriptObject()
	{
		return m_pGameRulesObj;
	};

	void PrintEnterGameMessage(const char* playername, int color);
	void OnHitObject(ref const SWeaponHit  hit);
	void OnHitPlayer(ref const SWeaponHit  hit);

	//! When new player connected.
	int OnClientConnect(IScriptObject* pSS, int nRequestedClassID);
	//! When new player connected.
	void OnClientDisconnect(IScriptObject* pSS);
	void OnClientRequestRespawn(IScriptObject* pSS, const EntityClassId nRequestedClassID);
	//! When player respawn after death.
	void OnPlayerRespawn(IEntity* player);
	//! When player try to change team
	int OnClientMsgJoinTeamRequest(CXServerSlot* pSS, BYTE nTeamId, const char* sClass);
	int OnClientCmd(CXServerSlot* pSS, const char* sCmd);
	//! when a spectator whant to switch spectating mode
	void OnSpectatorSwitchModeRequest(IEntity* spec);
	void OnClientMsgText(EntityId sender, ref TextMessage tm);
	void SetGameStuffScript(string sName);
	string GetGameStuffScript();

	void SendEntityTextMessage(EntityId sender, ref TextMessage tm);
	void SendTeamTextMessage(EntityId sender, ref TextMessage tm);
	void SendWorldTextMessage(EntityId sender, ref TextMessage tm);

	//! After the map and its entities have been loaded
	void OnAfterLoad();

public:
	// console variable used to set the rules
	IConsole* m_pConsole;

private:

	//! Get rules script.
	CXGame* m_pGame;
	IScriptSystem* m_pScriptSystem;
	IScriptObject* m_pGameRulesObj;
	bool m_init;
	string m_sGameStuffScript;

	//! load the GameRules for the given gametype
	//! /param inszGameType gametype e.g. "Default" or "TDM", must not be 0
	//! /return true=success, false=failed
	bool ChangeGameRules(const char* inszGameType);
};
