module IRenderer;

public import platform;

public extern(C++):

version(LINUX){
//	#include "Splash.h"
}
else
{
	enum eSplashType
	{
		EST_Water,
	};
}

alias HRESULT function (void * data, int miplevel, DWORD size, int width, int height, void * user_data) MIPDXTcallback;

// Global typedefs.
//////////////////////////////////////////////////////////////////////
alias const(char*)			cstr;
version(LINUX) alias ulong       DWORD;

//forward declarations.
//////////////////////////////////////////////////////////////////////
alias void*	WIN_HWND;
alias void*	WIN_HINSTANCE;
alias void*	WIN_HDC;
alias void*	WIN_HGLRC;

mixin(GenFWD!("CREOcLeaf"));
mixin(GenFWD!("CStatObj"));
mixin(GenFWD!("CStatObjInst"));
mixin(GenFWD!("ShadowMapFrustum"));
mixin(GenFWD!("CXFont"));
extern interface IStatObj;
//extern interface IEntityRender;

mixin(GenFWD!("CObjManager"));
mixin(GenFWD!("ShadowMapLightSource"));
mixin(GenFWD!("SPrimitiveGroup"));
extern interface ICryCharInstance;
//mixin(GenFWD!("CRendElement"));
import Renderer.RendElement;
import isystem;
//mixin(GenFWD!("ShadowMapLightSourceInstance"));
mixin(GenFWD!("CCObject"));
mixin(GenFWD!("CTexMan"));
mixin(GenFWD!("SVrect"));
mixin(GenFWD!("SColorVert2D"));
mixin(GenFWD!("SColorVert"));
mixin(GenFWD!("CFColor"));
mixin(GenFWD!("CShadowVolEdge"));
mixin(GenFWD!("CDLight"));
mixin(GenFWD!("IPhysicalWorld"));

//////////////////////////////////////////////////////////////////////
alias ubyte[4] bvec4;
alias float[4] vec4_t;
//alias ubyte byte;
alias float[2] vec2_t;

//////////////////////////////////////////////////////////////////////
//Vladimir's list
//template	<class T> class list2;
class list2(T)
{

}

//DOC-IGNORE-BEGIN
import ColorDefs;
import Utils.TArray;
import Math;

import IFont;
import MeshIdx;
extern struct ShadowMapLightSourceInstance;
//DOC-IGNORE-END

//////////////////////////////////////////////////////////////////////
enum R_CULL_DISABLE  = 0; 
enum R_CULL_NONE     = 0; 
enum R_CULL_FRONT    = 1;
enum R_CULL_BACK     = 2;

//////////////////////////////////////////////////////////////////////
enum R_TEXGEN_LINEAR	= 1;

//////////////////////////////////////////////////////////////////////
enum R_FOGMODE_LINEAR	= 1;
enum R_FOGMODE_EXP2		= 2;

//////////////////////////////////////////////////////////////////////
enum R_DEFAULT_LODBIAS	= 0;

//////////////////////////////////////////////////////////////////////
enum R_PRIMV_TRIANGLES		= 0;
enum R_PRIMV_TRIANGLE_STRIP	= 1;
enum R_PRIMV_QUADS	        = 2;
enum R_PRIMV_TRIANGLE_FAN  = 3;
enum R_PRIMV_MULTI_STRIPS	= 4;
enum R_PRIMV_MULTI_GROUPS	= 5;

//////////////////////////////////////////////////////////////////////
enum FILTER_NONE =		 -1;
enum FILTER_LINEAR		  = 0;
enum FILTER_BILINEAR		= 1;
enum FILTER_TRILINEAR	= 2;

//////////////////////////////////////////////////////////////////////
enum R_SOLID_MODE		= 1;
enum R_WIREFRAME_MODE	= 2;

enum R_GL_RENDERER	= 0;
enum R_DX8_RENDERER	= 1;
enum R_DX9_RENDERER	= 2;
enum R_NULL_RENDERER	= 3;
enum R_CUBAGL_RENDERER	= 4;

//////////////////////////////////////////////////////////////////////
// Render features

enum RFT_MULTITEXTURE = 1;
enum RFT_BUMP         = 2;
enum RFT_OCCLUSIONQUERY = 4;
enum RFT_PALTEXTURE   = 8;      // Support paletted textures
enum RFT_HWGAMMA      = 0x10;
enum RFT_ALLOWRECTTEX  = 0x20;  // Allow non-power-of-two textures
enum RFT_COMPRESSTEXTURE  = 0x40;
enum RFT_ALLOWANISOTROPIC = 0x100;  // Allows anisotropic texture filtering
enum RFT_SUPPORTZBIAS     = 0x200;
enum RFT_HW_ENVBUMPPROJECTED = 0x400; // Allows projected environment maps with EMBM
enum RFT_ALLOWSECONDCOLOR = 0x800;
enum RFT_DETAILTEXTURE    = 0x1000;
enum RFT_TEXGEN_REFLECTION = 0x2000;
enum RFT_TEXGEN_EMBOSS     = 0x4000;
enum RFT_OCCLUSIONTEST     = 0x8000; // Support hardware occlusion test

enum RFT_HW_GF2        = 0x10000; // GF2 class hardware (ATI Radeon 7500 as well :) )
enum RFT_HW_GF3        = 0x20000; // NVidia GF3 class hardware (ATI Radeon 8500 as well :) )
enum RFT_HW_RADEON     = 0x30000; // ATI R300 class hardware
enum RFT_HW_CUBAGL	  = 0x40000; // Nintendo Game-Cube
enum RFT_HW_GFFX       = 0x50000; // Geforce FX class hardware
enum RFT_HW_NV4X       = 0x60000; // NV4X class hardware
enum RFT_HW_MASK       = 0x70000; // Graphics chip mask
enum RFT_HW_HDR        = 0x80000; // Hardware supports high dynamic range rendering

enum RFT_HW_VS         = 0x100000;   // Vertex shaders 1.1
enum RFT_HW_RC         = 0x200000;   // Register combiners (OpenGL only)
enum RFT_HW_TS         = 0x400000;   // Texture shaders (OpenGL only)
enum RFT_HW_PS20       = 0x800000;   // Pixel shaders 2.0
enum RFT_HW_PS30       = 0x1000000;  // Pixel shaders 3.0

