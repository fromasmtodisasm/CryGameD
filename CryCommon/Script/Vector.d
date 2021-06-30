module ScriptObjects.Vector;

//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
// 
//	File: ScriptObjectVector.h
//
//  Description: interface for the CScriptObjectVector class.
//
//	History: 
//	- File Created by Alberto Demichelis
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

import iscriptsystem;
import Math;

//////////////////////////////////////////////////////////////////////
/*! this class maps a 3d vector to a LUA table with x,y,z members
*/
class CScriptObjectVector : _SmartScriptObject
{
public:
	this(IScriptSystem *pScriptSystem,bool bCreateEmpty=false)
	{
		super(pScriptSystem,bCreateEmpty);
	}
	
	void Set(ref const Vec3 v)
	{
		if(m_pSO.BeginSetGetChain())
		{
			m_pSO.SetValueChain("x",v.x);
			m_pSO.SetValueChain("y",v.y);
			m_pSO.SetValueChain("z",v.z);
			m_pSO.EndSetGetChain();
		}
	}
	Vec3 Get()
	{
		Vec3 v = Vec3(0,0,0);
		if(m_pSO.BeginSetGetChain())
		{
			m_pSO.GetValueChain("x",v.x);
			m_pSO.GetValueChain("y",v.y);
			m_pSO.GetValueChain("z",v.z);
			m_pSO.EndSetGetChain();
		}
		else assert(0 && "validate before calling Get()");

		return v;
	}

	//FIXME:
	//CScriptObjectVector &operator=(const Vec3 &v3)
	//{
	//	Set(v3);
	//	return *this;
	//}
};

//////////////////////////////////////////////////////////////////////
/*! this clsss maps a "color" to a LUA table with x,y,z members
*/
class CScriptObjectColor :
_SmartScriptObject
{
public:
	this(IScriptSystem *pScriptSystem,bool bCreateEmpty=false)
	{
		super(pScriptSystem,bCreateEmpty);
	}
	
	void Set(ref const Vec3 v)
	{
		m_pSO.SetAt(1,v.x);
		m_pSO.SetAt(2,v.y);
		m_pSO.SetAt(3,v.z);
	}
	ref Vec3 Get()
	{
		static Vec3  = Vec3(0,0,0);
		m_pSO.GetAt(1,v.x);
		m_pSO.GetAt(2,v.y);
		m_pSO.GetAt(3,v.z);
		return v;
	}
	//FIXME:
	//CScriptObjectColor &operator=(const Vec3 &v3)
	//{
	//	Set(v3);
	//	return *this;
	//}
};
