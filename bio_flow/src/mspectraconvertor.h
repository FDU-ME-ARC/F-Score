#ifndef MSPECTRACONVERTOR_H
#define MSPECTRACONVERTOR_H

#include <sstream>
#include <vector>
#include "mdataconverter.h"
#if 1
#include "mspectrum.h"
#else
#include "testtype.h"
#endif
using std::vector;

class mspectraConvertor
{
private:
    vector<string> m_speVector;
    mdataConverter m_converter;

	unsigned long m_num;

public:
	mspectraConvertor();
    ~mspectraConvertor() {}

    bool process(const vector<mspectrum> & _vSpectra, const vector<vmiType> &_vmiType);
    bool pack_spectra(stringstream & _ss, const mspectrum & _spe, const vmiType &_vmi);
    string get_package(int id);
    unsigned int get_size() { return m_num; }
    void clean() { m_speVector.clear(); m_num = 0; }
};

#endif // !MSPECTRACONVERTOR_H


