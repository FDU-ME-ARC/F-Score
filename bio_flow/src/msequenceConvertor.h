#ifndef MSEQUENCECONVERTOR_H
#define MSEQUENCECONVERTOR_H
#include "stdafx.h"
#include <map>

#include <sstream>
#include "mdataconverter.h"

class msequenceConvertor
{
private:
	
	stringstream m_seqstream;
	stringstream m_addrstream;
	mdataConverter m_converter;
	
	size_t m_tUid;
	long m_size;
	long m_addr;
	bool m_constract;

public:
	msequenceConvertor();
    ~msequenceConvertor() {}
    //bool process(const vector<msequence> & _ms, unordered_map<size_t, long> & _map);
    bool process(const msequence & _ms, map<size_t, size_t> & _id2addrmap, map<size_t, size_t> & _addr2idmap);
    bool pack_seq(const string & _s);
	bool pack_addr(const long & _addr, const long &_l);
	package get_seq_package();
	package get_addr_package();
	
	void clean_seq() { m_seqstream.str(""); }
	void clean_addr() { m_addrstream.str(""); }
};

#endif // !MSEQUENCECONVERTOR_H
