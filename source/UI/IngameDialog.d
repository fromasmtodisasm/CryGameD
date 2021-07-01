module UI.IngameDialog;


//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: IngameDialog.h 
//  Description: Interface for the CIngameDialog class.
//
//  History:
//  - February 8, 2001: File created by Marco Corbetta
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////
import isystem;

//////////////////////////////////////////////////////////////////////
class CIngameDialog  
{
private:
	this();
	/*virtual*/ ~this();
	bool Init(CIngameDialogMgr *pMgr, int nId, ISystem *pSystem, int nFillId, const char *pszFontName, const char *pszEffectName, int nSize, string sText,wstring swText, float fTimeout);
	void SetPos(float x, float y);
	float GetHeight() { return m_fH; }
	bool Update();

private:
	CIngameDialogMgr *m_pMgr;
	int m_nId;
	float m_fX;
	float m_fY;
	float m_fW;
	float m_fH;
	int m_nSize;
	string		m_sText;
	wstring	m_swText;
	IRenderer *m_pRenderer;
	IFFont *m_pFont;
	string m_sEffect;
	int m_nFillId;
	float m_fTimeout;
	bool m_bInited;
};

//////////////////////////////////////////////////////////////////////
struct SIGDId
{
	int nId;
	CIngameDialog *pDialog;
};

//////////////////////////////////////////////////////////////////////
class CIngameDialogMgr
{
private:
	int m_nDefaultFillId;
	int m_nNextId;
	IRenderer *m_pRenderer;
	ITimer *m_pTimer;
	//FIXME:
	//std::list<SIGDId*> m_lstDialogs;

public:
	this();
	~this(); 
	int AddDialog(ISystem *pSystem, int nFillId, const char *pszFontName, const char *pszEffectName, int nSize, string sText, wstring swText, float fTimeout=0.0f);  // return id to dialog
	void RemoveDialog(int nId);
	void Update();
};
