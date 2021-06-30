module UI.Hud;

import Renderer.Cry_Color4;
import game;
import iscriptsystem;
import IFont;

extern(C++):
//////////////////////////////////////////////////////////////////////
class CUIHud 
{
public:	
	this(CXGame *pGame,ISystem *pISystem);
	~this();

	bool Reset();
	bool Init(IScriptSystem *pScriptSystem);	
	bool Update();
	void ShutDown();	

	void SetFont(const char *pszFontName, const char *pszEffectName);
	void WriteNumber(int px,int py,int number,float r,float g,float b,float a,float xsize/*=1*/,float ysize/*=1*/);
	void WriteString(int px, int py, const wchar *swStr, float r, float g, float b, float a,float xsize/* =1 */, float ysize/* =1 */, float fWrapWidth);
	void WriteStringFixed(int px, int py, const wchar *swStr, float r, float g, float b, float a,float xsize/* =1 */, float ysize/* =1 */, float fWidthScale);
	IScriptObject *GetScript() { return(m_pHudScriptObj); } 
	IFFont *Getfont() { return(m_pFont); }

private:
	int GetHudTable() const;
	IScriptSystem *m_pScriptSystem;
	IScriptObject *m_pHudScriptObj;
	ISystem *m_pISystem;
	CXGame *m_pGame;
	bool m_init;
	IFFont *m_pFont;
};

