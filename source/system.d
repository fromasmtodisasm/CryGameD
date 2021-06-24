extern(C++){

  interface IGame{}

  //////////////////////////////////////////////////////////////////////////
  // Structure passed to CreateGame method of ISystem interface.
  struct SGameInitParams
  {
    const char *	sGameDLL;							// Name of Game DLL. (Win32 Only)
    IGame 				pGame;								// Pointer to already created game interface.
    bool					bDedicatedServer;			// When runing a dedicated server.
    char[256]			szGameCmdLine;		// command line, used to execute the console commands after game creation e.g. -DEVMODE "g_gametype ASSAULT"

  }


  ////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////
  // Main Engine Interface
  // initialize and dispatch all engine's subsystems
  interface ISystem
  {
    // Loads GameDLL and creates game instance.
    bool CreateGame( ref SGameInitParams params );

    // Release ISystem.
    void Release();

    // Update all subsystems (including the ScriptSink() )
    // @param flags one or more flags from ESystemUpdateFlags sructure.
    // @param boolean to set when in pause or cutscene mode in order to avoid
    // certain subsystem updates 0=menu/pause, 1=cutscene mode
    bool Update( int updateFlags,int nPauseMode);

    // update _time, _frametime (useful after loading level to apply the time value)
    void UpdateScriptSink();

    // Begin rendering frame.
    void	RenderBegin();
    // Render subsystems.
    void	Render();
    // End rendering frame and swap back buffer.
    void	RenderEnd();

  }

}
