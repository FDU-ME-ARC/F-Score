#ifndef YDEVICE_H
#define YDEVICE_H

#include "ydma.h"

class Ydma_Device
{
public:
	Ydma_Device();
	~Ydma_Device();
	void Open_Device_Reg();
	void Close_Device_Reg();
	void Open_Device(int* pdev, const char* dev_name);
	void Close_Device(int dev);
	
	void Write_Reg(off_t offset, uint32_t value);
	uint32_t Read_Reg(off_t offset);

	int Write_Strm(char* buf, int size);
	int Read_Strm(char* buf, int size);	

	int Write_DDR(char* buf, int size, uint32_t ddr_addr);
	int Read_DDR(char* buf, int size, uint32_t ddr_addr);

private:
	int dev_reg;
	void *map_base_reg;
	int dev_ddr_tx;
	int dev_ddr_rx;
	int dev_strm_tx;
	int dev_strm_rx;
};

#endif
