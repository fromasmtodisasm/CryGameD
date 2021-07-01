module ientitysystem;

public:
import core.sys.windows.windows;

import IStatObj;
import Misc.EntityDesc;
import physinterface;
import Stream;
import platform;
import IRenderer;
import i3dengine;

extern (C++):

////////////////////////////////////////////////////////////////////////////
// !!! don't change the type !!!
alias ushort EntityClassId; //! unique identifier for the entity class (defined in ClassRegistry.lua)
alias ULONG_PTR BoneBindHandle;

// Common
import Math;
import cry_camera;
import IEntityRenderState;
import iscriptsystem;

public import core.stdcpp.vector;

////////////////////////////////////////////////////////////////////////////
// all available events. if you want to add an event, dont forget to register a lua-constant in the EntitySystem:Init() !
enum EScriptEventId
{
	ScriptEvent_Activate = 0x00000001,
	ScriptEvent_Deactivate,
	ScriptEvent_FireModeChange,
	ScriptEvent_DropItem,
	ScriptEvent_Reset,
	ScriptEvent_Contact,
	ScriptEvent_Enter,
	ScriptEvent_Leave,
	ScriptEvent_Timer,
	ScriptEvent_StartAnimation,
	ScriptEvent_AnimationKey,
	ScriptEvent_EndAnimation,
	ScriptEvent_Respawn,
	ScriptEvent_ItemActivated,
	ScriptEvent_Hit,
	ScriptEvent_Fire,
	ScriptEvent_WeaponReady,
	ScriptEvent_StopFiring,
	ScriptEvent_Reload,
	ScriptEvent_Command,
	ScriptEvent_FireGrenade,
	ScriptEvent_Die,
	ScriptEvent_ZoomToggle,
	ScriptEvent_ZoomIn,
	ScriptEvent_ZoomOut,
	ScriptEvent_Land,
	ScriptEvent_FireCancel,
	ScriptEvent_GameDefinedEvent,
	ScriptEvent_ViewModeChange,
	ScriptEvent_SelectWeapon,
	ScriptEvent_Deafened,
	ScriptEvent_StanceChange,
	ScriptEvent_CycleGrenade,
	ScriptEvent_Use,
	ScriptEvent_MeleeAttack,
	ScriptEvent_PhysicalizeOnDemand,
	ScriptEvent_PhysCollision,
	ScriptEvent_FlashLightSwitch,
	ScriptEvent_EnterWater,
	ScriptEvent_CycleVehiclePos,
	ScriptEvent_AllClear, // sent when the main player has no opposition around him
	ScriptEvent_Expression,
	ScriptEvent_InVehicleAnimation,
	ScriptEvent_InVehicleAmmo,
	ScriptEvent_ProcessCharacterEffects,
	ScriptEvent_Jump, //! jump event
};

////////////////////////////////////////////////////////////////////////////
//! Draw mode
enum eDrawMode
{
	ETY_DRAW_NONE = 0,
	ETY_DRAW_NORMAL = 1,
	ETY_DRAW_NEAR = 2
};

////////////////////////////////////////////////////////////////////////////
//! Object info flags
enum eObjInfoFlags
{
	ETY_OBJ_INFO_DRAW = 1,
	ETY_OBJ_INFO_DRAW_NEAR = 2,
	ETY_OBJ_USE_MATRIX = 4,
	ETY_OBJ_IS_A_LINK = 8
};

////////////////////////////////////////////////////////////////////////////
//! Entity flags:
enum eEntityFlags
{
	ETY_FLAG_WRITE_ONLY = 1,
	ETY_FLAG_NOT_REGISTER_IN_SECTORS = 2,
	ETY_FLAG_CALC_PHYSICS = 4,
	//ETY_FLAG_DRAW_MODEL		= 8,
	ETY_FLAG_CLIENT_ONLY = 16,
	ETY_FLAG_NEED_UPDATE = 32,
	ETY_FLAG_DESTROYABLE = 64,
	//ETY_FLAG_DRAW_NEAR		= 64
	ETY_FLAG_RIGIDBODY = 128,
	ETY_FLAG_CALCBBOX_USEALL = 256, // use character and objects in BBOx calculations
	ETY_FLAG_IGNORE_PHYSICS_UPDATE = 512, // Used by Editor only, (dont set)
	ETY_FLAG_CALCBBOX_ZROTATE = 1024 // use only z angle when calculation bbox
};

////////////////////////////////////////////////////////////////////////////
// Misc
enum eMiscEnum
{
	PLAYER_MODEL_IDX = 0,
	MAX_ANIMATED_MODELS = 2
};

////////////////////////////////////////////////////////////////////////////
// object types - bitmask 0-terrain 1-static, 2-sleeping, 3-physical, 4-living
enum PhysicalEntityFlag
{
	PHYS_ENTITY_STATIC = (1 << 1),
	PHYS_ENTITY_DYNAMIC = (1 << 2) | (1 << 3),
	PHYS_ENTITY_LIVING = (1 << 4),
	PHYS_ENTITY_ALL = (1 << 1) | (1 << 2) | (1 << 3) | (1 << 4)
};

////////////////////////////////////////////////////////////////////////////
/*! Wrapper class for geometry attached to an entity. The entity contains slots which contain one entity object each.
 These objects can be arbitrarily offseted and rotated with respect to the entity that contains them.
*/
class CEntityObject
{
public:
	//CEntityObject()
	//{
	//	flags = 0;
	//	pos(0, 0, 0);
	//	angles(0, 0, 0);
	//	scale(0, 0, 0);
	//	object = 0;

	//	mtx.SetIdentity();
	//}

	int 		flags;
	Vec3 		pos;
	Vec3 		angles;
	Vec3 		scale;
	Matrix44 	mtx;

	IStatObj.IStatObj* object;

	// flags for "spring" objects that are connected to 2 other entity parts (ETY_OBJ_IS_LINKED)
	int ipart0, ipart1;
	Vec3 link_start0, link_end0;
};

////////////////////////////////////////////////////////////////////////////
/*! Entity iterator interface. This interface is used to traverse trough all the entities in an entity system. In a way,
	this iterator works a lot like a stl iterator.
*/
struct IEntityIt
{
	void AddRef();

/*! Deletes this iterator and frees any memory it might have allocated.
*/
	void Release();

/*! Check whether current iterator position is the end position.
	@return True if iterator at end position.
*/
	bool IsEnd();

/*! Retrieves next entity
	@return The entity that the iterator points to before it goes to the next
*/
	IEntity * Next();

/*! Positions the iterator at the begining of the entity list
*/
	void MoveFirst();
};

//import ICryAnimation;
private extern class CXServerSlot;

////////////////////////////////////////////////////////////////////////////
struct EntityCloneState
{

	////! destructor
	//EntityCloneState(const EntityCloneState& ecs)
	//{
	//	m_pServerSlot=ecs.m_pServerSlot;
	//	m_v3Angles=ecs.m_v3Angles;
	//	m_bLocalplayer=ecs.m_bLocalplayer;
	//	m_bSyncYAngle=ecs.m_bSyncYAngle;
	//	m_bSyncAngles=ecs.m_bSyncAngles;
	//	m_bSyncPosition=ecs.m_bSyncPosition;
	//	m_fWriteStepBack=ecs.m_fWriteStepBack;
	//	m_bOffSync=ecs.m_bOffSync;
	//}

