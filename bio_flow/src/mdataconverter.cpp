#include "stdafx.h"
#include "mdataconverter.h"

string mdataConverter::q20(const double _f, const int _size)
{
	size_t byte = 255;
	size_t ch;
	int num = _size / 8;
	size_t t = (size_t)(_f * 1048576);
	string s;
	for (int i = 0; i < num; ++i)
	{
		ch = t & byte;
		ch = ch >> (8 * i);
		s = char(ch) + s;
		byte = byte << 8;
	}
	return s;
}

string mdataConverter::int2string(const size_t _l, const int _size)
{
	size_t t = _l;
	size_t byte = 255;
	size_t ch;
	int num = _size / 8;
	string s;
	for (int i = 0; i < num; ++i)
	{
		ch = t & byte;
		ch = ch >> 8 * i;
		s = char(ch) + s;
		byte = byte << 8;
	}
	return s;
}

bool mdataConverter::compress(string & _s, const int _o/* = 0*/)
{
	for (auto & c : _s)
	{
		if (c == '*' && _o != 0)
			c = '[';
		if (c < _o)
			return false;
		c -= _o;
	}
	return true;
}

string mdataConverter::add_tail(const size_t _size, const size_t _aline/* = m_64Btye_alined*/)
{
	if (_size % _aline)
	{
		string tail(_aline - (_size % _aline), char(0));
		return tail;
	}
	else
		return "";
}