enum RFT_FOGVP         = 0x2000000;  // fog should be calculted in vertex shader (all NVidia cards)
enum RFT_ZLOCKABLE     = 0x4000000;  // depth buffer can be locked for read
enum RFT_SUPPORTFSAA   = 0x8000000;  // FSAA is supported by hardware
enum RFT_DIRECTACCESSTOVIDEOMEMORY   = 0x10000000;
enum RFT_RGBA          = 0x20000000; // RGBA order (otherwise BGRA)
enum RFT_DEPTHMAPS     = 0x40000000; // depth maps are supported
enum RFT_SHADOWMAP_SELFSHADOW  = 0x80000000; // depth correct shadow maps (via PS20 z-comparing)

//////////////////////////////////////////////////////////////////////////
// PrecacheResources flags

enum FPR_NEEDLIGHT     = 1;
enum FPR_2D            = 2;
enum FPR_IMMEDIATELLY  = 4;


//////////////////////////////////////////////////////////////////////////
// Draw shaders flags (EF_EndEf3d)

enum SHDF_ALLOWHDR = 1;
enum SHDF_SORT     = 2;

//////////////////////////////////////////////////////////////////////
// Texture flags

enum FT_PROJECTED   = 0x1;
enum FT_NOMIPS      = 0x2;
enum FT_HASALPHA    = 0x4;
enum FT_NORESIZE    = 0x8;
enum FT_HDR         = 0x10;
enum FT_UPDATE      = 0x20;
enum FT_ALLOCATED   = 0x40;
enum FT_BUILD       = 0x80;

enum FT_NODOWNLOAD  = 0x100;
enum FT_CONV_GREY   = 0x200;
enum FT_LM          = 0x400;
enum FT_HASDSDT     = 0x800;

enum FT_HASNORMALMAP = 0x1000;
enum FT_DYNAMIC    = 0x2000;
enum FT_NOREMOVE  = 0x4000;
enum FT_HASMIPS   = 0x8000;
enum FT_PALETTED  = 0x10000;
enum FT_NOTFOUND  = 0x20000;
enum FT_FONT     = 0x40000;
enum FT_SKY       = 0x80000;
enum FT_SPEC_MASK = 0x7f000;
enum FT_CLAMP     = 0x100000;
enum FT_NOSTREAM  = 0x200000;
enum FT_DXT1      = 0x400000;
enum FT_DXT3      = 0x800000;
enum FT_DXT5      = 0x1000000;
enum FT_DXT       = 0x1c00000;
enum FT_3DC       = 0x2000000;
enum FT_3DC_A     = 0x4000000;
enum FT_ALLOW3DC  = 0x8000000;

enum FT_BUMP_SHIFT = 27;
enum FT_BUMP_MASK      = 0xf0000000;
enum FT_BUMP_DETALPHA  = 0x10000000;
enum FT_BUMP_DETRED    = 0x20000000;
enum FT_BUMP_DETBLUE   = 0x40000000;
enum FT_BUMP_DETINTENS = 0x80000000;

//////////////////////////////////////////////////////////////////////
enum FT2_NODXT        = 1;
enum FT2_RENDERTARGET = 2;
enum FT2_FORCECUBEMAP = 4;
enum FT2_WASLOADED    = 8;
enum FT2_RELOAD       = 0x10;
enum FT2_NEEDRESTORED = 0x20;
enum FT2_UCLAMP       = 0x40;
enum FT2_VCLAMP       = 0x80;
enum FT2_RECTANGLE    = 0x100;
enum FT2_FORCEDXT     = 0x200;

enum FT2_BUMPHIGHRES   = 0x400;
enum FT2_BUMPLOWRES    = 0x800;
enum FT2_PARTIALLYLOADED  = 0x1000;
enum FT2_NEEDTORELOAD     = 0x2000;
enum FT2_WASUNLOADED      = 0x4000;
enum FT2_STREAMINGINPROGRESS  = 0x8000;

enum FT2_FILTER_BILINEAR  = 0x10000;
enum FT2_FILTER_TRILINEAR = 0x20000;
enum FT2_FILTER_ANISOTROPIC = 0x40000;
enum FT2_FILTER_NEAREST     = 0x80000;
enum FT2_FILTER = (FT2_FILTER_BILINEAR | FT2_FILTER_TRILINEAR | FT2_FILTER_ANISOTROPIC | FT2_FILTER_NEAREST);
enum FT2_VERSIONWASCHECKED  = 0x100000;
enum FT2_BUMPCOMPRESED      = 0x200000;
enum FT2_BUMPINVERTED       = 0x400000;
enum FT2_STREAMFROMDDS      = 0x8000000;
enum FT2_DISCARDINCACHE     = 0x1000000;
enum FT2_NOANISO            = 0x2000000;
enum FT2_CUBEASSINGLETEXTURE  = 0x4000000;
enum FT2_FORCEMIPS2X2         = 0x8000000;
enum FT2_DIFFUSETEXTURE       = 0x10000000;
enum FT2_WASFOUND             = 0x20000000;
enum FT2_REPLICATETOALLSIDES  = 0x40000000;
enum FT2_CHECKFORALLSEQUENCES = 0x80000000;

//////////////////////////////////////////////////////////////////////

// Render State flags
enum GS_BLSRC_MASK              = 0xf;
enum GS_BLSRC_ZERO              = 0x1;
enum GS_BLSRC_ONE               = 0x2;
enum GS_BLSRC_DSTCOL            = 0x3;
enum GS_BLSRC_ONEMINUSDSTCOL    = 0x4;
enum GS_BLSRC_SRCALPHA          = 0x5;
enum GS_BLSRC_ONEMINUSSRCALPHA  = 0x6;
enum GS_BLSRC_DSTALPHA          = 0x7;
enum GS_BLSRC_ONEMINUSDSTALPHA  = 0x8;
enum GS_BLSRC_ALPHASATURATE     = 0x9;

enum GS_BLDST_MASK              = 0xf0;
enum GS_BLDST_ZERO              = 0x10;
enum GS_BLDST_ONE               = 0x20;
enum GS_BLDST_SRCCOL            = 0x30;
enum GS_BLDST_ONEMINUSSRCCOL    = 0x40;
enum GS_BLDST_SRCALPHA          = 0x50;
enum GS_BLDST_ONEMINUSSRCALPHA  = 0x60;
enum GS_BLDST_DSTALPHA          = 0x70;
enum GS_BLDST_ONEMINUSDSTALPHA  = 0x80;

enum GS_BUMP                    = 0xa0;
enum GS_ENV                     = 0xb0;

enum GS_DXT1                    = 0xc0;
enum GS_DXT3                    = 0xd0;
enum GS_DXT5                    = 0xe0;

