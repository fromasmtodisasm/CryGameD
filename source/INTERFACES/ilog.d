module ilog;

import core.stdc.stdio;

import iminilog;

version (Linux)
{
	import platform;
}
////////////////////////////////////////////////////////////////////////////
const auto LOG_TO_FILE = (1L << 8);
const auto LOG_TO_CONSOLE = (2L << 8);
const auto LOG_TO_FILE_PLUS = (4L << 8); //
const auto LOG_TO_CONSOLE_PLUS = (8L << 8); //
const auto LOG_TO_SCREEN = (16L << 8);
const auto LOG_TO_SCREEN_PLUS = (32L << 8); //
const auto LOG_TO_FILE_AND_CONSOLE = (LOG_TO_FILE | LOG_TO_CONSOLE);

//verbosity levels
////////////////////////////////////////////////////////////////////////////
// log verbosity levels are from 1 to 5 (default is 5, 1 for messages with "ERROR", 3 for messages with "WARNING")
// global verbosity levels are from 0 to 5

// LEVEL 1 - Critical messages. Only events that are critical for the proper operation of the game need to be logged at this level. This includes features - event that are critical for a feature to work MUST be logged at this level.
// LEVEL 2 - Artifact filter - This level is for events that will not affect the basic operation of the game, but might introduce artifacts (visual or in the way the features work).
// LEVEL 3 - Startup / Shutdown logs - Basically information when systems start and when they shutdown as well as some diagnostic information if you want.
// LEVEL 4 - Events that are used for debugging purposes (like entity spawned there and there, which sector of the building we are loading etc)
// LEVEL 5 - Everything else - including stuff like (x=40 y=30 z=30 five times a frame :) 

// This means that clean verbosity 2 should guarantee a top notch run of the game.

// the console variable called log_Verbosity defines the verbosity
// level.
// With this option, the level of verbosity of the output is controlled.
// This option can be given multiple times to set the verbosity level to that value. 
// The default global verbosity level is 0, in which no log messages will be displayed.
//
// Usage:
//
// e.g. System:Log("\001 This is log verbosity 1") for error
// e.g. System:Log("\002 This is log verbosity 2")
// e.g. System:Log("\003 This is log verbosity 3") for warning
// e.g. System:Log("\004 This is log verbosity 4")
// e.g. System:Log("\005 This is log verbosity 5")
//
// e.g. System:Log("\002 This is log verbosity 2")      
//      with global_verbosity_level 1 this is not printed but with global_verbosity_level 2 or higher it is

////////////////////////////////////////////////////////////////////////////
interface ILog : IMiniLog
{
	void Release();

	//set the file used to log to disk
	void SetFileName(const char * command = null);
	//
	const char * GetFileName();

	//will log the text both to file and console
	void Log(const char * szCommand, ...);

	void LogWarning(const char * szCommand, ...);

	void LogError(const char * szCommand, ...);

	//will log the text both to the end of file and console
	void LogPlus(const char * command, ...);

	//log to the file specified in setfilename
	void LogToFile(const char * command, ...);

	//
	void LogToFilePlus(const char * command, ...);

	//log to console only
	void LogToConsole(const char * command, ...);

	//
	void LogToConsolePlus(const char * command, ...);

	//
	void UpdateLoadingScreen(const char * command, ...);

	//
	void UpdateLoadingScreenPlus(const char * command, ...);

	//
	void EnableVerbosity(bool bEnable);

	//
	void SetVerbosity(int verbosity);

	int GetVerbosityLevel();
};

////////////////////////////////////////////////////////////////////////////
// wrapper for PC and Xbox
FILE* fxopen(const char* file, const char* mode)
{
	version (LINUX)
	{
		return fopen_nocase(file, mode);
	}
	else
	{
		return fopen(file, mode);
	}
}