	CXServerSlot *	m_pServerSlot;			//!< destination serverslot, 0 if not used
	Vec3						m_v3Angles;					//!<
	bool						m_bLocalplayer;			//!< say if this entity is the entity of the player
	bool						m_bSyncYAngle = true;			//!< can be changed dynamically (1 bit), only used if m_bSyncAngles==true, usually not used by players (roll)
	bool						m_bSyncAngle = true;			//!< can be changed dynamically (1 bit)
	bool						m_bSyncPosition = true;		//!< can be changed dynamically (1 bit)
	float						m_fWriteStepBack;		//!<
	bool						m_bOffSync = true;					//!<
};

////////////////////////////////////////////////////////////////////////////
// types of dependance of entity update from visibility
enum EEntityUpdateVisLevel
{
  eUT_Always=0,			//! Always update entity.
  eUT_InViewRange,	//! Only update entity if it is in view range.
  eUT_PotVisible,		//! Only update entity if it is potentially visible.
  eUT_Visible,			//! Only update entity if it is visible.
	eUT_Physics,			//! Only update entity if it is need to be updated due to physics.
	eUT_PhysicsVisible,	//! Only update entity if it is need to be updated due to physics or if it is visible.
  eUT_Never,				//! Never update entity.
	eUT_PhysicsPostStep, //! Update only when PostStep is called from the physics
	eUT_Unconditional  //! Update regardless of anything - this has to be explicitly set
};

////////////////////////////////////////////////////////////////////////////
/*! Entity Update context structure.
 */
