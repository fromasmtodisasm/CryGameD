module platform;

public import core.stdc.stdarg;
public import core.stdcpp.string;
public import core.stdcpp.vector;

version (Windows)
{
	public import core.sys.windows.windows;

	//public import core.stdc.windows.com;
}

version (Windows)
{
	void DEBUG_BREAK()
	{
		asm
		{
			int 3;
		}
	}
}
else
{
	void DEBUG_BREAK()
	{
	}
}

//#if !defined(PS2) && !defined(_XBOX) && !defined(LINUX)
version(PS2) enum PS2;
version(_XBOX) enum _XBOX;
version(LINUX) enum LINuX;


alias char int8;
alias short int16;
alias int int32;
alias long int64;
alias ubyte uint8;
alias ushort uint16;
alias uint uint32;
alias ulong uint64;

alias float f32;
alias double f64;

template GenFWD(string Name)
{
	const char[] GenFWD = "extern struct " ~ Name ~ ";";
}

import core.stdcpp.xutility : StdNamespace;

extern (C++,"std")
{
	@nogc : /**
* D language counterpart to C++ std::pair.
*
* C++ reference: $(LINK2 https://en.cppreference.com/w/cpp/utility/pair)
*/
	struct pair(T1, T2)
	{
		///
		alias first_type = T1;
		///
		alias second_type = T2;

		///
		T1 first;
		///
		T2 second;

		// FreeBSD has pair as non-POD so add a contructor
		version (FreeBSD)
		{
			this(T1 t1, T2 t2) inout
			{
				first = t1;
				second = t2;
			}

			this(ref return scope inout pair!(T1, T2) src) inout
			{
				first = src.first;
				second = src.second;
			}
		}
	}
}

// I don't think we can have these here, otherwise symbols are emit to druntime, and we don't want that...
alias std_string = basic_string!char;
//alias std_u16string = basic_string!wchar; // TODO: can't mangle these yet either...
//alias std_u32string = basic_string!dchar;
//alias std_wstring = basic_string!wchar_t; // TODO: we can't mangle wchar_t properly (yet?)

class CTimeValue{

}
