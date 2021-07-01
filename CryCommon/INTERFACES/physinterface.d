module physinterface;
import Math;

extern (C++):

enum pe_type { PE_NONE=0, PE_STATIC=1, PE_LIVING=2, PE_RIGID=3, PE_WHEELEDVEHICLE=4, PE_PARTICLE=5, PE_ARTICULATED=6, PE_ROPE=7, PE_SOFT=8 };
const IPhysicalEntity*  WORLD_ENTITY = cast(IPhysicalEntity*)-10;


const int NMAXWHEELS = 16;
struct pe_cargeomparams /*: pe_geomparams*/ {
	enum entype { type_id=1 };
	//pe_cargeomparams() : pe_geomparams() { type=type_id; MARK_UNUSED bDriving,minFriction,maxFriction; bCanBrake=1; }
	//pe_cargeomparams(pe_geomparams &src) {
	//	type=type_id;	density=src.density; mass=src.mass;
	//	pos=src.pos; q=src.q; surface_idx=src.surface_idx;
	//	MARK_UNUSED bDriving,minFriction,maxFriction; bCanBrake=1;
	//}
	int bDriving;	// whether wheel is driving, -1 - geometry os not a wheel
	int iAxle; // wheel axle, currently not used
	int bCanBrake; // whether the wheel is locked during handbrakes
	vectorf pivot; // upper suspension point in vehicle CS
	float lenMax;	// relaxed suspension length
	float lenInitial; // current suspension length (assumed to be length in rest state)
	float kStiffness; // suspension stiffness, if 0 - calculate from lenMax, lenInitial, and vehicle mass and geometry
	float kDamping; // suspension damping, if <0 - calculate as -kdamping*(approximate zero oscillations damping)
	float minFriction,maxFriction; // additional friction limits for tire friction
};

extern struct pe_params_car;

struct pe_action_impulse{

}

struct coll_history_item{

}

interface IPhysicalEntity
{

}

interface IPhysicsStreamer{

}

interface IPhysicsEventClient{

}