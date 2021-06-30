module ColorDefs;
import Math;

extern(C++):
//////////////////////////////////////////////////////////////////////
float FClamp( float X, float Min, float Max )
{
  return X<Min ? Min : X<Max ? X : Max;
}

//////////////////////////////////////////////////////////////////////
struct CFColor
{
public:
  float r, g, b, a;

public:
  this(ref const Vec3 vVec)
  {
    r = vVec.x;
    g = vVec.y;
    b = vVec.z;
    a = 1.f;
  }
}
