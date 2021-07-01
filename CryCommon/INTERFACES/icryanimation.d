module icryanimation;

import platform;

////////////////////////////////////////////////////////////////////////////
struct AnimSinkEventData
{
	this (void* _p/* = null*/, INT_PTR n)
	{
		p(_p);
		n(cast(INT_PTR)_p);
	}
	
	void* p;
	INT_PTR   n;

	//FIXME:
	//operator void* () {return p;}
	//operator const void* ()const {return p;}
	//bool operator == (const AnimSinkEventData& that) const {return p == that.p && n == that.n;}
};
