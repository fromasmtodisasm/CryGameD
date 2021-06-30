module EntityDesc;


import System.Stream;
import IEntityRenderState;
import ientitysystem;
import IBitStream;

extern(C++):

//////////////////////////////////////////////////////////////////////////
class SafeString(int _max_size)
{
public:
	//FIXME:
	//SafeString &operator =(const string &s)
	//{
	//	assert( s.length() < _max_size );
	//	strcpy(m_s,s.c_str());
	//	return *this;
	//}
	//SafeString &operator =(const char *s) 
	//{
	//	assert( s );
	//	assert( strlen(s) < _max_size );
	//	strcpy(m_s,s);
	//	return *this;
	//}
	//operator const char*() const
	//{
	//	return m_s;
	//}
	//operator const char*()
	//{
	//	return m_s;
	//}
	const(char *)c_str() const {return m_s;}
	const(char *)c_str() {return m_s;}
	int length(){return strlen(m_s);}
private:
	char[_max_size] m_s;
};

//////////////////////////////////////////////////////////////////////////
/*!
	CEntityDecs class is an entity description.
  This class describes what kind of entity needs to be spawned, and is passed to entity system when an entity is spawned. This
	class is kept in the entity and can be later retrieved in order to (for example) clone an entity.
	@see IEntitySystem::SpawnEntity(CEntityDesc &)
	@see IEntity::GetEntityDesc()
 */
final class CEntityDesc
{
public:  
	//! the net unique identifier (EntityId)
	int32										id;						
	//! the name of the player... does not need to be unique
	SafeString!256					name;	
	//! player, weapon, or something else - the class id of this entity
	EntityClassId						ClassId;
  //! specify a model for the player container
	SafeString!256					sModel;

	Vec3										vColor;			//!< used for team coloring (0xffffff=default, coloring not used)

	//! this is filled out by container, defaults to ANY
	bool										netPresence;	
	//! the name of the lua table corresponding to this entity
	SafeString!256					className;								
	Vec3										pos;
	Vec3										angles;
	float										scale;
	void *									pUserData;			//! used during loading from XML

	IScriptObject *pProperties;
	IScriptObject *pPropertiesInstance;
	~this(){}
	this();
	this( int id, const EntityClassId ClassId );
	this( ref const CEntityDesc d ) { *this = d; };
	//FIXME:
	//CEntityDesc& operator=( const CEntityDesc &d );


	bool Write( IBitStream.IBitStream *pIBitStream, ref CStream stm);
	bool Read( IBitStream.IBitStream *pIBitStream, ref CStream stm);

	bool IsDirty();
};
