module WeaponClass;

//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
// 
//	File: WeaponClass.h
//  Description:
//	For every weapon type in the game, we have one CWeaponClass. It allows
//	access to the individual firemodes of the weapon (and their
//	corresponding properties).
//						
//	History:
//	- May 2003: Created by Marco Koegler
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

import Script.Vector;
import FireType;
import xplayer;
import Math;
import ientitysystem;

import iscriptsystem;

//class CWeaponSystemEx;
//class CScriptObjectWeaponClass;

//////////////////////////////////////////////////////////////////////
enum EWeaponFunc
{
	WeaponFunc_OnInit = 0,
	WeaponFunc_OnActivate,
	WeaponFunc_OnDeactivate,
	WeaponFunc_WeaponReady,
	WeaponFunc_OnAnimationKey,
	WeaponFunc_OnStopFiring,
	WeaponFunc_OnFireCancel,
	WeaponFunc_Reload,
	WeaponFunc_Drop,
	WeaponFunc_OnUpdate,
	WeaponFunc_OnFire,
	WeaponFunc_OnHit,
	WeaponFunc_OnEvent,
	WeaponFunc_Count
};

enum OT_ENTITY = 0;
enum OT_STAT_OBJ = 1;
enum OT_TERRAIN = 2;
enum OT_BOID = 3;
enum OT_RIGID_PARTICLE = 10;

//////////////////////////////////////////////////////////////////////
/*!
* Structure that represents how object been hit by the weapon.
*/
struct SWeaponHit
{
	Vec3 pos; //!< Excact position of hit.
	Vec3 normal; //!< Normal of hitted surface.
	Vec3 dir; //!< Direction of shoot.
	float damage; //!< Calculated damage that should be inflicted by this kind of hit.
	IEntity* target; //!< What entity was hit.
	IEntityRender* targetStat; //!< What static object was hit.
	int ipart; //!< id of hit entity part
	int objecttype; //!< If static object or terrain was hit			1-statobj, 2-terrain
	IEntity* shooter; //!< Player who shot.
	IScriptObject* weapon; //!< Weapon used to shoot.
	IEntity* projectile; //!< Projectile that caused this hit.
	int surface_id; //!< Physical surface
	int weapon_death_anim_id; //!< Death anim ID
	int iImpactForceMul;
	int iImpactForceMulFinal;
	int iImpactForceMulFinalTorso;

	// Explosion related.
	float rmin;
	float rmax;
	float radius; //!< Damage radius.
	float impulsive_pressure;
};

//////////////////////////////////////////////////////////////////////
struct WeaponParams
{
	//FIXME:
	//this()
	//{
	//	fire_activation=eHolding;
	//	max_recoil=1.2f;
	//	min_recoil=0.5f;
	//	fMinAccuracy=0.7f;
	//	fMaxAccuracy=0.5f;
	//	fAimImprovement=0.5;
	//	no_ammo=false;
	//	accuracy_decay_on_run=1;
	//	iFireModeType = -1; //unknown
	//}

	bool bAIMode; //!< is this mode used only by the AI
	bool bAllowHoldBreath; //!< should the hold breath key be active for this weapon in zoom mode
	float fAutoAimDist; //!< if 0 - no autoaiming, otherwise - autoAim snap distance in screen space
	// works only for wevicles autoveapons
	float fMinAccuracy;
	float fMaxAccuracy;
	float fAimImprovement;
	float fAimRecoilModifier;
	float fSprintPenalty;
	float fReloadTime;
	float fFireRate;
	float fTapFireRate;
	float fDistance;
	int nDamage;
	float fDamageDropPerMeters;
	int nBulletpershot;
	int fire_activation;

	float fAccuracyModifierStanding;
	float fAccuracyModifierCrouch;
	float fAccuracyModifierProne;

	float fRecoilModifierStanding;
	float fRecoilModifierCrouch;
	float fRecoilModifierProne;

	float max_recoil;
	float min_recoil;
	float accuracy_decay_on_run;
	bool no_ammo;
	float whizz_sound_radius;

	int iFireModeType; //!< type of the fire mode (instant, projectile, melee)
	bool bShootUnderwater;

	// projectile-related
	int iBulletsPerClip;
	int iDeathAnim;
	int iImpactForceMul;
	int iImpactForceMulFinal;
	int iImpactForceMulFinalTorso;

