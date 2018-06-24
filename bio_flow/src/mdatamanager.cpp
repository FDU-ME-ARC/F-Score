#include "stdafx.h"
#include "mdatamanager.h"
#include <iostream>
#include <fstream>
mdataManager::mdataManager()
    :
      m_isStart(false),
      m_isProcess(false),
      m_isRefine(false),
      m_sequenceValid(true),
      m_seqaddrValid(true),
      m_spectraValid(true),
      m_peptideValid(true),
      m_seqbestValid(true),
      m_peptideLen(0),
      m_spectraAll(0),
      m_spectraCount(0)
{}

mdataManager::~mdataManager()
{
    if (m_isStart)
        end_all();
}

void mdataManager::init()
{
    m_isStart = false;
    m_isProcess = true;
    m_isRefine = false;

	m_sequenceValid = true;
    m_seqaddrValid = true;
    m_spectraValid = true;
	m_peptideValid = true;
	m_seqbestValid = true;

	m_seqTuid2AddrMap.clear();
	m_seqAddr2TuidMap.clear();

    m_peptideLen = 0;
    m_spectraAll = 0;
    m_spectraCount = 0;
}

void mdataManager::set_dev()
{
	init_dev();
}

void mdataManager::init_dev()
{

}

void mdataManager::process_sequence(const msequence & _ms)
{
	if (!m_sequenceValid)
		return;
    m_sequenceConvertor.process(_ms, m_seqTuid2AddrMap, m_seqAddr2TuidMap);
}

void mdataManager::process_spectra(const vector<mspectrum> & _vSpectra, const vector<vmiType> &_vmiType, const vector<vector<matchedpep > > &_mapepVecVec)
{
	if (!m_spectraValid)
		return;
    m_spectraConvertor.process(_vSpectra, _vmiType, _mapepVecVec, m_seqTuid2AddrMap);
   // std::cout << "spectra out" << std::endl;
#if 0
    size_t size = m_spectraConvertor.get_size();
    ofstream fout("spectra_out", ios::app | ios::binary);
    for (int i = 0; i < size; ++i)
    {
      fout << m_spectraConvertor.get_package(i);
    }
    fout.close();
#endif
}
/*
void mdataManager::process_peptide(const msequence & _s, const size_t & _start, const size_t & _end, const double & _mh)
{
	if (!m_peptideValid)
		return;
    m_peptideSender.process(_s, _start, _end, _mh, m_seqTuid2AddrMap);
}
*/
void mdataManager::process_seqbest(vector<msequence> & _ms)
{
    if (!m_seqbestValid)
        return;
    m_seqbestSender.process(_ms, m_seqTuid2AddrMap);
}

