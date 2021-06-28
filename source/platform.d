module platform;

version(Windows){
  public import core.sys.windows.windows;
}

version (Windows)
{
	void DEBUG_BREAK()
	{
		asm
		{
			int3;
		}
	}
}
else
{
	void DEBUG_BREAK()
	{
	}
}
