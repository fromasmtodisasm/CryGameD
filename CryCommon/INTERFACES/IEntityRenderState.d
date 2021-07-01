module ientityrenderstate;

import Math;
import istatobj;
import irenderer;
import LeafBuffer;
import ientitysystem;
import core.stdc.stdio;
import platform;

import physinterface;

// !!! don't change the type !!!
alias ushort EntityId; //! unique identifier for each entity instance

////////////////////////////////////////////////////////////////////////////
enum EERType
{
	eERType_Unknown,
	eERType_Brush,
	eERType_Vegetation
};

////////////////////////////////////////////////////////////////////////////
struct OcclusionTestClient
{
	ubyte ucOcclusionByTerrainFrames;
	ubyte ucOcclusionByObjectsFrames;
	bool bLastResult = true;
	int nLastVisibleFrameID;
};

////////////////////////////////////////////////////////////////////////////
//! Rendering properties/state of entity
//! 3dengine/indoor/ should not have access to the game specific actual IEntity 
//! 3dengine only needs access to some functions.
struct IEntityRenderState
{
	// used for shadow maps
	struct ShadowMapInfo
	{

		void Release(EERType eEntType, IRenderer * pRenderer);
		list2!ShadowMapLightSourceInstance  * pShadowMapCasters;
		ShadowMapLightSource * pShadowMapFrustumContainer;
		ShadowMapLightSource * pShadowMapFrustumContainerPassiveCasters;
		list2!(CLeafBuffer*)  * pShadowMapLeafBuffersList;
		Vec3 vPrevTerShadowPos;
		float fPrevTerShadowRadius;
	}
	 ShadowMapInfo* pShadowMapInfo;

	// tmp flaot (distance to the light source, used for sorting)
	float fTmpDistance;

	//  ushort nScissorX1, nScissorY1, nScissorX2, nScissorY2;

	uint nStrongestLightId;
};

//! EntityRender flags
//! EntityRender flags
enum ERF_SELFSHADOW =						0x1;
enum ERF_CASTSHADOWVOLUME =					0x2;
enum ERF_RECVSHADOWMAPS =					0x4;
enum ERF_CASTSHADOWMAPS =					0x8;
enum ERF_DONOTCHECKVIS =         			0x10;
enum ERF_CASTSHADOWINTOLIGHTMAP =			0x20;
enum ERF_HIDABLE =							0x40;
enum ERF_HIDDEN =							0x80;
enum ERF_SELECTED =							0x100;
enum ERF_USELIGHTMAPS =						0x200;
enum ERF_OUTDOORONLY =						0x400;
enum ERF_UPDATE_IF_PV =						0x800;
enum ERF_EXCLUDE_FROM_TRIANGULATION =		0x1000;
enum ERF_MERGED =							0x2000;
enum ERF_RECVSHADOWMAPS_ACTIVE =			0x4000;
enum ERF_PHYS_NONCOLL =						0x8000;
enum ERF_MERGED_NEW =  						0x10000;
enum ERF_FIRST_PERSON_CAMERA_OWNER =		0x20000;

// Should be the same as FOB_ flags
enum ERF_NOTRANS_ROTATE =  					  0x10000000;
enum ERF_NOTRANS_SCALE = 					  0x20000000;
enum ERF_NOTRANS_TRANSLATE =				  0x40000000;
enum ERF_NOTRANS_MASK = (ERF_NOTRANS_ROTATE | ERF_NOTRANS_SCALE | ERF_NOTRANS_TRANSLATE);

////////////////////////////////////////////////////////////////////////////
abstract class IEntityRender
{

