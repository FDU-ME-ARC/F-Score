#include "stdafx.h"
#include "mpeptidesender.h"


mpeptideSender::mpeptideSender()
	:m_count(0)
{

}

void mpeptideSender::process(const msequence & _s, const size_t & _start, const size_t & _end, const double & _mh, map<size_t, size_t> &_map)
{
	//clear();
	m_addr = _map[_s.m_tUid];
	m_len = _s.m_strSeq.length();
	m_dMH = _mh;
	m_lS = _start;
	m_lE = _end;
	pack();
}

void mpeptideSender::clear()
{
	m_addr = 0;
	m_len = 0;
	m_lS = 0;
	m_lE = 0;
	m_dMH = 0.0;
}

bool mpeptideSender::pack()
{
	m_pepstream << m_converter.int2string(0, 8);
	m_pepstream << m_converter.q20(m_dMH, 40);
	m_pepstream << m_converter.int2string(m_addr, 32);
	m_pepstream << m_converter.int2string(m_len, 16);
	m_pepstream << m_converter.int2string(m_lS, 16);
	m_pepstream << m_converter.int2string(m_lE, 16);
	return true;
}

package mpeptideSender::get_package()
{
	m_pepstream << m_converter.add_tail(m_pepstream.str().size());
	/*package pep;
	string *str = & m_pepstream.str();
	pep.addr = str;
	pep.size = m_pepstream.str().size();
	*/return m_pepstream;
}




