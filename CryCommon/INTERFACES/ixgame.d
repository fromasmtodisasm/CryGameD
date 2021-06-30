module ixgame;

public:
import igame;
import isystem;
import imarkers;
import Math;
import player_system;
import ibitstream;

import GameServer.XServer;

extern (C++):
//////////////////////////////////////////////////////////////////////////
interface IXGame : IGame
{
	/* Initialize game.
	@return true on success, false otherwise
	*/
	bool Init(ISystem pSystem, bool bDedicatedSrv, bool bInEditor, const char* szGameMod);
	/*Upadate the module and all subsystems
	@return false to stop the main loop 
	*/
	bool Update();
	/*run the main loop until another subsystem force the exit
	@return false to stop the main loop 
	*/
	bool Run(ref bool bRelaunch);

	/* Returns current MOD
	NULL if FarCry, name of MOD otherwise
	*/
	const char* IsMODLoaded();

	/* Returns interface to access Game Mod functionality.
	*/
	IGameMods* GetModsInterface();

	/*Executes scheduled events, called by system before executing each fixed time step in multiplayer
	*/
	void ExecuteScheduledEvents();
	/*Tells whether fixed timestep physics in multiplayer is on
	*/
	bool UseFixedStep();
	/*Snaps to to fixed step 
	*/
	int SnapTime(float fTime, float fOffset = 0.5f);
	/*Snaps to to fixed step 
	*/
	int SnapTime(int iTime, float fOffset = 0.5f);
	/*returns fixed MP step in physworld time granularity
	*/
	int GetiFixedStep();
	/*returns fixed MP step
	*/
	float GetFixedStep();
	/*Shutdown and destroy the module (delete this)
	*/
	void Release();
	/*Load level [level editor only]
	@param pszLevelDirectory level directory
	*/
	bool LoadLevelForEditor(const char* pszLevelDirectory, const char* pszMissionName);
	/* Check if a sound is potentially hearable (used to check if loading a dialog is needed)
	*/
	bool IsSoundPotentiallyHearable(ref Vec3d SoundPos, float fClipRadius);
	/*Assign a material to a tarrain layer
	*/
	void SetTerrainSurface(const char* sMaterial, int nLayerID);
	/*Get the local player entity[editor only]
	*/
	IEntity* GetMyPlayer();
	/*Get the entity class regitry
	*/
	IEntityClassRegistry* GetClassRegistry();

	/*Set the angles of the view camera of the game
	*/
	void SetViewAngles(const ref Vec3 angles);

	/*Retrieves the player-system
	*/
	CPlayerSystem* GetPlayerSystem();

	/* This function creates a tag point in the game world
	*/
	ITagPoint* CreateTagPoint(const ref string name, const ref Vec3 pos, const ref Vec3 angles);

	/* Retieves a tag point by name
	*/
	ITagPoint* GetTagPoint(const ref string name);

	/*	Deletes a tag point from the game
	*/
	void RemoveTagPoint(ITagPoint* pPoint);

	// shape
	IXArea* CreateArea(const Vec3* vPoints, const int count, const string[] names,
			const int type, const int groupId = -1,
			const float width = 0.0f, const float height = 0.0f);
	// box
	IXArea* CreateArea(const ref Vec3 min, const ref Vec3 max, const ref Matrix44 TM,
			const string[] names, const int type,
			const int groupId = -1, const float width = 0.0f);
	// sphere
	IXArea* CreateArea(const ref Vec3 center, const float radius, const string[] names,
			const int type, const int groupId = -1, const float width = 0.0f);
	//		const char* const className, const int type, const float width.0f);
	void DeleteArea(const IXArea* pArea);
	IXArea* GetArea(const ref Vec3 point);

	// detect areas the listener is in before system update
	void CheckSoundVisAreas();
	// retrigger them if necessary after system update
	void RetriggerAreas();

	/* Returns an enumeration of the currently available weapons
	*/
	INameIterator* GetAvailableWeaponNames();
	INameIterator* GetAvailableProjectileNames();

	/* Add a weapon and load it
	*/
	bool AddWeapon(const char* pszName);

	/* Remove a loaded weapon by name
	*/
	bool RemoveWeapon(const char* pszName);

	/* Remove all loaded weapons
	*/
	void RemoveAllWeapons();

	bool AddEquipPack(const char* pszXML);

	void RestoreWeaponPacks();

	void SetPlayerEquipPackName(const char* pszPackName);

	void SetViewMode(bool bThirdPerson);

	void AddRespawnPoint(ITagPoint* pPoint);
	void RemoveRespawnPoint(ITagPoint* pPoint);
	void OnSetVar(ICVar* pVar);
	void SendMessage(const char* s);
	void ResetState();
	void GetMemoryStatistics(ICrySizer* pSizer);
	void HideLocalPlayer(bool hide, bool bEditor);

	// saves player configuration
	void SaveConfiguration(const char* sSystemCfg, const char* sGameCfg, const char* sProfile);

	/* This is used by editor for changing properties from scripts (no restart).
	*/
	void ReloadScripts();

	// sets a timer for a generic script object table
	int AddTimer(IScriptObject* pTable, uint nStartTimer, uint nTimer,
			IScriptObject* pUserData, bool bUpdateDuringPause);

	CXServer* GetServer();

	// functions to know if the current terminal is a server and/or a client
	bool IsServer();
	bool IsClient();
	bool IsMultiplayer(); // can be used for disabling cheats, or disabling features which cannot be synchronised over a network game
	bool IsDevModeEnable();

	void EnableUIOverlay(bool bEnable, bool bExclusiveInput);
	bool IsUIOverlay();
	bool IsInMenu();
	void GotoMenu(bool bTriggerOnSwitch = false);
	void GotoGame(bool bTriggerOnSwitch = false);

	// functions return callback sinks for the physics
	IPhysicsStreamer* GetPhysicsStreamer();
	IPhysicsEventClient* GetPhysicsEventClient();

	// checks if gore enabled in the game
	bool GoreOn() const;

	// for compressed readwrite operation with CStreams 
	// /return you can assume the returned pointer is always valid
	IBitStream* GetIBitStream();

	// is called from time to time during loading (usually network updates)
	// currently only called for server map loading
	void UpdateDuringLoading();

	bool GetModuleState(EGameCapability eCap);

	string GetName();
	int GetInterfaceVersion();
}