void mdataManager::send_config(const minitial & _minitial)
{
    std::vector<unsigned int > value(41, 0);
    unsigned int first_reg = 0;
    first_reg += _minitial.isotope_err?1:0;
    first_reg <<= 3;
    first_reg += _minitial.is_seq_mod?1:0;
    first_reg <<= 1;
    first_reg += _minitial.is_prompt?1:0;
    first_reg <<= 1;
    for (int i = 0; i < 6; ++i)
    {
        first_reg += _minitial.frag_type[5-i]?1:0;
	//std::cout << "minitial.frag_type[" << 5-i << "]=" << _minitial.frag_type[5-i] << std::endl;
        first_reg <<= 1;
    }
    first_reg += _minitial.is_ppm?1:0;
    first_reg <<= 1;
    first_reg += _minitial.is_dalton?1:0;
    first_reg <<= 3;
    first_reg += _minitial.mass_type?1:0;
    first_reg <<= 1;
    first_reg += _minitial.refine_spec_syn?1:0;

    value[0] = first_reg;
    value[1] = (unsigned int)(1048576 * _minitial.m_nt);
    value[2] = (unsigned int)(1048576 * _minitial.m_ct);
    value[3] = (unsigned int)(1048576 * _minitial.m_cleave_n);
    value[4] = (unsigned int)(1048576 * _minitial.m_cleave_c);
    value[5] = (unsigned int)(1048576 * _minitial.woe);
    value[6] = (unsigned int)(1048576 * _minitial.parent_err_minus);
    value[7] = (unsigned int)(1048576 * _minitial.parent_err_plus);
    value[8] = (unsigned int)(1048576 * _minitial.parent_err_minus_ppm);
    value[9] = (unsigned int)(1048576 * _minitial.parent_err_plus_ppm);
    value[10] = (unsigned int)(1048576 * _minitial.fullmod[26]);
    value[11] = (unsigned int)(1048576 * _minitial.fullmod[27]);
    value[12] = 0;
	value[13] = 0;
    for (int i = 0; i < 26; ++i)
    {
        value[14 + i] = (unsigned int)(1048576 * (_minitial.mod[i] + _minitial.fullmod[i]));
    }
    
    unsigned start_reg = 1;
    value[40] = first_reg + (start_reg << 17);
    
 //   for(int i = 0; i < value.size(); ++i)
 //   {
 //     std::cout << "value[" << i<< "]: "<< value[i] << std::endl; 
 //   }
    for (int i = 0; i < value.size()-1; ++i)
    {
	    dma_device.Write_Reg(i*4, value[i]);
    }
    dma_device.Write_Reg(0, value[40]);

}

void mdataManager::send_sequence()
{
    string str = m_sequenceConvertor.get_seq_package().str();
    //char * addr = (char *)str.c_str();
    char * addr ;
    posix_memalign((void**) &addr, 4096, str.size()+4096);
    memcpy(addr, (char *)str.c_str(), str.size());
    size_t size = str.size();
    //if (m_isStart)
    //{
	    //ylog("send_pr\nsize = %d\n",str.size());
	    dma_device.Write_DDR(addr, size, 0);
    //}
  //  cout << "cout seq: " << size << endl;
    //send("seq", addr, size);
    free(addr);
}

#if 0
void mdataManager::send_seqaddr()
{
    string str = m_sequenceConvertor.get_addr_package().str();
    char * addr = (char *)str.c_str();
    size_t size = str.size();
    if (m_isStart)
        m_dmadriver.send_seq_addr(addr, size);
    //send("addr", addr, size);
}
#endif

void mdataManager::send_onespectra()
{
    string str = m_spectraConvertor.get_package(m_spectraCount);
    char * addr;
    posix_memalign((void**) &addr, 4096, str.size()+4096);
    memcpy(addr, (char *)str.c_str(), str.size());
    size_t size = str.size();
    //run
    //m_dmadriver.run(m_peptideLen);
    if (m_isStart)
    {
	    //ylog("send_spec\nsize = %d\n",str.size());
	    dma_device.Write_Strm(addr, size);
    }
	
	free(addr);

        //m_dmadriver.send_onespectra(addr, size);
  //  std::cout << "sprectra: " << m_spectraCount << std::endl;
    //send("spe", addr, size);
}
/*
void mdataManager::send_peptide()
{
    string str = m_peptideSender.get_package().str();
    char * addr = (char *)str.c_str();
    size_t size = str.size();
    m_peptideLen = size;
    if (m_isStart)
        m_dmadriver.send_peptide(addr, size);
    //send("pep", addr, size);
}
*/
#if 0 
void mdataManager::send_seqbest()
{
    string str = m_seqbestSender.get_package().str();
    char * addr = (char *)str.c_str();
    size_t size = str.size();
    if (m_isStart)
        m_dmadriver.send_seq_addr(addr, size);
    //send(m_seqbestPath, m_seqbestSender.get_package());
}
#endif

