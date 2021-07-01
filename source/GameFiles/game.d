module game;

import igame;
import iscriptsystem;
import EntityClassRegistry;
import Localization.StringTableMgr;
import XSurfaceMgr;
import XDemoMgr;
import XArea;


import WeaponSystemEx;
import WeaponClass;
import XVehicleSystem;

import UI.IngameDialog;

import GameFiles.ScriptTimerMgr;



public import inetwork;
public import ixgame;
public import ixmldom;
public import platform;

public import GameMods;
public import ScriptDebugger;
public import UI.Hud;

public import common;
public import physinterface;
public import GameServer.XServerRules;
public import XEntityProcessingCmd;
public import ScriptObjects.Stream;

import UI.System;

import Math;
import Renderer.Cry_Color4;
import GameClient.XClient;

//////////////////////////////////////////////////////////////////////////////////////////////
// Version of the game
immutable GAME_MAIN_VERSION						= 1;						//!<\; [0..255]
immutable GAME_SUB_VERSION						= 4;						//!< [0..255] patch version number, shown in\; menu
immutable GAME_PATCH_VERSION					= 0;						//!<\; [0..256*256[
immutable SERVERINFO_FORMAT_VERSION		= 88; 				  //!< [0..255] bump if server info format changes (old version won't show up any\; more)
immutable NETWORK_FORMAT_VERSION			= 5;						//!< [0..2^32] bump if netcode stream format\; changes

immutable SAVEVERSION									= 23;					// [Petar] Do not bump this value anymore it shows the release version of the savegame - it will always be\; supported
immutable PATCH1_SAVEVERSION					= 24;					// [Kirill] Do not bump this value anymore it shows the Patch 1 version of the savegame - it will always be\; supported
immutable PATCH2_SAVEVERSION					= 36;					//!< bump this if the savegame format changes and we are still working on patch\; 2

immutable GAME_VERSION_SUFIX					= "F";			  //!< A - alpha, B - beta, RC - release candidate, F -\; final


int       MAKE_GAME_VERSION(int m, int s, int p)		{ return (((m)<<24)|((s)<<16)|(p)); }
immutable GAME_VERSION								= MAKE_GAME_VERSION(GAME_MAIN_VERSION,GAME_SUB_VERSION,GAME_PATCH_VERSION);

immutable ENTITYTYPE_PLAYER				    = 0x00000001;
immutable ENTITYTYPE_WAYPOINT			    = 0x00000002;
immutable ENTITYTYPE_OWNTEAM			    = 0x00000004;

immutable SAVEMAGIC = "CRYLEVELSAVE";

// game states
enum  CGS_INPROGRESS=0; 
enum  GS_COUNTDOWN=1; 
enum  GS_PREWAR=2; 
enum  GS_INTERMISSION=3;

import XNetwork;

enum EventType { EVENT_MOVECMD=0,EVENT_EXPLOSION=1,EVENT_IMPULSE=2,EVENT_VEHDAMAGE=3 };
enum ActionType { ACTIONTYPE_MOVEMENT = 1, ACTIONTYPE_COMBAT, ACTIONTYPE_GAME, ACTIONTYPE_MULTIPLAYER, ACTIONTYPE_DEBUG};

abstract class BaseEvent
{
	int nRefCount;
	EventType GetType() = 0;
	void Write(ref CStream stm,int iPhysicalTime, IBitStream *pBitStream );
	void Read(ref CStream stm,ref int iPhysicalTime, IBitStream *pBitStream );
	void Execute(CXGame *pGame);
};

struct GameEvent
{
	this(ref const GameEvent src)
	{
		iPhysTime = src.iPhysTime;
		idx = src.idx;
		(pEvent = src.pEvent).nRefCount++;
	}
	~this()
	{
		if (--pEvent.nRefCount<=0)
			delete pEvent;
	}
	//FIXME:
	//ref GameEvent operator=(ref const GameEvent src)
	//{
	//	iPhysTime = src.iPhysTime;
	//	idx = src.idx;
	//	(pEvent = src.pEvent).nRefCount++;
	//	return *this;
	//}
	int iPhysTime;
	int idx;
	BaseEvent *pEvent;
};

import XEntityProcessingCmd;

struct EventPlayerCmd //: BaseEvent
{
	EntityId				idEntity;
	CXEntityProcessingCmd	cmd;

