module ivalidator;

extern (C++)
{
	immutable MAX_WARNING_LENGTH = 4096;

	////////////////////////////////////////////////////////////////////////////
	enum EValidatorSeverity
	{
		VALIDATOR_ERROR,
		VALIDATOR_WARNING,
		VALIDATOR_COMMENT
	};

	////////////////////////////////////////////////////////////////////////////
	enum EValidatorModule
	{
		VALIDATOR_MODULE_UNKNOWN,
		VALIDATOR_MODULE_RENDERER,
		VALIDATOR_MODULE_3DENGINE,
		VALIDATOR_MODULE_AI,
		VALIDATOR_MODULE_ANIMATION,
		VALIDATOR_MODULE_ENTITYSYSTEM,
		VALIDATOR_MODULE_SCRIPTSYSTEM,
		VALIDATOR_MODULE_SYSTEM,
		VALIDATOR_MODULE_SOUNDSYSTEM,
		VALIDATOR_MODULE_GAME,
		VALIDATOR_MODULE_MOVIE,
		VALIDATOR_MODULE_EDITOR
	};

	////////////////////////////////////////////////////////////////////////////
	enum EValidatorFlags
	{
		VALIDATOR_FLAG_FILE = 0x0001, // Indicate that required file was not found or file was invalid.
		VALIDATOR_FLAG_TEXTURE = 0x0002, // Problem with texture.
		VALIDATOR_FLAG_SCRIPT = 0x0004, // Problem with script.
		VALIDATOR_FLAG_SOUND = 0x0008, // Problem with sound.
		VALIDATOR_FLAG_AI = 0x0010, // Problem with AI.
	};

	////////////////////////////////////////////////////////////////////////////
	struct SValidatorRecord
	{
		//! Severety of this error.
		EValidatorSeverity severity = EValidatorSeverity.VALIDATOR_WARNING;
		//! In which module error occured.
		EValidatorModule _module = EValidatorModule.VALIDATOR_MODULE_UNKNOWN;
		//! Error Text.
		const char* text = null;
		//! File which is missing or causing problem.
		const char* file = null;
		//! Additional description for this error.
		const char* description = null;
		//! Flags that suggest kind of error.
		int flags = 0;

	}

	/*! This interface will be givven to Validate methods of engine, for resources and objects validation.
 */
	interface IValidator
	{
		void Report(ref SValidatorRecord record);
	};

}
