module inetwork;


import platform;
public extern(C++):

import std.socket;
version(Windows)
{
	//#include <winsock.h>
}
else
{
	//#ifdef _XBOX
	//	#include <Xtl.h>
	//#endif
	//#ifdef LINUX
	//	#include <sys/socket.h>
	//#endif
}
import Math;					// CVec3
import IBitStream : IBitStream;				// IBitStream

//////////////////////////////////////////////////////////////////////

alias NRESULT= 	DWORD;

enum NET_OK= 		0x00000000;
enum NET_FAIL= 	0x80000000;

auto NET_FAILED(int a) { return (a)&NET_FAIL ?1:0; }
auto NET_SUCCEDED(int a) { return (a)&NET_FAIL ?0:1; }

auto MAKE_NRESULT(int severity, int facility, int code) {return (severity | facility | code);}
enum NET_FACILITY_SOCKET=  0x01000000;

//! regular BSD sockets error
//@{
enum NET_EINTR= 						MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEINTR);
enum NET_EBADF= 						MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEBADF);
enum NET_EACCES= 					MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEACCES);
enum NET_EFAULT= 					MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEFAULT);
enum NET_EINVAL= 					MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEINVAL);
enum NET_EMFILE= 					MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEMFILE);
enum NET_WSAEINTR=         MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEINTR);
enum NET_WSAEBADF=         MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEBADF);
enum NET_WSAEACCES=        MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEACCES);
enum NET_WSAEFAULT=        MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEFAULT);
enum NET_WSAEINVAL=        MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEINVAL);
enum NET_WSAEMFILE= 				MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEMFILE);
enum NET_EWOULDBLOCK= 			MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEWOULDBLOCK);
enum NET_EINPROGRESS= 			MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEINPROGRESS);
enum NET_EALREADY= 				MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEALREADY);
enum NET_ENOTSOCK= 				MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAENOTSOCK);
enum NET_EDESTADDRREQ= 		MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEDESTADDRREQ);
enum NET_EMSGSIZE= 				MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEMSGSIZE);
enum NET_EPROTOTYPE= 			MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEPROTOTYPE);
enum NET_ENOPROTOOPT= 			MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAENOPROTOOPT);
enum NET_EPROTONOSUPPORT= 	MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEPROTONOSUPPORT);
enum NET_ESOCKTNOSUPPORT= 	MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAESOCKTNOSUPPORT);
enum NET_EOPNOTSUPP= 			MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEOPNOTSUPP);
enum NET_EPFNOSUPPORT= 		MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEPFNOSUPPORT);
enum NET_EAFNOSUPPORT= 		MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEAFNOSUPPORT);
enum NET_EADDRINUSE= 			MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEADDRINUSE);
enum NET_EADDRNOTAVAIL= 		MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEADDRNOTAVAIL);
enum NET_ENETDOWN= 				MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAENETDOWN);
enum NET_ENETUNREACH= 			MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAENETUNREACH);
enum NET_ENETRESET= 				MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAENETRESET);
enum NET_ECONNABORTED= 		MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAECONNABORTED);
enum NET_ECONNRESET= 			MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAECONNRESET);
enum NET_ENOBUFS= 					MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAENOBUFS);
enum NET_EISCONN= 					MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEISCONN);
enum NET_ENOTCONN= 				MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAENOTCONN);
enum NET_ESHUTDOWN= 				MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAESHUTDOWN);
enum NET_ETOOMANYREFS= 		MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAETOOMANYREFS);
enum NET_ETIMEDOUT= 				MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAETIMEDOUT);
enum NET_ECONNREFUSED= 		MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAECONNREFUSED);
enum NET_ELOOP= 						MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAELOOP);
enum NET_ENAMETOOLONG= 		MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAENAMETOOLONG);
enum NET_EHOSTDOWN= 				MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEHOSTDOWN);
enum NET_EHOSTUNREACH= 		MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEHOSTUNREACH);
enum NET_ENOTEMPTY= 				MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAENOTEMPTY);
enum NET_EPROCLIM= 				MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEPROCLIM);
enum NET_EUSERS= 					MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEUSERS);
enum NET_EDQUOT= 					MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEDQUOT);
enum NET_ESTALE= 					MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAESTALE);
enum NET_EREMOTE= 					MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEREMOTE);
//@}

