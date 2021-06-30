module xplayer;

import GameObject;
import ientitysystem;
import ISound;
//import ScriptObjectStream;
import ScriptObjects.Vector;
import FireType;
//import SynchedRandomSeed;			// CSynchedRandomSeed

extern (C++):
//////////////////////////////////////////////////////////////////////
enum BITMASK_PLAYER =				1;
enum BITMASK_WEAPON =				2;				// both 1st and 3rd person weapon
enum BITMASK_OBJECT =				4;


/*!
 *	Base class for all game objects.
 *  Implements IEntityContainer interface.
 *	
 */

//////////////////////////////////////////////////////////////////////
//! Current weapon description structure.
struct WeaponInfo
{
	bool	owns;																					//!< have this weapon in possesion.
	int		maxAmmo;																			//!< Max ammo allowed for this weapon.
	bool	reloading;																		//!< Is weapon is reloading now.
	float fireFirstBulletTime;													//!< first bullet in a burst
	float fireTime;																			//!< Last time we fired.
	float fireLastShot;																	//!< Last succeded shot
	int		iFireMode;																		//!< firemode
  //FIXME:
  //ICryCharInstance::ObjectBindingHandle	hBindInfo, hAuxBindInfo;		//!<  auxillary bind info for two weapon shooting and binding
	
	//this()
	//{
	//	ZeroStruct(*this);
	//	hBindInfo			= ICryCharInstance::nInvalidObjectBindingHandle;
	//	hAuxBindInfo	= ICryCharInstance::nInvalidObjectBindingHandle;
	//}

	extern interface ICryCharInstance;
	void DetachBindingHandles(ICryCharInstance *pCharacter)
	{
		assert (IsHeapValid());
		if (hBindInfo)
		{
			pCharacter.Detach(hBindInfo);
			//FIXME:
			//hBindInfo = ICryCharInstance::nInvalidObjectBindingHandle;
		}
		if (hAuxBindInfo)
		{
			pCharacter.Detach(hAuxBindInfo);
			//FIXME:
			//hAuxBindInfo = ICryCharInstance::nInvalidObjectBindingHandle;
		}
		assert (IsHeapValid());
	}
};

//////////////////////////////////////////////////////////////////////
/*! Implement the entity container for the player entity
*/
class CPlayer //: public CGameObject
{
public:
	enum eInVehiclestate
	{
		PVS_OUT=0,
		PVS_DRIVER,
		PVS_GUNNER,
		PVS_PASSENGER,
	};
}
