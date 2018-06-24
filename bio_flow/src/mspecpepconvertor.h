#ifndef MSPECPEPCONVERTOR_H
#define MSPECPEPCONVERTOR_H

#include <sstream>
#include <vector>
#include "mdataconverter.h"
#include "matchedpep.h"
using std::vector;

class msequence;

class mspecpepConvertor
{
private:
    vector<string> m_speVector;
    mdataConverter m_converter;
    unsigned long m_num;
   unsigned long m_num_spec;//
    //map<size_t, size_t> & _map;

public:
	mspecpepConvertor();
    ~mspecpepConvertor() {}

    bool process(const vector<mspectrum> & _vSpectra, const vector<vmiType> & _vmiType, const vector<vector<matchedpep > > &_mapepVecVec, map<size_t, size_t> & _seqTuid2AddrMap);
    bool pack_spectra(stringstream &_ss, const mspectrum &_spe, const vmiType &_vmi, const long &_matchNum);
    bool pack_peptide(stringstream &_ss, const vector<matchedpep> & _mapepVec, map<size_t, size_t> & _seqTuid2AddrMap);
    string get_package(int id);
    unsigned int get_size() { return m_num; }
   void clean() { m_speVector.clear(); m_num = 0; m_num_spec = 0; }//
//void clean() { m_speVector.clear(); m_num = 0; }//
};

#endif // !MSPECPEPCONVERTOR_H