version(_WIN32)
{
//! extended winsock errors
//@{
enum NET_HOST_NOT_FOUND= 		MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAHOST_NOT_FOUND);
enum NET_TRY_AGAIN= 					MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSATRY_AGAIN)			;
enum NET_NO_RECOVERY= 				MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSANO_RECOVERY);
enum NET_NO_DATA= 						MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSANO_DATA);
enum NET_NO_ADDRESS= 				MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSANO_ADDRESS);
enum NET_SYSNOTREADY= 				MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSASYSNOTREADY);
enum NET_VERNOTSUPPORTED= 		MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAVERNOTSUPPORTED);
enum NET_NOTINITIALISED= 		MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSANOTINITIALISED);
enum NET_EDISCON= 						MAKE_NRESULT(NET_FAIL, NET_FACILITY_SOCKET, WSAEDISCON);
}
// CryNet specific errors and messages
enum NET_FACILITY_CRYNETWORK= 	0x02000000;

enum NET_NOIMPL= 							MAKE_NRESULT(NET_FAIL, NET_FACILITY_CRYNETWORK, 0x01);
enum NET_SOCKET_NOT_CREATED= 	MAKE_NRESULT(NET_FAIL, NET_FACILITY_CRYNETWORK, 0x02);

public import core.stdcpp.xutility;
public import core.stdcpp.vector;

enum DEFAULT_SERVERPORT= 				49001;
enum DEFAULT_SERVERPORT_STR= 		"49001";

enum SERVER_MULTICAST_PORT= 	5678;
//<<FIXME>> It can be changed
enum SERVER_MULTICAST_ADDRESS= 	"234.5.6.7";

enum SERVER_QUERY_MAX_PACKETS= 	(8);
enum SERVER_QUERY_PACKET_SIZE= 	(1120);

//////////////////////////////////////////////////////////////////////
enum CryNetworkVarible
{
	cnvDataStreamTimeout=0
};

////////////////////////////////////////////////////////////////////////////////////////
// Interfaces
////////////////////////////////////////////////////////////////////////////////////////
struct ICompressionHelper;
extern(C++, class) struct CIPAddress
{

}
public import System.Stream;
import isystem;

//////////////////////////////////////////////////////////////////////
/*! class factory of the Network module
	@see ::CreateNetwork()
*/
interface INetwork
{
	//! \return local IPAddress (needed if we have several servers on one machine), 0.0.0.0 if not used
	DWORD GetLocalIP();

	//! also initialize Ubi.com integration (flaw in the UBI.com SDK - we would like to be able to set the IP later but they
	//! need it during initialization)
	//! \param dwLocalIP local IPAddress (needed if we have several servers on one machine)
	void SetLocalIP( const char *szLocalIP );

	/*! create a client object and return the related interface
			@param pSink a pointer to an object the inplements IClientSink [the object that will receive all notification during the connection]
			@param bClient if true the client will be only able to connect to the local server and
				will use a "fake connection" (memory based)
			@return an IClient interface
	*/
	IClient *CreateClient(IClientSink *pSink,bool bLocal=false);

	/*! create and start a server ,return the related interface
			@param pFactory a pointer to an object the inplements IServerSlotFactory
				[the object that will receive all notification during the lifetime of the server]
			@param nPort local IP port where the server will listen
			@return an IServer interface
	*/
	IServer *CreateServer(IServerSlotFactory *pFactory,WORD nPort, bool local=false);

