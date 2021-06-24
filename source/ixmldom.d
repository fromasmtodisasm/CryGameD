module ixmldom;

alias XMLCHAR = char;

extern (C++, XDOM)
{
	//////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////

	enum _DOMNodeType
	{
		NODE_ELEMENT,
		NODE_ATTRIBUTE,
		NODE_TEXT
	};

	//////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////
	interface IXMLDOMBase
	{
		int AddRef();
		void Release();
	};

	//////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////
	interface IXMLDOMNode : IXMLDOMBase
	{
		_DOMNodeType getNodeType();
		const char* getText();
		const char* getName();
		IXMLDOMNodeList* getChildNodes();

		void setText(const char* sText);
		void setName(const char* sName);

		bool hasChildNodes();
		bool appendChild(IXMLDOMNode* pNode);

		IXMLDOMNode* getAttribute(const XMLCHAR* sName);
		IXMLDOMNodeList* getElementsByTagName(const XMLCHAR* sName);
	};

	//////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////
	interface IXMLDOMNodeList : IXMLDOMBase
	{
		size_t length();
		void reset();
		IXMLDOMNode* nextNode();
	};

	//////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////
	interface IXMLDOMDocument : IXMLDOMNode
	{
		bool load(const XMLCHAR* sSourceFile);
		bool loadXML(const XMLCHAR* szString);
		IXMLDOMNode* getRootNode();
		IXMLDOMNode* createNode(_DOMNodeType Type, const char* name);
		//const XMLCHAR *getXML();
		const XMLCHAR* getErrorString();
		ushort getCheckSum();
	};

}