	string sProjectileClass;
};

interface ICharInstanceSink
{

}

private interface ICryCharInstance
{

}
import istatobj;
import Stream;

//////////////////////////////////////////////////////////////////////
class CWeaponClass : ICharInstanceSink
{
public:
	//FIXME:
	//this(const ref CWeaponSystemEx rWeaponSystem)
	//{
	//	m_rWeaponSystem(rWeaponSystem);
	//	m_pObject = NULL;
	//	m_pCharacter = NULL;
	//	m_pMuzzleFlash = NULL;
	//	m_ID = 0;
	//	m_bIsLoaded = false;
	//	m_pScriptSystem = NULL;
	//	m_soWeaponClass = NULL;

	//	m_vAngles.Set(0,0,0);
	//	m_vPos.Set(0,0,0);
	//	m_fpvPos.Set(0,0,0);
	//	m_fpvAngles.Set(0,0,0);
	//	m_fpvPosOffset.Set(0,0,0);
	//	m_fpvAngleOffset.Set(0,0,0);
	//	m_fLastUpdateTime = 0;

	//	memset(m_hClientFuncs, 0, sizeof(m_hClientFuncs));
	//	memset(m_hServerFuncs, 0, sizeof(m_hServerFuncs));

	//	m_nAIMode = -1;
	//}

	 ~this();

	// BEGIN ICharInstanceSink
	void OnStartAnimation(const char* sAnimation);
	void OnAnimationEvent(const char* sAnimation, AnimSinkEventData UserData);
	void OnEndAnimation(const char* sAnimation);
	// END ICharInstanceSink

	bool Init(ref const string sName);
	void Reset();

	ref const(/*std_*/string) GetName() const
	{
		return m_sName;
	}

	void SetName(ref const string sName)
	{
		m_sName = sName;
	}

	int GetID() const
	{
		return m_ID;
	}

//FIXME:
	//ref CWeaponSystemEx GetWeaponSystem() const
	//{
	//	return m_rWeaponSystem;
	//}

	// rendering related
	IStatObj GetObject() const
	{
		//FIXME:
		//return m_pObject;
		return IStatObj.init;
	}

	ICryCharInstance GetCharacter() const
	{
		//FIXME:
		//return m_pCharacter;
		return ICryCharInstance.init;
	}

	IStatObj GetMuzzleFlash() const
	{
		//return m_pMuzzleFlash;
		return IStatObj.init;
	}

	ref const(/*std_*/string) GetBindBone() const
	{
		return m_sBindBone;
	}

	void SetBindBone(ref const /*std_*/string sBindBone)
	{
		m_sBindBone = sBindBone;
	}

	bool LoadMuzzleFlash(ref const /*std_*/string sGeometryName);

	// serialization
	void Read(ref CStream stm);
	void Write(ref CStream stm) const;

	// calls script functions of script object
	void ScriptOnInit();
	void ScriptOnActivate(IEntity* pShooter);
	void ScriptOnDeactivate(IEntity* pShooter);
	void ScriptWeaponReady(IEntity* pShooter);
	void ScriptOnStopFiring(IEntity* pShooter);
	bool ScriptOnFireCancel(IScriptObject* params);
	void ScriptReload(IEntity* pShooter);
	void ScriptDrop(IScriptObject* params);
	void ScriptOnUpdate(float fDeltaTime, IEntity* pShooter);
	bool ScriptOnFire(IScriptObject* params);
	void ScriptOnHit(IScriptObject* params);
	void ScriptOnEvent(int eventID, IScriptObject* params, bool* pRet = NULL);

	// positioning
	void SetFirstPersonWeaponPos(ref const Vec3 pos, ref const Vec3 angles);
	//! Find position of fire for this player.
	Vec3 GetFirePos(IEntity* pIEntity) const;

	//! Set offset of weapon for first person view.
	void SetFirstPersonOffset(ref const Vec3d posOfs, ref const Vec3d angOfs);
	Vec3 GetFirstPersonOffset()
	{
		return m_fpvPosOffset;
	};
	void MoveToFirstPersonPos(IEntity* pIEntity);

	ref const(Vec3) GetAngles() const
	{
		return m_vAngles;
	}

	ref const(Vec3) GetPos() const
	{
		return m_vPos;
	}