struct SEntityUpdateContext
{
	//! ScriptObject with Update params for script.
	IScriptObject *pScriptUpdateParams;
	//! Current rendering frame id.
	int nFrameID;
	//! Current camera.
	CCamera *pCamera;
	//! Current system time.
	float fCurrTime;
	//! Delta frame time (of last frame).
	float fFrameTime;
	//! If set to true must profile entity update to log.
	bool bProfileToLog;
	//! Number of updated entities.
	int numUpdatedEntities;
	//! Number of visible and updated entities.
	int numVisibleEntities;
	//! Maximal view distance.
	float fMaxViewDist = 100-000- 000;
	//! Maximal view distance squared.
	float fMaxViewDistSquared;
	//! Camera source position.
	Vec3 vCameraPos;
};
interface ICharInstanceSink
{

}
////////////////////////////////////////////////////////////////////////////
/*! Entity interface.

		The public interface of the CEntity class. Contains functions for managing an entity, controlling its position/orientation
		in the world, loading geometry for the entity, physicalizing an entity, etc.
*/
abstract class IEntity :
IEntityRender,
ICharInstanceSink
{
public:
/*!	Retrieves the unique identifier of this entity assigned to it by the Entity System.
	@return The entity id as an ushort if successful. This function always succeeds if a pointer to the interface is acquired.
*/
	EntityId GetId() const;

	// Description:
	//     Updates the Entitys internal structures once a frame.
	//		 Normally called from IEntitySystem::Update function.
	// See Also:
	//     IEntitySystem::Update, SEntityUpdateContext
	// Arguments:
	//     updateContext - Structure that contain general information needed to update entity,
	//                     Update time, Camera, etc..
	void Update( ref SEntityUpdateContext updateContext );

	// Description:
	//     Reset entity to initial state.
	//     This function is used by Sandbox editor to restore the state of entity when going in or out of game mode.
	//     It will call also OnReset callback of entity script.
	void	Reset();

	// Description:
	//     Retrieves the net presence state of the entity.
	//     Net presence detrermine if entity must be synchronized other network.
	// Returns:
	//     true - Entity should be present in network game.
	//     false - Entity should not be present in network game.
	bool GetNetPresence() const;

	// Description:
	//     Set the the net presence state of the entity.
	//     Net presence detrermine if entity must be synchronized other network.
	// Arguments:
	//     bPresent - True if the entity needs to be synchronized over network
	void SetNetPresence( bool bPresent );

	// Description:
	//     Changes entity name.
	//     Entity name does not have to be unique, but for the sake of easier finding entities by name it is better to not
	//     assign same name to different entities.
	// See Also:
	//     GetName
	// Arguments:
	//     name - New name for the entity.
	void  SetName( const char *name );

	// Description:
	//     Set class name of the entity.
	//     The class name is the name of the lua table that represents this entity in script.
	// See Also:
	//     GetClassName
	// Arguments:
	//     name - Name of the script table.
	void  SetClassName( const char *name);

	// Description:
	//     Get entity name.
	// See Also:
	//     SetName
	// Returns:
	//     Name of the entity.
	const(char *) GetName() const;

	// Description:
	//     Get class name of the entity.
	//     The class name is the name of the lua table that represents this entity in script
	// See Also:
	//     SetEntityClassName
	// Returns:
	//     Name of the entity class.
	const(char *) GetEntityClassName() const;

	// Description:
	//     Get description of entity in a CEntityDesc structure.
	//     This describes the entity class, entity id and other parameters.
	// See Also:
	//     Spawn, CEntityDesc
	// Arguments:
	//     desc - This parameter will be filled with entity description.
	void GetEntityDesc( ref CEntityDesc desc ) const;

	// Description:
	//     Retrieves the position of a helper defined in geometry or character loaded in this entity.
	//     This function will search helper inside objects and chracters in all entity slots.
	// Arguments:
	//     helper	- The name of the helper
	//     pos	  - The returned position of the helper. If helper not found, this is a zero vector.
	//     objectspace - If true, paremeter pos return helper position in object space, otherwise in world space.
	void GetHelperPosition(const char *helper, ref Vec3 pos, bool objectspace = false);

	// Description:
	//     Retrieves the class id of the entity.
	//     Example: If there are five ammoboxes for bullets, they all have the same type (ammo for bullet)
	//     but they have different entity id's. The valid types are registered previously in the CEntityRegistry
	// Returns:
	//     Id of the entity class.
	// See Also:
	//     GetId, IEntityClassRegistry
	EntityClassId GetClassId();

	// Description:
	//     Set the entity class id.
	// Arguments:
  //     ClassId - The desired entity type. This must be a valid class id registered previously in the IEntityClassRegistry.
	// See Also:
	//     IEntityClassRegistry
	void SetClassId(const EntityClassId ClassId);

	// Description:
	//     Frees any memory that the entity class might be using. This method is called before an entity is destroyed,
	//     and provides a way for the entity to clean up after itself.
	void ShutDown();

	// Description:
	//     Check if this entity was marked for deletion.
	//     If this function returns true, it will be deleted on next frame, and it is pointless to perform any operations on such entity.
	// Returns:
	//     True if entity marked for deletion, false otherwise.
	bool IsGarbage();

	// Description:
	//     Get the flags of an entity sub object
	// Arguments:
	//     nSubObj - Index of the object slot to get the flags from.
	// Returns:
 	//     Flags for the object slot, or 0 if there`s no such slot.
	int	GetObjectsFlags(int nSubObj);

	// Description:
	//     Sets the flags of an entity.
	// See Also:
	//     eEntityFlags
	// Arguments:
	//     flags - Flags to be set from eEntityFlags enum, they will be ORed with flags already in the entity (m_flags |= flags).
	void	SetFlags( uint flags );

	// Description:
	//     Sets the flags of an entity.
	// See Also:
	//     eEntityFlags
	// Arguments:
	//     flags - Flags to be removed from eEntityFlags enum, they will be removed from the flags theat already in the entity (m_flags &= ~flags).
	void ClearFlags( uint flags );

	// Description:
	//     Get the flags of an entity.
	// See Also:
	//     eEntityFlags
	// Returns:
	//     Entity flags, a combination of the flags from eEntityFlags enum.
	uint GetFlags();

	// Description:
	//     Get camera attached to this entity.
	//     Entity camera is an any class implementing IEntityCamera interface.
	// Returns:
	//     Pointer to an IEntityCamera interface that defines the camera.
	IEntityCamera* GetCamera()const;

	// Description:
	//     Attach a camera to this entity.
	// Arguments:
	//     cam - Pointer to an IEntityCamera interface that defines the camera.
	void SetCamera( IEntityCamera *cam );

	// Description:
	//     Get light attached to entity.
	// Returns:
	//     Pointer to CDLight structure that defines light parameters.
	extern struct CDLight;
	CDLight*	GetLight( );

	// Description:
	//     Initialize and attach light source to an entity.
	//     At the same time load projected texture and light shader if specified.
	// See Also:
	//     GetLight
	// Arguments:
	//     img - Filename of the projected texture, (DDS file) or NULL if no projected texture.
	//     shader - Name of the light shader, or NULL if not using light shader.
	//     bUseAsCube - When true, projected texture will be projected on all 6 sides arround light.
	//     fAnimSpeed - When using animated projected texture, this will specify animation speed for animated texture.
	//     nLightStyle - Style o light
	//     fCoronaScale - Scale of the light corona, if 0 light corona will not be visible.
	//                    Light corona is the flare image displayed at the position of the light source, that simulate glow of light.
	// Returns:
	//     True if light was successfully initialized and attched.
	bool	InitLight( const char* img=NULL, const char* shader=NULL, bool bUseAsCube=false, float fAnimSpeed=0, int nLightStyle=0, float fCoronaScale=0 );


	// Description:
	//     Fires an event in the entity script.
	//     This will call OnEvent(id,param) Lua function in entity script, so that script can handle this event.
	// See Also:
	//     EScriptEventId, IScriptObject
	void SendScriptEvent(EScriptEventId Event, IScriptObject *pParamters, bool *pRet=NULL);
	void SendScriptEvent(EScriptEventId Event, const char *str, bool *pRet=NULL );
	void SendScriptEvent(EScriptEventId Event, int nParam, bool *pRet=NULL );

	// Description:
	//     Calls script defined event handler.
	//     Script defined event handler is any function within Lua entity table, that starts with "Event_" characters.
	//     After Event_ follows the name of the event itself.
	//     Ex: Door.Event_Open(sender) - Event name is Open.
	// Arguments:
	//     sEvent - Name of event, in script function Event_[sEvent] inside entity table will be called.
	void CallEventHandler( const char *sEvent );


	// Description:
	//     Get Physical Entity associated with this entity.
	//     Physical entity is an object instance within physical world with its own transformation.
	//     Physical entity can have associate geometry to perform collision detection with, they have thier physical properties (mass,velocity)
	//     They also have reference to thier originating Entity, not all Physical entities are created by entity system, there are physical entities
	//     that represent static geometry in the world like vegetation,brushes and so on.
	// See Also:
	//     SetPhysics, DestroyPhysics, IPhysicalEntity.
	// Returns:
	//	An interface to a IPhysicalEntity if one exists, NULL if it doesn't exist.
	IPhysicalEntity* GetPhysics()const;

	// Description:
	//     Set Physical Entity to be used by this entity.
	// See Also:
	//     GetPhysics, DestroyPhysics
	// Arguments:
	//     physic	- A pointer to the IPhysicalEntity interface.
	void SetPhysics( IPhysicalEntity* physic );

/*! Destroys the physics for this entity.
*/
	void DestroyPhysics();

/*! Creates physical entity on demand
	@param iForeignFlags - 'foreign flags' specified when creating placeholder, can specify entity subtype (main/character etc.)
	@return nonzero if successful
*/
	int CreatePhysicalEntityCallback(int iForeignFlags);

/*! Notification upon dephysicalisation of a temporary physical entity (this function should save entity state if necessary)
	@param pent - pointer to physical entity
	@return nonzero if successful
*/
	int DestroyPhysicalEntityCallback(IPhysicalEntity *pent);

	// Description:
  //     Enables or disables physic calculation for this entity.
	//     When physics for entity is disabled, it will also suspend physics entity to be simulated or collided with in physics engnie.
	//     When enable argument is false this function will only unregister entity from the physics engine so that it does not recognized
	//     and not simulated anymore, but not destroyed so enabling/disabling physics entity is relatively cheap.
	// Arguments:
	//     enable - If true physics will be calculated for this entity, if false physics entity will be deactivated.
	void EnablePhysics( bool enable );

	// Description:
	//     Adds physical impulse to the entity.
	//     Will only affect entities with dynamic physic entity (RigidBody,Chracter).
	// Arguments:
	//     ipart   - Part identifier, passed to physics with AddGeometry, usually identify chracter bone.
	//     pos     - Position in world space where to apply impulse.
	//     impulse - Impulse direction and magnitude vector specified in world space coordinates.
	//     bPos    - When true, pos parameter will be used and valid position must be specified.
	//     fAuxScale - Auxilary scale for impulse magnitude.
	void AddImpulse(int ipart,Vec3 pos,Vec3 impulse,bool bPos=true,float fAuxScale=1.0f);

	// Description:
	//     Physicalize this entity as a rigid body.
	//     This function create rigid body physic object and associate it with this entity.
	// SeeAlso:
	//     GetPhysics,DestroyPhysics,EnablePhysics,CreateLivingEntity,CreateStaticEntity,CreateSoftEntity
	// Arguments:
	//     type - physical entity type (can be PE_RIGID or something else, say, PE_ARTICULATED)
	//     density - The density of matter of the rigid body (Object mass will be automatically calculted).
	//               if -1 then mass must be specified and desnity will be automatically calculated from geometry volume.
	//     mass - The mass of the rigid body, -1 if not specified, density must be specified in this case and mass will be calculated from geometry volume.
	//            if 0 it is considered as infinite mass rigid body, it will behave same was as static physical entity,
	//            (will not be simulated as rigid body but will participate in collision detection).
	//     surface_id - (Depricated) The identifier of the physical surface for this body.
	//     pInitialVelocity	- Pointer to an initial velocity vector, if NULL no initial velocity.
	//     slot - Make a rigid body from the object in this slot, if -1 chooses first non empty slot.
	//     bPermanent - For physics on demand (Leave on default).
	bool CreateRigidBody(pe_type type, float density,float mass,int surface_id,Vec3* pInitialVelocity = NULL, int slot=-1,
		bool bPermanent=false);

	// Description:
	//     Physicalize this entity as a living entity (ex. human chracter, monster,...)
	//     This function create living physic object and associate it with this entity.
	//     Living entity usually contain 2 physical entities:
	//       * Bounding cylinder with 2 optional additional sphere at the top and bottom of cylinder, for collision with surounding geometry.
	//       * Articulated chracter with IK for precise collision detection when shooting rays that hit this chracter or applying impulses.
	// SeeAlso:
	//     GetPhysics,DestroyPhysics,EnablePhysics,CreateLivingEntity,CreateStaticEntity,CreateSoftEntity
	// Arguments:
	//     density - The density of matter of the rigid body (Object mass will be automatically calculted).
	//               if -1 then mass must be specified and desnity will be automatically calculated from geometry volume.
	//     mass - The mass of the rigid body, -1 if not specified, density must be specified in this case and mass will be calculated from geometry volume.
	//            if 0 it is considered as infinite mass rigid body, it will behave same was as static physical entity,
	//            (will not be simulated as rigid body but will participate in collision detection).
	//     eye_height - The distance from ground level to the eyes of this living entity.
	//     sphere_height - The distance from ground level to the center of the bounding sphere of this living entity
	//     radius	- The radius of the bounding cylinder.
	bool CreateLivingEntity(float mass, float height, float eye_height, float sphere_height, float radius,int nSurfaceID, float fGravity , float fAirControl, bool collide=false);

	// Description:
	//     Physicalize this entity as a static physic geometry.
	//     This entity can be moved explicitly, but physics will never try to move or rotate this object, and will treat it as an object with infinite mass.
	// SeeAlso:
	//     GetPhysics,DestroyPhysics,EnablePhysics,CreateLivingEntity,CreateStaticEntity,CreateSoftEntity
	// Arguments:
	//     mass - (Depricated) Not used.
	//     surface_idx - (Depricated) Identifier of the surface of this static object.
	//     slotToUse - Object from this entity slot will be used as a physics geometry, if -1 combined geometry from all loaded slots will be used.
	//     bPermanent - For physics on demand (Leave on default).
	bool CreateStaticEntity(float mass, int surface_idx, int slotToUse=-1, bool bPermanent=false);

/*! Physicalize entity as a static object.
	@param mass		Mass of soft object
	@param density Density of soft object
	@param bCloth	treat object as cloth (remove the longest internal spans from triangles)
	@param pAttachTo attach to this physical entity
	@param iAttachToPart attach to this part of pAttachTo
*/
	bool CreateSoftEntity(float mass,float density, bool bCloth=true, IPhysicalEntity *pAttachTo=WORLD_ENTITY,int iAttachToPart=-1);

/*! Load and create vehicle physics. This function actually loads a vehicle from a cgf file, and according to some helper data that it finds
 in the cgf file creates a physical representation of a vehicle.
	@param objfile	Name of cgf file
	@param pparts		An array of geometry parts of this vehicle.
	@param params   General parameters of this vehicle
	@see pe_cargeomparams
	@see pe_params_car
*/
	bool LoadVehicle(const char *objfile, pe_cargeomparams *pparts, pe_params_car *params,bool bDestroy=false);

/*! Load and create boat physics. This function actually loads a boat from a cgf file, and according to some helper data that it finds
 in the cgf file creates a physical representation of a vehicle.
	@param objfile	Name of cgf file
	@param mass			mass of mass proxy.
*/
	bool LoadBoat(const char *objfile, float mass, int surfaceID);

/*! damage <<FIXME>> remove it
	@param damage model number
*/
	void SetDamage(const int dmg);

/*! Add geometry object to entity, which is loaded from a cgf file into an available slot in the entity. There is no limit on the number of
	cgf files that can be loaded into an entity.
	@param	slot	Identifier of the slot into which this object should be loaded. Note, if any object exists at this slot, it will be overwritten.
	@param	fileName	The filename of the cgf
	@param  scale	The desired scale of the object
	@return True upon successful loading of cgf file
*/
	bool	LoadObject( uint slot,const char *fileName,float scale, const char *geomName=NULL);
	bool GetObjectPos(uint slot,ref Vec3 pos);
	bool SetObjectPos(uint slot,ref const(Vec3) pos);
	bool GetObjectAngles(uint slot,ref Vec3 ang);
	bool SetObjectAngles(uint slot,ref const(Vec3) ang);
/*! Load a pre-broken object into the entity, piece by piece from the cgf-file. The pre broken pieces will be loaded in a separate slot
  each with a separate IStatObj pointer.
	@param	fileName	The filename of the cgf
	@see    IStatObj
*/
	void	LoadBreakableObject( const char *fileName);

/*! Assign object to specified slot.
	@param slot Identifier of the slot.
	@param object The object to be put in this slot.
	@see CEntityObject
*/
	bool	SetEntityObject( uint slot,const ref CEntityObject object );

/*! Get object at specified slot.
	@param slot Identifier of the slot.
	@param object The returned object at this slot
	@see CEntityObject
*/
	bool	GetEntityObject( uint slot,ref CEntityObject object );
/*! Get number of attached objects.
	@return number of objects in this entity
*/
	int		GetNumObjects();

/*! Get Static object interface from an object attached to an entity.
	@param pos	The slot at which this object is to be retrieved from
	@return Pointer to an IStatObj object interface
	@see IStatObj
*/
	IStatObj.IStatObj *GetIStatObj(uint pos);

	extern interface ISound;
/*! Play sound from entity position
	@param pSound Sound-handle
	@param fSoundScale Sound-scale factor
	@param Offset Offset to value returned by CalcSoundPos() in IEntityContainer or GetPos() if the former doesnt exist
*/
	void PlaySound(ISound *pSound, float fSoundScale, ref Vec3 Offset);

/*! Control draw method of an object at a specific slot. Mode can be ETY_DRAW_NORMAL, ETY_DRAW_NEAR or ETY_DRAW_NONE.
	NOTE: The static object slots are different than the character animated object slots.
	@param	pos	The slot of the object that we are modifying.
	@param	mode The desired drawing mode of this object
*/
	void	DrawObject(uint pos,int mode);

/*! Control draw method of all objects. Mode can be ETY_DRAW_NORMAL, ETY_DRAW_NEAR or ETY_DRAW_NONE.
	NOTE: The static object slots are different than the character animated object slots.
	@param	mode The desired drawing mode of this object
*/
	void	DrawObject(int mode);

/*! Control drawing of character animated object at a specific slot.Mode can be ETY_DRAW_NORMAL, ETY_DRAW_NEAR or ETY_DRAW_NONE.
	NOTE: The character animated object slots are different than the static object slots.
	@param	pos	The slot of the character that we are modifying.
	@param	mode The desired drawing mode of this character
*/
	void DrawCharacter(int pos, int mode);

/*! Control bones update of character animated object at a specific slot.
	NOTE: The character animated object slots are different than the static object slots.
	@param	pos	The slot of the character that we are modifying.
	@param	updt update switch
*/
	void NeedsUpdateCharacter( int pos, bool updt );


/*! Set Axis Aligned bounding box of entity.
	@param mins	Bottom left close corner of box
	@param maxs Top Right far corner of box
	@param bForcePhysicsCallback forces to create a physics object to check for contact
*/
	void	SetBBox(ref const(Vec3) mins,ref const(Vec3) maxs);

/*! Get Axis Aligned bounding box of entity.
	@param mins The value that contains the bottom left close corner of box after function completion
	@param maxs The value that contains the Top Right far corner of box after function completion
*/
	void	GetBBox( ref Vec3 mins,ref Vec3 maxs );

/*! Get Axis Aligned bounding box of entity in local space.
	NOTE: this function do not hash local bounding box, so it must be calculated every time this
	function is called.
	@param mins The value that contains the bottom left close corner of box after function completion
	@param maxs The value that contains the Top Right far corner of box after function completion
*/
	void GetLocalBBox( ref Vec3 min,ref Vec3 max );

/*! Marks internal bbox invalid, it will be recalculated on next update.
 */
	void InvalidateBBox();

/*! Enables tracking of physical colliders for this entity.
*/
	void TrackColliders( bool bEnable );

/*! Rendering of the entity.
*/
	bool DrawEntity(const ref IRenderer.SRendParams  EntDrawParams);

/*! Physicalize this entity as a particle.

*/
	bool CreateParticleEntity(float size,float mass, Vec3 heading, float acc_thrust=0,float k_air_resistance=0,
		float acc_lift=0,float gravity=-9.8, int surface_idx=0,bool bSingleContact=true);

//! Various accessors to entity internal stats
//@{
	void SetPos(ref const(Vec3) pos, bool bWorldOnly = true);
	ref  const(Vec3)  GetPos(bool bWorldOnly = true)const;

	void SetPhysAngles(ref const(Vec3) angl);
	void SetAngles(ref const(Vec3) pos,bool bNotifyContainer=true,bool bUpdatePhysics=true,bool forceInWorld=false);
	ref const(Vec3)  GetAngles(int realA=0)const;

	void SetScale( float scale );
	float GetScale()const;

	void SetRadius( float r );
	float GetRadius()const;
	float	GetRadiusPhys()const;	// gets radius from physics bounding box
	//@}

	//! Sets the entity in sleep mode on/off
	void	SetSleep(bool bSleep);

/*! Control the updating of this entity. This can be used to specify that an entity does not need to be updated every frame.
	@param needUpdate		If true, entity will be updated every frame.
*/
	void SetNeedUpdate( bool needUpdate );
/*! return true if the entity must be updated
*/
	bool NeedUpdate();
/*! Turn on/off registration of entity in sectors.
	@param needToRegister If true entity will be registered in terrain sectors.
*/
	void SetRegisterInSectors( bool needToRegister );

	//! Set radius in which entity will be always updated.
	void SetUpdateRadius( float fUpdateRadius );
	//! Get radius in which entity will be always updated.
	float GetUpdateRadius()const;

	//! If entity registered in sectors, force to reregister it again.
	void ForceRegisterInSectors();

	//! Check if current position is different from previous update
  bool IsMoving()const;

	//! Check if entity is bound to another entity
	bool IsBound();

	//! Bind another entity to this entity. Bounded entities always change relative to their parent.
	//! @param id The unique id of the entity which should be bounded to this entity.
	//! @param cBind
	//! @param bClientOnly true=don't send this message to the server again because it came from it
	void Bind(EntityId id,ubyte cBind=0, const bool bClientOnly=false, const bool bSetPos=false );

	//! Unbind another entity from this entity.
	//! @param id The unique if of the entity which needs to be unbinded from this entity.
	//! @param bClientOnly true=don't send this message to the server again because it came from it
	void Unbind(EntityId id,ubyte cBind, const bool bClientOnly=false );

/*! Forces the entity to act like a bind entity, when in reality it doesn't have to be
 */
	void ForceBindCalculation(bool bEnable);

/*! Sets the parent space parameters (locale)
 */
	void SetParentLocale(const ref Matrix44 matParent);

/*! calculate world position / angles
 */
	void CalculateInWorld();


/*! Attach another entity to this entity bone. Bounded entities always change relative to their parent.
	@param id The unique if of the entity which needs to be attached.
	@bone name
*/
	void AttachToBone(EntityId id, const char* boneName);

/*! Attach object from SLOT to bone
	@param slot object slot idx
	@bone name
	@return ObjectBind handle.
*/
	BoneBindHandle AttachObjectToBone(int slot,const char* boneName,bool bMultipleAttachments=false, bool bUseZOffset=false);

/*! Detach object from bone
	@bone name
	@param objectBindHandle If negative remove all objects from bone.
*/
	void DetachObjectToBone(const char* boneName,BoneBindHandle objectBindHandle=-1 );

/*! Set the script object that describes this entity in the script.
	@param pObject	Pointer to the script object interface
	@see IScriptObject
*/
	void SetScriptObject(IScriptObject *pObject);

/*! Get the script object that describes this entity in the script.
	@return	Pointer to the script object interface
	@see IScriptObject
*/
	IScriptObject *GetScriptObject()= 0 ;

	bool Write(ref CStream,EntityCloneState *cs=NULL);
	/*!	read the object from a stream(network)
		@param stm the stream class that store the bitstream
		@param bNoUpdate if true, just fetch the data from the stream w/o applying it
		@return true if succeded,false failed
		@see CStream
	*/
	bool Read(ref CStream,bool bNoUpdate=false);
	/*!	is called for each entity after ALL entities are read (this inter-entity connections can be serialized)
	*/
	bool PostLoad();
	/*! check if the object must be syncronized since the last serialization
		@return true must be serialized, false the object didn't change
	*/
	//bool IsDirty();

	/*!	serialize the object to a bitstream(file persistence)
		@param stm the stream class that will store the bitstream
		@param pStream script wrapper for the stream(optional)
		@return true if succeded,false failed
		@see CStream
	*/
	bool Save(ref CStream stm,IScriptObject *pStream=NULL);
	/*!	read the object from a stream(file persistence)
		@param stm the stream class that store the bitstream
		@param pStream script wrapper for the stream(optional)
		@return true if succeded,false failed
		@see CStream
	*/
	bool Load(ref CStream stm,IScriptObject *pStream=NULL);
	/*!	read the object from a stream(file persistence) RELLEASE save version - for compatibility
	@param stm the stream class that store the bitstream
	@param pStream script wrapper for the stream(optional)
	@return true if succeded,false failed
	@see CStream
	*/
	bool LoadRELEASE(ref CStream stm,IScriptObject *pStream=NULL);

	/*!	read the object from a stream(file persistence) PATCH1 save version - for compatibility
	@param stm the stream class that store the bitstream
	@param pStream script wrapper for the stream(optional)
	@return true if succeded,false failed
	@see CStream
	*/
	bool LoadPATCH1(ref CStream stm,IScriptObject *pStream=NULL);

/*! Get the entity container. The concept of the container is explained in IEntityContainer.
	@return Pointer to the entity container if there is one, otherwise NULL
	@see IEntityContainer
*/
	IEntityContainer* GetContainer()const;
	void SetContainer(IEntityContainer* pContainer);
/*! Get Character interface, if a character is loaded.
	@return Pointer to the character interface if one exists, otherwise NULL
	@see IEntityCharacter
*/
	IEntityCharacter* GetCharInterface()const;

/*! Start an animation of a character animated object in a specified slot.
	@param pos	The slot in which the character containing this animation is loaded.
	@param animname	The name of the animation that we want to start.
	@return True if animation started, otherwise false.
*/
	bool StartAnimation(int pos, const char *animname,int iLayerID =0, float fBlendTime=1.5f, bool bStartWithLayer0Phase = false );

  //! Set animations speed scale
	//! This is the scale factor that affects the animation speed of the character.
	//! All the animations are played with the constant real-time speed multiplied by this factor.
	//! So, 0 means still animations (stuck at some frame), 1 - normal, 2 - twice as fast, 0.5 - twice slower than normal.
	void SetAnimationSpeed( const float scale=1.0f );

	//! Returns the current animation in the layer or -1 if no animation is being played
	//! in this layer (or if there's no such layer)
  int GetCurrentAnimation(int pos, int iLayerID);


	//! Return the length of the given animation in seconds; 0 if no such animation found
	float GetAnimationLength( const char *animation );

/*! check if there is animation
	@param pos	The slot in which the character containing this animation is loaded.
	@param animname	The name of the animation that we want to start.
	@return True if animation present, otherwise false.
*/
	bool IsAnimationPresent( int pos,const char *animation );

/*! Reset an animation of a character animated object in a specified slot.
	@param pos	The slot in which the character containing this animation is loaded.
*/
	void ResetAnimations(int pos);

// sets the given aniimation to the given layer as the default
	void SetDefaultIdleAnimation( int pos,const char * szAnimation=NULL );

/*force update character in slot pos
	This is required if you start some animations abruptly (i.e. without blendin time)
	after the character update has passed, and need the results to be on this frame,
	rather than on the next.
*/
	void ForceCharacterUpdate( int pos );

/*! Registers this entity in the ai system so that agents can see it and interact with it
*/
	//FIXME:
	struct AIObjectParameters{};
	bool RegisterInAISystem(ushort type, const ref AIObjectParameters params);

/*! Gets AI representation
*/
	extern interface IAIObject;
	IAIObject *GetAI();

/*! Enables or disables AI presence of this entity
*/
	void EnableAI(bool enable);

/*! Enable disable the save of the entity when the level is saved on disk
*/
	void EnableSave(bool bEnable);
/*! return true if the entity must be saved on disk
*/
	bool IsSaveEnabled();

//! Retrieves the Trackable-flag
	bool IsTrackable();

	//////////////////////////////////////////////////////////////////////////
	// State Managment public interface.
	//////////////////////////////////////////////////////////////////////////

/*!
	Change entity state to specified.
	@param sState Name of state table within entity script (case sensetive).
	@return true if state succesfully changed or false if state is unknown.
*/
	bool GotoState( const char *sState );
	bool GotoState( int nState );
/*!
	Check if entity is in specified state.
	@param sState Name of state table within entity script (case sensetive).
	@return true if entity is currently in this state.
*/
	bool IsInState( const char *sState );
	bool IsInState( int nState );
/*!
	Get name of currently active entity state.
	@return State's name.
*/
	const char* GetState();
	int GetStateIdx();
/*!
	Register a state for this entity
	@return State's name.
*/
	void RegisterState(const char *sState);

	//! \return true=prevents error when state changes on the client and does not sync state changes to the client, false otherwise
	bool IsStateClientside()const;
	//! \param bEnable true=prevents error when state changes on the client and does not sync state changes to the client, false otherwise
	void SetStateClientside( const bool bEnable );

	//! Calls script OnTimer callback in current state.
	//! @param nTimerId Id of timer set with SetTimer.
	void OnTimer( int nTimerId );
	//! Calls script OnAction callback in current state.
	//! @nKey code of action.
	//void OnAction( int nAction );
	//! Calls script OnDamage callback in current state.
	//! @pObj structure to describe the hit. - script object, to be passed to script OnDamage
		void OnDamage( IScriptObject *pObj );
	//! Calls script OnEnterArea callback in current state. Called when the entity enters area
	//! @entity wich enters the area
	//! @areaID id of the area the entity is in
	void OnEnterArea( IEntity* entity, const int areaID );

	//! Physics	callback called when an entity overlaps with this one
	//! @IEntity pOther entity which enters in contact with this one
	void OnPhysicsBBoxOverlap(IEntity *pOther);

	//! Physics	callback called when an entity physics change its simulation class (Awakes or goes to sleep)
	void OnPhysicsStateChange( int nNewSymClass,int nPrevSymClass );

	//! Assign recorded physical state to the entity.
	void SetPhysicsState( const char *sPhysicsState );;

	//! Calls script OnLeaveArea callback in current state. Called when the entity leavs area
	//! @entity wich leaves the area
	//! @areaID id of the area
	void OnLeaveArea( IEntity* entity, const int areaID );

	//! Calls script OnProceedFadeArea callback in current state. Called every frame when the entity is in area
	//! @entity wich leaves the area
	//! @areaID id of the area
	//! @fadeCoeff	[0, 1] coefficient
	void OnProceedFadeArea( IEntity* entity, const int areaID, const float fadeCoeff );

	//! Calls script OnBind callback in current state. Called on client only
	//! @entity wich was bound to this on server
	//! @par
	void OnBind( IEntity* entity, const char par );

	//! Calls script OnUnBind callback in current state. Called on client only
	//! @entity wich was unbound to this on server
	//! @par
	void OnUnBind( IEntity* entity, const char par );


	void SetTimer(int msec);
	void KillTimer();
	//! Sets rate of calls to script update function.
	void SetScriptUpdateRate( float fUpdateEveryNSeconds );

	void ApplyForceToEnvironment(const float radius, const float force);

	int GetSide(ref const(Vec3) direction);

	//! Hide entity, making it invisible and not collidable. (Used by Editor).
	void Hide(bool b);
	//! Check if entity is hidden. (Used by Editor mostly).
	bool IsHidden()const;

	/** Used by editor, if entity will be marked as garbage do not destroy it.
	*/
	void SetDestroyable(bool b);
	bool IsDestroyable()const;
	void SetGarbageFlag( bool bGarbage );
	//////////////////////////////////////////////////////////////////////////

	bool WasVisible();
	//bool IsVisible();

	//! check wheteher this entity has changed
	bool HasChanged();

	//! get the slot containing the steering wheel
	//! FIXME: This better be moved in the game code, together with the
	//! loadvehicle function (-1 if not found)
	int	GetSteeringWheelSlot();

/*! Get bone hit zone type (head, torso, arm,...) for boneIdx bone
*/
	int		GetBoneHitZone( int boneIdx )const;
/*	hit parameters
		set by OnDamage()
		used by CPlayer::StartDeathAnimation()
*/
	void GetHitParms( ref int deathType, ref int deathDir, ref int deathZone ) const;

  //! access to the entity rendering info/state (used by 3dengine)
//  EntityRenderState & GetEntityRenderState();

	//! inits entity rendering properties ( tmp silution for particle spray entity )
	void InitEntityRenderState();

	//!
	void ActivatePhysics( bool activate );

	/* it sets common callback functions for those entities
		 without a script, by calling a common script function
		 for materials / sounds etc.
		 Client side only.
	@param pScriptSystem pointer to script system
	*/
	void SetCommonCallbacks(IScriptSystem *pScriptSystem);

	//! Create particle emitter at specified slot and with specified params
	extern interface IParticleEffect;
	int	CreateEntityParticleEmitter(int nSlotId, const ref ParticleParams PartParams, float fSpawnPeriod,Vec3 vOffSet,Vec3 vDir,IParticleEffect *pEffect = null,float fSize=1.0f );
	//! Delete particle emitter at specified slot
	void DeleteParticleEmitter(int nId);

	extern interface ICrySizer;
	void GetMemoryStatistics(ICrySizer *pSizer);

	//! gets/set water density for this object
	void	SetWaterDensity(float fWaterDensity);
	float	GetWaterDensity();

  //! set update type
  void SetUpdateVisLevel(EEntityUpdateVisLevel nUpdateVisLevel);

  //! get update type
  EEntityUpdateVisLevel GetUpdateVisLevel();


/*! Sets position for IK target for hands
	@param target	pointer to vec pos. If NULL - no hands IK
*/
	void SetHandsIKTarget( const Vec3* target=NULL );

	void Remove();

	//! Set custom shader parameters
	void SetShaderFloat(const char *Name, float Val);

	//! enable/disable entity objects light sources
	void	SwitchLights( bool bLights );

	//
	//needed for MP - when client connects after some entity was bound (player to vehicle) - connected clent does not get OnBing
	//so this will send binding to the client
	void	SinkRebind(IEntitySystemSink *pSink);

};