	EventType GetType() { return EVENT_MOVECMD; }
	void Write(ref CStream stm, int iPhysicalTime, IBitStream *pBitStream );
	void Read(ref CStream stm, ref int iPhysicalTime, IBitStream *pBitStream );
	void Execute(CXGame *pGame);
};

struct EventExplosion// : BaseEvent
{
	Vec3						pos;
	float						damage;
	float						rmin,rmax,radius;
	float 					impulsivePressure;
	int 						nTerrainDecalId;
	int32 					nShooterSSID;											//!< clientID - neeeded for MP score calculations, -1 if unknown
	uint16 					iImpactForceMul;
	uint16 					iImpactForceMulFinal;
	uint16 					iImpactForceMulFinalTorso;
	EntityId 				idShooter;
	EntityId 				idWeapon;
	uint8 					shakeFactor;								//!< 0..1
	uint8 					deafnessRadius;							//!< 0..20
	uint8 					deafnessTime;								//!< *0.25 to get float
	uint8 					rminOcc;										//!< 0..1
	uint8 					nOccRes;
	uint8 					nGrow;
	uint8 					terrainDefSize;							//!< 0..20

	EventType GetType() { return EVENT_EXPLOSION; }
	void Write(ref CStream stm, int iPhysicalTime, IBitStream *pBitStream );
	void Read(ref CStream stm, ref int iPhysicalTime, IBitStream *pBitStream );
	void Execute(CXGame *pGame);
};





