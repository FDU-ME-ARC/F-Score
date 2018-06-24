#include "stdafx.h"
#include "mseqbestsender.h"

mseqbestSender::mseqbestSender()
	:m_addr(0),
	m_length(0)
{}

//bool mseqbestSender::process(vector<msequence> & _v, unordered_map<size_t, long> & _map)
bool mseqbestSender::process(vector<msequence> & _v, map<size_t, size_t> & _map)
{
	for (auto & mseq : _v)
	{
		string seq = mseq.m_strSeq;
		size_t id = mseq.m_tUid;
        map<size_t, size_t>::iterator iter = _map.find(id);
		if (iter == _map.end())
			continue;
		m_addr = iter->second;
		m_length = seq.length();
		pack();
	}
	return true;
}

bool mseqbestSender::pack()
{
	m_addrstream << m_converter.int2string(m_addr, 32);
	m_addrstream << m_converter.int2string(m_length, 16);
	m_addrstream << m_converter.int2string(0, 16);
	return true;
}
package mseqbestSender::get_package()
{
	m_addrstream << m_converter.add_tail(m_addrstream.str().size());
	/*package seq;
	string *str = & m_addrstream.str();
	seq.addr = str;
	seq.size = m_addrstream.str().size();
	*/return m_addrstream;

}
