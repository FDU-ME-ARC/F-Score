#include "stdafx.h"
#include "mspectraconvertor.h"
#include <iostream>

mspectraConvertor::mspectraConvertor()
	:m_num(0)
{}

bool mspectraConvertor::process(const vector<mspectrum> & _vSpectra, const vector<vmiType> & _vmiType)
{
    m_num = 0;
    for (int i = 0; i < _vSpectra.size();++i)
	{
        stringstream ss;
        pack_spectra(ss, _vSpectra[i], _vmiType[i]);
        m_speVector.push_back(ss.str());
		++m_num;
	}
	return true;
}

bool mspectraConvertor::pack_spectra(stringstream &_ss, const mspectrum & _spe, const vmiType &_vmi)
{
    _ss << m_converter.int2string(m_num, 32);
    _ss << m_converter.int2string(_vmi.size(), 16);
    std::cout << "vmi[" << m_num << "]=" << _vmi.size() << std::endl;
    _ss << m_converter.q20(_spe.m_dMH, 40);
    _ss << char(_spe.m_fZ);
	for (int i = 0; i < 4; ++i)
        _ss << char(0);
    //for (auto & mi : _vmi)
    for (int i = 0; i < _vmi.size(); i++)
	{
	_ss << m_converter.int2string(_vmi[i].m_lM, 24);
        _ss << m_converter.q20(_vmi[i].m_fI, 40);
	}
	return true;
}

string mspectraConvertor::get_package(int id)
{
    //m_speVector[id] += m_converter.add_tail(m_speVector[id].size());
	/*string * str = & m_spestream.str();
	package spe;
	spe.addr = str;
	spe.size = m_spestream.str().size();
    */return m_speVector[id];
}
