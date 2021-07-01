module GameServer.XServer;

import platform;
import XNetwork;
import GameServer.XServerRules;
import XSnapshot;
import inetwork;					// IServerSlotFactory
import ScriptObjects.Server;
import iconsole;
import GameServer.XServerSlot;			// XServerSlot
import imarkers;
import game;
import ientitysystem;
import XNetworkStats;

extern(C++):

//////////////////////////////////////////////////////////////////////
// Broadcast flags organisation (from low byte to top):
// 32 bits  -  16 bits - Main flags
//              8 bits - Message
//				8 bits - Id of a slot (id 0 is the localhost)

enum BROADCAST_RELIABLE =				0x0000;								// Send a reliable packet
enum BROADCAST_UNRELIABLE =			0x0001;								// Send an unreliable packet
enum BROADCAST_EXCLUDE =					0x0002;								// Exclude the specified slots
enum BROADCAST_MESSAGE =					0x0004;								// Add a message at the begining of the stream
auto BROADCAST_SLOTID(uint id)		{ return cast(BYTE)id<<16;}		// Specify a slot
auto BROADCAST_MSG(uint msg)		{ return cast(BYTE)msg<<24; }		// Specify a message
auto GETBROADCAST_SLOTID(uint data)	{ return cast(BYTE)(data>>16)&0xFF; }
auto GETBROADCAST_MSG(uint data)	{ return cast(BYTE)(data>>24)&0xFF; }

enum MAXPLAYERS_LIMIT =					(32);


//typedef std::multimap<string, ITagPoint *>	RespawnPointMap;
alias ITagPoint *[string]	RespawnPointMap;

//////////////////////////////////////////////////////////////////////
extern(C++, class) struct BannedID
{
public:
	//this() { memset(vBanID, 0, 64); bSize = 0; };
	this(const ubyte *vByteArr, ubyte bArrSize, ref const string szPlayerName) { memset(vBanID, 0, 64); memcpy(vBanID, vByteArr, min(bArrSize, 64)); szName = szPlayerName; bSize = bArrSize; };
	this(ref const BannedID NewBannedID) { szName = NewBannedID.szName; memset(vBanID, 0, 64); memcpy(vBanID, NewBannedID.vBanID, NewBannedID.bSize); bSize = NewBannedID.bSize; };
	~this() {};

	//bool operator ==(const BannedID &arg) const {
	//	if (bSize != arg.bSize)
	//		return 0;
	//	return (memcmp(arg.vBanID, vBanID, bSize) == 0);
	//}
	//bool operator !=(const BannedID &arg) const {
	//	if (bSize != arg.bSize)
	//		return 1;
	//	return (memcmp(arg.vBanID, vBanID, bSize) != 0);
	//}

	ubyte[64]	vBanID;
	ubyte bSize;
	string				szName;
};

//typedef std::vector<BannedID>					BannedIDList;
alias vector!BannedID					BannedIDList;
//typedef BannedIDList::iterator				BannedIDListItor;
alias BannedIDList.iterator				BannedIDListItor;

//typedef std::vector<uint>			BannedIPList;
alias vector!uint			BannedIPList;
//typedef BannedIPList::iterator				BannedIPListItor;
//alias BannedIPList.iterator				BannedIPListItor;


///////////////////////////////////////////////
/*! this class represent a client on the server-side.This mean that 
for every connected client a respective CXServerSlot exists.
*/
class CXServer : IServerSlotFactory, IEntitySystemSink, IServerSecuritySink
{
	// the respawn points
	RespawnPointMap m_vRespawnPoints;

public:
  //typedef std::map<BYTE, CXServerSlot*>		XSlotMap;	
  alias CXServerSlot*[BYTE]		XSlotMap;	

	//! constructor
	this(CXGame *pGame, WORD nPort, const char *szName, bool listen);
	//! destructor
	 ~this();
	//!
	void DrawNetStats(IRenderer.IRenderer *pRenderer);

	//! /return true=server creation was successful, false otherwise
	bool IsOK() { return m_bOK; }

