module iconsole;

import isystem;

//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//	File: IConsole.h
//	Description:
//		Interface for the ingame console and relative cvars.
//		Cvars are accessible through scripts as well. 
//
//	History:
//	-	September 2001: File created by Marco Corbetta
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

extern (C++)
{
	//interface ConsoleBind;
	//class CXFont;
	//interface ICVar;

	enum CVAR_INT = 1;
	enum CVAR_FLOAT = 2;
	enum CVAR_STRING = 3;

	// if this flag is set during registering a console variable, and the variable exists,
	// then the variable will store its value in memory given by src
	enum CVF_CHANGE_SOURCE = (1u << 16);

	enum VF_SERVER_ONCE = 0x00000001;
	enum VF_CHEAT = 0x00000002;
	enum VF_USERINFO = 0x00000004;
	enum VF_MODIFIED = 0x00000008;
	enum VF_SERVER = 0x00000010;
	enum VF_NONOTIFY = 0x00000020;
	enum VF_NOCHANGELEV = 0x00000040;
	enum VF_REQUIRE_NET_SYNC = 0x00000080;
	enum VF_DUMPTODISK = 0x00000100;
	enum VF_SAVEGAME = 0x00000200;
	enum VF_NOHELP = 0x00000400;
	enum VF_READONLY = 0x00000800;
	enum VF_REQUIRE_LEVEL_RELOAD = 0x00001000;
	enum VF_REQUIRE_APP_RESTART = 0x00002000;

	//////////////////////////////////////////////////////////////////////
	interface ICVarDumpSink
	{
		void OnElementFound(ICVar* pCVar);
	};

	//////////////////////////////////////////////////////////////////////
	interface IKeyBindDumpSink
	{
		void OnKeyBindFound(const char* sBind, const char* sCommand);
	};

	//////////////////////////////////////////////////////////////////////
	interface IOutputPrintSink
	{
		void Print(const char* inszText);
	};

	//////////////////////////////////////////////////////////////////////
	//! Callback class to derive from when you want to recieve callbacks when console var changes.
	interface IConsoleVarSink
	{
		//! Called by Console before changing console var value, to validate if var can be changed.
		//! @return true if ok to change value, false if should not change value.
		bool OnBeforeVarChange(ICVar* pVar, const char* sNewValue);
	};

	//////////////////////////////////////////////////////////////////////
	/*! Interface to the engine console.

	The engine console allow to manipulate the internal engine parameters
	and to invoke commands.
	This interface allow external modules to integrate their functionalities
	into the console as commands or variables.

	IMPLEMENTATIONS NOTES:
	The console takes advantage of the script engine to store the console variables,
	this mean that all variables visible through script and console.

*/
	interface IConsole
	{
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! delete the variable
		NOTE: the variable will automatically unregister itself from the console
	*/
		void Release();
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Crate a new console variable
		@param sName console variable name
		@param sValue default value
		@param nFlag user definded flag, this parameter is used by other subsystems 
			and doesn't affect the console varible (basically of user data)
		@return a pointer to the interface ICVar
		@see ICVar
	*/
		ICVar* CreateVariable(const char* sName, const char* sValue,
				int nFlags, const char* help = "");
		ICVar* CreateVariable(const char* sName, int iValue,
				int nFlags, const char* help = "");
		ICVar* CreateVariable(const char* sName, float fValue,
				int nFlags, const char* help = "");
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Remove a variable from the console
		@param sVarName console variable name
		@param bDelete if true the variable is deleted
		@see ICVar
	*/
		void UnregisterVariable(const char* sVarName, bool bDelete = false);
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Set the y coordinate where the console will stop to scroll when is dropped
		@param value y in screen coordinates
	*/
		void SetScrollMax(int value);
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! add output sink (clases which are interested in the output) - order is not guaranteed
		@param inpSink must not be 0 and is not allowed to be added twice
	*/
		void AddOutputPrintSink(IOutputPrintSink inpSink);
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! remove output sink (clases which are interested in the output) - order is not guaranteed
		@param inpSink must not be 0 and has to be added before
	*/
		void RemoveOutputPrintSink(IOutputPrintSink inpSink);

		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! show/hide the console
		@param specifies if the window must be (true=show,false=hide)
	*/
		void ShowConsole(bool show);
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Crate a new console variable that store the value in a user defined memory block
		@param sName console variable name
		@param src pointer to the memory that will store the value 
		@param value default value
		@param type type of the value (can be CVAR_INT|CVAR_FLOAT)
		@return the value
		@see ICVar
	*/
		int Register(const char* name, void* src, float defaultvalue,
				int flags, int type, const char* help = "");
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Crate a new console variable that store the value in a user defined floating point
		@param sName console variable name
		@param src pointer to the memory that will store the value 
		@param value default value
		@return the value
		@see ICVar
	*/
		float Register(const char* name, float* src, float defaultvalue,
				int flags = 0, const char* help = "");
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Crate a new console variable that store the value in a user defined integer
				@param sName console variable name
				@param src pointer to the memory that will store the value 
				@param value default value
				@return the value
				@see ICVar
			*/
		int Register(const char* name, int* src, float defaultvalue,
				int flags = 0, const char* help = "");
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Dump all console-variables to a callback-interface
				@param Callback callback-interface which needs to be called for each element
			*/
		void DumpCVars(ICVarDumpSink* pCallback, uint nFlagsFilter = 0);

		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Bind a console command to a key
				@param sCmd console command that must be executed
				@param sRes name of the key to invoke the command
				@param bExecute legacy parameter(will be removed soon)
			*/
		void CreateKeyBind(const char* sCmd, const char* sRes, bool bExecute);
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Sets the background-image
				@param pImage background-image
			*/
		void SetImage(ITexPic* pImage, bool bDeleteCurrent);
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Retrieves the background-image
				@return background-image
			*/
		ITexPic* GetImage();
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Sets static/scroll background-mode
				@param bStatic true if static
			*/
		void StaticBackground(bool bStatic);

		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Sets the loading-background-image
			@param pImage background-image
			*/
		void SetLoadingImage(const char* szFilename);

		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Iterate through the lines - used for dedicated server (truncated if needed)
				@param indwLineNo 0.. counted from the last printed line on
				@param outszBuffer pointer to the destination string buffer (zero terminted afterwards), must not be 0
				@param indwBufferSize 1.. size of the buffer
				@return true=line was returned, false=there are no more lines
			*/

		bool GetLineNo(const DWORD indwLineNo, char* outszBuffer,
				const DWORD indwBufferSize) const;

		/*! @return current number of lines in the console
			*/
		int GetLineCount() const;

		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Retrieve a console variable by name
				@param sName variable name
				@param bCaseSensitive true=faster, false=much slower but allowes names with wrong case (use only where performce doesn't matter)
				@return a pointer to the ICVar interface, NULL if is not found
				@see ICVar
			*/
		ICVar* GetCVar(const char* name, const bool bCaseSensitive = true);
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! legacy function */
		CXFont* GetFont();
		/*! legacy function */
		void Help(const char* command = NULL);
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Read a value from a configuration file (.ini) and return the value
				@param szVarName variable name
				@param szFileName source configuration file
				@param def_val default value (if the variable is not found into the file)
				@return the variable value
			*/
		char* GetVariable(const char* szVarName, const char* szFileName, const char* def_val);
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Read a value from a configuration file (.ini) and return the value
				@param szVarName variable name
				@param szFileName source configuration file
				@param def_val default value (if the variable is not found into the file)
				@return the variable value
			*/
		float GetVariable(const char* szVarName, const char* szFileName, float def_val);
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Print a string in the console and go to the new line
				@param s the string to print
			*/
		void PrintLine(const char* s);
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Append a string in the last console line
				@param s the string to print
			*/
		void PrintLinePlus(const char* s);
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Retreive the status of the console (active/not active)
				@return the variable value(true = active/false = not active)
			*/
		bool GetStatus();
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Clear the console text
			*/
		void Clear();

		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Update the console
			*/
		void Update();
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Draw the console
			*/
		void Draw();
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Add a Console command
				@param sName name of the command (ex "connect")
				@param sScriptFunc script buffer the contain the command implementation
					EG "Game.Connect(%1)" the symbol "%1" will be replaced with the command parameter 1
					writing in the console "connect 127.0.0.1" will invoke Game.Connect("127.0.0.1")
				@param indwFlags bitfield consist of VF_ flags (e.g. VF_CHEAT)
			*/
		void AddCommand(const char* sName, const char* sScriptFunc,
				const DWORD indwFlags = 0, const char* help = "");
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Execute a string in the console
				@param command console command
			*/
		void ExecuteString(const char* command, bool bNeedSlash = false,
				bool bIgnoreDevMode = false);
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Print a message into the log and abort the execution of the application
				@param message error string to print in the log
			*/
		void Exit(const char* command, ...);
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Return true if the console is opened
				@return the variable value(true = opened/false = closed)
			*/
		bool IsOpened();

		//////////////////////////////////////////////////////////////////////////
		// Auto completion.
		//////////////////////////////////////////////////////////////////////////
		int GetNumVars();
		void GetSortedVars(const char** pszArray, size_t numItems);
		const char* AutoComplete(const char* substr);
		const char* AutoCompletePrev(const char* substr);
		char* ProcessCompletion(const char* szInputBuffer);
		//! 
		void ResetAutoCompletion();

		void DumpCommandsVars(char* prefix);

		//! Calculation of the memory used by the whole console system
		void GetMemoryUsage(ICrySizer* pSizer);

		//! Function related to progress bar
		void ResetProgressBar(int nProgressRange);
		//! Function related to progress bar
		void TickProgressBar();

		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Dump all key bindings to a callback-interface
				@param Callback callback-interface which needs to be called for each element
				*/
		void DumpKeyBinds(IKeyBindDumpSink* pCallback);
		const char* FindKeyBind(const char* sCmd);

		//////////////////////////////////////////////////////////////////////////
		// Console variable sink.
		//////////////////////////////////////////////////////////////////////////
		//! Adds a new console variables sink callback.
		void AddConsoleVarSink(IConsoleVarSink* pSink);
		//! Removes a console variables sink callback.
		void RemoveConsoleVarSink(IConsoleVarSink* pSink);

		//////////////////////////////////////////////////////////////////////////
		// History
		//////////////////////////////////////////////////////////////////////////

		//! \param bUpOrDown true=after pressed "up", false=after pressed "down"
		//! \return 0 if there is no history line or pointer to the null terminated history line
		const char* GetHistoryElement(const bool bUpOrDown);
		//! \param szCommand must not be 0
		void AddCommandToHistory(const char* szCommand);
	};

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//! this interface is the 1:1 "C++ representation"
	//! of a console variable.
	//! NOTE: a console variable is accessible in C++ trough
	//! this interface and in all scripts as global variable
	//! (with the same name of the variable in the console)
	interface ICVar
	{
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! delete the variable
		NOTE: the variable will automatically unregister itself from the console
	*/
		void Release();
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Return the integer value of the variable
		@return the value
	*/
		int GetIVal();
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Return the float value of the variable
		@return the value
	*/
		float GetFVal();
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Return the string value of the variable
		@return the value
	*/
		const(char*) GetString() const;
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! set the string value of the variable
		@param s string representation the value
	*/
		void Set(const char* s);

		/*! Force to set the string value of the variable - can be called 
			from inside code only
		@param s string representation the value
	*/
		void ForceSet(const char* s);
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! set the float value of the variable
		@param s float representation the value
	*/
		void Set(float f);
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! set the float value of the variable
		@param s integer representation the value
	*/
		void Set(int i);
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! refresh the values of the variable
	*/
		void Refresh();
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! clear the specified bits in the flag field
	*/
		void ClearFlags(int flags);
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! return the variable's flags 
		@return the variable's flags
	*/
		int GetFlags();
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! Set the variable's flags 
	*/
		int SetFlags(int flags);
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! return the primary variable's type
		@return the primary variable's type
	*/
		int GetType();
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! return the variable's name
		@return the variable's name
	*/
		const char* GetName();
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*! return the variable's name
		@return the variable's name
	*/
		const char* GetHelp();

	}

}
