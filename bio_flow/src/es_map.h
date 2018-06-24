/**
* Author: Zhou Xuegong
* Copyright(C) 2009-2014. CAD Team, State Key Laboratory of ASIC & System, Fudan University 
*/

#ifndef FUDAN_UTILS_H_
#define FUDAN_UTILS_H_

#include <string>
#include <iostream>
#include <typeinfo>

using namespace std;
///////////////////////////////////////////////////////////////////////////////////////
/// \class EnumStringMap
/// convert between enum and string

template <typename E>
class EnumStringMap {
	const char * const * _str_table;
	const int _size;
	const E   _def;
public:
	template <typename SA>
	explicit EnumStringMap(const SA& st, E default_value = (E)0)
		: _str_table(st), _size(sizeof(st)/sizeof(char*)), _def(default_value) {}

	E getEnum(const std::string& str) const {
		for (int i = 0; i < _size; ++i)
			if (str == _str_table[i])
				return str.empty() ? _def : static_cast<E>(i);
		throw std::bad_cast();
	}

	const char* getString(E val) const {
		return val == _def && (val < 0 || val >= _size) ? "" : _str_table[val];
	}

	E readEnum(std::istream& s) const {
		string str;
		s >> std::ws;
		if (!s.eof()) s >> str;		// empty input
		return getEnum(str);
	}

	std::ostream& writeEnum(std::ostream& s, E val) { return s << getString(val); }
};

#endif /*FUDAN_UTILS_H_*/
