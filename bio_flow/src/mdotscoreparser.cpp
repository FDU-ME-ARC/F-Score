#include "mdotscoreparser.h"
#include "ydma.h"
#include <iostream>
#include <fstream>
#include <cstring>
using std::cout;
using std::endl;

void DotResult::init()
{
	pro_num = 0;
	spec_num = 0;
	pep_start = 0;
	pep_end = 0;
	dotscore_total = 0;
	for (int i = 0; i < 6; ++i)
	{
		type[i] = false;
	}
	match_num_len = 0;
    frame_length = 0;
    ds_end = 0;
    miss_cleaves = 0;
    pep_mass = 0;
    for (int i = 0; i < 6; ++i)
	{
		ds_type[i] = 0;
	}
	for (int i = 0; i < 6; ++i)
	{
		match_num_type[i] = 0;
	}
	for (int i = 0; i < 30; ++i)
		for (int j = 0; j < 6; ++j)
		{
			match_num[i][j] = 0;
		}
}

void DotResult::show()
{
	cout << "pro_num = " << pro_num << endl;
	cout << "spec_num = " << spec_num << endl;
	cout << "pep_start = " << pep_start << endl;
	cout << "pep_end = " << pep_end << endl;
	cout << "dotscore_total = " << dotscore_total << endl;
#if 0
	for (int i = 0; i < 6; ++i)
	{
		cout << "type[" << i << "] = " << type[i] << endl;
	}
#endif
	cout << "match_num_len = " << match_num_len << endl;

    //cout << "frame_length = " << frame_length << endl;

    //cout << "ds_end = " << ds_end << endl;

    //cout << "miss_cleaves = " << miss_cleaves << endl;

    cout << "pep_mass = " << pep_mass << endl;

	for (int i = 0; i < 6; ++i)
	{
		cout << "ds_type[" << i << "] = " << ds_type[i] << endl;
	}

# if 0
	for (int i = 0; i < 6; ++i)
	{
		cout << "match_num_type[" << i << "] = " << match_num_type[i] << endl;
	}
	for (int i = 0; i < 30; ++i)
		for (int j = 0; j < 6; ++j)
			cout << "match_num[" << i << "][" << j << "] = " << match_num[i][j] << endl;
#endif
}

mdotscoreparser::mdotscoreparser()
	:
	m_buffer(NULL),
	m_end(NULL),
	m_head(NULL),
	m_tail(NULL),
	m_ds_len(0),
	m_len(0),
	m_type_len(0),
    tailzero_size(0),
    m_endFlag(false),
	m_isworking(false),
	m_allfinish(true),
	m_parsing_state(pronum)
{
	init_buffer();
	m_DotResult.init();
}

mdotscoreparser::~mdotscoreparser()
{
	recycle_buffer();
}

bool mdotscoreparser::init_buffer()
{
	if (m_buffer == NULL)
	{
		m_buffer = new char [buffer_size];
		m_head = m_tail = m_buffer;
		m_end = m_buffer + buffer_size;
		m_ds_len = 0;
		m_type_len = 0;
		m_len = 0;
        tailzero_size = 0;
        m_endFlag = false;
		return true;
	}
	return false;
}

void mdotscoreparser::init_state()
{
	m_parsing_state = pronum;
	m_DotResult_Vector.clear();
    m_isworking = true;
}

void mdotscoreparser::init_map(const map<size_t, size_t> & _map)
{
    m_Addr2Tuidmap = _map;
}

bool mdotscoreparser::push_ds(char* p, int length)
{
	if (m_tail + length  < m_end)
	{
		memcpy(m_tail, p, length);
		m_tail += length;
		return true;
	}
	else
		return false;
}

void mdotscoreparser::start_parse()
{
	//if (m_allfinish == false)
        //return;
	//int i = 0;
	m_allfinish = false;
    	init_state();
    //std::cout << "start parser" << std::endl;
	while (m_isworking)
	{
		//ylog("i = %d\n", i);
		parse_next();
	//	i++;
	}
	//ylog("Parser return!\n");
}

void mdotscoreparser::continue_parse()
{
	init_state();
}

void mdotscoreparser::reset_buffer()
{
	memset(m_head, 0, m_end - m_tail + 1);
	m_head = m_tail = m_buffer;
	m_ds_len = 0;
    m_len = 0;
    m_type_len = 0;
    tailzero_size = 0;
    m_endFlag = false;
	return;
}

void mdotscoreparser::recycle_buffer()
{
	if (m_buffer != NULL)
	{
		delete [] m_buffer;
		m_buffer = m_end = m_tail = m_head = NULL;
		m_ds_len = 0;
        m_len = 0;
        m_type_len = 0;
        tailzero_size = 0;
        m_endFlag = false;
	}
	return;
}