	//! create an RCon System (remote control system)
	IRConSystem *CreateRConSystem();
	/*! create an internet server snooper
	@param pSink id of the error
	@return Interface to a server snooper
	*/
	INETServerSnooper *CreateNETServerSnooper(INETServerSnooperSink *pSink);
	/*! create a server snooper
		@param pSink id of the error
		@return Interface to a server snooper
	*/
	IServerSnooper *CreateServerSnooper(IServerSnooperSink *pSink);
	/*! return the string representation of a socket error
		@param err id of the error
		@return string description of the error
	*/
	const char *EnumerateError(NRESULT err);
	//! release the interface(and delete the object that implements it)
  void Release();
	//!
	void GetMemoryStatistics(ICrySizer *pSizer);
	//!
	//! \return interface pointer to the compression helper library, is always valid
	ICompressionHelper *GetCompressionHelper();

	//! Submit to network list files, that must be matching on Client and Server.
	void ClearProtectedFiles();
	void AddProtectedFile( const char *sFilename );
	//!
	//! \return 0 if there is no server registered at this port
	IServer *GetServerByPort( const WORD wPort );
	//! used to update things like the UBI.com services
	void UpdateNetwork();
	//! currently used to update UBI.com info and check CDKey
	//! If it is a UBI type server we should the register, if we have already registered this will do nothing.
	//! \param szServerName must not be 0
	//! \param dwPlayerCount >0
	void OnAfterServerLoadLevel( const char *szServerName, const uint32 dwPlayerCount, const WORD wPort );
	//! \return true=it's possible (e.g. logged into UBI.com), false=it's not possible
	bool VerifyMultiplayerOverInternet();
	//! We have to tell Ubisoft that the client has successfully connected
	//! If ubisoft is not running this won't do anything.
	void Client_ReJoinGameServer();
	//! \return 0 if there is no client
	IClient *GetClient();

	//! Sets server's IP
	void					SetUBIGameServerIP(const char *szAddress);
	//! Gets server's IP
	const char		*GetUBIGameServerIP(bool bLan);
};


////////////////////////////////////////////////////////////////////////////////////////
/*! callback interface that must implement by the host that want to use IClient
*/
interface IClientSink
{
	/*! called by the client when the connection occur
	*/
	void OnXConnect();
	/*! called by the client when the disconnection occur
		@param string representation of the disconnection cause
	*/
	void OnXClientDisconnect(const char *szCause);
	/*! called by the client when the server send a contex setup.

		NOTES: for instance a context are all information that allow the client to load a
		level.
		A context setup is called every time the server want to load a new level.

		@param stmContext stream that contain the context informations(game dependent)
	*/
	void OnXContextSetup(ref CStream stmContext);
	/*! called by the client when some data is received
		@param stmContext stream that contain the data
	*/
	void OnXData(ref CStream stm);

	/*! called by the client when the server is very laggy (more than cl_timeout)
			that means that the client waits cl_timeout seconds, without any data from the server...
	*/
	void OnXServerTimeout();
	/*! called by the client when the server responds, after a lot of time without doing so..
			that means that the client was treating the server as "timedout", and hoppefully waiting for it,
			and now, the server, magicaly responded...
	*/
	void OnXServerRessurect();

	/*! called by the server when a timeout occurs..
			when a timeout is expected, because of the server loading for example,
			this function should return a number in milliseconds, that is the additional time to wait for the server.
			if not timeout is expected, this should return 0, and the normal timeout will take place.
	*/
	uint GetTimeoutCompensation();
	//!
	void MarkForDestruct();
	//!
	bool DestructIfMarked();
};