	const(char*) * GetEntityClassName() ;
	const ref Vec3  GetPos(bool bWorldOnly = true) ;
	const ref Vec3  GetAngles(int realA=0) ;
	float GetScale() ;
	const(char*) *GetName() ;
	void	GetRenderBBox( ref Vec3 mins,ref Vec3 maxs );
	void	GetBBox( ref Vec3 mins,ref Vec3 maxs ) { GetRenderBBox( mins, maxs ); }
	float GetRenderRadius() ;
  bool HasChanged() { return false; }
	bool DrawEntity(const ref SRendParams  EntDrawParams);
	bool IsStatic() ;
  IStatObj * GetEntityStatObj( uint nSlot, Matrix44 * pMatrix = NULL, bool bReturnOnlyVisible = false) { return 0; }
  void SetEntityStatObj( uint nSlot, IStatObj * pStatObj, Matrix44 * pMatrix = NULL ) {};
	ICryCharInstance* GetEntityCharacter( uint nSlot, Matrix44 * pMatrix = NULL ) { return 0; }
	void Physicalize(bool bInstant=false) {} 
	CDLight	* GetLight() { return 0; }
	IEntityContainer* GetContainer() const { return 0; }
 
	float m_fWSMaxViewDist;

  // rendering flags
  void SetRndFlags(uint dwFlags) { m_dwRndFlags = dwFlags; }
  void SetRndFlags(uint dwFlags, bool bEnable)
  { if(bEnable) m_dwRndFlags |= dwFlags; else ref m_dwRndFlags = ~dwFlags; }
  uint GetRndFlags() { return m_dwRndFlags; }
  int m_dwRndFlags; 

  // object draw frames (set if was drawn)
  void SetDrawFrame( int nFrameID, int nRecursionLevel ) { m_narrDrawFrames[nRecursionLevel] = nFrameID; }
  int GetDrawFrame( int nRecursionLevel = 0 ) const{ return m_narrDrawFrames[nRecursionLevel]; }
  int[2] m_narrDrawFrames;	

  // shadow draw frames (set if was drawn)
  void SetShadowFrame( ushort nFrameID, int nRecursionLevel ) { m_narrShadowFrames[nRecursionLevel] = nFrameID; }
  ushort GetShadowFrame( int nRecursionLevel = 0 ) const{ return m_narrShadowFrames[nRecursionLevel]; }

  // current distance to the camera (with reqursioin)
  float[2] m_arrfDistance;

  //! contains rendering properties, not 0 only if entity going to be rendered
  IEntityRenderState * m_pEntityRenderState;

  ushort[2] m_narrShadowFrames;	

	Vec3 m_vWSBoxMin = Vec3(0,0,0);
	Vec3 m_vWSBoxMax = Vec3(0,0,0);
	float m_fWSRadius;
	ubyte m_bForceBBox;
	ubyte ucViewDistRatio = 100;
	ubyte ucLodRatio = 100;
	ubyte m_nFogVolumeID;  // cur areas info

	extern(C) struct CSectorInfo;
	extern(C) struct CVisArea;
  CSectorInfo* m_pSector; 
  CVisArea * m_pVisArea;

	// Used for occlusion culling
	OcclusionTestClient OcclState;

  //! Access to the EntityRenderState for 3dengine
  ref IEntityRenderState * GetEntityRS() { return m_pEntityRenderState; }

	//## Lightmaps (here dot3lightmaps only)

	// Summary: 
	//   Assigns a texture set reference for dot3 lightmapping. The object will Release() it at the end of its lifetime
  extern(C) struct RenderLMData;
  void SetLightmap(RenderLMData * pLMData, float *pTexCoords, UINT iNumTexCoords, int nLod=0) {};

	// Summary: 
	//   Assigns a texture set reference for dot3 lightmapping. The object will Release() it at the end of its lifetime, special call from lightmap serializer/compiler to set occlusion map values
	void SetLightmap(RenderLMData *pLMData, float *pTexCoords, UINT iNumTexCoords, const ubyte cucOcclIDCount, ref const vector!(EntityId) aIDs){};

