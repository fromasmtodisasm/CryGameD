module GameMods;

import game;
extern (C++):

//////////////////////////////////////////////////////////////////////////
alias SGameModDescription[] lstMods;
//typedef lstMods::iterator lstModsIt;

/*!	Implement IGameMods interface to access and manipulate Game Mods.
*/
//////////////////////////////////////////////////////////////////////////
class CGameMods : IGameMods
{
public:
	this( CXGame *pGame );
	~this();
	
	// IGameMods implementation.
	const (SGameModDescription*) GetModDescription( const char *sModName ) const;
	const (char*) GetCurrentMod() const;
	bool SetCurrentMod( const char *sModName,bool bNeedsRestart=false );
	const char* GetModPath(const char *szSource);	

	//! Array of mod descriptions.
	lstMods m_mods;

private:

	//! Go thru Mods directory and find out what mods are installed.
	SGameModDescription* Find( const char *sModName ) const;
	void	ScanMods();	
	void	ClearMods();
	void	CloseMod(SGameModDescription *pMod);

	bool	ParseModDescription(const char *szFolder,SGameModDescription*pMod);
	bool	GetValue(const char *szKey,const char *szText,char *szRes);
	
	CXGame* m_pGame;
	ISystem *m_pSystem;
	ILog		*m_pILog;

	// Name of the mod currently active.
	string m_sCurrentMod;
	// Current mod
	SGameModDescription *m_pMod;
	// Used to return the path to other modules
	string m_sReturnPath;
};

