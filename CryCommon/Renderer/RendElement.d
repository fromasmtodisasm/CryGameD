module Renderer.RendElement;

import Math;
import irenderer;
import Renderer.ishader;
import platform;

//struct SMsurface;
//class CRendElement;
//struct CMatInfo;
//struct PrimitiveGroup;
//struct SShader;
//struct SShaderTechnique;
//struct Plane;

//////////////////////////////////////////////////////////////////////
enum EDataType
{
  eDATA_Unknown = 0,
  eDATA_Dummy,
  eDATA_Sky,		
  eDATA_Beam,		
  eDATA_Poly,
  eDATA_Curve,
  eDATA_MotModel,
  eDATA_MeshModel,
  eDATA_PolyBlend,
  eDATA_AnimPolyBlend,
  eDATA_ClientPoly,
  eDATA_ClientPoly2D,
  eDATA_ParticleSpray,
  eDATA_TriMesh,
  eDATA_TriMeshShadow,
  eDATA_Prefab,
  eDATA_Flare,
  eDATA_FlareGeom,
  eDATA_FlareProp,
  eDATA_Tree,
  eDATA_Tree_Leaves,
  eDATA_Tree_Branches,
  eDATA_Terrain,
  eDATA_SkyZone,
  eDATA_OcLeaf,
  eDATA_TerrainSector,
  eDATA_2DQuad,
  eDATA_FarTreeSprites,
	//  eDATA_TriMeshAdditionalShadow,
  eDATA_AnimModel,
  eDATA_MotionBlur,
  eDATA_ShadowMapGen,
  eDATA_TerrainDetailTextureLayers,
  eDATA_TerrainParticles,
  eDATA_Ocean,
  eDATA_Glare,
  eDATA_OcclusionQuery,
  eDATA_TempMesh,
	eDATA_ClearStencil,
  eDATA_FlashBang,

  // tiago: added
  eDATA_ScreenProcess,  
  eDATA_HDRProcess,  
};

import Renderer.ColorDefs;

//////////////////////////////////////////////////////////////////////
struct SInpData
{
  Vec3 Org;
  Vec3 Normal;
  CFColor Color;
  int UniqLightStyle;
  int OrigLightStyle;
};

//////////////////////////////////////////////////////////////////////
struct SMRendVert
{
  this (float x, float y, float z) { vert[0] = x; vert[1] = y; vert[2] = z; }
  Vec3 vert;
  union
  {
    uint m_uiInfo;
    ubyte[4] m_bInfo;
  };
};

//////////////////////////////////////////////////////////////////////
struct SMRendTexVert
{
  this (float u, float t) { vert[0] = u; vert[1] = t; }
  float[2] vert;
};

//////////////////////////////////////////////////////////////////////
struct SColorVert
{
  Vec3 vert;
  float[2] dTC;
  UCol color;
};

//////////////////////////////////////////////////////////////////////
struct SColorVert2D
{
  float[2] vert;
  float[2] dTC;
  UCol color;
};

//////////////////////////////////////////////////////////////////////
enum FCEF_TRANSFORM = 1;
enum FCEF_TRACE     = 2;
enum FCEF_NODEL     = 4;

enum FCEF_MODIF_TC   = 0x10;
enum FCEF_MODIF_VERT = 0x20;
enum FCEF_MODIF_COL  = 0x40;
enum FCEF_MODIF_MASK = 0xf0;

enum FCEF_NEEDFILLBUF = 0x100;
enum FCEF_ALLOC_CUST_FLOAT_DATA = 0x200;
enum FCEF_MERGABLE    = 0x400;

enum FGP_NOCALC = 1;
enum FGP_SRC    = 2;
enum FGP_REAL   = 4;
enum FGP_WAIT   = 8;

enum FGP_STAGE_SHIFT = 0x10;

//////////////////////////////////////////////////////////////////////
struct SVertBufComps
{
  bool m_bHasTC;
  bool m_bHasColors;
  bool m_bHasSecColors;
  bool m_bHasNormals;
};

enum MAX_CUSTOM_TEX_BINDS_NUM = 8;

//////////////////////////////////////////////////////////////////////
class CRendElement
{
public:
  EDataType m_Type;
  uint m_Flags;

public:
  int m_nCountCustomData;
  void *m_CustomData;
  float m_fFogScale;
  int[MAX_CUSTOM_TEX_BINDS_NUM] m_CustomTexBind;
  CFColor m_Color;
  int m_SortId;

  static CRendElement m_RootGlobal;
  CRendElement *m_NextGlobal;
  CRendElement *m_PrevGlobal;

