module VertexBufferSource;
import Renderer.IShader;
import IRenderer;
import System.CryHeaders;
//////////////////////////////////////////////////////////////////////////
struct VertexBufferSource
{
	// number of materials in the corresponding array
	uint numMaterials;
	// the pointer to numMaterials materials
	const MAT_ENTITY* pMaterials;
	// the pointer to the shaders, there must be numMaterials elements
	const SShaderItem* pShaders;
	// if there are no shaders, the client may specify the array of already loaded CMatInfo's
	// this array is then moved to the leaf buffer and this member is NULL'ed (if no error occurs)
	list2!CMatInfo* pMats;
	// for each material, there can be OR and/or AND flags. 
	// they are ORed and ANDed with m_Flags in CMatInfo
	// these parameters may be NULL
	const uint* pOrFlags;
	const uint* pAndFlags;
	
	// the number of Primitive Groups (sections)
	uint numPrimGroups;
	// the pointer to the array of sections
	extern(C) struct CCFMaterialGroup;
	const CCFMaterialGroup* pPrimGroups;
	
	// the number of indices in the index buffer
	uint numIndices;
	// the indices
	const ushort* pIndices;

  // the number of vertices
	uint numVertices;
	// the vertices
	const Vec3d* pVertices;
	// UVs
	const CryUV* pUVs;

	// these flags will be ORed to the RE m_Flags (this is for FCEF_DYNAMIC flag in animation)
	uint nREFlags;
};