////////////////////////////////////////////////////////////////////////////
enum ContainerInterfaceType
{
	CIT_IPLAYER,
	CIT_IWEAPON,
	CIT_IVEHICLE,
	CIT_ICOMMANDER,
	CIT_ISPECTATOR,
	CIT_IADVCAMSYSTEM
};

////////////////////////////////////////////////////////////////////////////
//! Just an interface that Aggregate object who wants to aggregate entity must implement.
/*!
	This interface is used to extend the functionality of an entity, trough aggregation.
	Different entity types have containers - players,
	weapons,vehicles and flocks(birds,fishes etc.) . The entity will call
	its container (if one exists) on major events like Init,Update and will enable the container to
	perform certain specialization for the entity. Most of the entities will
	not have a container, since their specialization will be done over
	the script that is associated with them. So, classes that implement this
	interface actually "contain" an entity within them, and therefore are EntityContainers.

*/
abstract class IEntityContainer
{

/*! Container Init Callback. This function is called from the init of the entity contained within this container.
	@return True if initialization completed with no fatal errors, false otherwise.
*/
	bool Init();

/*! Container update callback. This function is called from the update of the entity contained within this container.
*/
	void Update();

/*! Sets the entity contained in this container.
	@param entity	The desired entity.
	@see IEntity
*/
	void SetEntity( IEntity* entity );

/*! called by the entity when the position is changed
	@param new postition of the entity.
	@see IEntity
*/
	void OnSetAngles( const ref Vec3 ang );

/*! Get the interface which describes this container in script. Containers are not mapped to separate tables in script, but rather to a
  table which is a member of the sctipt table of the entity contained within the container. So this script object should not be used as
	a first parameter in a script call.
	@return The interface to the script object
	@see IScriptSystem
	@see IScriptSystem::BeginCall(const char*, const char *)
*/
	bool Write(ref CStream stm,EntityCloneState *cs=NULL);
	bool Read(ref CStream stm);

/*! Position for sound-sources attached to this entity object.
*/
	Vec3 CalcSoundPos();

