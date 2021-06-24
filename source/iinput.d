module iinput;

import platform;
import cry_math;

////////////////////////////////////////////////////////////////////////////////////////////////
//! Keys' code names
////////////////////////////////////////////////////////////////////////////////////////////////

extern (C++)
{
	//////////////////////////////////////////////////////////////////////////
	enum EKeyModifiersFlags
	{
		XKEY_MOD_NONE = 0,
		XKEY_MOD_LCONTROL = 0x01,
		XKEY_MOD_RCONTROL = 0x02,
		XKEY_MOD_LALT = 0x04,
		XKEY_MOD_RALT = 0x08,
		XKEY_MOD_LSHIFT = 0x010,
		XKEY_MOD_RSHIFT = 0x020,
		XKEY_MOD_CAPSLOCK = 0x040,
		XKEY_MOD_NUMLOCK = 0x080,

		XKEY_MOD_CONTROL = (0x01 | 0x02),
		XKEY_MOD_ALT = (0x04 | 0x08),
		XKEY_MOD_SHIFT = (0x010 | 0x020),
	};

	//////////////////////////////////////////////////////////////////////
	//JOYPAD	MOUSE		KEYBOARD
	//	00			00		0000
	enum KeyCodes
	{
		XKEY_NULL = 0x00000000, //forbidden

		XKEY_BACKSPACE = 0x00000001,
		XKEY_TAB = 0x00000002,
		XKEY_RETURN = 0x00000003,
		XKEY_CONTROL = 0x00000004,
		XKEY_ALT = 0x00000005,
		XKEY_SHIFT = 0x00000006,
		XKEY_PAUSE = 0x00000007,
		XKEY_CAPSLOCK = 0x00000008,
		XKEY_ESCAPE = 0x00000009,
		XKEY_SPACE = 0x0000000a,
		XKEY_PAGE_DOWN = 0x0000000b,
		XKEY_PAGE_UP = 0x0000000c,
		XKEY_END = 0x0000000d,
		XKEY_HOME = 0x0000000e,
		XKEY_LEFT = 0x0000000f,
		XKEY_UP = 0x00000010,
		XKEY_RIGHT = 0x00000011,
		XKEY_DOWN = 0x00000012,
		XKEY_PRINT = 0x00000013,
		XKEY_INSERT = 0x00000014,
		XKEY_DELETE = 0x00000015,
		XKEY_HELP = 0x00000016,
		XKEY_0 = 0x00000017,
		XKEY_1 = 0x00000018,
		XKEY_2 = 0x00000019,
		XKEY_3 = 0x0000001a,
		XKEY_4 = 0x0000001b,
		XKEY_5 = 0x0000001c,
		XKEY_6 = 0x0000001d,
		XKEY_7 = 0x0000001e,
		XKEY_8 = 0x0000001f,
		XKEY_9 = 0x00000020,
		XKEY_A = 0x00000021,
		XKEY_B = 0x00000022,
		XKEY_C = 0x00000023,
		XKEY_D = 0x00000024,
		XKEY_E = 0x00000025,
		XKEY_F = 0x00000026,
		XKEY_G = 0x00000027,
		XKEY_H = 0x00000028,
		XKEY_I = 0x00000029,
		XKEY_J = 0x0000002a,
		XKEY_K = 0x0000002b,
		XKEY_L = 0x0000002c,
		XKEY_M = 0x0000002d,
		XKEY_N = 0x0000002e,
		XKEY_O = 0x0000002f,
		XKEY_P = 0x00000030,
		XKEY_Q = 0x00000031,
		XKEY_R = 0x00000032,
		XKEY_S = 0x00000033,
		XKEY_T = 0x00000034,
		XKEY_U = 0x00000035,
		XKEY_V = 0x00000036,
		XKEY_W = 0x00000037,
		XKEY_X = 0x00000038,
		XKEY_Y = 0x00000039,
		XKEY_Z = 0x0000003a,
		XKEY_TILDE = 0x0000003b,
		XKEY_MINUS = 0x0000003c,
		XKEY_EQUALS = 0x0000003d,
		XKEY_LBRACKET = 0x0000003e,
		XKEY_RBRACKET = 0x0000003f,
		XKEY_BACKSLASH = 0x00000040,
		XKEY_SEMICOLON = 0x00000041,
		XKEY_APOSTROPHE = 0x00000042,
		XKEY_COMMA = 0x00000043,
		XKEY_PERIOD = 0x00000044,
		XKEY_SLASH = 0x00000045,
		XKEY_NUMPAD0 = 0x00000046,
		XKEY_NUMPAD1 = 0x00000047,
		XKEY_NUMPAD2 = 0x00000048,
		XKEY_NUMPAD3 = 0x00000049,
		XKEY_NUMPAD4 = 0x0000004a,
		XKEY_NUMPAD5 = 0x0000004b,
		XKEY_NUMPAD6 = 0x0000004c,
		XKEY_NUMPAD7 = 0x0000004d,
		XKEY_NUMPAD8 = 0x0000004e,
		XKEY_NUMPAD9 = 0x0000004f,
		XKEY_MULTIPLY = 0x00000050,
		XKEY_ADD = 0x00000051,
		XKEY_SEPARATOR = 0x00000052,
		XKEY_SUBTRACT = 0x00000053,
		XKEY_DECIMAL = 0x00000054,
		XKEY_DIVIDE = 0x00000055,
		XKEY_NUMPADENTER = 0x00000056,
		XKEY_F1 = 0x00000057,
		XKEY_F2 = 0x00000058,
		XKEY_F3 = 0x00000059,
		XKEY_F4 = 0x0000005a,
		XKEY_F5 = 0x0000005b,
		XKEY_F6 = 0x0000005c,
		XKEY_F7 = 0x0000005d,
		XKEY_F8 = 0x0000005e,
		XKEY_F9 = 0x0000005f,
		XKEY_F10 = 0x00000060,
		XKEY_F11 = 0x00000061,
		XKEY_F12 = 0x00000062,
		XKEY_F13 = 0x00000063,
		XKEY_F14 = 0x00000064,
		XKEY_F15 = 0x00000065,
		XKEY_F16 = 0x00000066,
		XKEY_F17 = 0x00000067,
		XKEY_F18 = 0x00000068,
		XKEY_F19 = 0x00000069,
		XKEY_F20 = 0x0000006a,
		XKEY_F21 = 0x0000006b,
		XKEY_F22 = 0x0000006c,
		XKEY_F23 = 0x0000006d,
		XKEY_F24 = 0x0000006e,
		XKEY_NUMLOCK = 0x0000006f,
		XKEY_SCROLLLOCK = 0x00000070,
		XKEY_LCONTROL = 0x00000071,
		XKEY_RCONTROL = 0x00000072,
		XKEY_LALT = 0x00000073,
		XKEY_RALT = 0x00000074,
		XKEY_LSHIFT = 0x00000075,
		XKEY_RSHIFT = 0x00000076,
		XKEY_WIN_LWINDOW = 0x00000077,
		XKEY_WIN_RWINDOW = 0x00000078,
		XKEY_WIN_APPS = 0x00000079,
		XKEY_OEM_102 = 0x00000080,
		XKEY_BUTTON0 = 0x00000100,
		XKEY_BUTTON1 = 0x00000101,
		XKEY_BUTTON2 = 0x00000102,
		XKEY_BUTTON3 = 0x00000103,
		XKEY_BUTTON4 = 0x00000104,
		XKEY_BUTTON5 = 0x00000105,
		XKEY_BUTTON6 = 0x00000106,
		XKEY_BUTTON7 = 0x00000107,
		XKEY_BUTTON8 = 0x00000108,
		XKEY_BUTTON9 = 0x00000109,
		XKEY_BUTTON10 = 0x0000010A,
		XKEY_BUTTON11 = 0x0000010B,
		XKEY_BUTTON12 = 0x0000010C,
		XKEY_BUTTON13 = 0x0000010D,
		XKEY_BUTTON14 = 0x0000010E,
		XKEY_BUTTON15 = 0x0000010F,
		XKEY_BUTTON16 = 0x00000110,
		XKEY_BUTTON17 = 0x00000111,
		XKEY_BUTTON18 = 0x00000112,
		XKEY_BUTTON19 = 0x00000113,
		XKEY_BUTTON20 = 0x00000114,
		XKEY_BUTTON21 = 0x00000115,
		XKEY_BUTTON22 = 0x00000116,
		XKEY_BUTTON23 = 0x00000117,
		XKEY_BUTTON24 = 0x00000118,
		XKEY_BUTTON25 = 0x00000119,
		XKEY_BUTTON26 = 0x0000011A,
		XKEY_BUTTON27 = 0x0000011B,
		XKEY_BUTTON28 = 0x0000011C,
		XKEY_BUTTON29 = 0x0000011D,
		XKEY_BUTTON30 = 0x0000011E,
		XKEY_BUTTON31 = 0x0000011F,
		//MOUSE
		XKEY_MOUSE1 = 0x00010000,
		XKEY_MOUSE2 = 0x00020000,
		XKEY_MOUSE3 = 0x00030000,
		XKEY_MOUSE4 = 0x00040000,
		XKEY_MOUSE5 = 0x00050000,
		XKEY_MOUSE6 = 0x00060000,
		XKEY_MOUSE7 = 0x00070000,
		XKEY_MOUSE8 = 0x00080000,
		XKEY_MWHEEL_UP = 0x00090000,
		XKEY_MWHEEL_DOWN = 0x000A0000,
		XKEY_MAXIS_X = 0x000B0000,
		XKEY_MAXIS_Y = 0x000C0000,

		//GAMEPAD
		XKEY_GP_A = 0x01000000,
		XKEY_GP_B = 0x02000000,
		XKEY_GP_X = 0x03000000,
		XKEY_GP_Y = 0x04000000,
		XKEY_GP_BLACK = 0x05000000,
		XKEY_GP_WHITE = 0x06000000,
		XKEY_GP_LEFT_TRIGGER = 0x07000000,
		XKEY_GP_RIGHT_TRIGGER = 0x08000000,

		XKEY_GP_DPAD_UP = 0x11000000,
		XKEY_GP_DPAD_DOWN = 0x12000000,
		XKEY_GP_DPAD_LEFT = 0x13000000,
		XKEY_GP_DPAD_RIGHT = 0x14000000,
		XKEY_GP_START = 0x15000000,
		XKEY_GP_BACK = 0x16000000,
		XKEY_GP_LEFT_THUMB = 0x17000000,
		XKEY_GP_RIGHT_THUMB = 0x18000000,

		XKEY_GP_STHUMBLUP = 0x19000000,
		XKEY_GP_STHUMBLDOWN = 0x1a000000,
		XKEY_GP_STHUMBLLEFT = 0x1b000000,
		XKEY_GP_STHUMBLRIGHT = 0x1c000000,

		XKEY_GP_STHUMBLX = 0x21000000,
		XKEY_GP_STHUMBLY = 0x22000000,
		XKEY_GP_STHUMBRX = 0x23000000,
		XKEY_GP_STHUMBRY = 0x24000000,

		//JOYPAD
		XKEY_J_BUTTON_01 = 0x30000000, // Button numbers must be sequential, starting at button_01
		XKEY_J_BUTTON_02 = 0x31000000,
		XKEY_J_BUTTON_03 = 0x32000000,
		XKEY_J_BUTTON_04 = 0x33000000,
		XKEY_J_BUTTON_05 = 0x34000000,
		XKEY_J_BUTTON_06 = 0x35000000,
		XKEY_J_BUTTON_07 = 0x36000000,
		XKEY_J_BUTTON_08 = 0x37000000,
		XKEY_J_BUTTON_09 = 0x38000000,
		XKEY_J_BUTTON_10 = 0x39000000,
		XKEY_J_BUTTON_11 = 0x3a000000,
		XKEY_J_BUTTON_12 = 0x3b000000,
		XKEY_J_BUTTON_13 = 0x3c000000,
		XKEY_J_BUTTON_14 = 0x3d000000,
		XKEY_J_BUTTON_15 = 0x3e000000,
		XKEY_J_BUTTON_16 = 0x3f000000,
		XKEY_J_BUTTON_17 = 0x40000000,
		XKEY_J_BUTTON_18 = 0x41000000,
		XKEY_J_BUTTON_19 = 0x42000000,
		XKEY_J_BUTTON_20 = 0x43000000,
		XKEY_J_BUTTON_21 = 0x44000000,
		XKEY_J_BUTTON_22 = 0x45000000,
		XKEY_J_BUTTON_23 = 0x46000000,
		XKEY_J_BUTTON_24 = 0x47000000,
		XKEY_J_BUTTON_25 = 0x48000000,
		XKEY_J_BUTTON_26 = 0x49000000,
		XKEY_J_BUTTON_27 = 0x4a000000,
		XKEY_J_BUTTON_28 = 0x4b000000,
		XKEY_J_BUTTON_29 = 0x4c000000,
		XKEY_J_BUTTON_30 = 0x4d000000,
		XKEY_J_BUTTON_31 = 0x4e000000,
		XKEY_J_BUTTON_32 = 0x4f000000,
		XKEY_J_BUTTON_STEP = (XKEY_J_BUTTON_02 - XKEY_J_BUTTON_01),
		XKEY_J_BUTTON_LAST = XKEY_J_BUTTON_32,

		XKEY_J_AXIS_1 = 0x50000000, // Axis numbers must be sequential, starting at AXIS_1
		XKEY_J_AXIS_2 = 0x51000000,
		XKEY_J_AXIS_3 = 0x52000000,
		XKEY_J_AXIS_4 = 0x53000000,
		XKEY_J_AXIS_5 = 0x54000000,
		XKEY_J_AXIS_6 = 0x55000000,
		XKEY_J_AXIS_STEP = (XKEY_J_AXIS_2 - XKEY_J_AXIS_1),
		XKEY_J_AXIS_LAST = XKEY_J_AXIS_6,

		XKEY_J_DIR_UP = 0x58000000, // Digital mapping of left stick. must be first
		XKEY_J_DIR_DOWN = 0x59000000,
		XKEY_J_DIR_LEFT = 0x5a000000,
		XKEY_J_DIR_RIGHT = 0x5b000000,
		XKEY_J_DIR_LAST = XKEY_J_DIR_RIGHT,

		XKEY_J_HAT_UP = 0x5c000000, // must be first hat
		XKEY_J_HAT_DOWN = 0x5d000000,
		XKEY_J_HAT_LEFT = 0x5e000000,
		XKEY_J_HAT_RIGHT = 0x5f000000,
		XKEY_J_HAT_LAST = XKEY_J_HAT_RIGHT,

	};

	//////////////////////////////////////////////////////////////////////
	/*! Interface to the Keyboard system.
*/
	interface IKeyboard
	{
		void ShutDown();

		//! allow to force a key code value
		/// void    SetKey(int p_key, int value);
		//! allow to force a key code value
		//inline  void    SetPrevKey(int p_key, int value);

		//! check for key pressed and held
		bool KeyDown(int p_key);

		//! check for key pressed only once
		bool KeyPressed(int p_key);

		//! check if the key has been released
		bool KeyReleased(int p_key);

		//! clear the key status
		void ClearKey(int p_key);

		//! return the code of the key pressed
		int GetKeyPressedCode();

		//! return the name of the key pressed 
		const char* GetKeyPressedName();

		//! return the code of the key down
		int GetKeyDownCode();

		//! return the name of the key down
		const char* GetKeyDownName();

		//! set/unset directinput to exclusive mode
		void SetExclusive(bool value, void* hwnd = null);

		//! wait for a key pressed
		void WaitForKey();

		//! clear the key (pressed) state
		void ClearKeyState();
	};

	//////////////////////////////////////////////////////////////////////
	/*! Interface to the Mouse system.
*/
	interface IMouse
	{
		void Shutdown();

		//! check for a mouse button pressed and held
		bool MouseDown(int p_numButton);

		//! check for a mouse button pressed only once
		bool MousePressed(int p_numButton);

		//! check if the mouse button has been released
		bool MouseReleased(int p_numButton);

		//! force the mouse wheel rotation to a certain value
		void SetMouseWheelRotation(int value);

		//! set/reset Directinput to exclusive mode
		bool SetExclusive(bool value, void* hwnd = null);

		//! get mouse X delta (left-right)
		float GetDeltaX();

		//! get mouse Y delta (up-down)
		float GetDeltaY();

		//! get mouse Z delta (mouse wheel)
		float GetDeltaZ();

		//! set mouse inertia
		void SetInertia(float);

		//! set mouse X screen corrdinate
		void SetVScreenX(float fX);

		//! set mouse Y screen corrdinate
		void SetVScreenY(float fY);

		//! get mouse X screen corrdinate
		float GetVScreenX();

		//! get mouse Y screen corrdinate
		float GetVScreenY();

		//! set the mouse sensitivity
		void SetSensitvity(float fSensitivity);

		//! get the mouse sensitivity
		float GetSensitvity();

		//! set the mouse sensitivity scale (from 0 to 1)
		void SetSensitvityScale(float fSensScale);

		//! get the mouse sensitivity scale
		float GetSensitvityScale();

		//! clear the key states
		void ClearKeyState();
	};

	//////////////////////////////////////////////////////////////////////

	alias int XACTIONID;

	//#define BEGIN_INPUTACTIONMAP() void OnAction(XACTIONID nActionID, float fValue,XActivationEvent ae) { switch(nActionID) {
	//#define END_INPUTACTIONMAP() default: break; } }
	//#define REGISTER_INPUTACTIONMAP(actionid, handler) case actionid: handler(fValue,ae); break;

	version (_XBOX)
	{
		const auto MAX_BINDS_PER_ACTION = 3;
	}
	else
	{
		const auto MAX_BINDS_PER_ACTION = 2;

	}
	//////////////////////////////////////////////////////////////////////
	enum XActionActivationMode
	{
		aamOnPress,
		aamOnDoublePress,
		aamOnPressAndRelease,
		aamOnRelease,
		aamOnHold
	};

	//////////////////////////////////////////////////////////////////////
	enum XActivationEvent
	{
		etPressing,
		etHolding,
		etReleasing,
		etDoublePressing
	};

	//////////////////////////////////////////////////////////////////////
	struct XBind
	{
		int nKey = KeyCodes.XKEY_NULL;
		int nModifier = KeyCodes.XKEY_NULL;
	};

	//////////////////////////////////////////////////////////////////////
	interface IActionMapSink
	{
		void OnAction(XACTIONID nActionID, float fValue, XActivationEvent ae);
	};

	//////////////////////////////////////////////////////////////////////
	interface IActionMap
	{
		void ResetAllBindings();
		void ResetBinding(XACTIONID nActionID);
		void RemoveBind(XACTIONID nActionID, ref XBind NewBind, XActionActivationMode aam);
		void BindAction(XACTIONID nActionID, ref XBind NewBind, int iKeyPos = -1); //int nKey,int nModifier=XKEY_NULL);
		void BindAction(XACTIONID nActionID, int nKey,
				int nModifier = KeyCodes.XKEY_NULL, int iKeyPos = -1); //, bool bConfigurable=false, bool bReplicate=false);
		void BindAction(XACTIONID nActionID, const char* sKey,
				const char* sModifier = null, int iKeyPos = -1);
		void GetBinding(XACTIONID nActionID, int nKeyPos, ref XBind Bind);
		void GetBinding(XACTIONID nActionID, int nKeyPos, ref int nKey, ref int nModifier);
		void GetBinding(XACTIONID nActionID, int nKeyPos, char* pszKey, char* pszModifier);
		// compare this action map with the one passed and store the key differences in keys
		void GetBindDifferences(IActionMap* pActionMap, /*std::vector < int >&*/ int[] keys);
	};

	//////////////////////////////////////////////////////////////////////
	interface IActionMapDumpSink
	{
		void OnElementFound(const char* pszActionMapName, IActionMap* pActionMap);
	};

	//////////////////////////////////////////////////////////////////////
	interface IActionMapManager
	{
		void SetInvertedMouse(bool bEnable);
		bool GetInvertedMouse();

		void RemoveBind(XACTIONID nActionID, ref XBind NewBind, XActionActivationMode aam);

		void SetSink(IActionMapSink* pSink);
		void CreateAction(XACTIONID nActionID, const char* sActionName,
				XActionActivationMode aam = XActionActivationMode.aamOnPress);

		IActionMap* CreateActionMap(const char* s);
		IActionMap* GetActionMap(const char* s);

		void ResetAllBindings();

		void GetActionMaps(IActionMapDumpSink* pCallback);

		void SetActionMap(const char* s);

		bool CheckActionMap(XACTIONID nActionID);
		bool CheckActionMap(const char* sActionName);
		void Reset();
		void Update(uint nTimeMSec);
		void Release();

		void Enable();
		void Disable();
		bool IsEnabled();
	};

	//////////////////////////////////////////////////////////////////////
	alias char INPUTACTIONID;

	//@{ Helper macros to implement the action triggers callback interface
	//#define BEGIN_INPUTACTIONTRIGGERS() void OnAction(INPUTACTIONID nActionID, float fValue) { switch(nActionID) {
	//#define END_INPUTACTIONTRIGGERS() default: break; } }
	//#define REGISTER_INPUTACTIONTRIGGER(actionid, handler) case actionid: handler(fValue); break;
	//@}

	//////////////////////////////////////////////////////////////////////
	// Action triggers callback interface
	interface IInputActionTriggerSink
	{
		void OnAction(INPUTACTIONID nActionID, float fValue);
	};

	//! Action map interface
	interface IInputActionMap
	{
		void SetSink(IInputActionTriggerSink* pIActionTrigger);

		void Release();

		//! Check all actions
		void Update();

		// Call the action trigger
		void CallActionTrigger(INPUTACTIONID nActionID, float fValue);

		//! Return the amount of pressing of the action input if the action is
		//! currently done
		float CheckAction(const INPUTACTIONID nActionID);

		/*! Set a new action
		@param nActionID id that identity the action[eg. ACTION_JUMP]
		@param bCheckPressed if true the action event is triggered only once when a button is pressed
		else the action is send every frame until the button is released
		@param szCodes key identifiers [eg. "MBT_1" mouse button]
		@param szMods key modifier [eg. "SHIFT"]
		@return true=succeded,false=failed*/

		bool SetAction(const INPUTACTIONID nActionID, bool bCheckPressed,
				const char* szCodes, const char* szMods = null);

		void ClearAction(const INPUTACTIONID nActionID);
	};

	//////////////////////////////////////////////////////////////////////
	// Input interface for the XBox controller
	//////////////////////////////////////////////////////////////////////

	version (_XBOX)
	{

		//@{ XBox Input code enumerations and constants
		enum eController
		{
			eOne = 0,
			eTwo = 1,
			eThree = 2,
			eFour = 3,
			ePrimary = 10,
			eAll = 11,
		};

		enum eDigitalButton
		{
			eDigitalUp = XINPUT_GAMEPAD_DPAD_UP,
			eDigitalDown = XINPUT_GAMEPAD_DPAD_DOWN,
			eDigitalLeft = XINPUT_GAMEPAD_DPAD_LEFT,
			eDigitalRight = XINPUT_GAMEPAD_DPAD_RIGHT,
			eStart = XINPUT_GAMEPAD_START,
			eBack = XINPUT_GAMEPAD_BACK,
			eLeftStick = XINPUT_GAMEPAD_LEFT_THUMB,
			eRightStick = XINPUT_GAMEPAD_RIGHT_THUMB,
		};

		enum eAnalogButton
		{
			eA = XINPUT_GAMEPAD_A,
			eB = XINPUT_GAMEPAD_B,
			eX = XINPUT_GAMEPAD_X,
			eY = XINPUT_GAMEPAD_Y,
			eBlack = XINPUT_GAMEPAD_BLACK,
			eWhite = XINPUT_GAMEPAD_WHITE,
			eLeftTrigger = XINPUT_GAMEPAD_LEFT_TRIGGER,
			eRightTrigger = XINPUT_GAMEPAD_RIGHT_TRIGGER,
		};

		enum eSide
		{
			eLeft,
			eRight,
		};

		const uint MAX_XBOX_CONTROLLERS = 4;
		const uint XBOX_ANALOGSTICK_DEADZONE = 8000;
		//@}

		//////////////////////////////////////////////////////////////////////
		interface IGamepad
		{
			void ShutDown();

			//! check for a mouse button pressed and held
			bool KeyDown(int p_numButton);

			//! check for a mouse button pressed only once
			bool KeyPressed(int p_numButton);

			//! check if the mouse button has been released
			bool KeyReleased(int p_numButton);

			//! get mouse X delta (left-right)
			float GetDeltaX();

			//! get mouse Y delta (up-down)
			float GetDeltaY();
		};

	} //_XBOX

	/*! InputEvents are generated by input system and broadcasted to all event listeners.
*/
	struct SInputEvent
	{
		//! Input Event types.
		enum EType
		{
			UNKNOWN,
			KEY_PRESS,
			KEY_RELEASE,
			MOUSE_MOVE,
		};

		//! Type of input event.
		EType type = EType.UNKNOWN;
		//! Key which was pressed or released, one of the XKeys.
		//! @see KeyCodes
		int key;
		//! Timestamp of the event, (GetTickCount compatable).
		uint timestamp;

		//! Key modifiers enabled at the time of this event.
		//! @see EKeyModifiersFlags
		int moidifiers = EKeyModifiersFlags.XKEY_MOD_NONE;

		//! Name of the event key.
		const char* keyname;

		//! For mouse axises.
		float value;
	};

	//////////////////////////////////////////////////////////////////////////
	/* Input event listeners registered to input system and recieve input events when they are generated.
*/
	interface IInputEventListener
	{
		//! Called every time input event is generated.
		//! @return if return True then broadcasting of this event should be aborted and the rest of input 
		//! listeners should not recieve this event.
		bool OnInputEvent(const ref SInputEvent event);
	};

	/*! Interface to the Input system.
	The input system give access and initialize Keyboard,Mouse and Joystick SubSystems.
	*/

	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	/*! Main Input system interface.
*/
	interface IInput
	{
		//////////////////////////////////////////////////////////////////////////
		//! Register new input events listener.
		void AddEventListener(IInputEventListener* pListener);
		void RemoveEventListener(IInputEventListener* pListener);
		void EnableEventPosting(bool bEnable);

		//! Register new console input event listeners. console input listeners receive all events, no matter what.
		void AddConsoleEventListener(IInputEventListener* pListener);
		void RemoveConsoleEventListener(IInputEventListener* pListener);

		void SetExclusiveListener(IInputEventListener* pListener);
		IInputEventListener* GetExclusiveListener();

		//////////////////////////////////////////////////////////////////////////
		//! update Keyboard, Mouse and Joystick. Set bFocus to true if window has focus and input is enabled.
		void Update(bool bFocus);
		//! clear all subsystems
		void ShutDown();
		//! @see IMouse::SetExclusive
		void SetMouseExclusive(bool exclusive, void* hwnd = null);
		//! @see IKeyboard::SetExclusive
		void SetKeyboardExclusive(bool exclusive, void* hwnd = null);

		//! @see IKeyBoard::KeyDown
		bool KeyDown(int p_key);
		//! @see IKeyBoard::KeyPressed
		bool KeyPressed(int p_key);
		//! @see IKeyBoard::KeyRelease
		bool KeyReleased(int p_key);

		//! @see IMouse::MouseDown
		bool MouseDown(int p_numButton);

		//! @see IMouse::MousePressed
		bool MousePressed(int p_numButton);

		//! @see IMouse::MouseDblClick
		bool MouseDblClick(int p_numButton);

		//! @see IMouse::MouseReleased
		bool MouseReleased(int p_numButton);

		//! @see IMouse::GetDeltaX
		float MouseGetDeltaX();

		//! @see IMouse::GetDeltaY
		float MouseGetDeltaY();

		//! @see IMouse::GetDeltaZ
		float MouseGetDeltaZ();

		//! @see IMouse::GetVScreenX
		float MouseGetVScreenX();

		//! @see IMouse::GetVScreenY
		float MouseGetVScreenY();

		//! Converts a key-name to the key-id
		int GetKeyID(const char* sName);
		void EnableBufferedInput(bool bEnable);
		void FeedVirtualKey(int nVirtualKey, long lParam, bool bDown);
		int GetBufferedKey();
		const char* GetBufferedKeyName();
		void PopBufferedKey();
		//! @see IMouse::SetInertia
		void SetMouseInertia(float);

		version (Win32)
		{ //--- NickH: new joystick code. API names have changed because button pressed functionality is different.
			//! Get the currently selected stick/game-pad
			int JoyGetDefaultControllerId() const;
			//! check if the joystick button is held down
			bool JoyIsRawBtnDown(int idCtrl, int p_numButton);
			//! check if the joystick button has just been pressed
			bool JoyIsRawBtnPressed(int idCtrl, int p_numButton);
			//! check if the joystick button has just been released
			bool JoyIsRawBtnReleased(int idCtrl, int p_numButton);

			//! check the joystick direction
			int JoyGetDir(int idCtrl);
			int JoyGetDirPressed(int idCtrl);
			int JoyGetDirReleased(int idCtrl);

			//! check the joy hat direction
			int JoyGetHatDir(int idCtrl);
			int JoyGetHatDirPressed(int idCtrl);
			int JoyGetHatDirReleased(int idCtrl);

			//! get the first 3 axis (xyz)
			Vec3 JoyGetAnalog1Dir(int idCtrl) const;
			//! get the next 3 axis (ruv)
			Vec3 JoyGetAnalog2Dir(int idCtrl) const;

			bool JoyIsXKeyPressed(int idCtrl, int idXKey);
			bool JoyIsXKeyDown(int idCtrl, int idXKey);
			bool JoyIsXKeyReleased(int idCtrl, int idXKey);

			float GetJoySensitivityHGain(int idCtrl);
			float GetJoySensitivityHScale(int idCtrl);
			float GetJoySensitivityVGain(int idCtrl);
			float GetJoySensitivityVScale(int idCtrl);
			void SetJoySensitivityHGain(int idCtrl, float fHGain);
			void SetJoySensitivityHScale(int idCtrl, float fHScale);
			void SetJoySensitivityVGain(int idCtrl, float fVGain);
			void SetJoySensitivityVScale(int idCtrl, float fVScale);
		} // old or new joystick code.

		//! return the keyboard interface 
		IKeyboard* GetIKeyboard();

		//! return the mouse interface 
		IMouse* GetIMouse();

		version (_XBOX)
		{
			//! return the Xbox gamepad interface 
			IGamepad* GetIGamepad();
		}
		//! Convert key code to the key name.
		//! @param nKey one of xkey codes.
		//! @param modifiers current modifiers (shift,ctrl,..).
		//! @see KeyCodes.
		const char* GetKeyName(int nKey, int modifiers = 0, bool bGUI = 0);

		bool GetOSKeyName(int nKey, wchar* szwKeyName, int iBufSize);

		//! @see IKeyBoard::GetKeyPressedCode
		int GetKeyPressedCode();

		//! @see IKeyBoard::GetKeyPressedName
		const char* GetKeyPressedName();

		//! @see IKeyBoard::GetKeyDownCode
		int GetKeyDownCode();

		//! @see IKeyBoard::GetKeyDownName
		const char* GetKeyDownName();

		//! @see IKeyBoard::WaitForKey
		void WaitForKey();

		//! action mapper
		IActionMapManager* CreateActionMapManager();

		//! return the name of the current XKEY(both mouse and keyboard excluding mouse delta)
		//! useful for the GUI to retrieve the first key pressed during the key configuration
		const char* GetXKeyPressedName();

		//! clear key states of all devices
		void ClearKeyState();

		char GetKeyState(int nKey);
	};

	auto IS_NULL_KEY(KeyCodes key)
	{
		return key == KeyCodes.XKEY_NULL;
	}

	auto IS_MOUSE_KEY(KeyCodes key)
	{
		return (key) & 0x00FF0000;
	}

	auto IS_JOYPAD_KEY(KeyCodes key)
	{
		return (key) & 0xFF000000;
	}

	auto IS_GAMEPAD_KEY(KeyCodes key)
	{
		return key & 0xFF000000;
	}

	auto IS_KEYBOARD_KEY(KeyCodes key)
	{
		return key & 0x0000FFFF;
	}

}
