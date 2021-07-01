module XArea;
import Math;

import imarkers;

extern (C++):

class CXAreaMgr : IXAreaMgr
{
	void RetriggerAreas()
	{

	}

	IXArea* CreateArea(const Vec3d* vPoints, const int count, const string[] names,
			const int type, const int groupId = -1,
			const float width = 0.0f, const float height = 0.0f)
	{
		return null; // TODO: implement
	}

	IXArea* CreateArea(const ref Vec3d min, const ref Vec3d max, const ref Matrix44 TM,
			const string[] names, const int type,
			const int groupId = -1, const float width = 0.0f)
	{
		return null; // TODO: implement
	}

	IXArea* CreateArea(const ref Vec3d center, const float radius, string[] names,
			const int type, const int groupId = -1, const float width = 0.0f)
	{
		return null; // TODO: implement
	}

	IXArea* GetArea(const ref Vec3 point)
	{
		return null; // TODO: implement
	}

	void DeleteArea(const IXArea aPtr)
	{

	}
}

class CXArea : IXArea
{
	void SetPoints(const ref Vec3 vPoints, const int count)
	{

	}

	void SetID(const int id)
	{

	}

	int GetID() const
	{
		return int.init; // TODO: implement
	}

	void SetGroup(const int id)
	{

	}

	int GetGroup() const
	{
		return int.init; // TODO: implement
	}

	void AddEntity(const char* clsName)
	{

	}

	void ClearEntities()
	{

	}

	void SetCenter(const ref Vec3 center)
	{

	}

	void SetRadius(const float rad)
	{

	}

	void SetMin(const ref Vec3 min)
	{

	}

	void SetMax(const ref Vec3 max)
	{

	}

	void SetTM(const ref Matrix44 TM)
	{

	}

	void SetVOrigin(float org)
	{

	}

	void SetVSize(float sz = 0.0f)
	{

	}

	void SetProximity(float prx)
	{

	}

	float GetProximity()
	{
		return float.init; // TODO: implement
	}
}
