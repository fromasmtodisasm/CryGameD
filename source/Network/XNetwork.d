module XNetwork;

import platform;
import ipadress;				// CIPAddress
import Stream;
import ScriptObjects.ServerSlot;
import cry_version;

extern(C++):

//////////////////////////////////////////////////////////////////////
// Server to client messages

alias ubyte XSERVERMSG;

enum : XSERVERMSG {
	XSERVERMSG_UPDATEENTITY				= 0,
	XSERVERMSG_ADDENTITY				= 1,
	XSERVERMSG_REMOVEENTITY				= 2,
	XSERVERMSG_TIMESTAMP				= 3,
	XSERVERMSG_TEXT						= 4,
	XSERVERMSG_SETPLAYERSCORE			= 5,
	XSERVERMSG_SETENTITYSTATE			= 6,
	//#define XSERVERMSG_OBITUARY		 = 7,
	XSERVERMSG_SETTEAMSCORE				= 8,
	XSERVERMSG_SETTEAMFLAGS				= 9,
	XSERVERMSG_SETPLAYER				= 10,
	XSERVERMSG_CLIENTSTRING				= 11,
	XSERVERMSG_CMD						= 12,
	XSERVERMSG_SETTEAM					= 13,
	XSERVERMSG_ADDTEAM					= 14,
	XSERVERMSG_REMOVETEAM				= 15,
	XSERVERMSG_SETENTITYNAME			= 16,
	XSERVERMSG_BINDENTITY				= 17,
	XSERVERMSG_SCOREBOARD				= 18,
	XSERVERMSG_SETGAMESTATE				= 19,
	XSERVERMSG_TEAMS					= 20,
	XSERVERMSG_SYNCVAR					= 21,
	XSERVERMSG_EVENTSCHEDULE			= 22,
	XSERVERMSG_UNIDENTIFIED				= 23,
	XSERVERMSG_REQUESTSCRIPTHASH		= 24,
	XSERVERMSG_AISTATE					= 25,

	XSERVERMSG_RESERVED_DONOT_USE1		= 250,
	XSERVERMSG_RESERVED_DONOT_USE2		= 251,
	XSERVERMSG_RESERVED_DONOT_USE3		= 252,
	XSERVERMSG_RESERVED_DONOT_USE4		= 253,
	XSERVERMSG_RESERVED_DONOT_USE5		= 254,
	XSERVERMSG_RESERVED_DONOT_USE6		= 255
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Client to server messages

alias ubyte XCLIENTMSG;

enum : XCLIENTMSG {
	XCLIENTMSG_UNKNOWN				= 0,
	XCLIENTMSG_PLAYERPROCESSINGCMD	= 1,
	XCLIENTMSG_TEXT					= 2,
	XCLIENTMSG_JOINTEAMREQUEST		= 3,
	XCLIENTMSG_CALLVOTE				= 4,
	XCLIENTMSG_VOTE					= 5,
	XCLIENTMSG_KILL					= 6,
	XCLIENTMSG_NAME					= 7,
	XCLIENTMSG_CMD					= 8,
	XCLIENTMSG_RATE					= 9,
	XCLIENTMSG_ENTSOFFSYNC			= 10,
	XCLIENTMSG_RETURNSCRIPTHASH		= 11,
	XCLIENTMSG_AISTATE				= 12,
	XCLIENTMSG_UNIDENTIFIED 		= XSERVERMSG_UNIDENTIFIED,		// 23 is not used as message

	XCLIENTMSG_RESERVED_DONOT_USE1	= 250,
	XCLIENTMSG_RESERVED_DONOT_USE2	= 251,
	XCLIENTMSG_RESERVED_DONOT_USE3	= 252,
	XCLIENTMSG_RESERVED_DONOT_USE4	= 253,
	XCLIENTMSG_RESERVED_DONOT_USE5	= 254,
	XCLIENTMSG_RESERVED_DONOT_USE6	= 255
}

//////////////////////////////////////////////////////////////////////
//CLIENT COMMAND
//////////////////////////////////////////////////////////////////////

enum SEND_ONE	 = 1;
enum SEND_MANY	 = 2;
enum SEND_TEAM	 = 3;

//<<>>list here the commands ids
//#define CMD_DONT_SEND_ME		0x00
enum CMD_SAY		= 0x01;
enum CMD_SAY_TEAM	= 0x02;
enum CMD_SAY_ONE	= 0x03;

//////////////////////////////////////////////////////////////////////
enum DEFAULT_TEXT_LIFETIME = 7.5f;

//////////////////////////////////////////////////////////////////////
struct TextMessage
{
	BYTE				cMessageType;			//!<
	ushort			uiSender;					//!<
	ushort			uiTarget;					//!<
  float								fLifeTime = DEFAULT_TEXT_LIFETIME;				//!<
	string							m_sText;					//!<

