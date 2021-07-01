module isystem;

public:
import platform;
import ivalidator;
import igame;
import ixmldom;
import ixml;
import cry_camera;
import frame_profiler;
import cry_version;
import iinput;
import iconsole;
import ilog;
import iscriptsystem;
import ientitysystem;
import irenderer;

extern (C++)
{

  interface ICryPak
  {
  }

  interface IKeyboard
  {
  }

  interface IMouse
  {
  }

  interface IProcess
  {
  }

  interface I3DEngine
  {
  }

  interface ITimer
  {
  }

  interface IAISystem
  {
  }

  interface IFlash
  {
  }

  interface INetwork
  {
  }

  interface ICryFont
  {
  }

  interface IMovieSystem
  {
  }

  interface IPhysicalWorld
  {
  }

  interface IMemoryManager
  {
  }

  interface ISoundSystem
  {
  }

  interface IMusicSystem
  {
  }
  //interface XDOM::IXMLDOMDocument{}
  interface IFrameProfileSystem
  {
  }

  interface FrameProfiler
  {
  }

  interface IStreamEngine
  {
  }

  interface ICryCharManager
  {
  }

  interface IDataProbe
  {
  }

  interface ICrySizer
  {
  }

  interface CXFont
  {
  }

  //////////////////////////////////////////////////////////////////////////
  enum ESystemUpdateFlags
  {
    ESYSUPDATE_IGNORE_AI = 0x0001,
    ESYSUPDATE_IGNORE_PHYSICS = 0x0002,
    // Special update mode for editor.
    ESYSUPDATE_EDITOR = 0x0004,
    ESYSUPDATE_MULTIPLAYER = 0x0008
  };

  //////////////////////////////////////////////////////////////////////////
  enum ESystemConfigSpec
  {
    CONFIG_LOW_SPEC = 0,
    CONFIG_MEDIUM_SPEC = 1,
    CONFIG_HIGH_SPEC = 2,
    CONFIG_VERYHIGH_SPEC = 3,
  };

  //////////////////////////////////////////////////////////////////////////
  // User defined callback, which can be passed to ISystem.
  interface ISystemUserCallback
  {
    /** Signals to User that engine error occured.
        @return true to Halt execution or false to ignore this error.
    */
    bool OnError(const char * szErrorString);
    /** If working in Editor environment notify user that engine want to Save current document.
        This happens if critical error have occured and engine gives a user way to save data and not lose it
        due to crash.
    */
    void OnSaveDocument();

    /** Notify user that system wants to switch out of current process.
        (For ex. Called when pressing ESC in game mode to go to Menu).
    */
    void OnProcessSwitch();
  };

  //////////////////////////////////////////////////////////////////////////
  // Structure passed to Init method of ISystem interface.
  struct SSystemInitParams
  {
    void * hInstance; //
    void * hWnd; //
    char[512] szSystemCmdLine; // command line, used to execute the early commands e.g. -DEVMODE "g_gametype ASSAULT"
    ISystemUserCallback * pUserCallback; //
    ILog * pLog; // You can specify your own ILog to be used by System.
    IValidator * pValidator; // You can specify different validator object to use by System.
    const char * sLogFileName; // File name to use for log.
    bool bEditor; // When runing in Editor mode.
    bool bPreview; // When runing in Preview mode (Minimal initialization).
    bool bTestMode; // When runing in Automated testing mode.
    bool bDedicatedServer; // When runing a dedicated server.
    ISystem * pSystem; // Pointer to existing ISystem interface, it will be reused if not NULL.

    version (Linux)
    {
      //void (*pCheckFunc)(void*);							// authentication function (must be set).
    }
    else
    {
      void * pCheckFunc; // authentication function (must be set).
    }

  };

  //////////////////////////////////////////////////////////////////////////
  // Structure passed to CreateGame method of ISystem interface.
  struct SGameInitParams
  {
    const char * sGameDLL; // Name of Game DLL. (Win32 Only)
    IGame pGame; // Pointer to already created game interface.
    bool bDedicatedServer; // When runing a dedicated server.
    char[256] szGameCmdLine; // command line, used to execute the console commands after game creation e.g. -DEVMODE "g_gametype ASSAULT"

  }

  ////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////
  // Main Engine Interface
  // initialize and dispatch all engine's subsystems
  interface ISystem
  {
    // Loads GameDLL and creates game instance.
    bool CreateGame(ref SGameInitParams params);

    // Release ISystem.
    void Release();

    // Update all subsystems (including the ScriptSink() )
    // @param flags one or more flags from ESystemUpdateFlags sructure.
    // @param boolean to set when in pause or cutscene mode in order to avoid
    // certain subsystem updates 0=menu/pause, 1=cutscene mode
    bool Update(int updateFlags, int nPauseMode);

    // update _time, _frametime (useful after loading level to apply the time value)
    void UpdateScriptSink();

    // Begin rendering frame.
    void RenderBegin();
    // Render subsystems.
    void Render();
    // End rendering frame and swap back buffer.
    void RenderEnd();

    // Renders the statistics; this is called from RenderEnd, but if the 
    // Host application (Editor) doesn't employ the Render cycle in ISystem,
    // it may call this method to render the essencial statistics
    void RenderStatistics();

    // Retrieve the name of the user currently logged in to the computer
    const char * GetUserName();

    // Gets current supported CPU features flags. (CPUF_SSE, CPUF_SSE2, CPUF_3DNOW, CPUF_MMX)
    int GetCPUFlags();

    // Get seconds per processor tick
    double GetSecondsPerCycle();

    // dumps the memory usage statistics to the log
    void DumpMemoryUsageStatistics();

    // Quit the appliacation
    void Quit();
    // Tells the system if it is relaunching or not
    void Relaunch(bool bRelaunch);
    // return true if the application is in the shutdown phase
    bool IsQuitting();

    // Display error message.
    // Logs it to console and file and error message box.
    // Then terminates execution.
    void Error(const char * sFormat, ...);

    //DOC-IGNORE-BEGIN
    //[Timur] DEPRECATED! Use Validator Warning instead.
    // Display warning message.
    // Logs it to console and file and display a warning message box.
    // Not terminates execution.
    //__declspec(deprecated) void Warning( const char *sFormat,... );
    //DOC-IGNORE-END

    // Report warning to current Validator object.
    // Not terminates execution.
    void Warning(EValidatorModule _module, EValidatorSeverity severity, int flags,
        const char * file, const char * format, ...);
    // Compare specified verbosity level to the one currently set.
    bool CheckLogVerbosity(int verbosity);

    // returns true if this is dedicated server application
    bool IsDedicated();

    // return the related subsystem interface
    IGame GetIGame();
    INetwork GetINetwork();
    IRenderer.IRenderer GetIRenderer();
    IInput GetIInput();
    ITimer GetITimer();
    IConsole GetIConsole();
    IScriptSystem GetIScriptSystem();
    I3DEngine GetI3DEngine();
    ISoundSystem GetISoundSystem();
    IMusicSystem GetIMusicSystem();
    IPhysicalWorld GetIPhysicalWorld();
    IMovieSystem GetIMovieSystem();
    IAISystem GetAISystem();
    IMemoryManager GetIMemoryManager();
    IEntitySystem GetIEntitySystem();
    ICryFont GetICryFont();
    ICryPak GetIPak();
    ILog GetILog();
    IStreamEngine GetStreamEngine();
    ICryCharManager GetIAnimationSystem();
    IValidator GetIValidator();
    IFrameProfileSystem GetIProfileSystem();

    void DebugStats(bool checkpoint, bool leaks);
    void DumpWinHeaps();
    int DumpMMStats(bool log);

    //////////////////////////////////////////////////////////////////////////
    // @param bValue set to true when running on a cheat protected server or a client that is connected to it (not used in singlplayer)
    void SetForceNonDevMode(const bool bValue);
    // @return is true when running on a cheat protected server or a client that is connected to it (not used in singlplayer)
    bool GetForceNonDevMode() const;
    bool WasInDevMode() const;
    bool IsDevMode() const;

    XDOM.IXMLDOMDocument CreateXMLDocument();

    //////////////////////////////////////////////////////////////////////////
    // IXmlNode interface.
    //////////////////////////////////////////////////////////////////////////
    // Creates new xml node.
    XmlNodeRef CreateXmlNode(const char * sNodeName);
    // Load xml file, return 0 if load failed.
    XmlNodeRef LoadXmlFile(const char * sFilename);
    // Load xml from string, return 0 if load failed.
    XmlNodeRef LoadXmlFromString(const char * sXmlString);

    void SetViewCamera(ref CCamera Camera);
    ref CCamera GetViewCamera();

    void CreateEntityScriptBinding(IEntity pEntity);
    // When ignore update sets to true, system will ignore and updates and render calls.
    void IgnoreUpdates(bool bIgnore);

    // Set rate of Garbage Collection for script system.
    // @param fRate in seconds
    void SetGCFrequency(const float fRate);

    /* Set the active process
      @param process a pointer to a class that implement the IProcess interface
    */
    void SetIProcess(IProcess process);
    /* Get the active process
      @return a pointer to the current active process
    */
    IProcess GetIProcess();

    version (Win32)
    {
      IRenderer.IRenderer CreateRenderer(bool fullscreen, void * hinst, void * hWndAttach);
    }

    // Returns true if system running in Test mode.
    bool IsTestMode() const;

    void ShowDebugger(const char * pszSourceFile, int iLine, const char * pszReason);

    //////////////////////////////////////////////////////////////////////////
    // Frame profiler functions
    void SetFrameProfiler(bool on, bool display, char * prefix);

    // Starts section profiling.
    void StartProfilerSection(CFrameProfilerSection * pProfileSection);
    // Stops section profiling.
    void EndProfilerSection(CFrameProfilerSection * pProfileSection);

    //////////////////////////////////////////////////////////////////////////
    // VTune Profiling interface.
    // Resume vtune data collection.
    void VTuneResume();
    // Pauses vtune data collection.
    void VTunePause();
    //////////////////////////////////////////////////////////////////////////

    void Deltree(const char * szFolder, bool bRecurse);

    //////////////////////////////////////////////////////////////////////////
    // File version.
    //////////////////////////////////////////////////////////////////////////

    const ref SFileVersion GetFileVersion();
    const ref SFileVersion GetProductVersion();

    // Compressed file read & write
    bool WriteCompressedFile(char * filename, void * data, uint bitlen);
    uint ReadCompressedFile(char * filename, void * data, uint maxbitlen);
    uint GetCompressedFileSize(char * filename);

    // Sample:  char str[256];	bool bRet=GetSSFileInfo("C:\\mastercd\\materials\\compound_indoor.xml",str,256);
    // get info about the last SourceSafe action for a specifed file (Name,Comment,Date)
    // @param inszFileName inszFileName!, e.g. "c:\\mastercd\\AssetMan\\AssetManShellExt\\AssManMenu.cpp"
    // @param outszInfo outszInfo!, [0..indwBufferSize-1]
    // @param indwBufferSize >0
    // @return true=success, false otherwise (output parameter is set to empty strings)
    bool GetSSFileInfo(const char * inszFileName, char * outszInfo, const DWORD indwBufferSize);

    // Retrieve IDataProbe interface.
    IDataProbe * GetIDataProbe();
    //////////////////////////////////////////////////////////////////////////
    // Configuration.
    //////////////////////////////////////////////////////////////////////////
    // Saves system configuration.
    void SaveConfiguration();
    // Loads system configuration
    void LoadConfiguration(const string sFilename);

    // Get current configuration specification.
    ESystemConfigSpec GetConfigSpec();

  }

  //////////////////////////////////////////////////////////////////////////
  // CrySystem DLL Exports.
  //////////////////////////////////////////////////////////////////////////
  // Get the system interface (must be defined locally in each module)
  ISystem GetISystem();

  // interface of the DLL
  extern (C)
  {
    export ISystem CreateSystemInterface(ref SSystemInitParams initParams);
  }
  //////////////////////////////////////////////////////////////////////////
  // Logs important data that must be printed regardless verbosity.
  void CryLogAlways(const char * format, ...)
  {
    if (GetISystem())
    {
      va_list args;
      va_start(args, format);
      GetISystem().GetILog().LogV(ILog.ELogType.eAlways, format, args);
      va_end(args);
    }
  }
}
