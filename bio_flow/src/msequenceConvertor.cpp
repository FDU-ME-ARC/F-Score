#include "stdafx.h"
#include "msequenceConvertor.h"

msequenceConvertor::msequenceConvertor()
	: m_tUid(0),
	m_size(0),
	m_addr(0),
	m_constract(false)
{}

//bool msequenceConvertor::process(const vector<msequence> & _ms, unordered_map<size_t, long> & _map)
bool msequenceConvertor::process(const msequence & _ms, map<size_t, size_t> & _id2addrmap, map<size_t, size_t> & _addr2idmap)
{
	string seq;
		seq = _ms.m_strSeq;
		if (!m_converter.compress(seq, int('A' - 1)))
			;//return false;
		if (!pack_seq(seq))
			;// return false;
		if (!pack_addr(m_addr, seq.length()))
			;// return false;
	m_tUid = _ms.m_tUid;
        _id2addrmap.insert(map<size_t, size_t>::value_type(m_tUid, m_addr));
        _addr2idmap.insert(map<size_t, size_t>::value_type(m_addr, m_tUid));
	m_addr += m_size;
	return true;

}

bool msequenceConvertor::pack_seq(const string &_s)
{
	string cstr = _s;

	m_seqstream << cstr;
    //string end;
    //m_seqstream << end;
	unsigned int count = _s.length();
	int ByteNum = 0;
	ByteNum = 64 - count % 64;
	if (ByteNum == 64)
		ByteNum = 0;
	for (int j = 0; j < ByteNum; ++j)
		m_seqstream << char(0);
	m_size = (count + ByteNum);
	return true;
}

bool msequenceConvertor::pack_addr(const long & _addr, const long & _l)
{
	m_addrstream << m_converter.int2string(_addr, 32);
	m_addrstream << m_converter.int2string(_l, 16);
	m_addrstream << m_converter.int2string(0, 16);
	return true;
}

package msequenceConvertor::get_seq_package()
{
	/*package seq;
	string *str = & m_seqstream.str();
	seq.addr = str;
	seq.size = m_seqstream.str().size();
	*/return m_seqstream;
}

package msequenceConvertor::get_addr_package()
{
	m_addrstream << m_converter.add_tail(m_addrstream.str().size());
	/*package seq;
	string *str = & m_addrstream.str();
	seq.addr = str;
	seq.size = m_addrstream.str().size();
	*/return m_addrstream;
}