	IScriptObject *GetScriptObject();
/*! Set the object that describes this container in script.
	@param object The desired script object.
*/
	void SetScriptObject(IScriptObject *object);

	void Release();

	bool QueryContainerInterface( ContainerInterfaceType desired_interface, void **pInterface);
/*!	Add description of container in a CEntityDesc structure. This describes the entity class, entity id and other parameters.
	@param desc This parameter will contain the filled in CEntityDesc structure.
	@see CEntityDesc
*/
	void GetEntityDesc( ref CEntityDesc desc );

	void OnDraw(const ref IRenderer.SRendParams  EntDrawParams);

	//! start preloading render resoures
	void PreloadInstanceResources(Vec3d vPrevPortalPos, float fPrevPortalDistance, float fTime);

	//! tells if the container should be serialized or not (checkpoints, savegame)
	bool IsSaveable();

	//! return maximum radius of lightsources in container, used for vehicle now,
	//	todo: find better solution later like store lsourses in same place as other entity components - in entity
	float GetLightRadius();// { return 0; }

	//! called before the entity is synched over network - to calculate priority or neccessarity
	//! \param pXServerSlot must not be 0
	//! \param inoutPriority 0 means no update at all
	void OnEntityNetworkUpdate( const ref EntityId idViewerEntity, const ref Vec3d v3dViewer, ref uint32 inoutPriority,
		ref EntityCloneState inoutCloneState ) ;
};


