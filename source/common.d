module common;

import core.stdc.stdlib;
import core.stdc.string;
import core.stdc.stdio;
import platform;

char* sTraceString;

static this(){
	import core.stdc.stdlib : free, malloc;
	sTraceString = cast(char*)malloc(1024);
}

static ~this(){
	import core.stdc.stdlib : free, malloc;
	free(sTraceString);
}

version (Windows)
{
	void FIXME_ASSERT(bool cond)
	{
		if (!(cond))
			abort();
	}

	extern (C) void DLL_TRACE(const char* sFormat, ...)
	{
		va_list vl;

		va_start(vl, sFormat);
		vsprintf(sTraceString, sFormat, vl);
		va_end(vl);

		strcat(sTraceString, "\n");

		OutputDebugStringA(sTraceString);
	}

}
else
{
	void FIXME_ASSERT(bool cond)
	{
		if (!(cond))
		{
			DEBUG_BREAK;
		}
	}
}
version (PS2)
{
	void FIXME_ASSERT(bool cond)
	{
		if (!(cond))
		{
			FORCE_EXIT();
		}
	}
}

extern interface IXSystem;
class CTimeValue{

}
