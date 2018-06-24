#ifndef MSEQBESTSENDER_H
#define MSEQBESTSENDER_H

#include "stdafx.h"
#include <algorithm>

#include <sstream>
#include "mdataconverter.h"

class mseqbestSender
{
private:
	stringstream m_addrstream;
	mdataConverter m_converter;

	long m_addr;
	long m_length;
public:
	mseqbestSender();
    ~mseqbestSender() {}

    //bool process(vector<msequence> & _v, unordered_map<size_t, long> & _map);
    bool process(vector<msequence> & _v, map<size_t, size_t> &_map);
	bool pack();

	package get_package();
	void clean() { m_addrstream.str(""); }

};
#endif // !MSEQBESTSENDER_H