//////////////////////////////////////////////////////////////////////
/*! Interface for accessing character related entity functions.
 */
interface IEntityCharacter
{
/*! Load new character model at a specific slot in the entity.
	@param pos The number of the slot in which this character will be loaded
	@param name The filename of the character cid file
	@return True on successful load, false otherwise.
*/
	bool LoadCharacter( int pos,const char *fileName );

/*! Physicalize existing character model. The model has to be previously loaded in the appropriate slot.
	@param pos Number of the slot where character model is loaded
	@param mass Mass of character
	@param surface_idx	Surface identifier for the player.
	@param bInstant - true if character is to be physicalized instantly and permanenty, otherwise it will be physicalized on-demand
	@return True if successfully physicalized, otherwise false.
*/
	bool PhysicalizeCharacter( int pos,float mass,int surface_idx,float stiffness_scale=1.0f,bool bInstant=false );

/*! Retrieves character physics from animation system and assigns it as main physical entity
*/
	void KillCharacter( int pos );

/*! Assign character model to a slot.
	@param pos	Number of slot where this character needs to be put.
	@param character	Character object
	@see ICryCharInstance
*/
	void SetCharacter( int pos,ICryCharInstance *character );

/*! Retrieves  character model from specified slot.
	@param pos Number of slot from which to retrieve character.
	@return Character object interface
	@see ICryCharInstance
*/
	extern interface ICryCharInstance;
	ICryCharInstance* GetCharacter( int pos );


/*! Enable/Disable drawing of character at a certain slot
	@param pos Number of slot which contains the character whose parameter is to be changed
	@param mode Desired drawing mode. This mode can be one of the following values: ETY_DRAW_NORMAL, ETY_DRAW_NEAR, ETY_DRAW_NONE.
*/
	void DrawCharacter( int pos,int mode );
/*! Reset all animations of the character at a specified slot.
	@param pos Number of slot which contains the character whose animation is to be reset
*/
	void ResetAnimations( int pos );
/*! Retrieves a lip-sync interface :)
*/
	extern interface ILipSync;
	ILipSync* GetLipSyncInterface();
/*! Release the lip-sync interface and deallocate all resources.
*/
	void ReleaseLipSyncInterface();
};

