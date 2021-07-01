module GameFiles.ScriptTimerMgr;

//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//		
// File: ScriptTimerMgr.h: 
// Description: Interface for the CScriptTimerMgr class.
//
//	History:
//	- December 11,2001: File created
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

import platform;
import isystem;

//////////////////////////////////////////////////////////////////////////
struct ScriptTimer{
	this(IScriptObject *_pTable,int64 _nStartTimer,int64 _nTimer,IScriptObject *_pUserData=NULL,bool _bUpdateDuringPause=true)
	{
		nTimer=_nTimer;
		nStartTime=_nStartTimer;
		pTable=_pTable;
		pUserData=_pUserData;
		bUpdateDuringPause=_bUpdateDuringPause;
	}
	~this()
	{
		if(pTable!=NULL)
			pTable.Release();
		if(pUserData!=NULL)
			pUserData.Release();
	}
	int64 nTimer;
	int64 nStartTime;
	IScriptObject *pTable;
	IScriptObject *pUserData;
	bool		bUpdateDuringPause;
};

alias ScriptTimer[int] ScriptTimerMap;
//alias ScriptTimerMap::iterator  ScriptTimerMapItor;

//////////////////////////////////////////////////////////////////////////
class CScriptTimerMgr  
{
public:
	this(IScriptSystem *pScriptSystem,IEntitySystem *pS,IGame *pGame);
	/*virtual*/ ~this();
	int		AddTimer(IScriptObject *pTable,int64 nStartTimer,int64 nTimer,IScriptObject *pUserData,bool bUpdateDuringPause);
	void	RemoveTimer(int nTimerID);
	void	Update(int64 nCurrentTime);
	void	Reset();
	void	Pause(bool bPause); 
private:
	ScriptTimerMap m_mapTimers;
	ScriptTimerMap m_mapTempTimers;
	IScriptSystem *m_pScriptSystem;
	IEntitySystem *m_pEntitySystem;	
	IGame					*m_pGame;
	int		m_nLastTimerID;
	bool	m_bPause;
};
