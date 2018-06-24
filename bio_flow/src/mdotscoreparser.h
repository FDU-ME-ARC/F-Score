#ifndef MDOTSCOREPARSER_H
#define MDOTSCOREPARSER_H
#include <stdio.h>
#include <vector>
#include <map>
//#include <boost/thread.hpp>
#include <iostream>
#include "stdafx.h"
using std::vector;
using std::map;

struct DotResult
{
    size_t pro_num;//32
    size_t spec_num;//32
    unsigned int pep_start;//16
    unsigned int pep_end;//16
    double dotscore_total;//64
    bool type[6];//8
    unsigned int match_num_len;//8
    unsigned int frame_length;//8
    unsigned int ds_end;//8
    //reverse//8
    unsigned long miss_cleaves;//16
    float pep_mass;//40
	double ds_type[6];
	unsigned int match_num_type[6];
	unsigned int match_num[30][6];

	void init();
	void show();
};

class mdotscoreparser
{
public:
	//enum type {z = 0, y, x, c, b, a};
	static const size_t page_size = 4096;
	static const size_t buffer_size = 600 * page_size;

	static const int pronum_size = 4;
	static const int specnum_size = 4;
	static const int peps_size = 2;
	static const int pepe_size = 2;
	static const int dstotal_size = 8;
	static const int type_size = 1;
    static const int number_size = 1;
    static const int length_size = 1;
    static const int end_size = 1;
    static const int reverse_size = 1;
    static const int cleaves_size = 2;
    static const int pepmass_size = 5;
	static const int dstype_size = 8;
	static const int mntype_size = 2;
	static const int mnnum_size = 6;

public:
	mdotscoreparser();
	~mdotscoreparser();
	bool init_buffer();
	void init_state();
    void init_map(const map<size_t, size_t> & _map);
	bool push_ds(char* p, int length);
	void start_parse();
    //void start_thread() {m_thread = boost::thread(boost::bind(&mdotscoreparser::start_parse, this)); }
	void continue_parse();
	void reset_buffer();
	void recycle_buffer();
	vector <DotResult> & dotResult_Vector() {return m_DotResult_Vector;}
    bool ready() { return m_isworking; }
    bool get_end() { return !m_isworking; }
	void finish_parse() { m_allfinish = true;}
	
private:
	unsigned int get_nextsize();
public:
	bool need_update();
//private:
    void parse_next();
	
	void parse_single_ds(char * head);//for test

	void parse_pro_num(char * head, int length = pronum_size);
 	void parse_spec_num(char * head, int length = specnum_size);
	void parse_pep_s(char * head, int length = peps_size);
	void parse_pep_e(char * head, int length = pepe_size);
	void parse_ds_total(char * head, int length = dstotal_size);
	void parse_type(char * type);
    void parse_number(char * number);
    void parse_length(char * head);
    void parse_end(char * head);
    void parse_cleaves(char * head, int length = cleaves_size);
    void parse_pep_mass(char * head, int length = pepmass_size);
	void parse_ds_type(char * head, int id, int length = dstype_size);
	void parse_mn_type(char * head, int id, int length = mntype_size);
	void parse_mn_num(char * head, int id, int length = mnnum_size);
    void parse_tailzero();

//private:
	char * m_buffer;
	char * m_end;
	char * m_head;
	char * m_tail;
    map<size_t, size_t> m_Addr2Tuidmap;

	vector <DotResult> m_DotResult_Vector;
	bool m_isworking;
	bool m_allfinish;
	DotResult m_DotResult;
    unsigned long miss_cleaves;//
	unsigned int m_ds_len;
	unsigned int m_len;
	unsigned int m_type_len;
    unsigned int tailzero_size;
    bool m_endFlag;
    enum State { pronum = 0, specnum, peps, pepe, dstotal, type, number, length, end, reverse, cleaves, pepmass, dstype, mntype, mnnum, tailzero};
	State m_parsing_state;
public:
    //boost::thread m_thread;
};

#endif // !MDOTSCOREPARSER_H
