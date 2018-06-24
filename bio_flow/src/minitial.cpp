#include "stdafx.h"
#include "minitial.h"

minitial::minitial()	
{
	refine_spec_syn = 0;
	mass_type = 0;
	is_dalton = 0;
	is_ppm = 0;
	is_prompt = 0;
	is_seq_mod = 0;
	isotope_err = 0;
	start = 0;
	m_nt = 0;
	m_ct = 0;
	m_cleave_n = 0;
	m_cleave_c = 0;
	woe = 0;
	parent_err_minus = 0;
	parent_err_plus = 0;
        parent_err_minus_ppm = 0;
	parent_err_plus_ppm = 0;
	for (int i = 0; i < 6; ++i)
	{
		frag_type[i] = 0;
	}
	for (int i = 0; i < 28; ++i)
	{
		mod[i] = 0;
	}
	for (int i = 0; i < 28; ++i)
	{
		fullmod[i] = 0;
	}
	for (int i = 0; i < 26; ++i)
	{
		prompt[i] = 0;
	}
	for (int i = 0; i < 26; ++i)
	{
		seqmod[i] = 0;
	}
}


