	//! /return pointer to the ServerSlot or 0 if there is no server slot for this id
	CXServerSlot *GetServerSlotByEntityId( const EntityId inId ) const
	{
		//for(XSlotMap::const_iterator itor=m_mapXSlots.begin();itor!=m_mapXSlots.end();++itor)
		foreach(slot;m_mapXSlots)
		{
			//CXServerSlot *slot=itor.second;

			if(slot.GetPlayerId()==inId)
				return itor.second;
		}

		return 0;
	}

	//! /return pointer to the ServerSlot or 0 if there is no server slot for this id
	CXServerSlot *GetServerSlotByIP( uint clientIP ) const;

	// IServerSlotFactory /////////////////////////////////
	/*override*/ bool CreateServerSlot(IServerSlot *pIServerSlot);
	/*override*/ bool GetServerInfoStatus(ref std_string szServerStatus);
	/*override*/ bool GetServerInfoStatus(ref std_string szName, ref std_string szGameType, ref std_string szMap, ref std_string szVersion, bool *pbPassword, int *piPlayers, int *piMaxPlayers);
	/*override*/ bool GetServerInfoRules(ref std_string szServerRules);
	/*override*/ bool GetServerInfoPlayers(std_string[4] *vszStrings, ref int nStrings);
	/*override*/ bool ProcessXMLInfoRequest( const char *sRequest,const char *sRespone,int nResponseMaxLength );

	///////////////////////////////////////////////////////
	// IEntitySystemSink /////////////////////////////////
	void OnSpawnContainer( ref CEntityDesc ed,IEntity *pEntity );
	void OnSpawn(IEntity *ent,  ref CEntityDesc ed);
	void OnRemove(IEntity *ent);
	void OnBind(EntityId id,EntityId child,ubyte param)
	{
		BindEntity(id,child,param);
	}
	void OnUnbind(EntityId id,EntityId child,ubyte param)
	{
		UnbindEntity(id,child,param);
	}
	///////////////////////////////////////////////////////

	void RegisterSlot(CXServerSlot *pSlot);

	//! is called by the XServerSlot itself during destruction
	//! don't call from anywhere else - a call cycle is likely 
	void UnregisterXSlot(DWORD nClientID);

	void ClearSlots();
  int GetNumPlayers();

	void OnClientMsgText(EntityId sender,ref CStream stm);

	void Update();
	void UpdateXServerNetwork();


	// Message broadcast
	void BroadcastUnreliable(XSERVERMSG msg, ref CStream stmIn,int nExclude=-1);
	void BroadcastReliable(XSERVERMSG msg, ref CStream stmIn,bool bSecondaryChannel);

	void BroadcastText(const char *sText, float fLifeTime = DEFAULT_TEXT_LIFETIME);
	void BroadcastCommand(const char *sCmd);
	void BroadcastCommand(const char *sCmd, const ref Vec3 invPos, const ref Vec3 invNormal, const EntityId inId, const ubyte incUserByte );

	void BindEntity(EntityId idParent,EntityId idChild,ubyte cParam);
	void UnbindEntity(EntityId idParent,EntityId idChild,ubyte cParam);
	void SyncVariable(ICVar *p);
	void SyncAIState();
	ref XSlotMap GetSlotsMap(){ return m_mapXSlots; }

	// Infos retriving
	const char *GetName()	{ return sv_name.GetString(); }
	const WORD  GetPort()	{ return m_ServerInfos.nPort; }

	// return the current context
	bool GetContext(ref SXGameContext ctxOut);

	void	AddRespawnPoint(ITagPoint *pPoint);
	void	RemoveRespawnPoint(ITagPoint *pPoint);
	// get a random respawn point
	ITagPoint* GetFirstRespawnPoint();
	ITagPoint* GetNextRespawnPoint();
	ITagPoint* GetPrevRespawnPoint();
  ITagPoint* GetRespawnPoint(char *name);
	ITagPoint* GetRandomRespawnPoint(const char *sFilter=NULL);