enum GS_BLEND_MASK              = 0xff;

enum GS_DEPTHWRITE               = 0x00000100;

enum GS_MODULATE                = 0x00000200;
enum GS_NOCOLMASK               = 0x00000400;
enum GS_ADDITIONALSTATE         = 0x00000800;

enum GS_POLYLINE                = 0x00001000;
enum GS_TEXPARAM_CLAMP          = 0x00002000;
enum GS_TEXPARAM_UCLAMP         = 0x00004000;
enum GS_TEXPARAM_VCLAMP         = 0x00008000;
enum GS_COLMASKONLYALPHA        = 0x00010000;
enum GS_NODEPTHTEST             = 0x00020000;
enum GS_COLMASKONLYRGB          = 0x00040000;
enum GS_DEPTHFUNC_EQUAL         = 0x00100000;
enum GS_DEPTHFUNC_GREAT         = 0x00200000;
enum GS_STENCIL                 = 0x00400000;
enum GS_TEXANIM                 = 0x00800000;

enum GS_ALPHATEST_MASK          = 0xf0000000;
enum GS_ALPHATEST_GREATER0      = 0x10000000;
enum GS_ALPHATEST_LESS128       = 0x20000000;
enum GS_ALPHATEST_GEQUAL128     = 0x40000000;
enum GS_ALPHATEST_GEQUAL64      = 0x80000000;

//////////////////////////////////////////////////////////////////////
// Texture object interface
interface ITexPic
{
  void AddRef();
  void Release(int bForce=false);
  const char *GetName();
  int GetWidth();
  int GetHeight();
  int GetOriginalWidth();
  int GetOriginalHeight();
  int GetTextureID();
  int GetFlags();
  int GetFlags2();
  void SetClamp(bool bEnable);
  bool IsTextureLoaded();
  void PrecacheAsynchronously(float fDist, int Flags);
  void Preload (int Flags);
  byte *GetData32();
  bool SetFilter(int nFilter);
};

enum FORMAT_8_BIT	 = 8;
enum FORMAT_24_BIT	= 24;
enum FORMAT_32_BIT	= 32;

//////////////////////////////////////////////////////////////////////
// Import and Export interfaces passed to the renderer
struct SCryRenderInterface
{
  extern(C++) struct CMalloc;
  CMalloc  *igcpMalloc;

  ILog     *ipLog;
  IConsole *ipConsole;
  ITimer   *ipTimer;
  ISystem  *ipSystem;
  int      *ipTest_int;
	IPhysicalWorld *pIPhysicalWorld;
};

//////////////////////////////////////////////////////////////////////
struct tLmInfo
{
	float[3] fS; 
	float[3] fT;
	ushort	nTextureIdLM;     // general color light map
	ushort	nTextureIdLM_LD;  // lights direction texture for DOT3 LM
};


//////////////////////////////////////////////////////////////////////
struct CObjFace
{
  
  ushort[3] v;
  ushort[3] t;
  ushort[3] n;
  ushort[3] b;
  ushort shader_id;
		
	//! tell if this surface is lit by the light (for dynamic lights)
  bool	m_bLit;
	//! plane equation for this surface (for dynamic lights)
  Plane m_Plane;  
  Vec3[3] m_Vecs;

  ubyte m_dwFlags;
  float m_fArea;	
};

//////////////////////////////////////////////////////////////////////////
enum VBF_DYNAMIC = 1;

struct SDispFormat
{
  int m_Width;
  int m_Height;
  int m_BPP;
};

struct SAAFormat
{
  char[64] szDescr;
  int nSamples;
  int nQuality;
  int nAPIType;
};

//////////////////////////////////////////////////////////////////////////
// Stream ID's
enum VSF_GENERAL  = 0;  // General vertex buffer
enum VSF_TANGENTS = 1;  // Tangents buffer

enum VSF_NUM      = 2;  // Number of vertex streams

// Stream Masks (Used during updating)
enum VSM_GENERAL =  (1<<VSF_GENERAL);
enum VSM_TANGENTS = (1<<VSF_TANGENTS);

//////////////////////////////////////////////////////////////////////////
union UHWBuf
{
  void *m_pPtr;
  uint m_nID;
};

//////////////////////////////////////////////////////////////////////////
struct SVertexStream
{
  void *m_VData;      // pointer to buffer data
  UHWBuf m_VertBuf;   // HW buffer descriptor 
  int m_nItems;
  bool m_bLocked;     // Used in Direct3D only
  bool m_bDynamic;
  int m_nBufOffset;
  extern(C) struct SVertPool; 
  SVertPool *m_pPool;
  //FIXME:
  //this()
  //{
  //  Reset();
  //  m_bDynamic = false;
  //  m_nBufOffset = 0;
  //  m_pPool = NULL;
  //}

  void Reset()
  {
    m_VData = NULL;
    m_VertBuf.m_pPtr = NULL;
    m_nItems = NULL;
    m_bLocked = false;
  }
};

//////////////////////////////////////////////////////////////////////
// General VertexBuffer created by CreateVertexBuffer() function
class CVertexBuffer
{
public:	
  this() 
  {
    for (int i=0; i<VSF_NUM; i++)
    {
      m_VS[i].Reset();
    }
    m_fence=0;
    m_bFenceSet=0;
    m_NumVerts = 0;
    m_vertexformat = 0;
  }
  
  this(void* pData, int nVertexFormat, int nVertCount=0)
  {
    for (int i=0; i<VSF_NUM; i++)
    {
      m_VS[i].m_VData = NULL;
      m_VS[i].m_VertBuf.m_pPtr = NULL;
      m_VS[i].m_bLocked = false;
    }
    m_VS[VSF_GENERAL].m_VData = pData;
    m_vertexformat = nVertexFormat;
	  m_fence=0;
	  m_bFenceSet=0;
    m_NumVerts = nVertCount;
  }
  void *GetStream(int nStream, int *nOffs);

  SVertexStream[VSF_NUM] m_VS; // 4 vertex streams and one index stream

  //FIXME: use bitset
  //uint m_bFenceSet : 1;
  //uint m_bDynamic : 1;
  int		m_vertexformat;
  uint m_fence;
  int   m_NumVerts;
//## MM unused?	void *pPS2Buffer;

  int Size(int Flags, int nVerts);
};

//////////////////////////////////////////////////////////////////////////
enum ERendStats
{
  eRS_VidBuffer,
  eRS_ShaderPipeline,
  eRS_CurTexturesInfo,
};

