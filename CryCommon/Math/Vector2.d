module Vector2;

import platform;
import Math.Vector3;

public extern (C++):
//////////////////////////////////////////////////////////////////////
alias Vec2_tpl!float Vec2;
alias Vec2_tpl!real Vec2_f64;

alias Vec2_tpl!float vector2f;
version (LINUX64)
{
	alias Vec2_tpl!int vector2l;
}
else
{
	alias Vec2_tpl!long vector2l;
}
alias Vec2_tpl!float vector2df;
alias Vec2_tpl!real vector2d;
alias Vec2_tpl!int vector2di;
alias Vec2_tpl!uint vector2dui;

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
struct Vec2_tpl(F)
{
	F x;
	F y;
}
