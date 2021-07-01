module IScriptSystem;

import platform;
import isystem;

extern (C++)
{
	alias void* HSCRIPT;
	alias uint HSCRIPTFUNCTION;
	enum
	{
		//## [Sergiy] this is the same as LUA_NOREF; I think this is better to use since 
		//## in LUA documentation only LUA_NOREF(-2) and LUA_REFNIL (-1) are described as
		//## special values, 0 isn't. Please put 0 here if you know for sure and it is documented
		//## that 0 is invalid reference value for LUA
		INVALID_SCRIPT_FUNCTION = -2
	};
	alias void* THIS_PTR;
	alias int HTAG;
	alias ULONG_PTR USER_DATA; //## AMD Port

	alias int function(HSCRIPT hScript) SCRIPT_FUNCTION;
	alias int HBREAKPOINT;

	enum BreakState
	{
		bsStepNext,
		bsStepInto,
		bsContinue,
		bsNoBreak
	};

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	/*! IScriptSystem callback interface
	this interface must be implemented by host applicatio the use the scripting system
	to receive error messages and notification
*/

	// Summary:
	//   Callback interface.
	// Description:
	//   This interface must be implemented by the host application in order to 
	//   receive error messages and various notifications from the Scripting 
	//   System.
	interface IScriptSystemSink
	{
		/*! called by the scripting system when an error occur
		@param sSourceFile the script file where the error occured
		@param sFuncName the script function where the error occured
		@param nLineNum the line number of the the script file where the error occured (-1 if there is no line no info)
		@param sErrorDesc descriptio of the error
	*/
		void OnScriptError(const char* sSourceFile,
				const char* sFuncName, int nLineNum, const char* sErrorDesc);

		/*! called by the scripting system to ask for permission to change a global tagged value
		@return true if permission is granted, false if not
	*/
		bool CanSetGlobal(const char* sVarName);

		/*! called by the scripting system when a global tagged value is set by inside a script
		@param sVarName the name of the variable that has been changed
	*/
		void OnSetGlobal(const char* sVarName);
		/*! called by the scripting system for each load script when DumpLoadedScripts is called
		@param sScriptPath path of a script
	*/
		void OnLoadedScriptDump(const char* sScriptPath);
		void OnCollectUserData(INT_PTR nValue, int nCookie); //## AMD Port
	};

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	/*! main interface of the scripting engine
		this interface is mapped 1:1 on a script state
		all script loaded from the same interface instance are visible together
	*/
	interface IScriptSystem
	{
		//DOC-IGNORE-BEGIN
		//! internal use
		IFunctionHandler* GetFunctionHandler();
		//! internal use
		HSCRIPT GetScriptHandle();
		//DOC-IGNORE-END

		/*! load a script file and run it
			@param sFileName path of the script file
			@param bRaiseError if true the script engine will call IScirptSystemSink::OnError() if
				an error will occur
			@return false if the execution fail if not true

			REMARKS: all global variables and function declared into the executed script
			will persist for all the script system lifetime
	*/
		bool ExecuteFile(const char* sFileName, bool bRaiseError = true,
				bool bForceReload = false);
		/*! execute an ASCII buffer
			@param sBuffer an 8bit ASCII buffer containing the script that must be executed
			@param bRaiseError if true the script engine will call IScirptSystemSink::OnError() if
				an error will occur
			@return false if the execution fail if not true

			REMARKS: all global variables and function declared into the executed buffer
			will persist for all the script system lifetime
	*/
		bool ExecuteBuffer(const char* sBuffer, size_t nSize);
		/*! unload a script 
			@param sFileName apath of the script file

			NOTES: the script engine never load twice the same file(same path) because internally
			stores a list of loaded files.This function simple remove the specified path from
			this list
	*/
		void UnloadScript(const char* sFileName);
		/*! unload all scripts
			
			NOTES: the script engine never load twice the same file(same path) because internally
			stores a list of loaded files.This function simple remove all entries from
			this list
	*/
		void UnloadScripts();
		/*! realod a script
			@param sFileName apath of the script file
			@param bRaiseError if true the script engine will call IScirptSystemSink::OnError() if
				an error will occur
			@return false if the execution fail if not true
	*/
		bool ReloadScript(const char* sFileName, bool bRaiseError = true);
		//! reload all scripts previously loaded
		bool ReloadScripts();
		//! generate a OnLoadedScriptDump() for every loaded script
		void DumpLoadedScripts() = 0;
		//! return a object that store all global variables as members 
		IScriptObject* GetGlobalObject();

		/*! create a new IScriptObject that is not mapped to a object in the script
		this is used to store an object that lua pass to a C++ function
		@return a pointer to the created object
	*/
		IScriptObject* CreateEmptyObject();
		/*!	create a new IScriptObject 
		@return a pointer to the created object
	*/
		IScriptObject* CreateObject();
		/*!	create a global IScriptObject 
		@param sName the name of the object into the script scope
		@param pThis pointer to the C++ class that will receive a call from the script
			[this parameter can be NULL]
		@return a pointer to the created object
	*/
		IScriptObject* CreateGlobalObject(const char* sName);

		/*! start a call to script function
		@param sTableName name of the script table that contai the function
		@param sFuncName function name


		CALLING A SCRIPT FUNCTION:
			to call a function in the script object you must
			call BeginCall
			push all parameters whit PushParam
			call EndCall

	
		EXAMPLE:

			m_ScriptSystem.BeginCall("Player","OnInit");

			m_ScriptSystem.PushParam(pObj);

			m_ScriptSystem.PushParam(nTime);

			m_ScriptSystem.EndCall();
			
	*/
		//##@{
		int BeginCall(HSCRIPTFUNCTION hFunc); // Mбrcio: changed the return type 
		int BeginCall(const char* sFuncName); // from void to int for error checking
		int BeginCall(const char* sTableName, const char* sFuncName); //
		//##@}

		/*! end a call to script function
		@param ret reference to the variable that will store an eventual return value
	*/
		//##@{
		void EndCall();
		void EndCall(ref int nRet);
		void EndCall(ref float fRet);
		void EndCall(const ref char* sRet);
		void EndCall(ref bool bRet);
		void EndCall(IScriptObject* pScriptObject);
		//##@}

		/*! function under development ingnore it*/
		//##@{
		HSCRIPTFUNCTION GetFunctionPtr(const char* sFuncName);
		HSCRIPTFUNCTION GetFunctionPtr(const char* sTableName, const char* sFuncName);
		//##@}
		void ReleaseFunc(HSCRIPTFUNCTION f);
		/*! push a parameter during a function call
		@param val value that must be pushed
	*/
		//##@{
		void PushFuncParam(int nVal);
		void PushFuncParam(float fVal);
		void PushFuncParam(const char* sVal);
		void PushFuncParam(bool bVal);
		void PushFuncParam(IScriptObject* pVal);
		//##@}

		/*! set a global script variable
		@param sKey variable name
		@param val variable value
	*/
		//##@{
		void SetGlobalValue(const char* sKey, int nVal);
		void SetGlobalValue(const char* sKey, float fVal);
		void SetGlobalValue(const char* sKey, const char* sVal);
		void SetGlobalValue(const char* sKey, IScriptObject* pObj);
		//##@}

		//! get the value of a global variable
		//##@{
		bool GetGlobalValue(const char* sKey, ref int nVal);
		bool GetGlobalValue(const char* sKey, ref float fVal);
		bool GetGlobalValue(const char* sKey, ref const char* sVal);
		bool GetGlobalValue(const char* sKey, IScriptObject* pObj);
		void SetGlobalToNull(const char* sKey);
		//##@}

		/*! create a global tagged value
		a tagged value is a varible tha is visible in lua as a normal
		script variable but his value is stored into a c++ defined memory block
		@param sKey name of the value
		@param pVal pointer to the C++ variable tha will store the value
		@return if succeded an handle to the tagged value else NULL
	*/
		//##@{
		HTAG CreateTaggedValue(const char* sKey, int* pVal);
		HTAG CreateTaggedValue(const char* sKey, float* pVal);
		HTAG CreateTaggedValue(const char* sKey, char* pVal);
		//##@}

		USER_DATA CreateUserData(INT_PTR nVal, int nCookie);
		/*! remove a tagged value
		@param tag handle to a tagged value
	*/
		void RemoveTaggedValue(HTAG tag);

		/*! generate a script error
		@param sErr "printf like" string tha define the error
	*/
		void RaiseError(const char* sErr, ...);

		/*! force a Garbage collection cycle
		in the current status of the engine the automatic GC is disabled
		so this function must be called explicitly
	*/
		void ForceGarbageCollection();

		/*! number of "garbaged" object
	*/
		int GetCGCount();

		/*! legacy function*/
		void SetGCThreshhold(int nKb);

		/*! un bind all gc controlled userdata variables (from this point is the application that must explicitly delete those objs)*/
		void UnbindUserdata();

		/*! release and destroy the script system*/
		void Release();

		//!debug functions
		//##@{
		void EnableDebugger(IScriptDebugSink pDebugSink);
		IScriptObject* GetBreakPoints();
		HBREAKPOINT AddBreakPoint(const char* sFile, int nLineNumber);
		IScriptObject* GetLocalVariables(int nLevel = 0);
		/*!return a table containing 1 entry per stack level(aka per call)
		an entry will look like this table
		
		[1]={
			description="function bau()",
			line=234,
			sourcefile="/scripts/bla/bla/bla.lua"
		}
	 
	 */
		IScriptObject* GetCallsStack();
		void DebugContinue();
		void DebugStepNext();
		void DebugStepInto();
		void DebugDisable();
		BreakState GetBreakState();
		//##@}
		void GetMemoryStatistics(ICrySizer* pSizer);
		//! Is not recusive but combines the hash values of the whole table when the specifies variable is a table
		//! otherwise is has to be a lua function
		//!	@param sPath zero terminated path to the variable (e.g. _localplayer.cnt), max 255 characters
		//!	@param szKey zero terminated name of the variable (e.g. luaFunc), max 255 characters
		//! @param dwHash is used as input and output
		void GetScriptHash(const char* sPath, const char* szKey, ref uint dwHash);

		//////////////////////////////////////////////////////////////////////////
		// Called one time after initialization of system to register script system console vars.
		//////////////////////////////////////////////////////////////////////////
		void PostInit();
	};

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	struct IScriptObjectSink
	{
		void OnRelease();
	};

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	enum ScriptVarType
	{
		svtNull = 0,
		svtString,
		svtNumber,
		svtFunction,
		svtObject,
		svtUserData,
	};

	// Returns literal representation of the type value
	const (char)* ScriptVarTypeAsCStr(ScriptVarType t)
	{
		switch (t)
		{
		case ScriptVarType.svtNull:
			return "Null";
		case ScriptVarType.svtString:
			return "String";
		case ScriptVarType.svtNumber:
			return "Number";
		case ScriptVarType.svtFunction:
			return "Function";
		case ScriptVarType.svtObject:
			return "Object";
		case ScriptVarType.svtUserData:
			return "UserData";
		default:
			return "#Unknown";
		}
	}

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////

	struct IScriptObjectDumpSink
	{
		void OnElementFound(const char* sName, ScriptVarType type);
		void OnElementFound(int nIdx, ScriptVarType type);
	};

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	struct IScriptObject
	{
		//DOC-IGNORE-BEGIN
		//! internal use
		int GetRef();
		//! internal use
		//DOC-IGNORE-END
		void Attach();
		void Attach(IScriptObject* so);

		void Delegate(IScriptObject* pObj);
		void PushBack(int nVal);
		void PushBack(float fVal);
		void PushBack(const char* sVal);
		void PushBack(bool bVal);
		void PushBack(IScriptObject* pObj);

		/*! Set the value of a memeber varible
		@param sKey variable name
		@param val variable value
	*/
		//##@{
		void SetValue(const char* sKey, int nVal);
		void SetValue(const char* sKey, float fVal);
		void SetValue(const char* sKey, const char* sVal);
		void SetValue(const char* sKey, bool bVal);
		void SetValue(const char* sKey, IScriptObject* pObj);
		void SetValue(const char* sKey, USER_DATA ud);
		//##@}
		/*! Set the value of a member variable to nil 
		@param sKey variable name
	*/
		void SetToNull(const char* sKey);

		/*! Get the value of a memeber varible
		@param sKey variable name
		@param val reference to the C++ variable that will store the value
		@return false if failed true if succeded
	*/
		//##@{
		bool GetValue(const char* sKey, ref int nVal);
		bool GetValue(const char* sKey, ref float fVal);
		bool GetValue(const char* sKey, ref bool bVal);
		bool GetValue(const char* sKey, ref const char* sVal);
		bool GetValue(const char* sKey, IScriptObject* pObj);
		bool GetValue(const char* sKey, ref HSCRIPTFUNCTION funcVal);
		bool GetUDValue(const char* sKey, ref USER_DATA nValue, ref int nCookie); //## AMD Port
		//! used to create a hash value out of a lua function (for cheat protection)
		bool GetFuncData(const char* sKey, ref uint* pCode, ref int iSize);
		//##@}

		/*! Get the value of a memeber varible
		@param sKey variable name
		@param val reference to the C++ variable that will store the value
		@return false if failed true if succeded
	*/
		//##@{
		bool BeginSetGetChain();
		bool GetValueChain(const char* sKey, ref int nVal);
		//bool GetValueChain(const char *sKey, unsigned int &nVal);
		bool GetValueChain(const char* sKey, ref float fVal);
		bool GetValueChain(const char* sKey, ref bool bVal);
		bool GetValueChain(const char* sKey, ref const char* sVal);
		bool GetValueChain(const char* sKey, IScriptObject* pObj);
		bool GetValueChain(const char* sKey, ref HSCRIPTFUNCTION funcVal);
		bool GetUDValueChain(const char* sKey, ref USER_DATA nValue, ref int nCookie); //## AMD Port
		void SetValueChain(const char* sKey, int nVal);
		void SetValueChain(const char* sKey, float fVal);
		void SetValueChain(const char* sKey, const char* sVal);
		void SetValueChain(const char* sKey, bool bVal);
		void SetValueChain(const char* sKey, IScriptObject* pObj);
		void SetValueChain(const char* sKey, USER_DATA ud);
		void SetToNullChain(const char* sKey);
		void EndSetGetChain();
		//##@}

		/*!Get the vaue type of a table member 
		@param sKey variable name
		@return the value type (svtNull if doesn't exist)
	*/
		ScriptVarType GetValueType(const char* sKey);
		ScriptVarType GetAtType(int nIdx);

		/*! Set the value of a memeber varible at the specified index
		this mean that you will use the object as vector into the script
		@param nIdx index of the variable
		@param val variable value
	*/
		//##@{
		void SetAt(int nIdx, int nVal);
		void SetAt(int nIdx, float fVal);
		void SetAt(int nIdx, bool bVal);
		void SetAt(int nIdx, const char* sVal);
		void SetAt(int nIdx, IScriptObject* pObj);
		void SetAtUD(int nIdx, USER_DATA nValue);
		//##@}

		/*! Set the value of a member variable to nil at the specified index
		@param nIdx index of the variable
	*/
		void SetNullAt(int nIdx);

		/*! Get the value of a memeber varible at the specified index
		@param nIdx index of the variable
		@param val reference to the C++ variable that will store the value
		@return false if failed true if succeded
	*/
		//##@{
		bool GetAt(int nIdx, ref int nVal);
		bool GetAt(int nIdx, ref float fVal);
		bool GetAt(int nIdx, ref bool bVal);
		bool GetAt(int nIdx, ref const char* sVal);
		bool GetAt(int nIdx, IScriptObject* pObj);
		bool GetAtUD(int nIdx, ref USER_DATA nValue, ref int nCookie);
		//##@}

		bool BeginIteration();
		bool MoveNext();
		bool GetCurrent(ref int nVal);
		bool GetCurrent(ref float fVal);
		bool GetCurrent(ref bool bVal);
		bool GetCurrent(ref const char* sVal);
		bool GetCurrent(IScriptObject* pObj);
		//! used to get a unique identifier for the table (to iterate without problems with cycles)
		bool GetCurrentPtr(ref const void* pObj);
		//! used to create a hash value out of a lua function (for cheat protection)
		bool GetCurrentFuncData(ref uint* pCode, ref int iSize);
		bool GetCurrentKey(ref const char* sVal);

		bool GetCurrentKey(ref int nKey);
		ScriptVarType GetCurrentType();
		void EndIteration();

		void SetNativeData(void*);
		void* GetNativeData();

		void Clear();
		//! get the count of elements into the object
		int Count() = 0;

		/* 
	*/
		bool Clone(IScriptObject* pObj);
		//DOC-IGNORE-BEGIN
		/*under development*/
		void Dump(IScriptObjectDumpSink* p);
		//DOC-IGNORE-END
		/*!	add a function to the object
		@param name of the function
		@param C++ function pointer(declared as SCRIPT_FUNCTION)
		@param nFuncID id of the function that will be passed beck by the engine
		@return false if failed true if succeded
	*/
		bool AddFunction(const char* sName, SCRIPT_FUNCTION pThunk, int nFuncID);
		//!
		bool AddSetGetHandlers(SCRIPT_FUNCTION pSetThunk, SCRIPT_FUNCTION pGetThunk);
		/*!	register the host object as parent
		@param pSink pointer to an object that implement IScriptObjectSink

		NOTE: if the parent is registered the script object will notify when is deleted
	*/
		void RegisterParent(IScriptObjectSink* pSink);
		//! detach the IScriptObject from the "real" script object
		//! used to detach from the C++ code quick objects like vectors or temporary structures
		void Detach();
		//! delete the IScriptObject/
		void Release();
		//! @param szPath e.g. "cnt.table1.table2", "", "mytable", max 255 characters
		//! @return true=path was valid, false otherwise
		bool GetValueRecursive(const char* szPath, IScriptObject* pObj);
	};

	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	//DOC-IGNORE-BEGIN
	/*! internal use*/
	interface IWeakScriptObject
	{
		IScriptObject* GetScriptObject();
		void Release() = 0;
	};
	//DOC-IGNORE-END
	////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////
	// Description:
	//   This interface is used by the C++ function mapped to the script
	//   to retrieve the function parameters passed by the script and
	//   to return an optiona result value to the script.
	interface IFunctionHandler
	{
		//DOC-IGNORE-BEGIN
		/*! internal use */
		void __Attach(HSCRIPT hScript);
		/*! internal use */
		THIS_PTR GetThis();
		//THIS_PTR GetThis2();
		/*! internal use */
		int GetFunctionID();
		//DOC-IGNORE-END

		//!	Get the number of parameter passed by lua
		int GetParamCount();

		/*! get the nIdx param passed by the script
		@param nIdx 1-based index of the parameter
		@param val reference to the C++ variable that will store the value
		@param nReference should the function create strong reference to the object? By default 0, means weak reference is created
	*/
		//##@{
		bool GetParam(int nIdx, ref int n);
		bool GetParam(int nIdx, ref float f);
		bool GetParam(int nIdx, ref const char* s);
		bool GetParam(int nIdx, ref bool b);
		bool GetParam(int nIdx, IScriptObject* pObj);
		bool GetParam(int nIdx, ref HSCRIPTFUNCTION hFunc, int nReference = 0);
		bool GetParam(int nIdx, ref USER_DATA ud);
		bool GetParamUDVal(int nIdx, ref USER_DATA val, ref int cookie); //## AMD Port
		//##@}
		ScriptVarType GetParamType(int nIdx);

		/*! get the return value that you must return from your "SCRIPT_FUNCTION"
		@param the value that xou want to return to the script
	*/
		//##@{
		int EndFunctionNull();
		int EndFunction(int nRetVal);
		int EndFunction(float fRetVal);
		int EndFunction(const char* fRetVal);
		int EndFunction(bool bRetVal);
		int EndFunction(IScriptObject* pObj);
		int EndFunction(HSCRIPTFUNCTION hFunc);
		int EndFunction(USER_DATA ud);
		int EndFunction();

		// 2 return params versions.
		int EndFunction(int nRetVal1, int nRetVal2);
		int EndFunction(float fRetVal1, float fRetVal2);
		//##@}

		void Unref(HSCRIPTFUNCTION hFunc);
	};

	//DOC-IGNORE-BEGIN
	//! under development
	struct ScriptDebugInfo
	{
		const char* sSourceName;
		int nCurrentLine;
	};

	//! under development
	interface IScriptDebugSink
	{
		void OnLoadSource(const char* sSourceName, char* sSource, long nSourceSize);
		void OnExecuteLine(ref ScriptDebugInfo sdiDebugInfo);
	};
	//DOC-IGNORE-END

	/////////////////////////////////////////////////////////////////////////////
	//Utility classes
	/////////////////////////////////////////////////////////////////////////////

	enum USE_WEAK_OBJS = 1;
class _SmartScriptObject
{
	this(const ref _SmartScriptObject)
	{
	}
	/*
	ref _SmartScriptObject operator =(ref const _SmartScriptObject )
	{
		return *this;
	};
	_SmartScriptObject& operator =(IScriptObject *)
	{
		return *this;
	}
public:
	_SmartScriptObject()
	{
			m_pSO=NULL;
	}
	explicit _SmartScriptObject(IScriptSystem *pSS,IScriptObject *p)
	{
    	m_pSO=pSS.CreateEmptyObject();
			m_pSO.Attach(p);
	}
	explicit _SmartScriptObject(IScriptSystem *pSS,bool bCreateEmpty=false)
	{
		if(!bCreateEmpty)
		{
			m_pSO=pSS.CreateObject();
		}
		else{
			m_pSO=pSS.CreateEmptyObject();
		}
	}
	*/
	~this()
	{
		if(m_pSO)
			m_pSO.Release();

	}
	/*	
	IScriptObject *operator .(){
		return m_pSO;
	}
	IScriptObject *operator *(){
		return m_pSO;
	}
	operator const IScriptObject*() const
	{
		return m_pSO;
	}
	operator IScriptObject*()
	{
		return m_pSO;
	}
	*/
	bool Create(IScriptSystem *pSS)
	{
		m_pSO=pSS.CreateObject();
		return m_pSO?true:false;
	}
	/*

	//////////////////////////////////////////////////////////////////////////
	// Boolean comparasions.
	//////////////////////////////////////////////////////////////////////////
	bool operator !() const 
	{
		return m_pSO == NULL;
	};
	bool  operator ==(const IScriptObject* p2) const 
	{
		return m_pSO == p2;
	};
	bool  operator ==(IScriptObject* p2) const 
	{
		return m_pSO == p2;
	};
	bool  operator !=(const IScriptObject* p2) const 
	{
		return m_pSO != p2;
	};
	bool  operator !=(IScriptObject* p2) const 
	{
		return m_pSO != p2;
	};
	bool  operator <(const IScriptObject* p2) const 
	{
		return m_pSO < p2;
	};
	bool  operator >(const IScriptObject* p2) const 
	{
		return m_pSO > p2;
	};
*/
protected:
	IScriptObject *m_pSO;
};
/*

class _HScriptFunction
{
public:
	_HScriptFunction(){m_pScriptSystem;m_hFunc;};
	_HScriptFunction(IScriptSystem *pSS){m_pScriptSystem=pSS;m_hFunc;}
	_HScriptFunction(IScriptSystem *pSS,HSCRIPTFUNCTION hFunc){m_pScriptSystem=pSS;m_hFunc;}
	~_HScriptFunction(){ if(m_hFunc)m_pScriptSystem.ReleaseFunc(m_hFunc);m_hFunc; }
	void Init(IScriptSystem *pSS,HSCRIPTFUNCTION hFunc){if(m_hFunc)m_pScriptSystem.ReleaseFunc(m_hFunc);m_hFunc=hFunc;m_pScriptSystem=pSS;}
	operator HSCRIPTFUNCTION() const
	{
		return m_hFunc;
	}
	_HScriptFunction& operator =(HSCRIPTFUNCTION f){
		if(m_hFunc)m_pScriptSystem.ReleaseFunc(m_hFunc);
		m_hFunc=f;
		return *this;
	}
private:
	HSCRIPTFUNCTION m_hFunc;
	IScriptSystem *m_pScriptSystem;
};
*/

	extern (C)
	{
		export IScriptSystem CreateScriptSystem(ISystem pSystem,
				IScriptSystemSink pSink, IScriptDebugSink pDebugSink, bool bStdLibs);
	}

}