//////////////////////////////////////////////////////////////////////////
//DOC-IGNORE-BEGIN
import IShader;
//DOC-IGNORE-END

//////////////////////////////////////////////////////////////////////////
enum EImFormat
{
  eIF_Unknown = 0,
  eIF_Pcx,
  eIF_Tga,
  eIF_Jpg,
  eIF_Gif,
  eIF_Tif,
  eIF_Bmp,
  eIF_Lbm,
  eIF_DXT1,
  eIF_DXT3,
  eIF_DXT5,
  eIF_DDS_LUMINANCE,
  eIF_DDS_RGB8,
  eIF_DDS_SIGNED_RGB8,
  eIF_DDS_SIGNED_HILO8,
  eIF_DDS_SIGNED_HILO16,
  eIF_DDS_RGBA8,
  eIF_DDS_DSDT,
  eIF_DDS_RGBA4,
};

//////////////////////////////////////////////////////////////////////////
// Flags passed in function FreeResources
enum FRR_SHADERS   = 1;
enum FRR_SHADERTEXTURES = 2;
enum FRR_TEXTURES  = 4;
enum FRR_SYSTEM    = 8;
enum FRR_RESTORE   = 0x10;
enum FRR_REINITHW  = 0x20;
enum FRR_ALL =      -1;

//////////////////////////////////////////////////////////////////////////
// Refresh render resources flags
// Flags passed in function RefreshResources
enum FRO_SHADERS  = 1;
enum FRO_SHADERTEXTURES  = 2;
enum FRO_TEXTURES = 4;
enum FRO_GEOMETRY = 8;
enum FRO_FORCERELOAD = 0x10;

//////////////////////////////////////////////////////////////////////////
// LoadAnimatedTexture returns pointer to this structure
struct AnimTexInfo
{
  char[256] sName;
  int * pBindIds;
  int nFramesCount;
	int nRefCounter;
};

version(PS2)
{
  alias  __HDC* HDC;
  alias  __HGLRC* HGLRC;
}
/*
// The following may be (and sometimes is) used for testing. Please don't remove.
struct IRenderer;
class IRendererCallbackServer;

// Renderer callback client.
// Derive your class (a renderer client) from this one in order to register its instances
// with the renderer.
class IRendererCallbackClient
{
public:
	// within this function, you can render your stuff and it won't flicker in the viewport
	void OnRenderer_BeforeEndFrame () {}
	// unregisters itsef from the server
	void Renderer_SelfUnregister() {}
};

// renderer callback server.
// Derive your renderer (server) from this one in order for it to be able to serve
// renderer callback client requests
class IRendererCallbackServer
{
public:
	// registers the given client  - do nothing by default
	void RegisterCallbackClient (IRendererCallbackClient* pClient) {}
	// unregisters the given client - do nothing by default
	void UnregisterCallbackClient (IRendererCallbackClient* pClient) {}
};
*/

// Draw3dBBox PrimType params
enum DPRIM_WHIRE_BOX			= 0;
enum DPRIM_LINE					= 1;
enum DPRIM_SOLID_BOX			= 2;
enum DPRIM_WHIRE_SPHERE	= 3;
enum DPRIM_SOLID_SPHERE	= 4;

enum EBufferType
{
	eBT_Static = 0,
	eBT_Dynamic,
};

//! Flags used in DrawText function.
//! @see SDrawTextInfo
enum EDrawTextFlags
{
	//! Text must be fixed pixel size.
	eDrawText_FixedSize = 0x01,
};

//////////////////////////////////////////////////////////////////////////
//! This structure used in DrawText method of renderer.
//! It provide all necesarry information of how to render text on screen.
//! @see IRenderer::Draw2dText
struct SDrawTextInfo
{
	//! One of EDrawTextFlags flags.
	//! @see EDrawTextFlags
	int			flags;
	//! Text color, (r,g,b,a) all members must be specified.
	float[4]		color = [1,1,1,1];
	float xscale;
	float yscale;
	CXFont*	xfont;
};

enum MAX_FRAME_ID_STEP_PER_FRAME = 8;

//////////////////////////////////////////////////////////////////////
class IRenderer//: public IRendererCallbackServer
{
	//! Init the renderer, params are self-explanatory
  WIN_HWND Init(int x,int y,int width,int height,uint cbpp, int zbpp, int sbits, bool fullscreen,WIN_HINSTANCE hinst, WIN_HWND Glhwnd=null, WIN_HDC Glhdc=null, WIN_HGLRC hGLrc=null, bool bReInit=false);

  bool SetCurrentContext(WIN_HWND hWnd);
  bool CreateContext(WIN_HWND hWnd, bool bAllowFSAA=false);
  bool DeleteContext(WIN_HWND hWnd);

  int GetFeatures();
  int GetMaxTextureMemory();

	//! Shut down the renderer
	void	ShutDown(bool bReInit=false);

	//! Return all supported by video card video formats (except low resolution formats)
	int	EnumDisplayFormats(ref TArray!SDispFormat Formats, bool bReset);

  //! Changes resolution of the window/device (doen't require to reload the level
  bool	ChangeResolution(int nNewWidth, int nNewHeight, int nNewColDepth, int nNewRefreshHZ, bool bFullScreen);

	//! Shut down the renderer
	void	Release();

	//! Free the allocated resources
  void  FreeResources(int nFlags);

  //! Refresh/Reload the allocated resources
  void  RefreshResources(int nFlags);

  //! Should be called before loading of the level
  void	PreLoad ();

  //! Should be called after loading of the level
  void	PostLoad ();

	//! Should be called at the beginning of every frame
	void	BeginFrame	();

	//! Should be called at the end of every frame
	void	Update		();	
	
	//! This renderer will share resources (textures) with specified renderer.
	//! Specified renderer must be of same type as this renderer.
	void  ShareResources( IRenderer *renderer );

	void	GetViewport(int *x, int *y, int *width, int *height);
	void	SetViewport(int x=0, int y=0, int width=0, int height=0);
	void	SetScissor(int x=0, int y=0, int width=0, int height=0);

	//! Make this renderer current renderer.
	//! Only relevant for OpenGL ignored of DX, used by Editors.
	void	MakeCurrent();

	//! Draw a triangle strip
	void  DrawTriStrip(CVertexBuffer *src, int vert_num=4);

  void *GetDynVBPtr(int nVerts, ref int nOffs, int Pool);
  void DrawDynVB(int nOffs, int Pool, int nVerts);
  void DrawDynVB(struct_VERTEX_FORMAT_P3F_COL4UB_TEX2F *pBuf, ushort *pInds, int nVerts, int nInds, int nPrimType);

