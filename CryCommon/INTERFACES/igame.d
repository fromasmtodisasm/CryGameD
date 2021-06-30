module igame;

import isystem;
import imarkers;

import cry_version;
import Math;

enum PLAYER_CLASS_ID				= 1;
enum ADVCAMSYSTEM_CLASS_ID			= 97;		// is this the right place to put that define?
enum SPECTATOR_CLASS_ID				= 98;		//
enum SYNCHED2DTABLE_CLASS_ID		= 205;		//

//////////////////////////////////////////////////////////////////////////
alias ushort EntityClassId;			//< unique identifier for the entity class (defined in ClassRegistry.lua)

//////////////////////////////////////////////////////////////////////////


public extern (C++):
/*
This structure stores the informations to identify an entity type
@see CEntityClassRegistry
*/
//////////////////////////////////////////////////////////////////////////
struct EntityClass
{
	// type id
	EntityClassId				ClassId;
	// class name inside the script file
	string							strClassName;
	// script relative file path
	string							strScriptFile;
	// script fully specified file path (Relative to root folder).
	string							strFullScriptFile;
	// Game type of this entity (Ex. Weapon,Player).
	string							strGameType;
	//specify that this class is not level dependent and is not loaded from LevelData.xml
	bool								bReserved;
	//
	bool								bLoaded;

	/*
	// Copy operator required by STL containers.
	EntityClass& operator=( const EntityClass &ec )
	{
		bReserved=ec.bReserved;
		ClassId = ec.ClassId;
		strClassName = ec.strClassName;
		strScriptFile = ec.strScriptFile;
		strFullScriptFile = ec.strFullScriptFile;
		strGameType = ec.strGameType;
		bLoaded=ec.bLoaded;
		return *this;
	}
	*/
};

//////////////////////////////////////////////////////////////////////
/* This interface allows to load or create new entity types
@see CEntityClassRegistry
*/
interface IEntityClassRegistry
{
	/*Retrieves an entity class by name
	@param str entity name
	@return EntityClass ptr if succeded, NULL if failed
	*/
	EntityClass *GetByClass(const char *sClassName,bool bAutoLoadScript=true);
	//EntityClass *GetByClass(const string &str)= 0;
	/*Retrieves an entity class by ClassId
	@param ClassId class id
	@return EntityClass ptr if succeded, NULL if failed
	*/
	EntityClass *GetByClassId(const EntityClassId ClassId,bool bAutoLoadScript=true);
	/*Adds a class type into the registry
	@param ClassId class id
	@param sClassName class name(into the script file)
	@param sScriptFile script file path
	@param pLog pointer to the log interface
	@param bForceReload if set to true force script to be eloaded for already registered class.
	@return true if added, false if failed
	*/
	bool AddClass(const EntityClassId ClassId,const char* sClassName,const char* sScriptFile,bool bReserved=false,bool bForceReload=false);

	/*move the iterator to the begin of the registry
	*/
	void MoveFirst();
	/*get the next entity class into the registry
	@return a pointer to the next entityclass, or NULL if is the end
	*/
	EntityClass *Next();
	/*return the count of the entity classes
	@return the count of the entity classes
	*/
	int Count();

	bool LoadRegistryEntry(EntityClass *pClass, bool bForceReload=false);
	// debug to OutputDebugString()
	void Debug();
};

//////////////////////////////////////////////////////////////////////
struct INameIterator
{
	void Release();
	void MoveFirst();
	bool MoveNext();
	bool Get(char *pszBuffer, INT *pSize);
};

class IPhysicsStreamer;
class IPhysicsEventClient;

//////////////////////////////////////////////////////////////////////////
// MOD related

// flags
// NOTE: flags are unused atm
enum MOD_NEWGAMEDLL	= 1L<<1; //tells if the MOD contains a replacement of CryGame.dll

// Description of the Game MOD.
//////////////////////////////////////////////////////////////////////////
struct SGameModDescription
{
	// Mod's name.
	string sName;
	// Mod's title.
	string sTitle;
	// Folder where this mod is located.
	string sFolder;
	// Mod's author.
	string sAuthor;
	// Mod Version.
	SFileVersion xversion;
	// Mod description.
	string sDescription;
	// Website.
	string sWebsite;
	// Mod flags
	int	dwFlags;
};

