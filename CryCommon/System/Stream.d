module Stream;

extern(C++):

class CStream
{
	bool Write(T)(T v){
		return false;
	}

	bool Read(T)(T v){
		return false;
	}
}
