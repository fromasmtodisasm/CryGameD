module source.common;

import core.stdc.stdlib;
import platform;

version (Windows)
{
	void FIXME_ASSERT(bool cond)
	{
		if (!(cond))
			abort();
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
version(PS2)
{
	void FIXME_ASSERT(bool cond)
	{
		if (!(cond))
		{
			FORCE_EXIT();
		}
	}
}
