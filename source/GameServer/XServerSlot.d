module GameServer.XServerSlot;

import XEntityProcessingCmd;
import ScriptObjects.ServerSlot;

extern (C++):
enum MAX_ENT_DIST_FACTOR = 100;
import XNetworkStats; // CXNetworkStats
import XNetwork;
import GameServer.XServer;
import inetwork;

class CXSnapshot
{

}

//////////////////////////////////////////////////////////////////////
struct SlotNetStats
{
	uint ping; //!<
	uint packetslost; //!<
	uint upacketslost; //!<
	string name; //!<
	uint maxsnapshotbitsize; //!<
	uint lastsnapshotbitsize; //!<
};

//////////////////////////////////////////////////////////////////////
/*! this class represent a client on the server-side.This means that 
for every connected client a respective CXServerSlot exists.
@see IServerSlot
@see IServerSlotSink
@see IServer
*/
class CXServerSlot : IServerSlotSink
{
public:
	//! constructor
	this(CXServer pParent, IServerSlot pSlot);
	//! destructor
	~this();
	//!
	void GetNetStats(ref SlotNetStats ss);
	//!
	void Disconnect(const char* sCause);

	//!< from the serverslot internals
	void GetBandwidthStats(ref SServerSlotBandwidthStats _out);
	//!< from the serverslot internals
	void ResetBandwidthStats();

	// interface IServerSlotSink 

	void OnXServerSlotConnect(const BYTE* pbAuthorizationID, uint uiAuthorizationSize);
	void OnXServerSlotDisconnect(const char* szCause);
	void OnContextReady(ref CStream stm);
	void OnData(ref CStream stm);
	void OnXPlayerAuthorization(bool bAllow, const char* szError,
			const BYTE* pGlobalID, uint uiGlobalIDSize);

	//! this function is only used to optimize the network code
	void OnSpawnEntity(ref CEntityDesc ed, IEntity* pEntity, bool bSend);
	//! this function is only used to optimize the network code
	void OnRemoveEntity(IEntity* pEntity);

	//!
	void BanByID();
	//!
	void BanByIP();

	// attributes 

	//! \return slot id
	BYTE GetID();
	//!
	bool IsXServerSlotGarbage();
	//!
	bool IsLocalHost();
	//! \return pin in milliseconds
	uint GetPing();
	//! \param idPlayer
	void SetPlayerID(EntityId idPlayer);
	//! \return 
	EntityId GetPlayerId() const;

	//! \return client requested name
	const char* GetName();
	//! \return client requested player model
	const char* GetModel();
	//! \return client requested player color in non team base multiplayer mods (string from the client)
	const char* GetColor();

	//! \param state
	//! \param time absolute time since the state started on the server (not used in SP)
	void SetGameState(int state, int time = 0);
	//!
	CXServer* GetServer();
	//!
	void SendReliable(ref CStream stm, bool bSecondaryChannel);
	//!
	void SendUnreliable(ref CStream stm);
	//! \return size in bits of the whole packet
	size_t SendReliableMsg(XSERVERMSG msg, ref CStream stm,
			bool bSecondaryChannel, const char* inszName = "Unknown");
	//! \return size in bits of the whole packet
	size_t SendUnreliableMsg(XSERVERMSG msg, ref CStream stm,
			const char* inszName = "Unknown", const bool bWithSize = false);
	//!
	void SendText(const char* sText, float fLifeTime = DEFAULT_TEXT_LIFETIME);
	//!
	void SendCommand(const char* sCmd);
	//!
	void SendCommand(const char* sCmd, const ref Vec3 invPos,
			const ref Vec3 invNormal, const EntityId inId, const ubyte incUserByte);
	//!
	bool IsReady();
	//!
	bool CanSpawn()
	{
		return m_bCanSpawn;
	}
	//!
	float GetPlayerWriteStepBack()
	{
		if (m_iLastCommandServerPhysTime != 0)
		{
			//FIXME:
			return float.init; //return (m_pPhysicalWorld.GetiPhysicsTime()-m_iLastCommandServerPhysTime)*m_pPhysicalWorld.GetPhysVars().timeGranularity;
		}
		return 0.0f;
	}
	//!
	uint GetCommandClientPhysTime()
	{
		//FiXME:
		//return m_iLastCommandClientPhysTime ? m_iLastCommandClientPhysTime : m_pPhysicalWorld.GetiPhysicsTime();
		return uint.init;
	}
	//!
	uint GetClientWorldPhysTime()
	{
		//FIXME:
		//return m_pPhysicalWorld.GetiPhysicsTime()+m_iClientWorldPhysTimeDelta;
		return uint.init;
	}
	//!
	void SendTextMessage(ref TextMessage tm, bool bSecondaryChannel);
	//!
	IScriptObject GetScriptObject()
	{
		//FIXME:
		//return m_ScriptObjectServerSlot.GetScriptObject();
		return IScriptObject.init;
	}
	//! update the server slot stuff
	void Update(bool send_snap, bool send_events);