	//!
	void AddToTeam(const char *sTeam,int eid);
	//!
	void RemoveFromTeam(int eid);
	//!
	void AddTeam(const char *sTeam);
	//!
	void RemoveTeam(const char *sTeam);
	//!
	void SetTeamScore(const char *sTeam,int score);
	//! request a script hash value from all connected clients (return-packet is then verified)
	//! - used for lua cheat protection
	//! \param Entity entity id, INVALID_WID for globals
	//! \param szPath e.g. "cnt.table1"
	//! \param szKey e.g. "luaFunc"
	void SendRequestScriptHash( EntityId Entity, const char *szPath, const char *szKey );
	//!
	void SetTeamFlags(const char *sTeam,int flags);
	//!
	uint MemStats();
	//!
	uint GetSchedulingDelay();
	//!
	uint GetMaxUpdateRate() const;
	//!
	void ClearRespawnPoints(){m_vRespawnPoints.clear();}
	//!
	CXServerRules* GetRules() { return &m_ServerRules; };
	//!
  void OnMapChanged();
	//!
	bool IsIDBanned(ref const BannedID ID);
	//!
	void BanID(ref const BannedID ID);
	//!
	void UnbanID(ref const BannedID ID);
	//! \return true during destruction (to avoid recursive calls), false otherwise
	bool IsInDestruction() const;

	// interface IServerSecuritySink 

	bool IsIPBanned(const uint dwIP);
	void BanIP(const uint dwIP);
	void UnbanIP(const uint dwIP);
	void CheaterFound( const uint dwIP,int type,const char *sMsg );
	bool GetSlotInfo(  const uint dwIP,ref SSlotInfo info , int nameOnly );

	bool GetServerInfo();

	bool									m_bOK;										//!< true=server creation was successful, false otherwise
	bool									m_bListen;								//!< server accepts non-local connections
	IServer*				m_pIServer;								//!<

	extern interface IXSystem;
	IXSystem*			m_pISystem;								//!< The system interface

	ITimer *				m_pTimer;									//!< timer interface to avoid thousands of GetTimer()
	CXGame *				m_pGame;									//!< the game

	// ID Generator	
	SXServerInfos					m_ServerInfos;						//!< server infos
	SXGameContext					m_GameContext;						//!< the current game context
	CXServerRules					m_ServerRules;						//!< server rules
	
	// snapshot
	CScriptObjectServer		m_ScriptObjectServer;			//!<

	// console variables
	ICVar *								sv_name;									//!< server name (shown in the serverlist)
	ICVar *								sv_ServerType;						//!< "LAN"-no publich, no cdkeychecks, "NET"-no publish, cdkey checks, "UBI", publish, cdkey checks
	ICVar *								sv_password;							//!< "" if not used
	ICVar *								sv_maxplayers;						//!<
	ICVar *								sv_maxrate;								//!< bitspersecond, Internet, maximum for all player, value is for one player
	ICVar *								sv_maxrate_lan;						//!< bitspersecond, LAN, maximum for all player, value is for one player
	ICVar *								sv_netstats;							//!<
	ICVar *								sv_max_scheduling_delay;	//!<
	ICVar *								sv_min_scheduling_delay;	//!<
	
	CXNetworkStats				m_NetStats;								//!< for network statistics (count and size per packet type)

	static const (char *) GetMsgName( XSERVERMSG inValue );

	bool									m_bIsLoadingLevel;				//!< true during loading of the level (used to disable synchronized spawning of entities and to make client waiting during that time)

	BannedIDList					m_vBannedIDList;					//!<
	BannedIPList					m_vBannedIPList;					//!<

	void SaveBanList(bool bSaveID = true, bool bSaveIP = true);
	void LoadBanList(bool bLoadID = true, bool bLoadIP = true);

private: 

	XSlotMap							m_mapXSlots;							//!<
	bool									m_bInDestruction;					//!< only true during destruction (to avoid recursive calls)

	ICVar *								sv_maxupdaterate;					//!< is limiting the updaterate of the clients
};