//////////////////////////////////////////////////////////////////////
// Pointer to Global ISystem.
private ISystem gISystem = null;
public extern (C++)
{
  public ISystem GetISystem()
  {
    return gISystem;
  }

  //////////////////////////////////////////////////////////////////////
  class DebugOutputPrinter : IOutputPrintSink
  {
    void Print(const char* inszText)
    {
        DLL_TRACE(inszText);
    }
  };

  class CXGame : IXGame
  {

    CScriptDebugSink m_pScriptDebugger;
    DebugOutputPrinter m_Printer;
    float test_f = 35;

	// interface IGame ----------------------------------------------------------

	bool Init(ISystem *pSystem,bool bDedicatedSrv,bool bInEditor,const char *szGameMod);
	bool InitClassRegistry();
	bool Update();
	bool Run(ref bool bRelaunch);
	void Release() { delete this; }
	const char *IsMODLoaded();
	IGameMods* GetModsInterface();

	void AllowQuicksave(bool bAllow) {m_bAllowQuicksave = bAllow;};
	bool IsQuicksaveAllowed() {return m_bAllowQuicksave;}

	//! \return 0 before was initialized, otherwise point to the GameMods
	CGameMods	*GetModsList() { return(m_pGameMods); }

	bool IsSoundPotentiallyHearable(ref Vec3d SoundPos, float fClipRadius);
	void SetTerrainSurface(const char *sMaterial,int nSurfaceID){m_XSurfaceMgr.SetTerrainSurface(sMaterial,nSurfaceID);}
	//! load level for the editor
	bool LoadLevelForEditor(const char *pszLevelDirectory,const char *pszMissionName);
	bool GetLevelMissions( const char *szLevelDir, string[] missions );

	void UpdateDuringLoading();

	IScriptObject *GetScriptObject();

	// load level for the game
	void LoadLevelCS(bool reconnect, const char *szMapName, const char *szMissionName, bool listen);

	IEntity *GetMyPlayer();

	// tagpoint management functions
	ITagPoint *CreateTagPoint( ref const string name, ref const Vec3 pos, ref const Vec3 angles);
	ITagPoint *GetTagPoint(const string name);
	void RemoveTagPoint(ITagPoint *pPoint);
	bool RenameTagPoint(const string oldname, const string newname);

	//real internal load level
	//return true if is loading a saved singleplayer level(this should disappear)
	bool IsLoadingLevelFromFile(){	return m_bIsLoadingLevelFromFile;	}
	ISystem *GetSystem() { return m_pSystem; }
	IScriptSystem *GetScriptSystem(){return m_pScriptSystem;}
	IEntityClassRegistry *GetClassRegistry() { return &m_EntityClassRegistry;}

	CUIHud*	GetHud() const { return cast(CUIHud*)m_pUIHud; }
	CXServerRules* GetRules() const;
	IActionMapManager *GetActionMapManager(){ return m_pIActionMapManager; }
	extern interface IXSystem;
	IXSystem *GetXSystem();
	bool IsOK() { return m_bOK; }

	void OnSetVar(ICVar *pVar);
	// Servers management
	bool	StartupServer(bool listen, const char *szName = NULL);
	void	ShutdownServer();

	// Client management
	bool StartupClient();
	bool StartupLocalClient();
	void ShutdownClient();
	void MarkClientForDestruct();

	bool IsSynchronizing() { return m_bSynchronizing; }
	void AdvanceReceivedEntities(int iPhysicalWorldTime);
	bool HasScheduledEvents();
	void ScheduleEvent(int iPhysTime, BaseEvent *pEvent);
	void ScheduleEvent(IEntity *pEnt, ref CXEntityProcessingCmd cmd);

	//! \param shooterSSID clientID 0..255 or -1 if unknown
	void ScheduleEvent(int iPhysTime, ref const Vec3 pos,float fDamage,float rmin,float rmax,float radius,float fImpulsivePressure,
					   float fShakeFactor,float fDeafnessRadius,float fDeafnessTime,float fImpactForceMul,
					   float fImpactForceMulFinal,float fImpactForceMulFinalTorso,
					   float rMinOcc,int nOccRes,int nOccGrow, IEntity *pShooter, int shooterSSID, IEntity *pWeapon,
					   float fTerrainDefSize,int nTerrainDecalId);
	void ScheduleEvent(int iPhysTime, IEntity *pVehicle,float fDamage);
	void ScheduleEvent(int iPhysTime, IPhysicalEntity *pPhysEnt,pe_action_impulse *pai);
	void ExecuteScheduledEvents();
	void WriteScheduledEvents(ref CStream stm, ref int iLastEventWritten, int iTimeDelta=0);
	void ReadScheduledEvents(ref CStream stm);
	bool UseFixedStep() { return m_iFixedStep2TimeGran!=0; }
	int GetiFixedStep() { return m_iFixedStep2TimeGran; }
	float GetFixedStep() { return g_MP_fixed_timestep.GetFVal(); }
	int QuantizeTime(float fTime)
	{
		return cast(int)(fTime*m_frTimeGran+0.5f*sgn(fTime));
	}
	int SnapTime(float fTime,float fOffset=0.5f)
	{
		return m_iFixedStep2TimeGran ?
			cast(int)(fTime*m_frFixedStep+0.5f*sgn(fTime))*m_iFixedStep2TimeGran : cast(int)(fTime*m_frTimeGran+0.5f*sgn(fTime));
	}
	int SnapTime(int iTime,float fOffset=0.5f)
	{
		return m_iFixedStep2TimeGran ?
			cast(int)(iTime*m_fTimeGran2FixedStep+0.5f*sgn(iTime))*m_iFixedStep2TimeGran : iTime;
	}

	//! \param shooterSSID clientID 0..255 or -1 if unknown
	void CreateExplosion(ref const Vec3 pos,float fDamage,float rmin,float rmax,float radius,float fImpulsivePressure,
						 float fShakeFactor,float fDeafnessRadius,float fDeafnessTime,
						 float fImpactForceMul,float fImpactForceMulFinal,float fImpactForceMulFinalTorso,
						 float rMinOcc,int nOccRes,int nOccGrow, IEntity *pShooter, int shooterSSID, IEntity *pWeapon,
						 float fTerrainDefSize,int nTerrainDecalId, bool bScheduled=false);

	//! IPhysicsStreamer (physics-on-demand) callback functions
	int CreatePhysicalEntity(void *pForeignData,int iForeignData,int iForeignFlags);
	int DestroyPhysicalEntity(IPhysicalEntity *pent);
	const char *GetForeignName(void *pForeignData,int iForeignData,int iForeignFlags);

	//////////////////////////////////////////////////////////////////////////
	//! physical events callback functions
	void OnBBoxOverlap(IPhysicalEntity *pEntity, void *pForeignData,int iForeignData,
					   IPhysicalEntity *pCollider, void *pColliderForeignData,int iColliderForeignData);
	void OnStateChange(IPhysicalEntity *pEntity, void *pForeignData,int iForeignData, int iOldSimClass,int iNewSimClass);
	void OnCollision(IPhysicalEntity *pEntity, void *pForeignData,int iForeignData, coll_history_item *pCollision);
	int OnImpulse(IPhysicalEntity *pEntity, void *pForeignData,int iForeignData, pe_action_impulse *action);
	void OnPostStep(IPhysicalEntity *pEntity, void *pForeignData,int iForeignData, float fTimeInterval);

	IPhysicsStreamer *GetPhysicsStreamer() { return this; }
	IPhysicsEventClient *GetPhysicsEventClient() { return this; }

	bool ConstrainToSandbox(IEntity *pEntity);

	// Ingame Dialogs
	CIngameDialogMgr *GetIngameDialogManager() { return m_pIngameDialogMgr; }

	void BindAction(const char *sAction,const char *sKeys,const char *sActionMap=NULL, int iKeyPos = -1);
	void BindActionMultipleMaps(const char *sAction,const char *sKeys, int iKeyPos = -1);
	bool CheckForAction(const char *sAction);
	void ClearAction(const char *sAction);
	// Stuffs...
	void	ProcessPMessages(const char *szMsg);

	// Return the version of the game
	const char *GetVersion();


	//! functions to know if the current terminal is a server and/or a client
	//@{
	bool	IsServer()	{	return m_pServer!=NULL;	}
	bool	IsClient();
	bool  IsMultiplayer();   // can be used for disabling cheats, or disabling features which cannot be synchronised over a network game
	bool	IsDevModeEnable();
	//@}
	//! save/laod game

	bool SaveToStream(ref CStream stm, Vec3 *pos, Vec3 *angles,string sFilename);
	bool LoadFromStream(ref CStream stm, bool isdemo);
	bool LoadFromStream_RELEASEVERSION(ref CStream str, bool isdemo, ref CScriptObjectStream scriptStream);
	bool LoadFromStream_PATCH_1(ref CStream str, bool isdemo, ref CScriptObjectStream scriptStream);

	void Save(string sFileName, Vec3 *pos, Vec3 *angles,bool bFirstCheckpoint=false );
	bool Load(string sFileName);
	void LoadConfiguration(const string sSystemCfg,const string sGameCfg);
	void SaveConfiguration( const char *sSystemCfg,const char *sGameCfg,const char *sProfile);
	void RemoveConfiguration(ref string sSystemCfg,ref string sGameCfg,const char *sProfile);

	void LoadLatest();

	CXServer* GetServer() { return m_pServer; }

	CXClient* GetClient() { return m_pClient; }

	void SetViewAngles(ref const Vec3 angles);

	CWeaponSystemEx *GetWeaponSystemEx(){ return m_pWeaponSystemEx; }
	CUISystem *GetUISystem(){ return m_pUISystem; };
	void ReloadWeaponScripts();
	CVehicleSystem *GetVehicleSystem(){ return m_pVehicleSystem; }
	CPlayerSystem *GetPlayerSystem(){ return m_pPlayerSystem; }

	IClient *CreateClient(IClientSink *pSink,bool bLocal=false)
	{
		return m_pNetwork.CreateClient(pSink,bLocal);
	}
	IServer *CreateServer(IServerSlotFactory *pSink,WORD nPort, bool listen){return m_pNetwork.CreateServer(pSink,nPort,listen);}

	bool GetPreviewMapPosition(ref float x, ref float y, float mapx, float mapy, float sizex, float sizey, float zoom, float center_x, float center_y, bool bRound);
	int GetSector(int nSectorsX, int nSectorsY, float x, float y);
	void DrawMapPreview(float mapx, float mapy, float sizex, float sizey, float zoom, float center_x, float center_y, float alpha, PreviewMapParams *pParams=null);
	void DrawRadar(float x, float y, float w, float h, float fRange, INT_PTR *pRadarTextures, _SmartScriptObject *pEntities, char *pRadarObjective);

	// Demo recording stuff ------------------------------------------------

	bool StartRecording(const char *sFileName);
	void StopRecording();
	bool AddDemoChunk(ref CStream stm);
	void StartDemoPlay(const char *sFileName);
	void StopDemoPlay();
	void PlaybackChunk();

	// Weapons -------------------------------------------------------------

	INameIterator * GetAvailableWeaponNames();
	INameIterator * GetAvailableProjectileNames();
	bool AddWeapon(const char *pszName);
	bool RemoveWeapon(const char *pszName);
	void RemoveAllWeapons();
	bool AddEquipPack(XDOM.IXMLDOMNode *pPack);
	bool AddEquipPack(const char *pszXML);
	void SetPlayerEquipPackName(const char *pszPackName);
	void RestoreWeaponPacks();

	// Network -------------------------------------------------------------

	//!
	void RefreshServerList();
	//!
	void OnServerFound(ref CIPAddress ip, ref const string szServerInfoString, int ping);
	//!
	void OnNETServerFound(ref const CIPAddress ip, ref const string szServerInfoString, int ping);
	//!
	void OnNETServerTimeout(ref const CIPAddress ip);
	//! \return might be 0
	INETServerSnooper *GetNETSnooper() { return m_pNETServerSnooper; };
	//! \return might be 0
	IRConSystem *GetIRConSystem() { return m_pRConSystem; };

	void SendMessage(const char *str){
		m_qMessages.push(str);
	}
	bool ExecuteScript(const char *sPath,bool bForceReload=false);

	void EnableUIOverlay(bool bEnable, bool bExclusiveInput);
	bool IsUIOverlay();

	bool	IsInMenu() { return m_bMenuOverlay; };		//!< checks if we are in menu or not
	void	GotoMenu(bool bTriggerOnSwitch = false);	//!< arranges the message queue so that the game goes to the menu
	void	GotoGame(bool bTriggerOnSwitch = false);	//!< arranges the message queue so that the game goes out of the menu
	void	MenuOn();																	//!< enables menu instantly (no message)
	void	MenuOff();																//!< disables menu instantly (no message)
	void	DeleteMessage(const char *szMessage);			//!< deletes all occurrences of a specified message from the message queue

	const char *GetLevelName() { return m_currentLevel.c_str(); }

	void  ResetInputMap();
	string GetLevelsFolder() const;

protected:
	void SetConfigToActionMap(const char *pszActionName, ...);
	//bool LoadMaterials(string sFolder);
	void	InitInputMap();
	void	InitConsoleCommands();
	void	InitConsoleVars();
	bool	IsInPause(IProcess *pProcess);
	//everything related to vehicle will be in another file
	//Marco's NOTE: should be the same for other cvars, code and includes,
	void	InitVehicleCvars();

	//set the common key bindings for the specified action map.
	//it reduces code redundancy and makes things more clear.
	void SetCommonKeyBindings(IActionMap *pActionMap);
	void OnCollectUserData(INT_PTR nValue,int nCookie);		//AMD Port

public:
	void ClearTagPoints();
	void SetCurrentUI(CUIHud *pUI);

	//FIXME:
	//vector2f GetSubtitleSize(ref const string szMessage, float sizex, float sizey, ref const string szFontName = "default", ref const string szFontEffect = "default");
	void WriteSubtitle(ref const string szMessage, float x, float y, float sizex, float sizey, ref const color4f cColor, ref const string szFontName = "default", ref const string szFontEffect = "default");

	bool								m_bIsLoadingLevelFromFile;		//!<
	IActionMapManager*					m_pIActionMapManager;			//!<
	bool								m_bDedicatedServer;				//!<
	bool								m_bOK;							//!<
	bool								m_bUpdateRet;					//!<
	bool								m_bRelaunch;					//!<
	bool								m_bMovieSystemPaused;

	ISystem	*							m_pSystem;						//!< The system interface

	ILog *								m_pLog;							//!<
	I3DEngine	*						m_p3DEngine;					//!< The 3D engine interface
	CXServer *							m_pServer;						//!< The server of this computer
	CXClient *							m_pClient;						//!< The client of this computer


	int m_nDEBUG_TIMING;
	float m_fDEBUG_STARTTIMER;

	//!	The dummy client of this computer, required to get the list of servers if
	//! theres not a real client actually connected and playing

	IServerSnooper	*					m_pServerSnooper;				//!< used for LAN Multiplayer, to remove control servers
	INETServerSnooper	*				m_pNETServerSnooper;			//!< used for Internet Multiplayer, to remove control servers
	IRConSystem *						m_pRConSystem;					//!< used for Multiplayer, to remote control servers
	string								m_szLastAddress;
	bool								m_bLastDoLateSwitch;
	bool								m_bLastCDAuthentication;

	CUIHud *							m_pUIHud;						//!< Hud
	CUIHud *							m_pCurrentUI;					//!< for the current ui

	string								m_currentLevel;					//!< Name of current level.
	string								m_currentMission;				//!< Name of current mission.
	string								m_currentLevelFolder;			//!< Folder of the current level.


	// console variables -----------------------------------------------------------

version (_INTERNET_SIMULATOR) {
	ICVar* g_internet_simulator_minping;
	ICVar* g_internet_simulator_maxping;
	ICVar* g_internet_simulator_packetloss;
}
	ICVar* g_MP_fixed_timestep;
	ICVar* g_maxfps;
	ICVar* cl_ThirdPersonRange;
	ICVar* cl_ThirdPersonRangeBoat;
	ICVar* cl_ThirdPersonAngle;

	ICVar* cl_ThirdPersonOffs;
	ICVar* cl_ThirdPersonOffsAngHor;
	ICVar* cl_ThirdPersonOffsAngVert;

	ICVar* cl_scope_flare;
	ICVar* cl_lazy_weapon;
	ICVar* cl_use_joypad;
	ICVar* cl_weapon_fx;
	ICVar* cl_projectile_light;
	ICVar* cl_weapon_light;
	ICVar* w_underwaterbubbles;

	ICVar* cl_ViewFace;
	ICVar* cl_display_hud;
	ICVar* cl_motiontracker;
	ICVar* cl_msg_notification;
	ICVar* cl_hud_name;
	ICVar* cl_hud_pickup_icons;
	ICVar* ai_num_of_bots;

	ICVar* p_name;
	ICVar* p_color;
	ICVar* p_model;
	ICVar* mp_model;
	ICVar* p_always_run;
	ICVar* g_language;
	ICVar* g_playerprofile;
	ICVar* g_serverprofile;
	ICVar* g_Render;
	ICVar* g_GC_Frequence;
	ICVar* g_GameType;
	ICVar* g_LeftHanded;
	ICVar* g_Gore;
	ICVar* g_InstallerVersion;


	ICVar* p_speed_run;
	ICVar* p_sprint_scale;
	ICVar* p_sprint_decoy;
	ICVar* p_sprint_restore_run;	// restore rate when normal run
	ICVar* p_sprint_restore_idle;	// restore rate whwen not running
	ICVar* p_speed_walk;
	ICVar* p_speed_crouch;
	ICVar* p_speed_prone;
	ICVar* p_jump_force;
	ICVar* p_jump_walk_time;
	ICVar* p_jump_run_time;
	ICVar* p_jump_walk_d;
	ICVar* p_jump_walk_h;
	ICVar* p_jump_run_d;
	ICVar* p_jump_run_h;
	ICVar* p_gravity_modifier;
	//[KIRILL]	this console variable makes lean global - it has to be player's per-instance property
	// to fix bug in MP with leaning
	//	ICVar* p_lean;			// lean angle
	ICVar* p_lean_offset;
	ICVar* p_bob_pitch;
	ICVar* p_bob_roll;
	ICVar* p_bob_length;
	ICVar* p_bob_weapon;
	ICVar* p_bob_fcoeff;
	ICVar* p_waterbob_pitch;
	ICVar* p_waterbob_pitchspeed;
	ICVar* p_waterbob_roll;
	ICVar* p_waterbob_rollspeed;
	ICVar* p_waterbob_mindepth;
	ICVar* p_weapon_switch;
	ICVar* p_deathtime;
	ICVar* p_restorehalfhealth;

	ICVar* p_ai_runspeedmult;			//combat stance
	ICVar* p_ai_crouchspeedmult;
	ICVar* p_ai_pronespeedmult;
	ICVar* p_ai_rrunspeedmult;		//relaxed stance
	ICVar* p_ai_rwalkspeedmult;
	ICVar* p_ai_xrunspeedmult;		//stealth stance
	ICVar* p_ai_xwalkspeedmult;

	ICVar* p_lightrange;
	ICVar* p_lightfrustum;

	// player animation control parametrs
	ICVar* pa_leg_velmoving;
	ICVar* pa_leg_velidle;
	ICVar* pa_leg_idletime;
	ICVar* pa_leg_limitaim;
	ICVar* pa_leg_limitidle;
	ICVar* pa_blend0;
	ICVar* pa_blend1;
	ICVar* pa_blend2;
	ICVar* pa_forcerelax;
	ICVar* pa_spine;
	ICVar* pa_spine1;

	ICVar*	m_pCVarCheatMode;

	// limping state

	ICVar* p_limp;

	// flashlight stuff
	ICVar* pl_force;
	ICVar* pl_dist;
	ICVar* pl_intensity;
	ICVar* pl_fadescale;
	ICVar* pl_head;

	//mutants jump parameters
	ICVar* m_jump_vel;
	ICVar* m_jump_arc;

	// boat
	//*
	ICVar* b_dump;		//angular velocity - waiving
	ICVar* b_dumpRot;	//angular velocity - turning
	ICVar* b_dumpV;		//velocity
	ICVar* b_dumpVH;		//velocity
	ICVar* b_stand;
	ICVar* b_turn;
	ICVar* b_tilt;
	ICVar* b_speedV;
	ICVar* b_accelerationV;
	ICVar* b_float;
	ICVar* b_speedMinTurn;
	//	water waves param
	ICVar* b_wscale;
	ICVar* b_wscalew;
	ICVar* b_wmomentum;


	//	camera mode
	ICVar* b_camera;
	/*
	//fire/burnable
	ICVar* f_update;
	ICVar* f_draw;
	ICVar* f_drawDbg;
	*/
	ICVar* g_LevelName;	
	ICVar* g_StartMission;

	ICVar *sv_port;
	ICVar *sv_mapcyclefile;
	ICVar *sv_cheater_kick;
	ICVar *sv_cheater_ban;

	ICVar *sv_timeout;
	ICVar	*cl_timeout;
	ICVar *cl_loadtimeout;
	ICVar	*cl_snooptimeout;
	ICVar	*cl_snoopretries;
	ICVar	*cl_snoopcount;

	ICVar* p_CameraSmoothVLimit;
	ICVar* p_CameraSmoothTime;
	ICVar* p_CameraSmoothScale;

	ICVar* p_LeaveVehicleImpuls;
	ICVar* p_LeaveVehicleBrake;
	ICVar* p_LeaveVehicleBrakeDelay;

	ICVar* p_AutoCenterDelay;
	ICVar* p_AutoCenterSpeed;

	ICVar* p_HitImpulse;
	ICVar* p_DeadBody;
	ICVar* p_RotateHead;
	ICVar* p_RotateMove;
	ICVar* p_HeadCamera;
	ICVar* p_EyeFire;
	ICVar* a_DrawArea;
	ICVar* a_LogArea;
	ICVar* cv_game_Difficulty;
	ICVar* cv_game_Aggression;
	ICVar* cv_game_Accuracy;
	ICVar* cv_game_Health;
	ICVar* cv_game_AllowAIMovement;
	ICVar* cv_game_AllAIInvulnerable;
	ICVar* cv_game_GliderGravity;
	ICVar* cv_game_GliderBackImpulse;
	ICVar* cv_game_GliderDamping;
	ICVar* cv_game_GliderStartGravity;
	ICVar* cv_game_physics_quality;

	ICVar* cv_game_subtitles;
	ICVar* g_first_person_spectator;

	ICVar* g_timedemo_file;

	ICVar* h_drawbelow;	// show bboxes for static objects below helicopter

	ICVar* pl_JumpNegativeImpulse; //!< this represent the downward impulse power applied when the player reach the max height of the jump, 0 means no impulse.

	ICVar* e_deformable_terrain; //!< the Cvar is created in cry3dengine, this is just a pointer

	float w_recoil_speed_up;
	float w_recoil_speed_down;
	float w_recoil_max_degree;
	float w_accuracy_decay_speed;
	float w_accuracy_gain_scale;
	int w_recoil_vertical_only;

	CStringTableMgr m_StringTableMgr;
	CXSurfaceMgr m_XSurfaceMgr;
	CScriptTimerMgr *m_pScriptTimerMgr;


  }
}

extern (C) export IGame CreateGameInstance()
{
  return new CXGame;
}