	//! append fence to the end of rendering stream
	void SetFenceCompleted(CVertexBuffer * buffer);

	//! Create a vertex buffer
	CVertexBuffer	*CreateBuffer(int  vertexcount,int vertexformat, const char *szSource, bool bDynamic=false);

	//! Release a vertex buffer
	void	ReleaseBuffer(CVertexBuffer *bufptr);

	//! Draw a vertex buffer
	void	DrawBuffer(CVertexBuffer *src,SVertexStream *indicies,int numindices, int offsindex, int prmode,int vert_start=0,int vert_stop=0, CMatInfo *mi=NULL);

	//! Update a vertex buffer
	void	UpdateBuffer(CVertexBuffer *dest,const void *src,int vertexcount, bool bUnLock, int nOffs=0, int Type=0);

  void  CreateIndexBuffer(SVertexStream *dest,const void *src,int indexcount);
  //! Update indicies 
  void  UpdateIndexBuffer(SVertexStream *dest,const void *src, int indexcount, bool bUnLock=true);
  void  ReleaseIndexBuffer(SVertexStream *dest);

	//! Check for an error in the current frame
	void	CheckError(const char *comment);

	//! Draw a bbox specified by mins/maxs (debug puprposes)
	void	Draw3dBBox(ref const(Vec3) mins,ref const(Vec3) maxs, int nPrimType=DPRIM_WHIRE_BOX);

	//! Draw a primitive specified by min/max vertex (for debug purposes)
	//! because of legacy code, the default implementation calls Draw3dBBox.
	//! in the newly changed renderer implementations, this will be the principal function and Draw3dBBox will eventually only draw 3dbboxes
	void	Draw3dPrim(ref const(Vec3) mins,ref const(Vec3) maxs, int nPrimType=DPRIM_WHIRE_BOX, const float* fRGBA = NULL)
	{
		// default implementaiton ignores color
		Draw3dBBox(mins, maxs,nPrimType);
	}

	//! Set the renderer camera
	void	SetCamera(ref const CCamera cam);

	//! Get the renderer camera
	ref const CCamera GetCamera();

	//! Set delta gamma
	bool	SetGammaDelta(const float fGamma);

	//! Change display size
	bool	ChangeDisplay(uint width,uint height,uint cbpp);

	//! Chenge viewport size
  void  ChangeViewport(uint x,uint y,uint width,uint height);

	//! Save source data to a Tga file (NOTE: Should not be here)	
	bool	SaveTga(ubyte *sourcedata,int sourceformat,int w,int h,const char *filename,bool flip);

	//! Set the current binded texture
	void	SetTexture(int tnum, ETexType Type=ETexType.eTT_Base);	

	//! Set the white texture
	void	SetWhiteTexture();	

	//! Write a message on the screen
	void	WriteXY(CXFont *currfont,int x,int y, float xscale,float yscale,float r,float g,float b,float a,const char *message, ...);	
	//! Write a message on the screen with additional flags.
	//! for flags @see 
	void	Draw2dText( float posX,float posY,const char *szText,ref SDrawTextInfo info );

	//! Draw a 2d image on the screen (Hud etc.)
  void	Draw2dImage	(float xpos,float ypos,float w,float h,int texture_id,float s0=0,float t0=0,float s1=1,float t1=1,float angle=0,float r=1,float g=1,float b=1,float a=1,float z=1);

	//! Draw a image using the current matrix
	void DrawImage(float xpos,float ypos,float w,float h,int texture_id,float s0,float t0,float s1,float t1,float r,float g,float b,float a);

	//! Set the polygon mode (wireframe, solid)
	int	SetPolygonMode(int mode);

	//! Get screen width
	int		GetWidth();

	//! Get screen height
	int		GetHeight();

	//! Memory status information
	void GetMemoryUsage(ICrySizer* Sizer);

	//! Get a screenshot and save to a file
	void ScreenShot(const char *filename=NULL);

	//! Get current bpp
  int	GetColorBpp();

	//! Get current z-buffer depth
  int	GetDepthBpp();

	//! Get current stencil bits
  int	GetStencilBpp();

  //! Project to screen
  void ProjectToScreen( float ptx, float pty, float ptz, 
                                float *sx, float *sy, float *sz );

	//! Unproject to screen
  int UnProject(float sx, float sy, float sz, 
                float *px, float *py, float *pz,
                const float[16] modelMatrix, 
                const float[16] projMatrix, 
                const int[4]    viewport);

	//! Unproject from screen
  int UnProjectFromScreen( float  sx, float  sy, float  sz, 
                           float *px, float *py, float *pz);

  //! for editor
  void  GetModelViewMatrix(float *mat);

	//! for editor
  void  GetModelViewMatrix(double *mat);

	//! for editor
  void  GetProjectionMatrix(double *mat);

	//! for editor
  void  GetProjectionMatrix(float *mat);

	//! for editor
  Vec3 GetUnProject(ref const(Vec3) WindowCoords,ref const CCamera cam);

  void RenderToViewport(ref const CCamera cam, float x, float y, float width, float height);

  void WriteDDS(byte *dat, int wdt, int hgt, int Size, const char *name, EImFormat eF, int NumMips);
	void WriteTGA(byte *dat, int wdt, int hgt, const char *name, int bits);
	void WriteJPG(byte *dat, int wdt, int hgt, char *name);

	/////////////////////////////////////////////////////////////////////////////////
	//Replacement functions for Font

	extern(C) struct CFBitmap;
	bool FontUploadTexture(CFBitmap*, ETEX_Format eTF=ETEX_Format.eTF_8888);
	int  FontCreateTexture(int Width, int Height, byte *pData, ETEX_Format eTF=ETEX_Format.eTF_8888);
  bool FontUpdateTexture(int nTexId, int X, int Y, int USize, int VSize, byte *pData);
	void FontReleaseTexture(CFBitmap *pBmp);
	void FontSetTexture(CFBitmap*, int nFilterMode);
  void FontSetTexture(int nTexId, int nFilterMode);
	void FontSetRenderingState(ulong nVirtualScreenWidth, ulong nVirtualScreenHeight);
	void FontSetBlending(int src, int dst);
	void FontRestoreRenderingState();

  /////////////////////////////////////////////////////////////////////////////////


  /////////////////////////////////////////////////////////////////////////////////
  // external interface for shaders
  /////////////////////////////////////////////////////////////////////////////////