//////////////////////////////////////////////////////////////////////
// Interface to access Game modifications parameters.
interface IGameMods
{
	// Returns description of the currently active game mode.
	// @returns NULL if the game mod is not found.
	immutable(SGameModDescription*) GetModDescription( const char *sModName ) immutable;
	// @returns name of the mod currently active, never returns 0
	immutable(char*) GetCurrentMod() immutable;
	// Sets the currently active game mod.
	// @returns true if Mod is successfully set, false if Mod set failed.
	bool SetCurrentMod( const char *sModName,bool bNeedsRestart=false );
	// Returns modified path for the currently active mod/tc (if any)
	// @returns true if there is an active mod, false otherwise
	const char* GetModPath(const char *szSource);
};

//////////////////////////////////////////////////////////////////////
interface ITagPointManager
{
	// This function creates a tag point in the game world
	ITagPoint *CreateTagPoint(const string name, ref const Vec3 pos, ref const Vec3 angles);

	// Retrieves a tag point by name
	ITagPoint *GetTagPoint(const string name);

	// Deletes a tag point from the game
	void RemoveTagPoint(ITagPoint pPoint);

	void AddRespawnPoint(ITagPoint pPoint);
	void RemoveRespawnPoint(ITagPoint pPoint);
};

//////////////////////////////////////////////////////////////////////
enum EGameCapability
{
	EGameMultiplayer = 1,
	EGameClient,
	EGameServer,
	EGameDevMode,
};

//	Exposes the basic functionality to initialize and run the game.
interface IGame
{
	//########################################################################
	//## EXTREMELY IMPORTANT: Do not modify anything below, else the binary
	//##                      compatibility with the gold version of Far Cry
	//##                      will be broken.

	// Summary: Initialize game.
	// Returns: true on success, false otherwise
	bool Init(ISystem pSystem, bool bDedicatedSrv, bool bInEditor, const char* szGameMod);

	// Summary: Update the module and all subsystems
	// Returns: false to stop the main loop
	bool Update();

	// Summary: Run the main loop until another subsystem force the exit
	// Returns: false to stop the main loop
	bool Run(ref bool bRelaunch);

	// Summary: Determines if a MOD is currently loaded
	// Returns: A string holding the name of the MOD if one is loaded, else
	//          NULL will be returned if only Far Cry is loaded.
	const char* IsMODLoaded();

	// Returns interface to access Game Mod functionality.
	IGameMods GetModsInterface();

	//## EXTREMELY IMPORTANT: Do not modify anything above, else the binary
	//##                      compatibility with the gold version of Far Cry
	//##                      will be broken.
	//########################################################################

	//Shutdown and destroy the module (delete this)
	void Release();

	// Executes scheduled events, called by system before executing each fixed time step in multiplayer
	void ExecuteScheduledEvents();

	// Tells whether fixed timestep physics in multiplayer is on
	bool UseFixedStep();

	// Snaps to to fixed step
	int SnapTime(float fTime, float fOffset);

	// Snaps to to fixed step
	int SnapTime(int iTime, float fOffset);

	// returns fixed MP step in physworld time granularity
	int GetiFixedStep();

	// returns fixed MP step
	float GetFixedStep();

	// Load level [level editor only]
	// @param pszLevelDirectory level directory
	bool LoadLevelForEditor(const char* pszLevelDirectory, const char* pszMissionName);

	// Get the entity class regitry
	IEntityClassRegistry* GetClassRegistry();

	void OnSetVar(ICVar pVar);
	void SendMessage(const char* s);
	void ResetState();
	void GetMemoryStatistics(ICrySizer* pSizer);

	// saves player configuration
	void SaveConfiguration(const char* sSystemCfg, const char* sGameCfg, const char* sProfile);

	// This is used by editor for changing properties from scripts (no restart).
	void ReloadScripts();

	bool GetModuleState(EGameCapability eCap);

	// functions return callback sinks for the physics
	IPhysicsStreamer GetPhysicsStreamer();
	IPhysicsEventClient* GetPhysicsEventClient();

	// is called from time to time during loading (usually network updates)
	// currently only called for server map loading
	void UpdateDuringLoading();

	//ITagPointManager* GetTagPointManager();
	IXAreaMgr GetAreaManager();
	ITagPointManager GetTagPointManager();
}

extern (C) export IGame CreateGameInstance();
