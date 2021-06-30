module ScriptObjects.ServerSlot;

import iscriptsystem;
import Script._ScriptableEx;

class CXServerSlot;
//////////////////////////////////////////////////////////////////////
class CScriptObjectServerSlot :
_ScriptableEx!CScriptObjectServerSlot
{
public:
	//! constructor
	this();
	//! destructor
	~this();
	void Create(IScriptSystem *pScriptSystem);
	void SetServerSlot(CXServerSlot *pSS){m_pSS=pSS;}
	static void InitializeTemplate(IScriptSystem *pSS);
private:
	int BanByID(IFunctionHandler *pH);
	int BanByIP(IFunctionHandler *pH);
	int SetPlayerId(IFunctionHandler *pH);
	int GetPlayerId(IFunctionHandler *pH);
	int GetName(IFunctionHandler *pH);
	int GetModel(IFunctionHandler *pH);
	int GetColor(IFunctionHandler *pH);
	int SetGameState(IFunctionHandler *pH);
	int SendText(IFunctionHandler *pH);
	int Ready(IFunctionHandler *pH);
	int IsReady(IFunctionHandler *pH);
	int IsContextReady(IFunctionHandler *pH);
	int ResetPlayTime(IFunctionHandler *pH);
	int GetPlayTime(IFunctionHandler *pH);
	int SendCommand(IFunctionHandler *pH);
	int Disconnect(IFunctionHandler *pH);
	int GetId(IFunctionHandler *pH);
	int GetPing(IFunctionHandler *pH);

	CXServerSlot *				m_pSS;				//!<
};