////////////////////////////////////////////////////////////////////////////////////////
/*! client interface
	this interface allow to connect and exchange data with a server

	REMARKS:
		when a disconnection occur the object that implements this interface
		CANNOT BE REUSED. This mean that the interface must be released 
		and a new IClient must be created for each connection.
*/
interface IClient
{
	/*! start the connection to a server
		@param szIP address of the server can be an ip address like 134.122.345.3 or a symbolic www.stuff.com
		@param pbAuthorizationID must not be 0
		@param iAuthorizationSize >0
		--@param wPort the remote port of the server
	*/
	void Connect(const char *szIP, WORD wPort, const BYTE *pbAuthorizationID, uint iAuthorizationSize);
	/*! start disconnect from a server
		@param szCause cause of the disconneciton that will be send to the server
	*/
	void Disconnect(const char *szCause);
	/*! send reliable data to the server
		@param stm the bitstream that store the data
	*/
	void SendReliable(ref CStream );
	/*! send unreliable data to the server
		@param stm the bitstream that store the data
	*/
	void SendUnreliable(ref CStream );
	/*! notify the server that the contex setup was received and the client now is ready to 
		start to receive the data stream.
		usually called when the client finish to load the level.
		@param stm the bitstream that store the data that the server will receive(usally player name etc..)
	*/
	void ContextReady(ref CStream );
	/*! check if the client is ready to send data to the server
		@return true if the client is ready,false if not
	*/
	bool IsReady();
	/*! called to update the client status
		@param nTime the current time in milliseconds
		@return true=this object is still exising, false=this object was destroyed

		REMARKS: to keep the connection working correctly this function must be called at least every frame
	*/
	bool Update(uint nTime);
	/*! get the average bandwidth used by the current connection
		@param fIncomingKbPerSec incoming kb per sec
		@param fOutgoingKbPerSec outgoing kb per sec
		@param nIncomingPackets per sec
		@param nOutgoingPackets per sec
	*/
	void GetBandwidth( ref float fIncomingKbPerSec, ref float fOutgoinKbPerSec, ref DWORD nIncomingPackets, ref DWORD nOutgoingPackets );
	/*! release the interface(and delete the object that implements it)
	*/
	void Release();
	/*! get the average round trip delay through client and server
		@return the average ping in milliseconds
	*/
	uint GetPing();
	//!
	uint GetRemoteTimestamp(uint nTime);
	//!
	uint GetPacketsLostCount();
	//!
	uint GetUnreliablePacketsLostCount();
	//! returns IP of server.
	CIPAddress GetServerIP();
	//!
	void InitiateCDKeyAuthorization( const bool inbCDAuthorization );
	//! \param pbAuthorizationID 0 if you wanna create a fake AuthorizationID, otherwise pointer to the AuthorizationID
	void OnCDKeyAuthorization( BYTE *pbAuthorizationID );
	//!
	void SetServerIP( const char *szServerIP );
};

//////////////////////////////////////////////////////////////////////
interface IServerSnooper
{
	/*! query the LAN for servers
	*/
	void SearchForLANServers(uint nTime=0);
	void Update(uint nTime);
	//! release the interface(and delete the object that implements it)
  void Release();
};

//////////////////////////////////////////////////////////////////////
interface IServerSnooperSink
{
	/*! called by the client when some server is found
		@param ip IP address of the found server
		@param stmServerInfo stream containing all server informations(game dependent)
	*/
	void OnServerFound(ref CIPAddress ip, ref const std_string szServerInfoString, int ping);
};

//////////////////////////////////////////////////////////////////////
interface INetworkPacketSink
{
	void OnReceivingPacket( const ubyte inPacketID, ref CStream Packet, ref CIPAddress ip );
};

//////////////////////////////////////////////////////////////////////
interface INETServerSnooper
{
	//! query internet servers for info
	void Update(uint dwTime);
	//!
	void AddServer(const ref CIPAddress ip);
	//!
	void AddServerList(const ref vector!CIPAddress vIP);
	//! release the interface(and delete the object that implements it)
	void Release();
	//! clear the current list of servers
	void ClearList();
};

//////////////////////////////////////////////////////////////////////
interface INETServerSnooperSink
{
	/*! called by the client when some server is found
	@param ip IP address of the found server
	@param stmServerInfo stream containing all serer informations(game dependent)
	*/
	void OnNETServerFound(ref const CIPAddress ip, ref const std_string szServerInfoString, int ping);

	/*! called by the client when some server timedout
	@param ip IP address of the dead server
	*/
	void OnNETServerTimeout(ref const CIPAddress ip);
};

//////////////////////////////////////////////////////////////////////
//! interface to control servers remotely
interface IRConSystem
{
	//! query response packets
	//! Can specify optional client, to get server ip from.
	void Update( uint dwTime,IClient *pClient=NULL );
	//! release the interface(and delete the object that implements it)
	void Release();
	//!
	void ExecuteRConCommand( const char *inszCommand );
	//!
	void OnServerCreated( IServer *inpServer );
};


