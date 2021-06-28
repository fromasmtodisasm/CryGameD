module ientitysystem;

import core.sys.windows.windows;

import IStatObj;

extern (C++):

////////////////////////////////////////////////////////////////////////////
// !!! don't change the type !!!
alias ushort EntityClassId; //! unique identifier for the entity class (defined in ClassRegistry.lua)
alias ULONG_PTR BoneBindHandle;

// Common
import cry_math;
import cry_camera;
import IEntityRenderState;

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

struct IScriptObject;