////////////////////////////////////////////////////////////////////////////
/*! A callback interface for a class that wants to be aware when new entities are being spawned or removed. A class that implements
	this interface will be called everytime a new entity is spawned, removed, or when an entity container is to be spawned.
*/
interface IEntitySystemSink
{
/*! This callback enables the class which implements this interface a way to spawn containers for the entity that is just in the
	process of spawning. Every entity class that has a container creates it here. NOTE: Although the container is being created here,
	it is not initialized yet (this will be done when the entity being spawned initializes itself).
	@param ed	Entity description of entity which would be contained in this container
	@param pEntity The entity that will hold this container
*/
	void OnSpawnContainer( ref CEntityDesc ed,IEntity *pEntity);

/*! This callback is called when this entity has finished spawning. The entity has been created and added to the list of entities,
 but has not been initialized yet.
	@param e The entity that was just spawned
*/
	void OnSpawn( IEntity *e, ref CEntityDesc ed  );

/*! Called when an entity is being removed.
	@param e The entity that is being removed. This entity is still fully valid.
*/
	void OnRemove( IEntity *e );

	void OnBind(EntityId id,EntityId child,ubyte param);

	void OnUnbind(EntityId id,EntityId child,ubyte param);

};

////////////////////////////////////////////////////////////////////////////
/*! Interface to the system that manages the entities in the game, their creation, deletion and upkeep. The entities are kept in a map
 indexed by their uniqie entity ID. The entity system updates only unbound entities every frame (bound entities are updated by their
 parent entities), and deletes the entities marked as garbage every frame before the update. The entity system also keeps track of entities
 that have to be drawn last and with more zbuffer resolution.
*/
struct IEntitySystem
{

/*! Update entity system and all entities. This function executes once a frame.
*/
	void	Update();

/*! Retrieves the script system interface.
	@return Script System Interface
	@see IScriptSystem
*/
	IScriptSystem * GetScriptSystem();

/*! Reset whole entity system, and destroy all entities.
*/
	void	Reset();

/*! Spawns a new entity according to the data in the Entity Descriptor
	@param ed	Entity descriptor structure that describes what kind of entity needs to be spawned
	@param bAutoInit If true automatically initialize entity.
	@return The spawned entity if successfull, NULL if not.
	@see CEntityDesc
*/
	IEntity* SpawnEntity( ref CEntityDesc ed,bool bAutoInit=true );

/*! Initialize entity if entity was spawned not initialized (with bAutoInit false in SpawnEntity)
		Used only by Editor, to setup properties & other things before initializing entity,
		do not use this directly.
		@param pEntity Pointer to just spawned entity object.
		@param ed	Entity descriptor structure that describes what kind of entity needs to be spawned.
		@return true if succesfully initialized entity.
*/
	bool InitEntity( IEntity* pEntity,ref CEntityDesc ed );

/*! Retrieves entity from its unique id.
	@param id The unique ID of the entity required
	@return The entity if one with such an ID exists, and NULL if no entity could be matched with the id
*/
  IEntity* GetEntity( EntityId id );

/*! Set an entity as the player associated with this client, identified with the entity id
	@param id Unique Id of the entity which is to represent the player
*/
	//void SetMyPlayer( EntityId id );

/*! Get the entity id of the entity that represents the player.
	@return The entity id as an ushort*/

