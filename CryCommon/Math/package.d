module Math;

public import Math.Matrix;
public import Math.Vector2;
public import Math.Vector3;
public import Math.Quat;

extern (C++):
struct Vec3
{
	this(float x, float y, float z){

	}
}

struct Matrix44
{

}

alias Vec3 Vec3d;  //obsolete! please use just Vec3
alias Vec3 vectorf;
alias Vec3_f64 vectorr;
//alias Vec3_tpl<int>		vectori;
