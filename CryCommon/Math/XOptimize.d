module XOptimize;

import Utils.TArray;
import platform;

extern int g_CpuFlags;

//////////////////////////////////////////////////////////////////////
/*inline */float AngleMod(float a)
{
  a = cast(float)((360.0/65536) * (cast(int)(a*(65536/360.0)) & 65535));
  return a;
}

//////////////////////////////////////////////////////////////////////
/*inline */ushort Degr2Word(float f)
{
  return cast(ushort)(AngleMod(f)/360.0f*65536.0f);
}

//////////////////////////////////////////////////////////////////////
/*inline */float Word2Degr(ushort s)
{
  return cast(float)s / 65536.0f * 360.0f;
}

//////////////////////////////////////////////////////////////////////
//MISC FUNCTIONS
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
version(_CPU_X86) {
//float __fastcall Ffabs(float f) {
//	*((u*) & f) &= ~0x80000000;
//	return (f);
//}
}
else
{
/*inline */float Ffabs(float x) { return fabsf(x); }
}
//////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////
//#define rnd()	(((float)rand())/RAND_MAX)  // Floating point random number generator ( 0 -> 1)

//////////////////////////////////////////////////////////////////////
/*inline */void multMatrices(double[16] dst, const double[16] a, const double[16] b)
{
  int i, j;

  for (i = 0; i < 4; i++) {
    for (j = 0; j < 4; j++) {
      dst[i * 4 + j] =
        b[i * 4 + 0] * a[0 * 4 + j] +
        b[i * 4 + 1] * a[1 * 4 + j] +
        b[i * 4 + 2] * a[2 * 4 + j] +
        b[i * 4 + 3] * a[3 * 4 + j];
    }
  }
}

//////////////////////////////////////////////////////////////////////
/*inline */void multMatrices(double[16] dst, const double[16] a, const double[16] b)
{
  int i, j;

  for (i = 0; i < 4; i++) {
    for (j = 0; j < 4; j++) {
      dst[i * 4 + j] =
        b[i * 4 + 0] * a[0 * 4 + j] +
        b[i * 4 + 1] * a[1 * 4 + j] +
        b[i * 4 + 2] * a[2 * 4 + j] +
        b[i * 4 + 3] * a[3 * 4 + j];
    }
  }
}

//////////////////////////////////////////////////////////////////////
// transform vector
/*inline */void matmult_trans_only(float[3] a, float[4][4] b, float[3] result)
{
  result[0] = a[0] * b[0][0] + a[1] * b[1][0] + a[2] * b[2][0] + b[3][0];
  result[1] = a[0] * b[0][1] + a[1] * b[1][1] + a[2] * b[2][1] + b[3][1];
  result[2] = a[0] * b[0][2] + a[1] * b[1][2] + a[2] * b[2][2] + b[3][2];
}