	//EntityId GetMyPlayer() ;

/*! Find first entity with given name.
	@param name The name to look for
	@return The entity if found, 0 if failed
*/
	IEntity* GetEntity(const char *sEntityName);
//! obsolete
	EntityId FindEntity( const char *name ) ;

/*! Remove an entity by ID
	@param entity	The id of the entity to be removed
	@param bRemoveNode If true forces immidiate delete of entity, overwise will delete entity on next update.
*/
	void	RemoveEntity( EntityId entity,bool bRemoveNow=false );

/*! Get number of entities stored in entity system.
	@return The number of entities
*/
	int		GetNumEntities() ;


/*! Get entity iterator. This iterator interface can be used to traverse all the entities in this entity system.
	@return An entityIterator
	@see IEntityIt
*/
	IEntityIt * GetEntityIterator();

/*! Get entity iterator of all visible entities. This iterator interface can be used to traverse all the visible entities in this entity system.
	bFromPrevFrame	- to get entities visible in previouse update
	@return An entityIterator
	@see IEntityIt
*/
	IEntityIt * GetEntityInFrustrumIterator( bool bFromPrevFrame=false );

/*! Get all entities in specified radius.
		 physFlags is one or more of PhysicalEntityFlag.
	 @see PhysicalEntityFlag
*/
	void	GetEntitiesInRadius( const ref Vec3 origin, float radius, ref vector!(IEntity*) entities,int physFlags=PhysicalEntityFlag.PHYS_ENTITY_ALL ) ;

/*! Add the sink of the entity system. The sink is a class which implements IEntitySystemSink.
	@param sink	Pointer to the sink
	@see IEntitySystemSink
*/
	void	SetSink( IEntitySystemSink *sink );

	void	PauseTimers(bool bPause,bool bResume=false);

/*! Remove listening sink from the entity system. The sink is a class which implements IEntitySystemSink.
	@param sink	Pointer to the sink
	@see IEntitySystemSink
*/
	void RemoveSink( IEntitySystemSink *sink );

/*! Creates an IEntityCamera that can be attached to an entity
	@return Pointer to a new entity camera.
	@see IEntityCamera
*/
	IEntityCamera * CreateEntityCamera();
/*! Enable/Disable the Client-Side script calls
	@param bEnable true enable false disable
*/
	void EnableClient(bool bEnable);
/*! Enable/Disable the Server-Side script calls
	@param bEnable true enable false disable
*/
	void EnableServer(bool bEnable);

	//IEntityClonesMgr *CreateEntityClonesMgr();
/*! Destroys the entity system
*/
	void Release();

/*! Checks whether a given entity ID is already used
*/
	bool IsIDUsed(EntityId nID);

//! Calls reset for every entity, to reset its state
	void ResetEntities();

	//! Puts the memory statistics of the entities into the given sizer object
	//! According to the specifications in interface ICrySizer
	extern interface ICrySizer;
	void GetMemoryStatistics(ICrySizer *pSizer);

	//! if this is set to true (usually non editor mode)
	//! only dynamic EntityID s are created, no longer static ones
	void SetDynamicEntityIdMode( const bool bActivate );

	//! sets the default update level for the entities
	//! every entity spawned after this call will have the specified update level at creation time
	//! the entity can specify it differently later
	void SetDefaultEntityUpdateLevel( EEntityUpdateVisLevel eDefault);

	//! Set entity system mode into precaching of resources.
	void SetPrecacheResourcesMode( bool bPrecaching );

//	CIDGenerator* GetIDGenerator();
	bool	IsDynamicEntityId( EntityId id );
	void	MarkId( EntityId id );
	void	ClearId( EntityId id );
};

////////////////////////////////////////////////////////////////////////////
enum ThirdPersonMode 
{
	CAMERA_3DPERSON1,
	CAMERA_3DPERSON2
};

////////////////////////////////////////////////////////////////////////////
/*! Various camera parameters.
*/
struct EntityCameraParam
{
	float m_cam_dist;
	Vec3 m_cam_dir, m_1pcam_butt_pos,m_1pcam_eye_pos;
	float m_cam_kstiffness,m_cam_kdamping;
	float m_cam_angle_kstiffness,m_cam_angle_kdamping;
	float m_1pcam_kstiffness,m_1pcam_kdamping;
	float m_1pcam_angle_kstiffness,m_1pcam_angle_kdamping;
	float m_cur_cam_dist, m_cur_cam_dangle;
	float m_cur_cam_vel, m_cur_cam_dangle_vel;
	int   m_cam_angle_flags;
	Vec3 m_cur_cam_rotax;
	Vec3 m_camoffset;
	float m_viewoffset;
};

////////////////////////////////////////////////////////////////////////////
struct IEntityCamera
{
	void Release();
	void SetPos( const ref Vec3 p );
	Vec3 GetPos() ;
	void SetAngles( const ref Vec3 p );
	Vec3 GetAngles() ;
	void SetFov( ref const float f, const uint iWidth, const uint iHeight );
	float GetFov() ;
	Matrix44 GetMatrix() ;
	void Update();
	ref CCamera GetCamera();
	void SetCamera( const ref CCamera cam );
	void SetParameters(const EntityCameraParam *pParam);
	void GetParameters(EntityCameraParam *pParam);
	void SetViewOffset(float f);
	float GetViewOffset();
	void SetCamOffset(Vec3 v);
	ref Vec3 GetCamOffset();
	extern interface I3DEngine;
	void SetThirdPersonMode( const ref Vec3 pos,const ref Vec3 angles,int mode,float frameTime,float
		range,int dangleAmmount,IPhysicalEntity *physic, IPhysicalEntity *physicMore=NULL, I3DEngine* p3DEngine=NULL, float safe_range=0.0f);
	void SetCameraMode(const ref Vec3 lookat,const ref Vec3 lookat_angles, IPhysicalEntity *physic);
	void SetCameraOffset(const ref Vec3 offset);
	void GetCameraOffset(ref Vec3 offset);
};