unsigned int mdotscoreparser::get_nextsize()
{
	if (m_parsing_state == pronum)
		return pronum_size;
	else if (m_parsing_state == specnum)
		return specnum_size;
	else if (m_parsing_state == peps)
		return peps_size;
	else if (m_parsing_state == pepe)
		return pepe_size;
	else if (m_parsing_state == dstotal)
		return dstotal_size;
	else if (m_parsing_state == type)
		return type_size;
    else if (m_parsing_state == number)
        return number_size;
    else if (m_parsing_state == length)
        return length_size;
    else if (m_parsing_state == end)
        return end_size;
	else if (m_parsing_state == reverse)
		return reverse_size;
    else if (m_parsing_state == cleaves)
        return cleaves_size;
    else if (m_parsing_state == pepmass)
        return pepmass_size;
	else if (m_parsing_state == dstype)
		return dstype_size * m_type_len;
	else if (m_parsing_state == mntype)
		return mntype_size * m_type_len;
	else if (m_parsing_state == mnnum)
		return mnnum_size * m_len;
    else if (m_parsing_state == tailzero)
        return tailzero_size;
	else //error
	{
		return 0;
	}
}

bool mdotscoreparser::need_update()
{
	
	return ((m_tail - m_head) >= get_nextsize() );
}

void mdotscoreparser::parse_next()
{
	//cout << "get_end" << get_end() << endl;
	if (m_isworking)
		if (need_update())
		{
            //cout << "m_head: " << (int)m_head << endl;
            //cout << "parse_state: " << m_parsing_state << endl;
            //cout << "get_nextsize: " << get_nextsize() << endl;
			if (m_parsing_state == pronum)
				parse_pro_num(m_head);
			else if (m_parsing_state == specnum)
				parse_spec_num(m_head);
			else if (m_parsing_state == peps)
				parse_pep_s(m_head);
			else if (m_parsing_state == pepe)
				parse_pep_e(m_head);
			else if (m_parsing_state == dstotal)
				parse_ds_total(m_head);
			else if (m_parsing_state == type)
				parse_type(m_head);
            else if (m_parsing_state == number)
                parse_number(m_head);
            else if (m_parsing_state == length)
                parse_length(m_head);
            else if (m_parsing_state == end)
                parse_end(m_head);
			else if (m_parsing_state == reverse)
                ;
            else if (m_parsing_state == cleaves)
                parse_cleaves(m_head);
            else if (m_parsing_state == pepmass)
                parse_pep_mass(m_head);
	    else if (m_parsing_state == dstype)
	    {
	      for (int i = 0; i < m_type_len; ++i)
		parse_ds_type(m_head + i * dstype_size, i);
	    }
	    else if (m_parsing_state == mntype)
	    {
	      for (int i = 0; i < m_type_len; ++i)
		parse_mn_type(m_head + i * mntype_size, i);
	    }
	    else if (m_parsing_state == mnnum)
	    {
	      for (int i = 0; i < m_len; ++i)
		parse_mn_num(m_head + i * mnnum_size, i);
	    }
            else if (m_parsing_state == tailzero)
                parse_tailzero();
			else
				;
			m_head += get_nextsize();
            if (m_parsing_state == tailzero)
				m_parsing_state = pronum;
			else
				m_parsing_state = State(m_parsing_state + 1);
		}
		else //not to update
		{
			//ylog("not to update, stop_parse!\n");
			m_isworking = 0;
			return;
		}
	else // not working
	{
		return;
	}
	return;
}

void mdotscoreparser::parse_single_ds(char * head)
{
	m_DotResult.init();
	m_ds_len = 0;
	char * pt = head;
	parse_pro_num(pt);
	pt += pronum_size;
 	parse_spec_num(pt);
 	pt += specnum_size;
	parse_pep_s(pt);
	pt += peps_size;
	parse_pep_e(pt);
	pt += pepe_size;
	parse_ds_total(pt);
	pt += dstotal_size;
	parse_type(pt);
	pt += type_size;
    parse_number(pt);
    pt += number_size;
	pt += reverse_size;
	for (int i = 0; i < 6; ++i)
	{
		if (m_DotResult.type[i])
		{
			parse_ds_type(pt, i);
			pt += dstype_size;
		}
	}
	for (int i = 0; i < 6; ++i)
	{
		if (m_DotResult.type[i])
		{
			parse_mn_type(pt, i);
			pt += mntype_size;
		}
	}
	for (int i = 0; i < m_len; ++i)
	{
		parse_mn_num(pt, i);
		pt += mnnum_size;
	}
	m_ds_len = pt - m_head;
}

void mdotscoreparser::parse_pro_num(char * head, int length)
{
    m_DotResult.pro_num = 0;
    size_t tmp = 0;
	for (int i = 0; i < length; ++i)
	{
        tmp <<= 8;
        tmp += (unsigned char) head[i];
	}
    m_DotResult.pro_num = m_Addr2Tuidmap[tmp];
 #if 0
    ofstream fout;
    fout.open("pro_num",ios::app);
    fout << "pro num hard: " << tmp << "\tsoft: " << m_DotResult.pro_num << "\n";
    fout.close();
  #endif
}

