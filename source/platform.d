module platform;

public import core.stdc.stdarg;

version(Windows){
  public import core.sys.windows.windows;
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
