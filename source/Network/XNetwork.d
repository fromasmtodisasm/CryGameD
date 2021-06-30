module Network.XNetwork;

import IPAddress;				// CIPAddress

//////////////////////////////////////////////////////////////////////
// Server to client messages

alias ubyte XSERVERMSG;

immutable(ubyte) XSERVERMSG_UPDATEENTITY				= 0;
immutable(ubyte) XSERVERMSG_ADDENTITY					= 1;
immutable(ubyte) XSERVERMSG_REMOVEENTITY				= 2;
immutable(ubyte) XSERVERMSG_TIMESTAMP					= 3;
immutable(ubyte) XSERVERMSG_TEXT					= 4;
immutable(ubyte) XSERVERMSG_SETPLAYERSCORE				= 5;
immutable(ubyte) XSERVERMSG_SETENTITYSTATE				= 6;
//immutable(ubyte) XSERVERMSG_OBITUARY					7
immutable(ubyte) XSERVERMSG_SETTEAMSCORE				= 8;
immutable(ubyte) XSERVERMSG_SETTEAMFLAGS				= 9;
immutable(ubyte) XSERVERMSG_SETPLAYER					= 10;
immutable(ubyte) XSERVERMSG_CLIENTSTRING				= 11;
immutable(ubyte) XSERVERMSG_CMD						= 12;
immutable(ubyte) XSERVERMSG_SETTEAM					= 13;
immutable(ubyte) XSERVERMSG_ADDTEAM					= 14;
immutable(ubyte) XSERVERMSG_REMOVETEAM					= 15;
immutable(ubyte) XSERVERMSG_SETENTITYNAME				= 16;
immutable(ubyte) XSERVERMSG_BINDENTITY					= 17;
immutable(ubyte) XSERVERMSG_SCOREBOARD					= 18;
immutable(ubyte) XSERVERMSG_SETGAMESTATE				= 19;
immutable(ubyte) XSERVERMSG_TEAMS					= 20;
immutable(ubyte) XSERVERMSG_SYNCVAR					= 21;
immutable(ubyte) XSERVERMSG_EVENTSCHEDULE				= 22;
immutable(ubyte) XSERVERMSG_UNIDENTIFIED				= 23;		// 23 is not used as message
immutable(ubyte) XSERVERMSG_REQUESTSCRIPTHASH				= 24;
immutable(ubyte) XSERVERMSG_AISTATE					= 25;

immutable(ubyte) XSERVERMSG_RESERVED_DONOT_USE1				= 250;
immutable(ubyte) XSERVERMSG_RESERVED_DONOT_USE2				= 251;
immutable(ubyte) XSERVERMSG_RESERVED_DONOT_USE3				= 252;
immutable(ubyte) XSERVERMSG_RESERVED_DONOT_USE4				= 253;
immutable(ubyte) XSERVERMSG_RESERVED_DONOT_USE5				= 254;
immutable(ubyte) XSERVERMSG_RESERVED_DONOT_USE6				= 255;

//////////////////////////////////////////////////////////////////////////////////////////////
// Client to server messages

alias ubyte XCLIENTMSG;

immutable XCLIENTMSG_UNKNOWN					= 0;
immutable XCLIENTMSG_PLAYERPROCESSINGCMD			= 1;
immutable XCLIENTMSG_TEXT					= 2;
immutable XCLIENTMSG_JOINTEAMREQUEST				= 3;
immutable XCLIENTMSG_CALLVOTE			        	= 4;
immutable XCLIENTMSG_VOTE			            	= 5;
immutable XCLIENTMSG_KILL			            	= 6;
immutable XCLIENTMSG_NAME			            	= 7;
immutable XCLIENTMSG_CMD					= 8;
immutable XCLIENTMSG_RATE					= 9;
immutable XCLIENTMSG_ENTSOFFSYNC				= 10;
immutable XCLIENTMSG_RETURNSCRIPTHASH				= 11;
immutable XCLIENTMSG_AISTATE					= 12;
immutable XCLIENTMSG_UNIDENTIFIED				= XSERVERMSG_UNIDENTIFIED;		// 23 is not used as message

immutable XCLIENTMSG_RESERVED_DONOT_USE1	= 250;
immutable XCLIENTMSG_RESERVED_DONOT_USE2	= 251;
immutable XCLIENTMSG_RESERVED_DONOT_USE3	= 252;
immutable XCLIENTMSG_RESERVED_DONOT_USE4	= 253;
immutable XCLIENTMSG_RESERVED_DONOT_USE5	= 254;
immutable XCLIENTMSG_RESERVED_DONOT_USE6	= 255;

//////////////////////////////////////////////////////////////////////
//CLIENT COMMAND
//////////////////////////////////////////////////////////////////////

immutable SEND_ONE	 = 1;
immutable SEND_MANY	 = 2;
immutable SEND_TEAM	 = 3;

//<<>>list here the commands ids
//#define CMD_DONT_SEND_ME		0x00
immutable CMD_SAY			= 0x01;
immutable CMD_SAY_TEAM			= 0x02;
immutable CMD_SAY_ONE			= 0x03;

//////////////////////////////////////////////////////////////////////
immutable DEFAULT_TEXT_LIFETIME = 7.5f;

//////////////////////////////////////////////////////////////////////

