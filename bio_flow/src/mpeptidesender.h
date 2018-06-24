#ifndef MPEPTIDESENDER_H
#define MPEPTIDESENDER_H
#include "stdafx.h"
#include <sstream>
#include "mdataconverter.h"

class msequence;

class mpeptideSender
{
private:
	stringstream m_pepstream;
	mdataConverter m_converter;

	size_t m_addr;
	size_t m_len;
	unsigned int m_lS;
	unsigned int m_lE;
	double m_dMH;

	size_t m_count;

public:
	mpeptideSender();
    ~mpeptideSender() {}

    void process(const msequence & _s, const size_t & _start, const size_t & _end, const double & _mh, map<size_t, size_t> & _map);
	void clear();
	bool pack();

	package get_package();
	void clean() { m_pepstream.str(""); }

};

#endif // !MPEPTIDESENDER_H