	//! context setup
	void ContextSetup();
	//!
	void CleanupSnapshot()
	{
		//FIXME:
		//m_Snapshot.Cleanup();
	}
	//!
	bool IsContextReady();

	//return if this is the first snapshot(so you have to send the full snapshot for all entities)

	void ResetPlayTime()
	{
		//FIXME:
		//m_fPlayTime = m_pTimer.GetCurrTime();
	}
	//!
	float GetPlayTime()
	{
		//FIXME:
		//return m_pTimer.GetCurrTime() - m_fPlayTime;
		return float.init;
	}
	//! \return amount of bytes allocated by this instance and it's childs 
	uint MemStats();
	//!
	int GetClientTimeDelta()
	{
		return m_iClientWorldPhysTimeDelta;
	}
	//!
	void MarkEntityOffSync(EntityId id);
	//!
	bool IsEntityOffSync(EntityId id);
	//!
	bool IsClientSideEntity(IEntity* pEnt);
	//!
	IServerSlot* GetIServerSlot()
	{
		return m_pISSlot;
	}
	//! \return true=channel is now occupied you can send your data through the lazy channel, false=channel is not ready yet
	bool OccupyLazyChannel();
	//! 
	bool ShouldSendOverLazyChannel();
	//!
	bool GetServerLazyChannelState();

	static void ConvertToValidPlayerName(const char* szName, char* outName, size_t sizeOfOutName);

	CXEntityProcessingCmd m_PlayerProcessingCmd; //!<
	bool m_bForceScoreBoard; //!<
	float m_fLastScoreBoardTime; //!<
	CXSnapshot m_Snapshot; //!< snapshot

private:

	bool ParseIncomingStream(ref CStream stm);
	void OnClientMsgPlayerProcessingCmd(ref CStream stm);
	void OnClientMsgJoinTeamRequest(ref CStream stm);
	void OnClientMsgCallVote(ref CStream stm);
	void OnClientMsgVote(ref CStream stm);
	void OnClientMsgKill(ref CStream stm);
	void OnClientMsgName(ref CStream stm);
	void OnClientMsgCmd(ref CStream stm);
	void OnClientMsgRate(ref CStream stm);
	void OnClientOffSyncEntityList(ref CStream stm);
	void OnClientReturnScriptHash(ref CStream stm);
	void OnClientMsgAIState(ref CStream stm);
	void SendScoreBoard();
	void ValidateName();
	void ClientString(const char* s);
	void FinishOnContextReady();

	string m_strPlayerName; //!< client requested player name
	string m_strPlayerModel; //!< client requested player model
	string m_strClientColor; //!< client requested player color in non team base multiplayer mods

	EntityId m_wPlayerId; //!<
	float m_fPlayTime; //!< absolute time when ResetPlayTime() was called
	bool m_bXServerSlotGarbage; //!<
	bool m_bLocalHost; //!<
	bool m_bCanSpawn; //!<
	bool m_bWaitingForContextReady; //!<
	bool m_bContextIsReady; //!< Gametype on client is syncronized (ClientStuff is available)
	IServerSlot* m_pISSlot; //!< might be 0
	CXServer* m_pParent; //!<

	CScriptObjectServerSlot m_ScriptObjectServerSlot;
	ILog* m_pLog;
	ITimer* m_pTimer;
	IPhysicalWorld* m_pPhysicalWorld;
	int m_nState;

	EntityClassId m_ClassId; //!<
	int m_ClientRequestedClassId; //!< do we need this?
	bool m_bReady; //!<

	CEntityDesc m_ed;

	int m_iLastCommandServerPhysTime;
	int m_iLastCommandClientPhysTime;
	int m_iClientWorldPhysTimeDelta;
	int m_nDesyncFrames;
	int[EntityId] m_mapOffSyncEnts;
	int m_iLastEventSent;

	float m_fLastClientStringTime;
	string m_sClientString; //!< XSERVERMSG_CLIENTSTRING
	EntityId m_idClientVehicle;
	float m_fClientVehicleSimTime;

	BYTE[64] m_vGlobalID;
	ubyte m_bGlobalIDSize;
	BYTE[64] m_vAuthID;
	ubyte m_bAuthIDSize;
	bool m_bServerLazyChannelState; //!< used for sending ordered reliable data over the unreliable connection (slow but never stalls, used for scoreboard)
	bool m_bClientLazyChannelState; //!< used for sending ordered reliable data over the unreliable connection (slow but never stalls, used for scoreboard)
	uint32 m_dwUpdatesSinceLastLazySend; //!< update cylces we wait for response (for resending), 0=it wasn't set at all

	//friend class CScriptObjectServerSlot;
	//friend class CXSnapshot;
};