void mdotscoreparser::parse_spec_num(char * head, int length)
{
    m_DotResult.spec_num = 0;
	for (int i = 0; i < length; ++i)
	{
		m_DotResult.spec_num <<= 8;
		m_DotResult.spec_num += (unsigned char) head[i];
	}
}

void mdotscoreparser::parse_pep_s(char * head, int length)
{
	m_DotResult.pep_start = 0;
	for (int i = 0; i < length; ++i)
	{
		m_DotResult.pep_start <<= 8;
		m_DotResult.pep_start += (unsigned char) head[i];
	}
}

void mdotscoreparser::parse_pep_e(char * head, int length)
{
	m_DotResult.pep_end = 0;
	for (int i = 0; i < length; ++i)
	{
		m_DotResult.pep_end <<= 8;
		m_DotResult.pep_end += (unsigned char) head[i];
	}
}

void mdotscoreparser::parse_ds_total(char * head, int length)
{
	size_t tmp = 0;
	for (int i = 0; i < length; ++i)
	{
		tmp <<= 8;
		tmp += (unsigned char) head[i];
	}
	m_DotResult.dotscore_total = tmp / 1048576.0;
}

void mdotscoreparser::parse_type(char * type)
{
	unsigned int mux = 0x1;
	m_type_len = 6;
	for (int i = 0; i < 6; ++i)
	{
		m_DotResult.type[5 - i] = mux  & (* type);
		mux <<= 1;
	}
}

void mdotscoreparser::parse_number(char * number)
{
    //m_DotResult.match_num_len = 0;
    m_DotResult.match_num_len = (* number);
    m_len = (unsigned char) (* number);
}

void mdotscoreparser::parse_length(char * head)
{
    //m_DotResult.frame_length = 0;
    m_DotResult.frame_length = (* head);
    m_ds_len = (* head) * 32;
    if (m_ds_len == 32)
      m_type_len = 0;
    tailzero_size = m_ds_len - pronum_size \
            - specnum_size - peps_size - pepe_size \
            - dstotal_size - type_size - number_size \
            - length_size - end_size - reverse_size \
            - cleaves_size - pepmass_size \
            - dstype_size * m_type_len - mntype_size * m_type_len \
            - mnnum_size * m_len;
    //cout << "tailzero = " << tailzero_size << endl;
}

void mdotscoreparser::parse_end(char * head)
{
    if ((* head) == 0)
        m_endFlag = false;
    else
        m_endFlag = true;
}

void mdotscoreparser::parse_cleaves(char * head, int length)
{
    m_DotResult.miss_cleaves = 0;
    for (int i = 0; i < length; ++i)
    {
        m_DotResult.miss_cleaves <<= 8;
        m_DotResult.miss_cleaves += head[i];
    }
}

void mdotscoreparser::parse_pep_mass(char * head, int length)
{
    size_t tmp = 0;
    for (int i = 0; i < length; ++i)
    {
        tmp <<= 8;
        tmp += (unsigned char) head[i];
    }
    m_DotResult.pep_mass = tmp / 1048576.0;
}

void mdotscoreparser::parse_ds_type(char * head, int id, int length)
{
	size_t tmp = 0;
	for (int i = 0; i < length; ++i)
	{
		tmp <<= 8;
		tmp += (unsigned char) head[i];
	}
	m_DotResult.ds_type[id] = tmp / 1048576.0;
}

void mdotscoreparser::parse_mn_type(char * head, int id, int length)
{
	m_DotResult.match_num_type[id] = 0;
	for (int i = 0; i < length; ++i)
	{
		m_DotResult.match_num_type[id] <<= 8;
		m_DotResult.match_num_type[id] += (unsigned char) head[i];
	}
}

void mdotscoreparser::parse_mn_num(char * head, int id, int length) 
{
	size_t tmp = 0;
	unsigned int mux = 0x3f;
	for (int i = 0; i < length; ++i)
	{
		tmp <<= 8;
		tmp += (unsigned char) head[i];
	}
	for (int i = 0; i < 6; ++i)
	{
		m_DotResult.match_num[id][i] = mux & tmp;
		tmp >>= 8;
	}
}

void mdotscoreparser::parse_tailzero()
{

    //cout << "it is end" << endl;
    m_DotResult_Vector.push_back(m_DotResult);
    m_DotResult.init();
    //cout << "it is the " <<  m_DotResult_Vector.size() << "ds" << endl;
    m_isworking = !m_endFlag;
	
    if(m_head == m_tail) 
    {
	    //ylog("m_head == m_tail, stop parse!\n");
	    m_isworking = 0;
    }

}
