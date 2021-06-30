module Vector3;
import Math;
import platform;

extern(C++):

//////////////////////////////////////////////////////////////////////
struct Plane
{

	//plane-equation: n.x*x+n.y*y+n.z*z+d>0 is in front of the plane 
	Vec3	n;	//!< normal
	f32	d;	//!< distance
		 

	/*ILINE*/ this( ref const Plane p ) {	n=p.n; d=p.d; }
	/*ILINE*/ this( ref const Vec3 normal, ref const f32 distance ) {  n=normal; d=distance; }

	//! set normal and dist for this plane and  then calculate plane type
	/*ILINE*/ void	Set(ref const Vec3 vNormal,const f32 fDist)	{	
		n = vNormal; 
		d = fDist;
	}

	/*ILINE*/ void SetPlane( ref const Vec3 normal, ref const Vec3 point ) { 
		n=normal; 
		d=-(point | normal); 
	}

	/*ILINE*/ Plane GetPlane(  ref const Vec3 normal, ref const Vec3 point ) {  
		return Plane( normal,-(point|normal)  );
	}

	/*!
	*
	* Constructs the plane by tree given Vec3s (=triangle) 
	*
	* Example 1:
	* \code
	*  Vec3 v0(1,2,3),v1(4,5,6),v2(6,5,6);
	*  Plane  plane;
	*  plane.CalculatePlane(v0,v1,v2);
	* \endcode
	*
	* Example 2:
	* \code
	*  Vec3 v0(1,2,3),v1(4,5,6),v2(6,5,6);
	*  Plane  plane=CalculatePlane(v0,v1,v2);
	* \endcode
	*
	*/
	/*ILINE*/ void SetPlane( ref const Vec3 v0, ref const Vec3 v1, ref const Vec3 v2 ) {  
		n = GetNormalized((v1-v0)%(v0-v2));	//vector cross-product
		d	=	-(n | v0);				//calculate d-value
	}
	/*ILINE*/ Plane GetPlane( ref const Vec3 v0, ref const Vec3 v1, ref const Vec3 v2 ) {  
		Plane p;
		p.n = GetNormalized((v1-v0)%(v0-v2)); //vector cross-product
		p.d	=	-(p.n | v0);			 //calculate d-value
		return p;
	}

	/*!
	*
	* Computes signed distance from point to plane.
	* This is the standart plane-equation: d=Ax*By*Cz+D.
	* The normal-vector is assumed to be normalized.
	* 
	* Example:
	*  Vec3 v(1,2,3);
	*  Plane  plane=CalculatePlane(v0,v1,v2);
	*  f32 distance = plane|v;
	*
	*/
	//FIXME:
	///*ILINE*/ f32 operator | ( ref const Vec3 point ) const { return (n | point) + d; }


	//FIXME:
	////! check for equality between two planes
	///*ILINE*/  bool operator== (ref const Plane p1, ref const Plane p2) {
	//	if (fabsf(p1.n.x-p2.n.x)>0.0001f) return (false);
	//	if (fabsf(p1.n.y-p2.n.y)>0.0001f) return (false);
	//	if (fabsf(p1.n.z-p2.n.z)>0.0001f) return (false);
	//	if (fabsf(p1.d-p2.d)<0.01f) return(true);
	//	return (false);
	//}


//////////////////////////////////////////////////////////////////////
// Obsolete plane stuff - don't use
//////////////////////////////////////////////////////////////////////

	//! calc the plane giving 3 points  
	void	CalcPlane(ref const Vec3 p0, ref const Vec3 p1, ref const Vec3 p2) 
	{
		n = (p0-p1)^(p2-p1);
		n.Normalize();
		d = (p0*n);
	}

	//! Makes the plane by 3 given points
	void Init(ref const Vec3  v1, ref const Vec3  v2, ref const Vec3  v3)
	{
		Vec3 u, v, t;
		u = v2 - v1;
		v = v2 - v3;
		t = u ^ v;
		t.Normalize();
		n = t;
		d = t*v1;
	}

	//! same as above for const members
	/*ILINE*/ f32	DistFromPlane(ref const Vec3 vPoint) const	{
		return (n*vPoint-d);
	}

	Vec3 MirrorVector(ref Vec3 i)  {
		return i - n*((n|i)*2);
	}

	Vec3 MirrorPosition(ref Vec3 i) {
		return i - n * (2.f * ((n|i) - d));
	}
};



