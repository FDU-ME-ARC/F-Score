#ifndef MDATAMANAGER_H
#define MDATAMANAGER_H

#include "stdafx.h"
#include <cmath>
#include <float.h>
#include <algorithm>
//#include <unordered_map>
#include "msequenceConvertor.h"
//#include "mspectraconvertor.h"
//#include "mpeptidesender.h" 
#include "mspecpepconvertor.h"
#include "mseqbestsender.h"

//#include "mdmadriver.h"
#include "ydma.h"
#include "mdotscoreparser.h"


#include "minitial.h"

class mdataManager
{
public:
	mdataManager();
    ~mdataManager();

	void init();
	void set_dev();
	void init_dev();

    void process_sequence(const msequence & _ms);
    void process_spectra(const vector<mspectrum> & _vSpectra, const vector<vmiType> &_vmiType, const vector<vector<matchedpep > > &_mapepVecVec);
    //void process_peptide(const msequence & _s, const size_t & _start, const size_t & _end, const double & _mh);
    void process_seqbest(vector<msequence> & _ms);
	
    void send_config(const minitial & _minitial);
    void send_sequence();
	void send_seqaddr();
    void send_onespectra();//need to fixed
	//void send_peptide();
	void send_seqbest();

    vector<DotResult> parse_score();
    bool open_dma();
    void start_process();
    void start_refine();//need to update
    void end_all();
    int read_result();//ymc`

    bool spectra_finished();
    bool parse_ready();
    bool parse_end();

    void send(string _path, char *_p, size_t _size);

//private:
    //convertor
    msequenceConvertor m_sequenceConvertor;
    mspecpepConvertor m_spectraConvertor;
    //mpeptideSender m_peptideSender;
    mseqbestSender m_seqbestSender;
//private:
	//db
    //std::unordered_map<size_t, long> m_sequenceAddrMap; // sequence tUid -> addr
    map<size_t, size_t> m_seqTuid2AddrMap; // sequence tUid -> addr
    map<size_t, size_t> m_seqAddr2TuidMap; // sequence addr -> tUid
	//signal
    bool m_isStart;
    bool m_isProcess;
	bool m_isRefine;

	bool m_sequenceValid;
    bool m_seqaddrValid;
	bool m_spectraValid;
	bool m_peptideValid;
	bool m_seqbestValid;

	//dma
	//mdmaDriver m_dmadriver;
	Ydma_Device dma_device;//ymc
	mdotscoreparser m_parser;

    //spectra count
    size_t m_peptideLen;
    size_t m_spectraAll;
    size_t m_spectraCount;

};
#endif // !MDATAMANAGER_H



