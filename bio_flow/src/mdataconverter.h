#ifndef MDATACONVERTER_H
#define MDATACONVERTER_H
#include "stdafx.h"
#include <sstream>

#if 1
#include "msequence.h"
#include "mspectrum.h"
#include "mscore.h"
#else
#include "testtype.h"
#endif

/*struct package
{
	string * addr;
	unsigned int size;
};*/
typedef stringstream & package;

class mdataConverter
{
public:
	static const size_t m_64Btye_alined = 64;

public:
	mdataConverter() {}
	virtual ~mdataConverter() {}

	string q20(const double  _f, const int _size);
	string int2string(const size_t _l, const int _size = 32);
	bool compress(string & _s, const int _o = 0);
	string add_tail(const size_t _size, const size_t _aline = m_64Btye_alined);

};

#endif // !MDATACONVERTER_H



