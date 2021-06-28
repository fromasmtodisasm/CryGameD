module ScriptDebugger;

public import isystem;
import game;

extern (C++):

class CScriptDebugSink : IScriptDebugSink
{
	IScriptSystem m_pScriptSystem;

	this(IScriptSystem pScriptSystem)
	{
		m_pScriptSystem = pScriptSystem;
		CryLogAlways("Debug Script Sink Constructed");
	}

	void OnLoadSource(const char* sSourceName, char* sSource, long nSourceSize)
	{
		game.GetISystem().GetILog().LogWarning("Debug Script Sink OnLoadSource");
	}

	void OnExecuteLine(ref ScriptDebugInfo sdiDebugInfo)
	{
		game.GetISystem().GetILog().LogWarning("Debug Script Sink OnExecuteLine");

	}
}
