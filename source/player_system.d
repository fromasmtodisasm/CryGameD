module player_system;

import ientitysystem;
import std.algorithm;
import std.range;


extern (C++):
//////////////////////////////////////////////////////////////////////
//!store all player entity class ids
class CPlayerSystem
{
	EntityClassId[] m_vPlayerClasses;

public:
	//virtual ~CPlayerSystem(){}

	void AddPlayerClass(const EntityClassId classid)
	{
		m_vPlayerClasses ~= classid;
	}

	bool IsPlayerClass(const EntityClassId classid)
	{
		return  !m_vPlayerClasses.find(classid).empty;
	}
};