  extern(C) struct CVProgram;
  CVProgram *m_LastVP;      // Last Vertex program which updates Z buffer

protected:


  void UnlinkGlobal()
  {
    if (!m_NextGlobal || !m_PrevGlobal)
      return;
    m_NextGlobal.m_PrevGlobal = m_PrevGlobal;
    m_PrevGlobal.m_NextGlobal = m_NextGlobal;
    m_NextGlobal = m_PrevGlobal = NULL;
  }
  void LinkGlobal( CRendElement* Before )
  {
    if (m_NextGlobal || m_PrevGlobal)
      return;
    m_NextGlobal = Before.m_NextGlobal;
    Before.m_NextGlobal.m_PrevGlobal = this;
    Before.m_NextGlobal = this;
    m_PrevGlobal = Before;
  }

public:
  this()
  {
    m_Type = eDATA_Unknown;
    m_NextGlobal = NULL;
    m_PrevGlobal = NULL;
    m_Flags = 0;
    m_CustomData = NULL;
		for(int i=0; i<MAX_CUSTOM_TEX_BINDS_NUM; i++)
	    m_CustomTexBind[i] = -1;
    m_fFogScale=0;
    m_SortId = 0;
    m_LastVP = NULL;
    if (!m_RootGlobal.m_NextGlobal)
    {
      m_RootGlobal.m_NextGlobal = &m_RootGlobal;
      m_RootGlobal.m_PrevGlobal = &m_RootGlobal;
    }
    if (this != &m_RootGlobal)
      LinkGlobal(&m_RootGlobal);
  }

  ~this()
  {
    if ((m_Flags & FCEF_ALLOC_CUST_FLOAT_DATA) && m_CustomData)
		{
			delete [] (cast(float*)m_CustomData);
			m_CustomData=0;
		}
    UnlinkGlobal();
  }

  const char *mfTypeString();

  EDataType mfGetType() { return m_Type; }

  void mfSetType(EDataType t) { m_Type = t; }

  uint mfGetFlags() { return m_Flags; }
  void mfSetFlags(uint fl) { m_Flags = fl; }
  void mfUpdateFlags(uint fl) { m_Flags |= fl; }
  void mfClearFlags(uint fl) { m_Flags &= ~fl; }

  abstract void mfPrepare();
  abstract bool mfCullByClipPlane(CCObject *pObj);
  abstract CMatInfo *mfGetMatInfo();
  abstract list2!CMatInfo *mfGetMatInfoList();
  abstract int mfGetMatId();
  abstract bool mfCull(CCObject *obj);
  abstract bool mfCull(CCObject *obj, SShader *ef);
  abstract void mfReset();
  abstract CRendElement *mfCopyConstruct();
  abstract void mfCenter(ref Vec3 centr, CCObject*pObj);
  abstract void mfGetBBox(ref Vec3 vMins, ref Vec3 vMaxs)
  {
    vMins.Set(0,0,0);
    vMaxs.Set(0,0,0);
  }
  abstract void mfGetPlane(ref Plane pl);
  abstract float mfDistanceToCameraSquared(const ref CCObject  thisObject);
  abstract void mfEndFlush();
  abstract void Release();
  abstract int mfTransform(ref Matrix44 ViewMatr, ref Matrix44 ProjMatr, vec4_t *verts, vec4_t *vertsp, int Num);
  abstract bool mfIsValidTime(SShader *ef, CCObject *obj, float curtime);
  abstract void mfBuildGeometry(SShader *ef);
  abstract bool mfCompile(SShader *ef, char *scr);
  abstract CRendElement *mfCreateWorldRE(SShader *ef, SInpData *ds);
  abstract bool mfDraw(SShader *ef, SShaderPass *sfm);
  abstract void *mfGetPointer(ESrcPointer ePT, int *Stride, int Type, ESrcPointer Dst, int Flags);
  abstract bool mfPreDraw(SShaderPass *sl) { return true; }
  abstract float mfMinDistanceToCamera(CCObject *pObj) {return -1;};
  abstract bool mfCheckUpdate(int nVertFormat, int Flags) {int i=Flags; return true;}
  abstract int Size() {return 0;}
};

//FIXME:
//import Renderer.CREOcLeaf;
//import Renderer.CRESky;
//import Renderer.CRE2DQuad;
//import Renderer.CREDummy;
//import Renderer.CRETerrainSector;
//import Renderer.CRETriMeshShadow;
//import Renderer.CRETriMeshAdditionalShadow;
//import Renderer.CREShadowMap;
//import Renderer.CREOcclusionQuery;
//import Renderer.CREFlashBang;

// tiago: added
//import Renderer.CREGlare;  
//import Renderer.CREScreenProcess; 

