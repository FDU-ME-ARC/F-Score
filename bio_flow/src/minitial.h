#ifndef MINITIAL_H
#define MINITIAL_H

class minitial
{
   public:
	minitial();
//	~minitial();
	
	bool refine_spec_syn;
	bool mass_type;
	bool is_dalton;
	bool is_ppm;
	bool frag_type[6];
	bool is_prompt;
	bool is_seq_mod;
	bool isotope_err;
	bool start;
	float m_nt;
	float m_ct;
	float m_cleave_n;
	float m_cleave_c;
	float woe;
	float parent_err_minus;
	float parent_err_plus;
        float parent_err_minus_ppm;
	float parent_err_plus_ppm;
	float mod[26];
	float fullmod[28];
	float prompt[26];
	float seqmod[26];
   
};

#endif // MINITIAL_H

