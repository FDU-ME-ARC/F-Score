#ifndef MATCHEDPEP_H
#define MATCHEDPEP_H

struct matchedpep
{
	size_t m_protein_id;
	size_t m_protein_len;
	unsigned int m_pep_lS;
	unsigned int m_pep_lE;
	double m_pep_dMH;      //与你原来定义一致，除了名字
	
    bool is_c;
	bool is_n;
	bool term_c;
	bool term_n; //这四个需要合成8bit的pep_judge再下发
	long pep_missedcleaves;
	float mod_left;
	float mod_right;
		
};

#endif // MATCHEDPEP_H
