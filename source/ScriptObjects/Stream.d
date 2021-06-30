module ScriptObjects.Stream;

import iscriptsystem;
import Script._ScriptableEx;

import Stream;

//////////////////////////////////////////////////////////////////////
class CScriptObjectStream :
_ScriptableEx!CScriptObjectStream
{
public:
	this();
	~this();
	bool Create(IScriptSystem *pScriptSystem);
	void Attach(CStream *pStm)
	{
		m_pStm=pStm;
	}
public:
	int WriteInt(IFunctionHandler *pH);
	int WriteShort(IFunctionHandler *pH);
	int WriteByte(IFunctionHandler *pH);
	int WriteFloat(IFunctionHandler *pH);
	int WriteString(IFunctionHandler *pH);
	int WriteBool(IFunctionHandler *pH);
	int WriteNumberInBits(IFunctionHandler *pH);

	int ReadInt(IFunctionHandler *pH);
	int ReadShort(IFunctionHandler *pH);
	int ReadByte(IFunctionHandler *pH);
	int ReadFloat(IFunctionHandler *pH);
	int ReadString(IFunctionHandler *pH);
	int ReadBool(IFunctionHandler *pH);
	int ReadNumberInBits(IFunctionHandler *pH);
	static void InitializeTemplate(IScriptSystem *pSS);
public:
	CStream *m_pStm;
};