	IScriptObject* GetScriptObject()
	{
		return m_soWeaponClass;
	}

	bool IsLoaded() const
	{
		return m_bIsLoaded;
	}

	void Unload();
	bool Load();

	//! retrieve fire-type dependent fire rate ... 
	float GetFireRate(eFireType ft) const;

	//! does the weapon have an AI specific fire mode
	//!
	//! @return true if there is an AI fire mode
	bool HasAIFireMode() const;

	//! retrieve the AI specific fire mode number
	//!
	//! @return the fire mode the AI should use
	int GetAIFireMode() const;

	//! retrieve the index of the next fire mode. This function will
	//! skip/retrieve AI specific firemodes where necessary.
	//!
	//! @return index of the next firemode
	int GetNextFireMode(int oldMode, bool isAI) const;

	//! memory statistics
	//! @return number of bytes used
	uint MemStats() const;

private:
	bool InitWeaponClassVariables();
	bool InitScripts();
	bool InitModels();
	void ProcessHitTarget(ref const SWeaponHit hit);

	// the actual weapon class variables
	int m_ID; //!< class ID
	/*std_*/string m_sScript; //!< script file representing this weapon class
	/*std_*/string m_sPickup; //!< pickup script file representing this weapon class
	bool m_bIsLoaded; //!< is the class loaded

	/*ref*/
	//FIXME:
	//CWeaponSystemEx m_rWeaponSystem; //!< reference to the weapon system we belong to
	IScriptSystem* m_pScriptSystem; //!< pointer to script system
	/*std_*/string m_sName; //!< the name of the weapon class (e.g. "Machete")
	IScriptObject* m_soWeaponClass;

	// position
	Vec3 m_vAngles;
	Vec3 m_vPos;
	Vec3 m_fpvPos;
	Vec3 m_fpvAngles;
	Vec3 m_fpvPosOffset;
	Vec3 m_fpvAngleOffset;

	// script function callback tables
	HSCRIPTFUNCTION[EWeaponFunc.WeaponFunc_Count] m_hClientFuncs;
	HSCRIPTFUNCTION[EWeaponFunc.WeaponFunc_Count] m_hServerFuncs;

	// rendering related
	IStatObj* m_pObject; //!< third person weapon model
	ICryCharInstance* m_pCharacter; //!< first person animated weapon
	IStatObj* m_pMuzzleFlash; //!< muzzle flash (used in both 3rd and 1st person)
	string m_sBindBone; //!< name of bone to bind object to

	// FIXME: clean this stuff up
public:
	WeaponParams* AddWeaponParams(const ref WeaponParams params);
	void GetWeaponParams(ref WeaponParams params);
	bool GetModeParams(int mode, ref WeaponParams stats);
	bool CancelFire();
	void Update(CPlayer* pPlayer);
	int Fire(ref const Vec3d origin, ref const Vec3d angles, CPlayer* pPlayer,
			ref WeaponInfo winfo, IPhysicalEntity* pIRedirected);
	void ProcessHit(ref const SWeaponHit hit);
	void CalculateWeaponAngles(BYTE random_seed, Vec3d* pVector, float fAccuracy);

	//alias vector!(WeaponParams*) WeaponParamsVec;
	alias WeaponParamsVec = WeaponParams*[];
	//alias WeaponParamsVec.iterator WeaponParamsVecItor;
	WeaponParamsVec m_vFireModes;
	int m_nAIMode; //!< fire mode number which the AI will use for this weapon (-1 if there is no AI mode)
	char m_HoldingType;
	WeaponParams m_fireParams;
	float m_fLastUpdateTime;
	int m_nLastMaterial; //used to avoid playing the same material sound twice in a row

	_SmartScriptObject m_ssoFireTable;
	_SmartScriptObject m_ssoProcessHit;

	_SmartScriptObject m_sso_Params_OnAnimationKey;
	_SmartScriptObject m_sso_Params_OnActivate;
	_SmartScriptObject m_sso_Params_OnDeactivate;

	CScriptObjectVector m_ssoHitPosVec;
	CScriptObjectVector m_ssoHitDirVec;
	CScriptObjectVector m_ssoHitNormVec;
	CScriptObjectVector m_ssoHitPt;
	CScriptObjectVector m_ssoBulletPlayerPos;
};
