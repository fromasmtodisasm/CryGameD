module iminilog;

extern (C++) {
	////////////////////////////////////////////////////////////////////////////
interface IMiniLog
{
	enum ELogType
	{
		eMessage,
		eWarning,
		eError,
		eAlways,
		eWarningAlways,
		eErrorAlways,
		eInput,
	};

	//! you only have to implement this function
	void LogV (const ELogType nType, const char* szFormat, va_list args);
	
	//! this is the simplest log function for messages
	//! with the default implementation
	void Log(const char * szFormat,...)
	{
		va_list args;
		va_start(args,szFormat);
		LogV (eMessage, szFormat, args);
		va_end(args);
	}

	//! this is the simplest log function for warnings
	//! with the default implementation
	void LogWarning(const char * szFormat,...)
	{
		va_list args;
		va_start(args,szFormat);
		LogV (eWarning, szFormat, args);
		va_end(args);
	}

	//! this is the simplest log function for errors
	//! with the default implementation
	void LogError(const char * szFormat,...)
	{
		va_list args;
		va_start(args,szFormat);
		LogV (eError, szFormat, args);
		va_end(args);
	}
};

////////////////////////////////////////////////////////////////////////////
// By default, to make it possible not to implement the log at the beginning at all,
// empty implementations of the two functions are given
class CNullMiniLog: IMiniLog
{
	// the default implementation just won't do anything
	void LogV(const char* szFormat, va_list args) {}
};

}