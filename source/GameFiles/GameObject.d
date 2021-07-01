module GameObject;

import ientitysystem;
import Math;
extern(C++):

//////////////////////////////////////////////////////////////////////
/*!@see IEntityContainer
*/
abstract class CGameObject : 
IEntityContainer
{
public:
	//! constructor
	//! destructor
	//~this() {}

	//! Return entity used by this game object.
	IEntity* GetEntity() const { return m_pEntity; }

	//! Forwards name calls to entity.
	void	SetName( const char *s ) { m_pEntity.SetName(s); };
	//!@return the name of the entity
	const (char *) GetName() const { return m_pEntity.GetName(); };

	// interface IEntityContainer 

	override void SetEntity( IEntity *e ) { m_pEntity = e; }
	override void OnSetAngles( ref const Vec3 ang ){};
	override Vec3 CalcSoundPos() { if (m_pEntity) return m_pEntity.GetPos(); return Vec3(0.0f, 0.0f, 0.0f); }
	override void Release() {  delete this; };
	override bool QueryContainerInterface(ContainerInterfaceType desired_interface, void** ppInterface) { *ppInterface=0; return false;}
	override void OnDraw(ref const SRendParams  RendParams) {}
	override bool IsSaveable() { return(true); }
	override void OnEntityNetworkUpdate( ref const EntityId idViewerEntity, ref const Vec3d v3dViewer, ref uint32 inoutPriority, 
		ref EntityCloneState inoutCloneState ) const {}

protected:  

	IEntity *					m_pEntity;						//!< Entity attached to object.
};