////////////////////////////////////////////////////////////////////////////////////////
//! callback interface that must implement by the host that want to use ISererSlot
interface IServerSlotSink
{
	//! called by the serverslot when the connection occur
	void OnXServerSlotConnect(const BYTE *pbAuthorizationID, uint uiAuthorizationSize);
	/*! called by the serverslot when the disconnection occur
		@param string representation of the disconnection cause
	*/
	void OnXServerSlotDisconnect(const char *szCause);
	/*! called by the serverslot when the client send a "context ready"
		@param stm bitstream that store the data sent by the client as answer of the context setup(usally player name etc..)
	*/
	void OnContextReady(ref CStream ); //<<FIXME>> add some level validation code
	/*! called by the serverslot when some data is received
		@param stm bitstream that store the received data
	*/
	void OnData(ref CStream );
	//! 
	void OnXPlayerAuthorization( bool bAllow, const char *szError, const BYTE *pGlobalID, 
		uint uiGlobalIDSize );
};

//////////////////////////////////////////////////////////////////////
struct SServerSlotBandwidthStats
{
	uint		m_nReliableBitCount;				//!<
	uint		m_nReliablePacketCount;			//!<
	uint		m_nUnreliableBitCount;			//!<
	uint		m_nUnreliablePacketCount;		//!<
};

////////////////////////////////////////////////////////////////////////////////////////
/*! server slot interface
	The server slot is the endpoint of a client connection on the server-side. Besically for
	every remote client a server slot exist on the server.
*/
interface IServerSlot
{
	/*! set the host object that will receive all server slot notifications
		@param pSink poiter to an object thath implements IServerSlotSink
	*/
	void Advise(IServerSlotSink *pSink);
	/*! disconnect the client associated to this server slot
		@param szCause cause of the disconneciton that will be send to the client
	*/
	void Disconnect(const char *szCause);
	/*! send a context setup to the client
		@param stm bitstream that store the context information(usually level name etc..)
	*/
	bool ContextSetup(ref CStream );
	/*! send reliable data to the client
		@param stm the bitstream that store the data
	*/
	void SendReliable(ref CStream ,bool bSecondaryChannel=false);
	/*! send unreliable data to the client
		@param stm the bitstream that store the data
	*/
	void SendUnreliable(ref CStream );
	/*! check if the server slot is ready to send data to the client
		@return true if the serverslot is ready,false if not
	*/
	bool IsReady();
	/*! get the unique id that identify the server slot on a server
		@return ID of the serverslot
	*/
	ubyte GetID();
	
	// Return IP in integer form.
	uint GetClientIP();
	//! release the interface(and delete the object that implements it)
	void Release();
	/*! get the average round trip delay through client and server
		@return the average ping in milliseconds
	*/
  uint GetPing();
	//!
	uint GetPacketsLostCount();
	//!
	uint GetUnreliablePacketsLostCount();
	//! used for bandwidth calculations (to adjust the bandwidth)
	void ResetBandwidthStats();
	//! used for bandwidth calculations (to adjust the bandwidth)
	void GetBandwidthStats( ref SServerSlotBandwidthStats _out );
	//! just calles OnXPlayerAuthorization of the corresponding game specific object
	void OnPlayerAuthorization( bool bAllow, const char *szError, const BYTE *pGlobalID, 
		uint uiGlobalIDSize );
};

////////////////////////////////////////////////////////////////////////////////////////
//the application must implement this class
interface IServerSlotFactory
{
	bool CreateServerSlot(IServerSlot *pIServerSlot);
	
