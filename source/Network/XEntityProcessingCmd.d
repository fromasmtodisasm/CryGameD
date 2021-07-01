module XEntityProcessingCmd;

import Math;
import Stream;
import IBitStream : IBitStream;

//////////////////////////////////////////////////////////////////////
//! Structure used to hold the commands
class CXEntityProcessingCmd
{
public:
	//! constructor
	this();
	//! destructor
	this();

	void Release()
	{
		//FIXME:
		//delete this;
	}

	// Flag management... 
	void AddAction(uint nFlags);
	void RemoveAction(uint nFlags);
	void Reset();
	bool CheckAction(uint nFlags);

	// Angles...
	ref Vec3 GetDeltaAngles();
	void SetDeltaAngles(ref const Vec3 ang);
	void SetPhysicalTime(int iPTime) //,float fTimeSlice)
	{
		m_iPhysicalTime = iPTime;
	}

	int GetPhysicalTime()
	{
		return m_iPhysicalTime;
	}

	void SetLeaning(float fLeaning)
	{
		m_fLeaning = fLeaning;
	}

	float GetLeaning()
	{
		return m_fLeaning;
	}

//FIXME:
	//int AddTimeSlice(float* pfSlice, int nSlices = 1)
	//{
	//	for (int i = 0; i < nSlices
	//			&& m_nTimeSlices < sizeof(m_fTimeSlices) / sizeof(m_fTimeSlices[0]);
	//		i++, m_nTimeSlices++)
	//		m_fTimeSlices[m_nTimeSlices] = pfSlice[i];
	//	return m_nTimeSlices;
	//}

	//int InsertTimeSlice(float fSlice, int iBefore = 0)
	//{
	//	m_nTimeSlices = min(m_nTimeSlices + 1,
	//			sizeof(m_fTimeSlices) / sizeof(m_fTimeSlices[0]));
	//	for (int i = m_nTimeSlices; i > iBefore; i--)
	//		m_fTimeSlices[i] = m_fTimeSlices[i - 1];
	//	m_fTimeSlices[iBefore] = fSlice;
	//	return m_nTimeSlices;
	//}

	//int GetTimeSlices(ref float* pfSlices)
	//{
	//	pfSlices = m_fTimeSlices;
	//	return m_nTimeSlices;
	//}

	void ResetTimeSlices()
	{
		m_nTimeSlices = 0;
	}

	void SetPhysDelta(float fServerDelta, float fClientDelta = 0)
	{
		m_fServerDelta = fServerDelta;
		m_fClientDelta = fClientDelta;
	}

	float GetServerPhysDelta()
	{
		return m_fServerDelta;
	}

	float GetClientPhysDelta()
	{
		return m_fClientDelta;
	}

	//! \param pBitStream must not be 0 (compressed or uncompressed)
	bool Write(ref CStream stm, IBitStream* pBitStream, bool bWriteAngles);

	//! \param pBitStream must not be 0 (compressed or uncompressed)
	bool Read(ref CStream stm, IBitStream* pBitStream);

	void SetMoveFwd(float fVal)
	{
		m_fMoveFwd = fVal;
	}

	void SetMoveBack(float fVal)
	{
		m_fMoveBack = fVal;
	}

	void SetMoveLeft(float fVal)
	{
		m_fMoveLeft = fVal;
	}

	void SetMoveRight(float fVal)
	{
		m_fMoveRight = fVal;
	}

	float GetMoveFwd()
	{
		return m_fMoveFwd;
	}

	float GetMoveBack()
	{
		return m_fMoveBack;
	}

	float GetMoveLeft()
	{
		return m_fMoveLeft;
	}

	float GetMoveRight()
	{
		return m_fMoveRight;
	}

public:

	uint[2] m_nActionFlags; //!< Timedemo recorded needs access to these.

private:

	int m_iPhysicalTime; //!<
	Ang3 m_vDeltaAngles; //!<
	float[32] m_fTimeSlices; //!<
	ubyte m_nTimeSlices; //!<

	// non serialized variables 

	float m_fServerDelta; //!<
	float m_fClientDelta; //!<
	float m_fLeaning; //!<

	float m_fMoveFwd; // 
	float m_fMoveBack;
	float m_fMoveLeft;
	float m_fMoveRight;
};
