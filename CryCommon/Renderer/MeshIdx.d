module MeshIdx;
import irenderer;
import CryHeaders;
import Math;
import irenderer;

//////////////////////////////////////////////////////////////////////////
struct TexCoord
{
  float s,t;

  //FIXME:
  //bool operator == (TexCoord & other)
  //{
  //  if(s == other.s)
  //  if(t == other.t)
  //    return 1;

  //  return 0;
  //}
};

//////////////////////////////////////////////////////////////////////////
struct UColor
{
  ubyte r,g,b,a;
};

//////////////////////////////////////////////////////////////////////////
final class CIndexedMesh
{
public:

	// geometry data
	CObjFace * m_pFaces;
	Vec3d * m_pVerts;
	TexCoord * m_pCoors;
	extern(C) struct CBasis;
	CBasis * m_pTangBasis;
	int * m_pVertMats;
  
	Vec3d * m_pNorms;
	UColor* m_pColor;
	UColor* m_pColorSec;
	int m_nFaceCount;
	int m_nVertCount;
	int m_nCoorCount; // number of texture coordinates in m_pCoors array
	int m_nNormCount;

	// bbox
	Vec3d m_vBoxMin, m_vBoxMax;

	// materials table
	list2!CMatInfo m_lstMatTable;

	// list of geom names from cgf file
	list2!(char*) m_lstGeomNames;
}
