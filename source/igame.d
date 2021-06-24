module igame;

import isystem;

public extern (C++){
  interface IGameMods{}
  interface IEntityClassRegistry{}
  interface ICrySizer{}

  interface IPhysicsStreamer{}
  interface IPhysicsEventClient{}
  interface IXAreaMgr{}
  interface ITagPointManager{}
  interface ICVar{}

  //////////////////////////////////////////////////////////////////////
  enum EGameCapability
  {
    EGameMultiplayer = 1,
    EGameClient,
    EGameServer,
    EGameDevMode,
  }

  //	Exposes the basic functionality to initialize and run the game.
  interface IGame {
    //########################################################################
    //## EXTREMELY IMPORTANT: Do not modify anything below, else the binary
    //##                      compatibility with the gold version of Far Cry
    //##                      will be broken.

    // Summary: Initialize game.
    // Returns: true on success, false otherwise
    bool Init( ISystem pSystem, bool bDedicatedSrv, bool bInEditor, const char *szGameMod );

    // Summary: Update the module and all subsystems
    // Returns: false to stop the main loop
    bool Update();

    // Summary: Run the main loop until another subsystem force the exit
    // Returns: false to stop the main loop
    bool Run( ref bool bRelaunch );

    // Summary: Determines if a MOD is currently loaded
    // Returns: A string holding the name of the MOD if one is loaded, else
    //          NULL will be returned if only Far Cry is loaded.
    const char *IsMODLoaded();

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
    int SnapTime(int iTime,float fOffset);

    // returns fixed MP step in physworld time granularity
    int GetiFixedStep();

    // returns fixed MP step
    float GetFixedStep();

    // Load level [level editor only]
    // @param pszLevelDirectory level directory
    bool LoadLevelForEditor(const char *pszLevelDirectory, const char *pszMissionName);

    // Get the entity class regitry
    IEntityClassRegistry *GetClassRegistry();

    void OnSetVar(ICVar pVar);
    void SendMessage(const char *s);
    void ResetState();
    void GetMemoryStatistics(ICrySizer *pSizer);

    // saves player configuration
    void SaveConfiguration( const char *sSystemCfg,const char *sGameCfg,const char *sProfile);

    // This is used by editor for changing properties from scripts (no restart).
    void ReloadScripts();

    bool GetModuleState( EGameCapability eCap );

    // functions return callback sinks for the physics
    IPhysicsStreamer GetPhysicsStreamer();
    IPhysicsEventClient *GetPhysicsEventClient();

    // is called from time to time during loading (usually network updates)
    // currently only called for server map loading
    void UpdateDuringLoading();

    //ITagPointManager* GetTagPointManager();
    IXAreaMgr GetAreaManager();
    ITagPointManager GetTagPointManager();
  }
}


extern (C) export IGame CreateGameInstance();