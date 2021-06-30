module IPAddres;


//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//	
//	File: ipaddress.h
//  Description: ip address wrapper
//
//	History:
//	- July 25,2001:Created by Alberto Demichelis
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////


import Stream;

import platform;
import core.stdc.stdlib;
import core.stdc.string;

version (LINUX)
{
	//import <sys/types.h>
	//import <sys/socket.h>
	//import <netinet/in.h>
	//import <arpa/inet.h>
	//import <netdb.h>
}
//////////////////////////////////////////////////////////////////////
struct _SOCKADDR_IN
{
	short sin_family;
	ushort sin_port;
version (LINUX)
{
	union
	{
		in_addr_windows sin_addr_win;
		in_addr sin_addr;
	};
}
else
{
	in_addr sin_addr;
}
	char[8] sin_zero;
};

import std.socket;

//#ifdef PS2
//#include <SocketManager.h>
//#define PS2_MEM_SOCKET
//#endif //PS2

//////////////////////////////////////////////////////////////////////
ushort __ntohs(ushort us)
{
	ushort nTemp=(us>>8)|(us<<8);
	return nTemp;
}
/* NOTE FOR PS2 PROGRAMMERS ABOUT THIS CLASS
	I rollback this file to our version because 
	your change caused a bug inside our version.

	in your version you changed this 
		m_Address.sin_addr.S_un.S_addr
	to this
		m_Address.sin_addr.S_addr

	but you also replaced 
		m_Address.sin_port
	with
		m_Address.sin_addr.S_addr

	be careful because for some strange reason
	was partially working :)	
*/
//#if defined(LINUX)
//	#define ADDR sin_addr_win.S_un.S_addr
//#else
//	#define ADDR sin_addr.S_un.S_addr
//#endif

//////////////////////////////////////////////////////////////////////
class CIPAddress
{
public:
	this(WORD wPort,const char *sAddress)
	{
		m_Address.sin_family = AF_INET;
		m_Address.sin_port = htons(wPort);
		m_Address.ADDR = inet_addr(sAddress);
		m_Address.sin_zero[0] = 0;

		if(m_Address.ADDR == INADDR_NONE)
		{
			hostent *pHostEntry;
			pHostEntry = gethostbyname(sAddress);

			if(pHostEntry)
				m_Address.ADDR = *cast(uint *)pHostEntry.h_addr_list[0];
			else
				m_Address.ADDR = 0;
		}
	}
	
	this(sockaddr_in *sa)
	{
		
		memcpy(&m_Address, sa, sizeof(sockaddr_in));
	}
	
	this(ref const CIPAddress xa)
	{
		
		memcpy(&m_Address, &xa.m_Address, sizeof(sockaddr_in));
	}
	
	~this()
	{
	}

	bool IsLocalHost()
	{
		if(m_Address.ADDR==inet_addr("127.0.0.1"))
			return true;
		return false;
	}
		
	void Set(WORD wPort, char *sAddress)
	{
		m_Address.sin_family = AF_INET;
		m_Address.sin_port = htons(wPort);
		m_Address.ADDR = inet_addr(sAddress);
		m_Address.sin_zero[0] = 0;

		// win2003 server edition compatibility
		// the behaviour changed in this OS version
		// inet_addr returns INADDR_NONE instead of 0 when an empty string is passed.
		if(m_Address.ADDR == INADDR_NONE)
		{
			m_Address.ADDR = 0;
		}
	}

	void Set(WORD wPort, UINT dwAddress)
	{
		m_Address.sin_family = AF_INET;
		m_Address.sin_port = htons(wPort);
		m_Address.ADDR = dwAddress;
		m_Address.sin_zero[0] = 0;
	}
	void Set(sockaddr_in *sa)
	{
		memcpy(&m_Address, sa, sockaddr_in.sizeof);
	}
	void Set(ref const CIPAddress xa)
	{
		memcpy(&m_Address, &xa.m_Address, _SOCKADDR_IN.sizeof);
	}
	UINT GetAsUINT() const	{return m_Address.ADDR;}
	//const CIPAddress& operator =(const CIPAddress& xa);
	//bool operator !=(const CIPAddress& s1);
	//bool operator ==(const CIPAddress& s1);
	//bool operator <(const CIPAddress& s1) const ;
	char *GetAsString(bool bPort) const
	{
		static char[64] s;
		if (bPort)
	version(LINUX)	
	{
			wsprintf(s, "%i.%i.%i.%i:%i", m_Address.sin_addr.S_un.S_un_b.s_b1,
			m_Address.sin_addr.S_un.S_un_b.s_b2,
			m_Address.sin_addr.S_un.S_un_b.s_b3,
			m_Address.sin_addr.S_un.S_un_b.s_b4, __ntohs(m_Address.sin_port));
	}
	else	//LINUX
	{
			sprintf(s, "%s:%i", 
				inet_ntoa(m_Address.sin_addr), 
				ntohs(m_Address.sin_port)
			);
	}
		else
	version(LINUX)
	{
			sprintf(s, "%s", 
				inet_ntoa(m_Address.sin_addr)
			);
			//sprintf(s, "%i", InAddress());
	}
	else	//LINUX
	{
			wsprintf(s, "%i.%i.%i.%i", m_Address.sin_addr.S_un.S_un_b.s_b1,
			m_Address.sin_addr.S_un.S_un_b.s_b2,
			m_Address.sin_addr.S_un.S_un_b.s_b3,
			m_Address.sin_addr.S_un.S_un_b.s_b4);
	}
		return s;
	}


	bool Load(ref CStream s)
	{
		if (!s.Read(cast(uint)(m_Address.ADDR)))
			return false;
		if (!s.Read(m_Address.sin_port))
			return false;
		return true;
	}
	
	bool Save(ref CStream s)
	{
		if (!s.Write(cast(uint)m_Address.ADDR))
			return false;
		if (!s.Write(m_Address.sin_port))
			return false;
		return true;
	}

public:
	_SOCKADDR_IN m_Address;
};


/*
//////////////////////////////////////////////////////////////////////
bool CIPAddress::operator ==(const CIPAddress& s1)
{
	return (!(memcmp(&s1.m_Address, &m_Address, sizeof(_SOCKADDR_IN))))?true:false;
}

//////////////////////////////////////////////////////////////////////
bool CIPAddress::operator <(const CIPAddress& s1) const 
{
	if(s1.m_Address.ADDR <m_Address.ADDR)
	{
		return true;
	}
	else
	{
		if(s1.m_Address.ADDR==m_Address.ADDR)
		{
			if(s1.m_Address.sin_port<m_Address.sin_port)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else
		{
			return false;
		}
	}	
}

//////////////////////////////////////////////////////////////////////
bool CIPAddress::operator !=(const CIPAddress& s1) 
{
	return (memcmp(&s1.m_Address, &m_Address, sizeof(sockaddr_in)))?true:false;
}

//////////////////////////////////////////////////////////////////////
const CIPAddress& CIPAddress::operator =(const CIPAddress& xa)
{
	Set(xa);
	return *this;
}
*/

//////////////////////////////////////////////////////////////////////