  bool EF_PrecacheResource(IShader.IShader *pSH, float fDist, float fTimeToReady, int Flags);
  bool EF_PrecacheResource(ITexPic *pTP, float fDist, float fTimeToReady, int Flags);
  bool EF_PrecacheResource(CLeafBuffer *pPB, float fDist, float fTimeToReady, int Flags);
  bool EF_PrecacheResource(CDLight *pLS, float fDist, float fTimeToReady, int Flags);

  void EF_EnableHeatVision(bool bEnable);
  bool EF_GetHeatVision();

  void EF_PolygonOffset(bool bEnable, float fFactor, float fUnits);

  // Add 3D polygon to the list
  void EF_AddPolyToScene3D(int Ef, int numPts, SColorVert *verts, CCObject *obj=NULL, int nFogID=0);

  // Add Sprite to the list
  CCObject *EF_AddSpriteToScene(int Ef, int numPts, SColorVert *verts, CCObject *obj, byte *inds=NULL, int ninds=0, int nFogID=0);

  // Add 2D polygon to the list
  void EF_AddPolyToScene2D(int Ef, int numPts, SColorVert2D *verts);
  void EF_AddPolyToScene2D(SShaderItem si, int nTempl, int numPts, SColorVert2D *verts);

  /////////////////////////////////////////////////////////////////////////////////
  // Shaders/Shaders management /////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////
  // Load shader for name (name)
  IShader.IShader *EF_LoadShader (const char *name, EShClass Class, int flags=0, uint64 nMaskGen=0);
  // Load shader item for name (name)
  SShaderItem EF_LoadShaderItem (const char *name, EShClass Class, bool bShare, const char *templName, int flags=0, SInputShaderResources *Res=NULL, uint64 nMaskGen=0);
  // reload file
  bool					EF_ReloadFile (const char *szFileName);
  // Reinit all shader files (build hash tables)
  void					EF_ReloadShaderFiles (int nCategory);
  // Reload all texturer files
  void					EF_ReloadTextures ();
  // Create new shader as copy of (ef)
  IShader.IShader			*EF_CopyShader(IShader.IShader *ef);
  // Get texture object by ID
  ITexPic *EF_GetTextureByID(int Id);
  // Loading of the texture for name(nameTex)
  ITexPic			*EF_LoadTexture(const char* nameTex, uint flags, uint flags2, byte eTT, float fAmount1=-1.0f, float fAmount2=-1.0f, int Id=-1, int BindId=0);
  // Load lightmap for name (name)
  int			    EF_LoadLightmap (const char *name);
  bool			    EF_ScanEnvironmentCM (const char *name, int size, ref Vec3 Pos);
  // Function used for loading animated texture from specified folder
  int						EF_ReadAllImgFiles(IShader.IShader *ef, SShaderTexUnit *tl, STexAnim *ta, char *name);
  // Return texture procedure for name (name)
  char					**EF_GetShadersForFile(const char *File, int num);
  // Return Light. Material properties for Name (Str). Materials descriptions - in shader file LightMaterials.ses
  SLightMaterial *EF_GetLightMaterial(char *Str);
  // Register new user defined template
  bool					EF_RegisterTemplate(int nTemplId, char *Name, bool bReplace);

  // Create splash
  void			EF_AddSplash (Vec3 Pos, eSplashType eST, float fForce, int Id=-1);

  // Hide shader template (exclude from list)
  bool					EF_HideTemplate(const char *name);
  // UnHide shader template (include in list)
  bool					EF_UnhideTemplate(const char *name);
  // UnHide all shader templates (include in list)
  bool					EF_UnhideAllTemplates();

  bool EF_SetLightHole(Vec3 vPos, Vec3 vNormal, int idTex, float fScale=1.0f, bool bAdditive=true);

  // Create new RE (RenderElement) of type (edt)
  CRendElement *EF_CreateRE (EDataType edt);

  // Begin using shaders (return first index for allow recursions)
  void EF_StartEf ();

  // Get CCObject for RE transformation
  CCObject *EF_GetObject (bool bTemp=false, int num=-1);

  // Add shader to the list
  void EF_AddEf (int NumFog, CRendElement *re, IShader.IShader *ef, SRenderShaderResources *sr,  CCObject *obj, int nTempl, IShader.IShader *efState=null, int nSort=0);

  // Draw all shaded REs in the list
  void EF_EndEf3D (int nFlags);

  // Dynamic lights
  bool EF_IsFakeDLight (CDLight *Source);
  void EF_ADDDlight(CDLight *Source);
  void EF_ClearLightsList();
  bool EF_UpdateDLight(CDLight *pDL);

  /////////////////////////////////////////////////////////////////////////////////
  // 2d interface for the shaders
  /////////////////////////////////////////////////////////////////////////////////
  void EF_EndEf2D(bool bSort);

  // Add new shader to the list
  bool EF_DrawEfForName(char *name, float x, float y, float width, float height, ref CFColor col, int nTempl=-1);
  bool EF_DrawEfForNum(int num, float x, float y, float width, float height, ref CFColor col, int nTempl=-1);
  bool EF_DrawEf(IShader.IShader *ef, float x, float y, float width, float height, ref CFColor col, int nTempl=-1);
  bool EF_DrawEf(SShaderItem si, float x, float y, float width, float height, ref CFColor col, int nTempl=-1);

  // Add new shader as part of texture to the list
  bool EF_DrawPartialEfForName(char *name, SVrect *vr, SVrect *pr, ref CFColor col);
  bool EF_DrawPartialEfForNum(int num, SVrect *vr, SVrect *pr, ref CFColor col);
  bool EF_DrawPartialEf(IShader.IShader *ef, SVrect *vr, SVrect *pr, ref CFColor col, float iwdt=0, float ihgt=0);

  // Return different common shader parameters (used in ShaderBrowser) CryIndEd.exe
  void *EF_Query(int Query, int Param=0);
  // Construct effector (optimize) after parsing
  void EF_ConstructEf(IShader.IShader *Ef);
  // Setting of the global world color (use in shaders pipeline)
  void EF_SetWorldColor(float r, float g, float b, float a=1.0f);
  //! Register fog volume for layered fog
  int  EF_RegisterFogVolume(float fMaxFogDist, float fFogLayerZ, ColorDefs.CFColor color, int nIndex=-1, bool bCaustics=false);

  // for stats
	int  GetPolyCount();
  void GetPolyCount(ref int nPolygons,ref int nShadowVolPolys);

