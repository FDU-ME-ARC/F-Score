#include "stdafx.h"
#include "mspecpepconvertor.h"
#include <cmath>
#include <iostream>

mspecpepConvertor::mspecpepConvertor()
	:m_num(0),
       m_num_spec(0)
{}

bool mspecpepConvertor::process(const vector<mspectrum> & _vSpectra, const vector<vmiType> & _vmiType, const vector<vector<matchedpep > > &_mapepVecVec, map<size_t, size_t> & _seqTuid2AddrMap)
{
    m_num = 0;
    m_num_spec = 0;//
    m_speVector.reserve(_vSpectra.size());
    //std::cout << "in spec pack area: " << std::endl;
    //std::cout << "spec_size: " << _vSpectra.size() << std::endl;
    //std::cout << "pep_size: " << _mapepVecVec.size() << std::endl;
    //std::cout << "_vmiType_size: " << _vmiType.size() << std::endl;
    for (int i = 0; i < _vSpectra.size();++i)
	{ 
        if (_mapepVecVec.size() > i && _mapepVecVec[i].size() > 0)
        {
            stringstream ss;
            pack_spectra(ss, _vSpectra[i], _vmiType[i], _mapepVecVec[i].size());
            pack_peptide(ss, _mapepVecVec[i], _seqTuid2AddrMap);
            m_speVector.push_back(ss.str());
	    ++m_num;
	//    std::cout << "spec: "<< i << std::endl;
	//    std::cout << "pep: " <<  _mapepVecVec[i].size() << std::endl;
        }
        ++m_num_spec;//
	}
	return true;
}

bool mspecpepConvertor::pack_spectra(stringstream &_ss, const mspectrum &_spe, const vmiType &_vmi, const long &_matchNum)
{
    _ss << m_converter.int2string(m_num_spec, 32);//
    _ss << m_converter.int2string(_vmi.size(), 16);
    _ss << char(_spe.m_fZ);
    _ss << m_converter.int2string(_matchNum, 32);
    _ss << m_converter.add_tail(_ss.str().size(), 32);
    for (auto & mi : _vmi)
	{
        _ss << m_converter.int2string(mi.m_lM, 24);
        _ss << m_converter.q20(mi.m_fI, 40);
	}
    _ss << m_converter.add_tail(_ss.str().size(), 32);
	return true;
}

bool mspecpepConvertor::pack_peptide(stringstream &_ss, const vector<matchedpep> & _mapepVec, map<size_t, size_t> &_seqTuid2AddrMap)
{
    for (auto i : _mapepVec)
    { 
      _ss << m_converter.int2string(_seqTuid2AddrMap[i.m_protein_id], 32);
	    _ss << m_converter.int2string(i.m_protein_len, 16);
	    _ss << m_converter.q20(i.m_pep_dMH, 40);
        _ss << m_converter.int2string(i.m_pep_lS, 16);
	    _ss << m_converter.int2string(i.m_pep_lE, 16);
        
        unsigned char c = 0;
        if (i.is_c) c++;
        c <<= 1;
        if (i.is_n) c++;
        c <<= 1;
        if (i.term_c) c++;
        c <<= 1;
        if (i.term_n) c++;
        _ss << c;
        _ss << m_converter.int2string(i.pep_missedcleaves, 16);
        _ss << m_converter.q20(i.mod_left, 32);
        _ss << m_converter.q20(i.mod_right, 32);
        _ss << m_converter.add_tail(_ss.str().size(), 32);
    }
	return true;
}
string mspecpepConvertor::get_package(int id)
{
    return m_speVector[id];
}