	//!
	bool Write(ref CStream stm)
	{
		stm.Write(cMessageType);
		stm.Write(uiSender);
		stm.Write(uiTarget);
		if(fLifeTime==DEFAULT_TEXT_LIFETIME)
		{
			stm.Write(false);
		}
		else
		{
			stm.Write(true);
			ubyte temp;
			temp = cast(ubyte) (fLifeTime * 10.0f);
			stm.Write(temp);
		}
		return stm.Write(m_sText);
	}

	//!
	bool Read(ref CStream stm)
	{
		bool b;

		if(!stm.Read(cMessageType))
			return false;
		if(!stm.Read(uiSender))
			return false;
		if(!stm.Read(uiTarget))
			return false;
		if(!stm.Read(b))
			return false;

		if(!b)
		{
			fLifeTime=DEFAULT_TEXT_LIFETIME;
		}
		else
		{
			ubyte temp;
			temp = cast(ubyte) (fLifeTime * 10.0f);
			stm.Read(temp);
			fLifeTime = temp / 10.0f;
		}
		return stm.Read(m_sText);
	}
};


//////////////////////////////////////////////////////////////////////
// Utility classes

//////////////////////////////////////////////////////////////////////
// Infos about the server
struct SXServerInfos
{
	enum Flags
	{
		FLAG_PASSWORD		= 1 << 0,
		FLAG_CHEATS			= 1 << 1,
		FLAG_NET				= 1 << 2,
		FLAG_PUNKBUSTER	= 1 << 3,
	};

	string				strName;							//!< e.g. "Jack's Server"
	string				strMap;								//!< e.g. "MP_Airstrip"
	string				strGameType;					//!< e.g. "ASSAULT", "FFA", "TDM"
	string				strMod;								//!< e.g. "FarCry", "Counterstrike"  current TCM(Total Conversion Mod), specified with -MOD ...
	BYTE					nPlayers;							//!< current player count
	BYTE					nMaxPlayers;					//!< max player count
	WORD					nPort;								//!<
	WORD					nPing;								//!<
//	DWORD					dwGameVersion;				//!< still used?
	CIPAddress		IP;										//!< 
	BYTE					nComputerType;        //!< reserved, currently not used (CPU: AMD64,Intel  OS:Linux,Win)
	int						nServerFlags;					//!< Flags with special info about server.
	SFileVersion	VersionInfo;					//!<

	//! constructor
	//FIXME:
	//this();
	~this() {};

	bool Read(ref const string szServerInfoString);
};

//////////////////////////////////////////////////////////////////////
// Game context (sent to the client when connecting to a server)
struct SXGameContext
{
	ubyte		ucServerInfoVersion;	//!< SERVERINFO_FORMAT_VERSION (needed to prevent connects from old clients)
	string		strMapFolder;					//!<
	string		strMod;								//!< e.g. "FarCry", "FarStrike" current TCM(Total Conversion Mod), specified with -MOD ...
	string		strGameType;					//!< e.g. "ASSAULT", "FFA", "TDM"
	string		strMission;						//!<
	DWORD		dwNetworkVersion;			//!< NETWORK_FORMAT_VERSION
	WORD		wLevelDataCheckSum;		//!<
	bool		bForceNonDevMode;			//!< client is forced not to use the Devmode
	bool		bInternetServer;			//!< true=requires UBI login, false=LAN
	BYTE		nComputerType;        //!< HI:CPUType, LO:OSType

	//! constructor
	//FIXME:
	//this();

	//!
	bool Write(ref CStream stm);
	//!
	bool Read(ref CStream stm);
	//!
	bool IsVersionOk() const;
	//! \return 0 if unknown, zero terminated string otherwise
	const (char *) GetCPUTarget() const;
	//! \return 0 if unknown, zero terminated string otherwise
	const (char *) GetOSTarget() const;
};
