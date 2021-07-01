module ifont;

import Math;
import Math.Vector2;
import isystem;
import Renderer.Cry_Color4;

public:

extern(C) ICryFont* CreateCryFontInterface(ISystem *pSystem);

extern(C++):
////////////////////////////////////////////////////////////////////////////
// Rendering interfaces
enum CRYFONT_RENDERINGINTERFACE
{
	CRYFONT_RI_OPENGL = 0,		// pRIData is ignored
	CRYFONT_RI_LAST
};

////////////////////////////////////////////////////////////////////////////
struct ICryFont
{

	void Release();
	
	//! create a named font
	IFFont *NewFont(const char *pszName);
	//! get a named font
	IFFont *GetFont(const char *pszName);

	//! Puts the objects used in this module into the sizer interface
	void GetMemoryUsage (ICrySizer* pSizer);
};

//////////////////////////////////////////////////////////////////////////////////////////////
enum TTFFLAG_SMOOTH_NONE = 		0x00000000;	//  no smooth
enum TTFFLAG_SMOOTH_BLUR = 		0x00000001;	//  smooth by bluring it
enum TTFFLAG_SMOOTH_SUPERSAMPLE = 	0x00000002;	//  smooth by rendering the characters into a bigger texture, 
																										// and then resize it to the normal size using bilinear filtering

enum TTFFLAG_SMOOTH_MASK = 		0x0000000f;	//  mask for retrieving
enum TTFFLAG_SMOOTH_SHIFT = 		0;		//  shift amount for retrieving

enum TTFLAG_SMOOTH_AMOUNT_2X = 		0x00010000;	//  blur / supersample [2x]
enum TTFLAG_SMOOTH_AMOUNT_4X = 		0x00020000;	//  blur / supersample [4x]

enum TTFFLAG_SMOOTH_AMOUNT_MASK = 0x000f0000;		//  mask for retrieving
enum TTFFLAG_SMOOTH_AMOUNT_SHIFT = 16;			//  shift amount for retrieving

// create a ttflag
auto TTFFLAG_CREATE(int smooth, int amount)		{ return ((((smooth) << TTFFLAG_SMOOTH_SHIFT) & TTFFLAG_SMOOTH_MASK) | (((amount) << TTFFLAG_SMOOTH_AMOUNT_SHIFT) & TTFFLAG_SMOOTH_AMOUNT_MASK)); }
auto TTFFLAG_GET_SMOOTH(int flag)			{ return (((flag) & TTFLAG_SMOOTH_MASK) >> TTFFLAG_SMOOTH_SHIFT); }
auto TTFFLAG_GET_SMOOTH_AMOUNT(int flag)		{ return (((flag) & TTFLAG_SMOOTH_SMOUNT_MASK) >> TTFFLAG_SMOOTH_AMOUNT_SHIFT); }

enum FONTRF_HCENTERED = 		0x80000000;	//  The font will be centered horizontaly around the x coo
enum FONTRF_VCENTERED = 		0x40000000;	//  The font will be centered verticaly around the y coo
enum FONTRF_FILTERED = 			0x20000000;	//  The font will be drawn with bilinear filtering

////////////////////////////////////////////////////////////////////////////
struct IFFont
{
	//! Reset the font to the default state
	void Reset();

	void Release();

	//! Load a font from a TTF file
	bool Load(const char *szFile, ulong nWidth, ulong nHeight, ulong nTTFFlags);

	//! Load a font from a XML file
	bool Load(const char *szFile);

	//! Free the memory
	void Free();

	//! Set the current effect to use
	void SetEffect(const char *szEffect);

	// Set clipping rectangle
	void SetClippingRect(float fX, float fY, float fW, float fH);

	// Enable / Disable clipping (off by default)
	void EnableClipping(bool bEnable);

	//! Set the color of the current effect
	void SetColor(ref const color4f col, int nPass = 0);
	void UseRealPixels(bool bRealPixels=true);
	bool UsingRealPixels();

	//! Set the characters base size
	void SetSize(ref const vector2f size);

	//! Return the seted size
	ref vector2f GetSize();

	//! Return the char width
	float GetCharWidth();

	//! Return the char height
	float GetCharHeight();

	//! Set the same size flag
	void SetSameSize(bool bSameSize);

	//! Get the same size flag
	bool GetSameSize();

	//! Set the width scaling
	void SetCharWidthScale(float fScale = 1.0f);

	//! Get the width scaling
	float GetCharWidthScale();

	//! Draw a formated string
	//! \param bASCIIMultiLine true='\','n' is a valid return, false=it's not
	void DrawString( float x, float y, const char *szMsg, const bool bASCIIMultiLine=true );

	//! Compute the text size
	//! \param bASCIIMultiLine true='\','n' is a valid return, false=it's not
	vector2f GetTextSize(const char *szMsg, const bool bASCIIMultiLine=true );

	//! Draw a formated string
	//! \param bASCIIMultiLine true='\','n' is a valid return, false=it's not
	void DrawStringW( float x, float y, const wchar *swStr, const bool bASCIIMultiLine=true );

	// Draw a formated string
	void DrawWrappedStringW( float x, float y, float w, const wchar *swStr, const bool bASCIIMultiLine=true );

	//! Compute the text size
	//! \param bASCIIMultiLine true='\','n' is a valid return, false=it's not
	vector2f GetTextSizeW(const wchar *swStr, const bool bASCIIMultiLine=true );	

	// Compute the text size
	vector2f GetWrappedTextSizeW(const wchar *swStr, float w, const bool bASCIIMultiLine=true );

	//! Compute text-length (because of special chars...)
	int GetTextLength(const char *szMsg, const bool bASCIIMultiLine=true);

	//! Compute text-length (because of special chars...)
	int GetTextLengthW(const wchar *szwMsg, const bool bASCIIMultiLine=true);

	//! Puts the memory used by this font into the given sizer
	void GetMemoryUsage (ICrySizer* pSizer);
};

