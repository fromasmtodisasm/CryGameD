module XVehicleSystem;

//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//	File: XVehicleSystem.h
//	Description: - vehicle system class declaration  - 
//	A simple class that takes care of the class id's of the vehicles
//	
//	History:
//	- Created by Petar Kotevski
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

import platform : vector;
import ientitysystem;
alias VehicleClassVector = vector!EntityClassId;

//////////////////////////////////////////////////////////////////////
class CVehicleSystem
{

	VehicleClassVector	m_vVehicleClasses;

public:
	this();
	~this();

	void AddVehicleClass(const EntityClassId classid);
	bool IsVehicleClass(const EntityClassId classid);
};