  // 3d engine set this color to fog color
  void SetClearColor(ref const(Vec3)  vColor);

  // create/delete LeafBuffer object
  CLeafBuffer * CreateLeafBuffer(bool bDynamic, const char *szSource="Unknown", CIndexedMesh * pIndexedMesh=null);
  
  CLeafBuffer * CreateLeafBufferInitialized(
    void * pVertBuffer, int nVertCount, int nVertFormat, 
    ushort* pIndices, int nIndices,
    int nPrimetiveType, const char *szSource, EBufferType eBufType = EBufferType.eBT_Dynamic,
    int nMatInfoCount=1, int nClientTextureBindID=0,
    bool function (CLeafBuffer *, bool)=null,
    void *CustomData=NULL,
    bool bOnlyVideoBuffer=false, bool bPrecache=true);

  void DeleteLeafBuffer(CLeafBuffer * pLBuffer);
  int GetFrameID(bool bIncludeRecursiveCalls=true);

  void MakeMatrix(ref const(Vec3)  pos, ref const(Vec3)  angles,ref const(Vec3)  scale, Matrix44* mat);

//////////////////////////////////////////////////////////////////////	
	/*!	Draw an image on the screen as a label text
			@param vPos:	3d position
			@param fSize: size of the image
			@nTextureId:	Texture Id dell'immagine
	*/
	void DrawLabelImage(ref const(Vec3) vPos,float fSize,int nTextureId);

  void DrawLabel(Vec3 pos, float font_size, const char * label_text, ...);
  void DrawLabelEx(Vec3 pos, float font_size, float * pfColor, bool bFixedSize, bool bCenter, const char * label_text, ...);
	void Draw2dLabel( float x,float y, float font_size, float * pfColor, bool bCenter, const char * label_text, ...);	

//////////////////////////////////////////////////////////////////////	

	float ScaleCoordX(float value);
	float ScaleCoordY(float value);

	void	SetState(int State);

	void	SetCullMode	(int mode=R_CULL_BACK);
	bool	EnableFog	(bool enable);
	void	SetFog		(float density,float fogstart,float fogend,const float *color,int fogmode);
	void	EnableTexGen(bool enable); 
	void	SetTexgen	(float scaleX,float scaleY,float translateX=0,float translateY=0);
  void  SetTexgen3D(float x1, float y1, float z1, float x2, float y2, float z2);
	void	SetLodBias	(float value=R_DEFAULT_LODBIAS);
  void  SetColorOp(byte eCo, byte eAo, byte eCa, byte eAa);

	//! NOTE: the following functions will be removed.
	void	EnableVSync(bool enable);
	void	PushMatrix();
	void	RotateMatrix(float a,float x,float y,float z);
  void	RotateMatrix(ref const(Vec3)  angels);
	void	TranslateMatrix(float x,float y,float z);
	void	ScaleMatrix(float x,float y,float z);
	void	TranslateMatrix(ref const(Vec3) pos);
  void  MultMatrix(float * mat);
	void	LoadMatrix(const Matrix44 *src=null);
	void	PopMatrix();
	void	EnableTMU(bool enable);
	void	SelectTMU(int tnum);	  	
	uint DownLoadToVideoMemory(ubyte *data,int w, int h, ETEX_Format eTFSrc, ETEX_Format eTFDst, int nummipmap, bool repeat=true, int filter=FILTER_BILINEAR, int Id=0, char *szCacheName=NULL, int flags=0);
  void UpdateTextureInVideoMemory(uint tnum, ubyte *newdata,int posx,int posy,int w,int h,ETEX_Format eTFSrc=ETEX_Format.eTF_0888);	
	uint LoadTexture(const char * filename,int *tex_type=NULL,uint def_tid=0,bool compresstodisk=true,bool bWarn=true);
  bool DXTCompress( byte *raw_data,int nWidth,int nHeight,ETEX_Format eTF, bool bUseHW, bool bGenMips, int nSrcBytesPerPix, MIPDXTcallback callback=null);
  bool DXTDecompress(byte *srcData,byte *dstData, int nWidth,int nHeight,ETEX_Format eSrcTF, bool bUseHW, int nDstBytesPerPix);
	void	RemoveTexture(uint TextureId);
  void	RemoveTexture(ITexPic * pTexPic);	
  void TextToScreen(float x, float y, const char * format, ...);
  void TextToScreenColor(int x, int y, float r, float g, float b, float a, const char * format, ...);
  void ResetToDefault();
  int  GenerateAlphaGlowTexture(float k);
	void SetMaterialColor(float r, float g, float b, float a);	
	int  LoadAnimatedTexture(const char * format,const int nCount);  
	void RemoveAnimatedTexture(AnimTexInfo * pInfo);
  AnimTexInfo * GetAnimTexInfoFromId(int nId);
	void	Draw2dLine	(float x1,float y1,float x2,float y2);
  void SetLineWidth(float fWidth);
  void DrawLine(ref const(Vec3)  vPos1, ref const(Vec3)  vPos2);
  void DrawLineColor(ref const(Vec3)  vPos1, ref const CFColor  vColor1, ref const(Vec3)  vPos2, ref const CFColor  vColor2);
  void Graph(byte *g, int x, int y, int wdt, int hgt, int nC, int type, char *text, ref CFColor color, float fScale);
  void DrawBall(float x, float y, float z, float radius);
  void DrawBall(ref const(Vec3)  pos, float radius );
  void DrawPoint(float x, float y, float z, float fSize = 0.0f);
  void FlushTextMessages();  
  void DrawObjSprites(list2!(CStatObjInst*) *pList, float fMaxViewDist, CObjManager *pObjMan);
  void DrawQuad(ref const(Vec3) right, ref const(Vec3) up, ref const(Vec3) origin,int nFlipMode=0);
  void DrawQuad(float dy,float dx, float dz, float x, float y, float z);
  void ClearDepthBuffer();  
  void ClearColorBuffer(const Vec3 vColor);  
  void ReadFrameBuffer(ubyte * pRGB, int nSizeX, int nSizeY, bool bBackBuffer, bool bRGBA, int nScaledX=-1, int nScaledY=-1);  
  void SetFogColor(float * color);
  void TransformTextureMatrix(float x, float y, float angle, float scale);
  void ResetTextureMatrix();
  char	GetType();
  char*	GetVertexProfile(bool bSupportedProfile);
  char*	GetPixelProfile(bool bSupportedProfile);
  void	SetType(char type);	
  uint  MakeSprite(float object_scale, int tex_size, float angle, IStatObj * pStatObj, ubyte * pTmpBuffer, uint def_tid);
  uint  Make3DSprite(int nTexSize, float fAngleStep, IStatObj * pStatObj);
  ShadowMapFrustum * MakeShadowMapFrustum(ShadowMapFrustum * lof, ShadowMapLightSource * pLs, ref const(Vec3)  obj_pos, list2!(IStatObj*) * pStatObjects, int shadow_type);
  void Set2DMode(bool enable, int ortox, int ortoy);
  int ScreenToTexture();  
  void SetTexClampMode(bool clamp);  
	void EnableSwapBuffers(bool bEnable);
  WIN_HWND GetHWND();
	void OnEntityDeleted(IEntityRender * pEntityRender);
	void SetGlobalShaderTemplateId(int nTemplateId);
	int GetGlobalShaderTemplateId();