vector<DotResult> mdataManager::parse_score()
{
    vector<DotResult> dotResult = m_parser.dotResult_Vector();
    if (dotResult.size() == 0)
      std::cout << "dotResult is Empty!!" <<std::endl; 
 //  for (int i = 0; i < dotResult.size(); ++i)
  //   std::cout << "get dotResult: " << i << std::endl;
    m_parser.dotResult_Vector().clear();
    ++ m_spectraCount;
    m_parser.reset_buffer();
    m_parser.continue_parse();
  // std::cout << "0xb0a0" << m_dmadriver.m_fdma->get_reg(0xb0a0)<< std::endl;
  // std::cout << "0xa000" << m_dmadriver.m_fdma->get_reg(0xa000)<< std::endl;
  // std::cout << "0xa03c" << m_dmadriver.m_fdma->get_reg(0xa03c)<< std::endl;
  //char cc;
   //std::cin >> cc;
   
    return dotResult;
}

bool mdataManager::open_dma()
{
    if (m_isStart)
        return false;
    //open
    //m_dmadriver.open();
    m_isStart = true;
}

void mdataManager::start_process()
{
    //recv
    //m_dmadriver.do_receive();
    //while(!m_dmadriver.is_recv());  
    //mparse
    m_parser.init_map(m_seqAddr2TuidMap);
    m_parser.init_buffer();
    //m_parser.start_thread();
    //if (!m_isProcess || !m_isStart)
        //return;
    //length
    m_spectraAll = m_spectraConvertor.get_size();
    m_spectraCount = 0;
}

void mdataManager::start_refine()
{
    if (!m_isRefine || !m_isStart)
        return;
    //start_refine();
}

void mdataManager::end_all()
{
    if (!m_isStart)
        return;
    //end mparser
    m_parser.finish_parse();
    //m_parser.m_thread.join();
    m_parser.recycle_buffer();
    //end receive
    //m_dmadriver.stop_receive();
    //end mdma
    //m_dmadriver.close();

    m_isStart = false;
}

bool mdataManager::spectra_finished()
{
	if(m_spectraCount % 1000 == 0)
		ylog("------------- spec progress: %d/%d ---------------\n", m_spectraCount, m_spectraAll);
    return !(m_spectraCount < m_spectraAll);
}

bool mdataManager::parse_ready()
{
    return m_parser.ready();
}

bool mdataManager::parse_end()
{
    return m_parser.get_end();
}

void mdataManager::send(string _path, char *_p, size_t _size)
{
    ofstream fin(_path.c_str(), ios::binary | ios::out);
    for(int i = 0; i < _size; ++i)
    {
        fin << _p[i];
    }
    fin.close();
}


int mdataManager::read_result()
{
	int length, value;
	char c;
	length = dma_device.Read_Strm(m_parser.m_tail, MAX_SIZE);
	//ylog("Read from stream: %d bytes\n", length);
	//value = dma_device.Read_Reg(0x38);
	//ylog("PackageNum: %d\n", value);

#if 0
	if((length > 0) && (length <= 128) && (value > 2))
	{
		ylog("It's the missed package of last spec, drop it!\n");
	//	length = dma_device.Read_Strm(m_parser.m_tail, MAX_SIZE);
	//	ylog("Read from stream: %d bytes\n", length);
	}
#endif

	while(length == 0)
	{
	//	ylog("length == 0, Wait and Read again!\n");
		//c = getchar();
		//if(c == 'x') return -1;
		
		length = dma_device.Read_Strm(m_parser.m_tail, MAX_SIZE);
	//	ylog("Read from stream: %d bytes\n", length);
	}
		
	m_parser.m_tail += length;
	value = dma_device.Read_Reg(0x38);
	//ylog("PackageNum: %d\n", value);
	if(length > (128*(value - 1)));
		//ylog("All package recieved!\n");
	else
	{
	//	ylog("One more package to recieve\n");
		length = dma_device.Read_Strm(m_parser.m_tail, MAX_SIZE);
	//	ylog("Read from stream: %d bytes\n", length);
	}
	m_parser.m_tail += length;
	
	if (m_parser.m_tail >= m_parser.m_end)
	{
	//	ylog("m_parser buffer full!");
	}
	return 0;
}