	//  Returns:
	//    true if there are lightmap texture coodinates and a lightmap texture assignment
  bool HasLightmap(int nLod) { return false; };
	//  Returns:
	//    Lightmap texture set for this object, or NULL if there's none assigned. Don't release obtained copy, it's not a reference
	//  See Also: 
	//    SetLightmap
  RenderLMData * GetLightmap(int nLod) { return 0; };
	// Summary:
	//   Returns vertex buffer holding instance specific texture coordinate set for dot3 lightmaps
  CLeafBuffer * GetLightmapTexCoord(int nLod) { return 0; };


	bool IsEntityHasSomethingToRender() = 0;

	bool IsEntityAreasVisible() = 0;

  // Returns:
	//   Current VisArea or null if in outdoors or entity was not registered in 3dengine
  extern interface IVisArea;
  IVisArea * GetEntityVisArea() { return cast(IVisArea*)m_pVisArea; }

  /* Allows to adjust defailt max view distance settings, 
    if fMaxViewDistRatio is 100 - default max view distance is used */
  void SetViewDistRatio(int nViewDistRatio) { ucViewDistRatio = min(254,max(0,nViewDistRatio)); }

	/*! Makes object visible at any distance */
	void SetViewDistUnlimited() { ucViewDistRatio = 255; }

	// Summary:
	//   Retrieves the view distance settings
	int GetViewDistRatio() { return (ucViewDistRatio==255) ? 1000 : ucViewDistRatio; }

  //! return max view distance ratio
  float GetViewDistRatioNormilized() { return 0.01f*GetViewDistRatio(); }

  /*! Allows to adjust defailt lod distance settings, 
  if fLodRatio is 100 - default lod distance is used */
  void SetLodRatio(int nLodRatio) { ucLodRatio = min(255,max(0,nLodRatio)); }

  //! return lod distance ratio
  float GetLodRatioNormilized() { return 0.01f*ucLodRatio; }

	// get/set physical entity
	IPhysicalEntity* GetPhysics() ;
	void SetPhysics( IPhysicalEntity* pPhys ) = 0;

	//! Set override material for this instance.
	void SetMaterial( IMatInfo *pMatInfo ) = 0;
	//! Query override material of this instance.
	IMatInfo* GetMaterial() ;
  int GetEditorObjectId() { return 0; }
  void SetEditorObjectId(int nEditorObjectId) {}

  //! Physicalize if it isn't already
  void CheckPhysicalized() {};

  int DestroyPhysicalEntityCallback(IPhysicalEntity *pent) { return 0; }

  void SetStatObjGroupId(int nStatObjInstanceGroupId) { }

  float GetMaxViewDist() { return 0; }

  extern struct ICryPak;
  void Serialize(bool bSave, ICryPak * pPak, FILE * f) {}
  EERType GetEntityRenderType() { return eERType_Unknown; }
  void Dephysicalize( ) {}
  void Dematerialize( ) {}
  int GetMemoryUsage() { return 0; }

	list2!ShadowMapLightSourceInstance * GetShadowMapCasters()
	{
		if(m_pEntityRenderState && m_pEntityRenderState.pShadowMapInfo)
			return m_pEntityRenderState.pShadowMapInfo.pShadowMapCasters;
		return 0;
	}

	ShadowMapLightSource * GetShadowMapFrustumContainer()
	{
		if(m_pEntityRenderState && m_pEntityRenderState.pShadowMapInfo)
			return m_pEntityRenderState.pShadowMapInfo.pShadowMapFrustumContainer;
		return 0;

	}

	ShadowMapLightSource * GetShadowMapFrustumContainerPassiveCasters()
	{
		if(m_pEntityRenderState && m_pEntityRenderState.pShadowMapInfo)
			return m_pEntityRenderState.pShadowMapInfo.pShadowMapFrustumContainerPassiveCasters;
		return 0;
	}

	void PreloadInstanceResources(Vec3d vPrevPortalPos, float fPrevPortalDistance, float fTime) = 0;
	void Precache() {};
};