  //! Return all supported by video card video AA formats
  int	EnumAAFormats(ref TArray!SAAFormat Formats, bool bReset);
  int  CreateRenderTarget (int nWidth, int nHeight, ETEX_Format eTF);
  bool DestroyRenderTarget (int nHandle);
  bool SetRenderTarget (int nHandle);
  float EF_GetWaterZElevation(float fX, float fY);
};

//////////////////////////////////////////////////////////////////////////
// Query types for CryInd editor (used in EF_Query() function)
enum EFQ_NUMEFS							= 0;
enum EFQ_LOADEDEFS						= 1;
enum EFQ_NUMTEXTURES					= 2;
enum EFQ_LOADEDTEXTURES			= 3;
enum EFQ_NUMEFFILES0					= 6;
enum EFQ_NUMEFFILES1					= 7;
enum EFQ_EFFILENAMES0				= 12;
enum EFQ_EFFILENAMES1				= 13;
enum EFQ_VProgramms					= 16;
enum EFQ_PShaders						= 17;
enum EFQ_LightSource					= 18;
enum EFQ_RecurseLevel				= 19;
enum EFQ_Pointer2FrameID			= 20;
enum EFQ_RegisteredTemplates = 21;
enum EFQ_NumRenderItems			= 22;
enum EFQ_DeviceLost					= 23;
enum EFQ_CubeColor						= 24;
enum EFQ_D3DDevice						= 25;
enum EFQ_glReadPixels				= 26;

enum EFQ_Orients             = 33;
enum EFQ_NumOrients          = 34;
enum EFQ_SkyShader           = 35;
enum EFQ_SunFlares           = 36;
enum EFQ_CurSunFlare         = 37;
enum EFQ_Materials           = 38;
enum EFQ_LightMaterials      = 39;

//////////////////////////////////////////////////////////////////////

enum STRIPTYPE_NONE           = 0;
enum STRIPTYPE_ONLYLISTS      = 1;
enum STRIPTYPE_SINGLESTRIP    = 2;
enum STRIPTYPE_MULTIPLESTRIPS = 3;
enum STRIPTYPE_DEFAULT        = 4;

/////////////////////////////////////////////////////////////////////

//DOC-IGNORE-BEGIN
import Renderer.VertexFormats;
import Renderer.LeafBuffer;
//DOC-IGNORE-END

//////////////////////////////////////////////////////////////////////////
// this structure used to pass render parameters to Render() functions of IStatObj and ICharInstance
struct SRendParams
{

	//FIXME: copy ctor
	//SRendParams (const SRendParams& rThat)
	//{
	//	memcpy (this, &rThat, sizeof(SRendParams));
	//}

	//! position of render elements
  Vec3				vPos;
	//! scale of render elements
  float				fScale = 1.f;
	//! angles of the object
  Vec3				vAngles;
	//! object transformations
  Matrix44		*pMatrix;
  //! custom offset for sorting by distance
  float				fCustomSortOffset;
	//! shader template to use
  int					nShaderTemplate = -2;
	//! light mask to specifiy which light to use on the object
  uint nDLightMask;
	//! strongest light affecting the object
	uint nStrongestDLightMask;
	//! fog volume id
  int					nFogVolumeID;
	//! amount of bending animations for vegetations
  float				fBending;
	//! state shader
  IShader.IShader			*pStateShader;
	//! list of shadow map casters
  list2!ShadowMapLightSourceInstance * pShadowMapCasters;
	//! object color
	Vec3     vColor = Vec3(1,1,1);
	//! object alpha
  float     fAlpha = 1.f;
	//! force a sort value for render elements
	int				nSortValue;
	//! Ambient color for the object
	Vec3			vAmbientColor;
	//! distance from camera
  float     fDistance;
	//! CCObject flags
  int		    dwFObjFlags;
	//! light source for shadow volume calculations
	CDLight		*pShadowVolumeLightSource;
  //! reference to entity, allows to improve handling of shadow volumes of IStatObj instances
  IEntityRender	* pCaller;
	//! Heat Amount for heat vision
	float			fHeatAmount;
	//! define size of shadow volume
	float			fShadowVolumeExtent;
	//! lightmap informaion
	extern class RenderLMData;
	RenderLMData * pLightMapInfo;
	CLeafBuffer * pLMTCBuffer; // Object instance specific tex LM texture coords;
	byte[4] arrOcclusionLightIds;
	//! Override material.
	IMatInfo *pMaterial;
  //! Scissor settings for this object
//  int nScissorX1, nScissorY1, nScissorX2, nScissorY2;
	//! custom shader params
	TArray!SShaderParam * pShaderParams;
	//! squared distance to the center of object
	float fSQDistance = - 1.f;
  //! CCObject custom data
  void * pCCObjCustomData;
};

//////////////////////////////////////////////////////////////////////////
//! holds shadow volume informations for static objects
abstract class ItShadowVolume
{
	void	Release()=0;	
	Vec3	GetPos()=0;
	void	SetPos(ref const(Vec3) vPos);
	extern class CShadowVolObject; 
	CShadowVolObject	*GetShadowVolume();
	void	SetShadowVolume(CShadowVolObject *psvObj);

	//! /param lSource lightsource, worldspace and objectspace position is used
	//! /param inArea pointer to the area whre the object is in (could be 0 - but shadow extrusion is set to maximum)
  void	RebuildShadowVolumeBuffer( ref const CDLight lSource, float fExtent );

	//! return memory usage
	int GetMemoryUsage(){ return 0; }; //todo: implement

  //! this buffer will contain vertices after RebuildDynamicShadowVolumeBuffer() calll
  Vec3 * GetSysVertBufer() = 0;
  void CheckUnload() {};
};

