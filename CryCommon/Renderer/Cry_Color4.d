module Renderer.Cry_Color4;
import platform;

public extern(C++):
//////////////////////////////////////////////////////////////////////////////////////////////
//TODO: mixin
//#define RGBA8( r,g,b,a ) (  uint32( ##(r)|(g<<8)|(b<<16)|(a<<24)##) )

//template <class T> struct color4;

//////////////////////////////////////////////////////////////////////////////////////////////
// RGBA Color structure.
struct color4(T)
{
	union {
		struct { T	r,g,b,a;	};
		T[4] v;
	};

	//this(const T *p_elts);
	//this(const color4 & v);
	//this(T _x, T _y = 0, T _z = 0, T _w = 0);

	//this( uint32 c ) {	*(uint32*)(&v)=c; } //use this with RGBA8 macro!
	
	void set(T _x, T _y = 0, T _z = 0, T _w = 0);
	void set(T _x, T _y = 0, T _z = 0);

	//color4 operator + () const;
	//color4 operator - () const;
	//
	//color4 & operator += (const color4 & v);
	//color4 & operator -= (const color4 & v);
	//color4 & operator *= (const color4 & v);
	//color4 & operator /= (const color4 & v);
	//color4 & operator *= (T s);
	//color4 & operator /= (T s);
	//
	//color4 operator + (const color4 & v) const;
	//color4 operator - (const color4 & v) const;
	//color4 operator * (const color4 & v) const;
	//color4 operator / (const color4 & v) const;
	//color4 operator * (T s) const;
	//color4 operator / (T s) const;
	//
	//bool operator == (const color4 & v) const;
	//bool operator != (const color4 & v) const;

	ubyte pack_rgb332(){ return 0; }
	ushort pack_argb4444(){ return 0; }
	ushort pack_rgb555(){ return 0; }
	ushort pack_rgb565(){ return 0; }
	uint pack_rgb888(){ return 0; }
	uint pack_argb8888(){ return 0; }

	uint pack8() { return pack_rgb332(); }
	uint pack12() { return pack_argb4444(); }
	uint pack15() { return pack_rgb555(); }
	uint pack16() { return pack_rgb565(); }
	uint pack24() { return pack_rgb888(); }
	uint pack32() { return pack_argb8888(); }

	//void clamp(T bottom = 0.0f, T top = 1.0f);

	//void maximum(const color4<T> &ca, const color4<T> &cb);
	//void minimum(const color4<T> &ca, const color4<T> &cb);
	//void abs();
	//
	//void adjust_contrast(T c);
	//void adjust_saturation(T s);

	//void lerp(const color4<T> &ca, const color4<T> &cb, T s);
	//void negative(const color4<T> &c);
	//void grey(const color4<T> &c);
	//void black_white(const color4<T> &c, T s);
};

alias color4!uint8	Color; // [0, 255]

alias color4!f32	color4f; // [0.0, 1.0]
alias color4!f64	color4d; // [0.0, 1.0]
alias color4!uint8	color4b; // [0, 255]
alias color4!uint16	color4w; // [0, 65535]		