	//! \return true=success, false otherwise
	//! fill the given string with server infos
	//! \note do not overwrite the string, just append to it
	bool GetServerInfoStatus(ref std_string szServerStatus);
	bool GetServerInfoStatus(ref std_string szName, ref std_string szGameType, ref std_string szMap, ref std_string szVersion, bool *pbPassword, int *piPlayers, int *piMaxPlayers);
	bool GetServerInfoRules(ref std_string szServerRules);
	bool GetServerInfoPlayers(std_string[4] *vszStrings, ref int nStrings);
	//! Called when someone sends XML request to server, this function must fill sResponse string with XML response.
	bool ProcessXMLInfoRequest( const char *sRequest,const char *sRespone,int nResponseMaxLength );
};

//////////////////////////////////////////////////////////////////////
// the application should implement this class
interface IServerSecuritySink
{
	enum CheaterType
	{
		CHEAT_NOT_RESPONDING,
		CHEAT_NET_PROTOCOL,
		CHEAT_MODIFIED_FILE,
		CHEAT_MODIFIED_CODE,
		CHEAT_MODIFIED_VARS,
	};
	struct SSlotInfo
	{
		char[32] playerName;
		int score;
		int deaths;
	};

	/*!	check the state of an ip address before creating the slot
			\return the state of the ip (banned or not)
	*/
	bool IsIPBanned(const uint dwIP);

	/*! ban an ip address
			\param dwIP the ip address to ban
	*/
	void BanIP(const uint dwIP);

	/*! ban an ip address
	\param dwIP the ip address to ban
	*/
	void UnbanIP(const uint dwIP);

	/*! Report cheating user.
	 *	
	 */
	void CheaterFound( const uint dwIP,int type,const char *sMsg );

	/*! Request slot information from the game.
	 *	
	 */
	bool GetSlotInfo(  const uint dwIP,ref SSlotInfo info , int nameOnly );
};

//////////////////////////////////////////////////////////////////////////
enum EMPServerType
{
	eMPST_LAN=0,                        //!< LAN
	eMPST_NET,                        //!< e.g. ASE
	eMPST_UBI,                        //!< UBI.com
};

////////////////////////////////////////////////////////////////////////////////////////
/*!Server interface
*/
interface IServer
{
	/*! called to update the server status, this update all serverslots too
		@param nTime the current time in milliseconds

		REMARKS: to keep the connection working correctly this function must be called at least every frame
	*/
	void Update(uint nTime);
	//! release the interface and delete the implemetation
	void Release();
	//! set a server veriable
	void SetVariable(CryNetworkVarible eVarName,uint nValue);
	/*! get the average bandwidth used by all active connections
		@param fIncomingKbPerSec incoming kb per sec
		@param fOutgoingKbPerSec outgoing kb per sec
		@param nIncomingPackets per sec
		@param nOutgoingPackets per sec
	*/
	void GetBandwidth( ref float fIncomingKbPerSec, ref float fOutgoinKbPerSec, ref DWORD nIncomingPackets, ref DWORD nOutgoingPackets );
	/*!return the symbolic name of the localhost
		@return the symbolic name of the localhost
	*/
	const char *GetHostName();
	//! \param inPacketID e.g. FT_CQP_RCON_COMMAND
	//! \param inpSink must not be 0
	void RegisterPacketSink( const ubyte inPacketID, INetworkPacketSink *inpSink );

	/*! set the security sink
			\param pSecurirySink pointer to a class that implements the IServerSecuritySink interface
	*/
	void SetSecuritySink(IServerSecuritySink *pSecuritySink);

	/*!	check the state of an ip address before creating the slot
		\return the state of the ip (banned or not)
	*/
	bool IsIPBanned(const uint dwIP);

	/*! ban an ip address
		\param dwIP the ip address to ban
	*/
	void BanIP(const uint dwIP);

	/*! ban an ip address
		\param dwIP the ip address to ban
	*/
	void UnbanIP(const uint dwIP);

	//! time complexity: O(n) n=connected server slots
	//! \return 0 if there is no serverslot with this client (was never there or disconnected)
	IServerSlot *GetServerSlotbyID( const ubyte ucId );

	//! to iterate through all clients (new clients ids are the lowest available at that time)
	uint8 GetMaxClientID();

	//! LAN/UBI/NET
	EMPServerType GetServerType();
};

extern(C) export INetwork *CreateNetwork(ISystem *pSystem);
