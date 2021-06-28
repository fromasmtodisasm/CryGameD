module crygame;

import core.sys.windows.windows;
import core.sys.windows.dll;

import isystem;
import igame;

public import common;

mixin SimpleDllMain;

extern (C++)
{
  class CGame : IGame
  {

    IInput m_IInput;
    ILog m_pLog;
    IScriptSystem m_pScriptSystem;
    float test_f = 35;

    bool Init(ISystem pSystem, bool bDedicatedSrv, bool bInEditor, const char* szGameMod)
    {

      m_ISystem = pSystem;
      m_pLog = pSystem.GetILog();
      m_pScriptSystem = pSystem.GetIScriptSystem();
      IConsole pConsole = pSystem.GetIConsole();

      pConsole.PrintLine("Game Initialization");

      auto var = pConsole.CreateVariable("test_v", "10", 0);

      var = pConsole.CreateVariable("my_var", 20, 0);

      pConsole.Register("test_f", &test_f, test_f);
      pConsole.UnregisterVariable("my_var");
      pConsole.CreateKeyBind("System:Quit()", "q", false);
      pConsole.AddCommand("dump_scripts", "Script:DumpLoadedScripts()", 0,
          "Outputs a list of currently loaded scripts.\nUsage: dump_scripts\n");

      pConsole.AddCommand("clear", "System:ClearConsole()", 0,
          "Clears console text.\nUsage: clear\n");

      // execute the "main"-script (to pre-load other scripts, etc.)
      assert(m_pScriptSystem.ExecuteFile("scripts/main.lua"));

      //m_pScriptSystem.BeginCall("Init");
      //m_pScriptSystem.PushFuncParam(0);
      //m_pScriptSystem.EndCall();

      return true;
    }

    // Summary: Update the module and all subsystems
    // Returns: false to stop the main loop
    bool Update()
    {
      while (true)
      {
        IConsole con = m_ISystem.GetIConsole();

        if (m_ISystem.GetIInput().KeyPressed(KeyCodes.XKEY_ESCAPE))
        {
          return false;
        }
        if (m_ISystem.GetIInput().KeyPressed(KeyCodes.XKEY_F1))
        {
          con.Help("r_ShowLight");
        }
        m_ISystem.Update(0, 0);

        auto var = con.GetLineCount();
        if (var)
        {
          //img.Release();
        }

        m_ISystem.RenderBegin();

        m_ISystem.Render();

        m_ISystem.RenderEnd();
      }
    }

    // Summary: Run the main loop until another subsystem force the exit
    // Returns: false to stop the main loop
    bool Run(ref bool bRelaunch)
    {
      return Update();
    }

    // Summary: Determines if a MOD is currently loaded
    // Returns: A string holding the name of the MOD if one is loaded, else
    //          NULL will be returned if only Far Cry is loaded.
    const char* IsMODLoaded()
    {
      return null;
    }

    // Returns interface to access Game Mod functionality.
    IGameMods GetModsInterface()
    {
      return null;
    }

    //## EXTREMELY IMPORTANT: Do not modify anything above, else the binary
    //##                      compatibility with the gold version of Far Cry
    //##                      will be broken.
    //########################################################################

    //Shutdown and destroy the module (delete this)
    void Release()
    {
    }

    // Executes scheduled events, called by system before executing each fixed time step in multiplayer
    void ExecuteScheduledEvents()
    {
    }

    // Tells whether fixed timestep physics in multiplayer is on
    bool UseFixedStep()
    {
      return false;
    }

    // Snaps to to fixed step
    int SnapTime(float fTime, float fOffset)
    {
      return false;
    }

    // Snaps to to fixed step
    int SnapTime(int iTime, float fOffset)
    {
      return false;
    }

    // returns fixed MP step in physworld time granularity
    int GetiFixedStep()
    {
      return false;
    }

    // returns fixed MP step
    float GetFixedStep()
    {
      return false;
    }

    // Load level [level editor only]
    // @param pszLevelDirectory level directory
    bool LoadLevelForEditor(const char* pszLevelDirectory, const char* pszMissionName)
    {
      return false;
    }

    // Get the entity class regitry
    IEntityClassRegistry* GetClassRegistry()
    {
      return null;
    }

    void OnSetVar(ICVar pVar)
    {
    }

    void SendMessage(const char* s)
    {
    }

    void ResetState()
    {
    }

    void GetMemoryStatistics(ICrySizer* pSizer)
    {
    }

    // saves player configuration
    void SaveConfiguration(const char* sSystemCfg, const char* sGameCfg, const char* sProfile)
    {
    }

    // This is used by editor for changing properties from scripts (no restart).
    void ReloadScripts()
    {
    }

    bool GetModuleState(EGameCapability eCap)
    {
      return false;
    }

    // functions return callback sinks for the physics
    IPhysicsStreamer GetPhysicsStreamer()
    {
      return null;
    }

    IPhysicsEventClient* GetPhysicsEventClient()
    {
      return null;
    }

    // is called from time to time during loading (usually network updates)
    // currently only called for server map loading
    void UpdateDuringLoading()
    {
    }

    //ITagPointManager* GetTagPointManager(){ return false; }
    IXAreaMgr GetAreaManager()
    {
      return null;
    }

    ITagPointManager GetTagPointManager()
    {
      return null;
    }

    public ISystem m_ISystem;

  }
}

extern (C) export IGame CreateGameInstance()
{
  return new CGame;
}
