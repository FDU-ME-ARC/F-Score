
#include "ydevice.h"

Ydma_Device::Ydma_Device()
{
	Open_Device_Reg();
	Open_Device(&dev_ddr_tx, DEV_DDR_TX);
	Open_Device(&dev_ddr_rx, DEV_DDR_RX);
	Open_Device(&dev_strm_tx, DEV_STRM_TX);
	Open_Device(&dev_strm_rx, DEV_STRM_RX);
}

Ydma_Device::~Ydma_Device()
{
	Close_Device_Reg();
	Close_Device(dev_ddr_tx);
	Close_Device(dev_ddr_rx);
	Close_Device(dev_strm_tx);
	Close_Device(dev_strm_rx);
}

void Ydma_Device::Open_Device_Reg()
{
	if ((dev_reg = open(DEV_REG, O_RDWR | O_SYNC)) == -1) FATAL;
	//ylog("character device %s opened.\n", DEV_REG);
	map_base_reg = mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, dev_reg, 0);	
	if (map_base_reg == (void *) -1) FATAL;
	//ylog("Memory mapped at address %p.\n", map_base_reg);
	return;
}

void Ydma_Device::Close_Device_Reg()
{
	if (munmap(map_base_reg, MAP_SIZE) == -1) FATAL;
	close(dev_reg);
	return;
}

void Ydma_Device::Write_Reg(off_t offset, uint32_t value)
{
	*((uint32_t*) (map_base_reg + offset)) = value;
	return;
}

uint32_t Ydma_Device::Read_Reg(off_t offset)
{
	return *((uint32_t*)(map_base_reg + offset));
}

void Ydma_Device::Open_Device(int* pdev, const char* dev_name)
{
	if ((*pdev = open(dev_name, O_RDWR | O_SYNC)) == -1) FATAL;
	//ylog("character device %s opened.\n", dev_name);
	return;
}

void Ydma_Device::Close_Device(int dev)
{
	close(dev);
	return;
}

int Ydma_Device::Write_Strm(char* buf, int size)
{
	//ylog("Now writing to %s\n", DEV_STRM_TX);
	int remaining;
	int ret;
	int last_flag = 0;
	int cnt = 0;
	
	remaining = size;
	while(1)
	{
		if(remaining > MAX_SIZE)
		{
			//ylog("Size larger than %d bytes, split to write\n", MAX_SIZE);
			remaining -= MAX_SIZE;
			ret = write(dev_strm_tx, buf, MAX_SIZE);
			cnt += ret;
			assert(ret == MAX_SIZE);
			//ylog("Write %d bytes to AXI-Stream\n", ret);
		}
		else
		{
			//ylog("Last transfer: %d bytes\n", remaining);
			last_flag = 1;
			ret = write(dev_strm_tx, buf, remaining);
			cnt += ret;
			//ylog("Write %d bytes to AXI-Stream\n", ret);
		}
		if(last_flag) break;
	}

	return cnt;
}

int Ydma_Device::Read_Strm(char* buf, int size)
{
	//ylog("Now Reading from %s\n", DEV_STRM_RX);
	int ret;

	if(size > MAX_SIZE)
	{
		//ylog("Size is larger than %d bytes\n", MAX_SIZE);
//		size = MAX_SIZE;
	}

	ret = read(dev_strm_rx, buf, size);
	if ((ret > 0) && (ret < size))
		//ylog("Short read of %d bytes into a %d bytes buffer\n", ret, size);
	return ret;
}

int Ydma_Device::Write_DDR(char*buf, int size, uint32_t ddr_addr)
{
	//ylog("Now Writing %d bytes to DDR!\n", size);
	off_t base = DDR_DMA_H2C_BASE;
	int remaining = size;
	int size2write;
	char* buf2write = buf;
	int rc;
	int cnt = 0;
	
	ylog("dma_cr = 0x%x\n", Read_Reg(base+REG_CR));
	ylog("dma_sr = 0x%x\n", Read_Reg(base+REG_SR));

	Write_Reg(base+REG_CR, 0x04);
	ylog("After reset!\n");
	ylog("dma_cr = 0x%x\n", Read_Reg(base+REG_CR));
	ylog("dma_sr = 0x%x\n", Read_Reg(base+REG_SR));
	//for(int i=0;i<10;i++);

	Write_Reg(base+REG_CR, 0x01);
	ylog("After start!\n");
	ylog("dma_cr = 0x%x\n", Read_Reg(base+REG_CR));
	ylog("dma_sr = 0x%x\n", Read_Reg(base+REG_SR));

	while(remaining)
	{
		if (remaining > MAX_SIZE)
		{
			ylog("Size larger than %d bytes, split!\n", MAX_SIZE);
			size2write = MAX_SIZE;
			cnt += size2write;
			remaining -= MAX_SIZE;
		}
		else
		{
			ylog("Last transfer!\n");
			size2write = remaining;
			cnt += size2write;
			remaining = 0;
		}

		ylog("Write addr: %x\nWrite length: %d\n", ddr_addr, size2write);
		Write_Reg(base+REG_ADDR, ddr_addr);
		Write_Reg(base+REG_LENGTH, size2write);

		rc = write(dev_ddr_tx, buf2write, size2write);
		assert(rc == size2write);

		ylog("After write %d bytes!\n", size2write);
		ylog("dma_cr = 0x%x\n", Read_Reg(base+REG_CR));
		ylog("dma_sr = 0x%x\n", Read_Reg(base+REG_SR));
		
		ddr_addr += (off_t)size2write;
		buf2write += (off_t)size2write;
	}

	
	ylog("Totally write %d bytes\n", cnt);
	return cnt;
}

int Ydma_Device::Read_DDR(char*buf, int size, uint32_t ddr_addr)
{
	ylog("Now Reading %d bytes from DDR!\n", size);
	off_t base = DDR_DMA_C2H_BASE;
	int remaining = size;
	int size2read;
	char* buf2read = buf;
	int rc;
	int cnt = 0;
	
	ylog("dma_cr = 0x%x\n", Read_Reg(base+REG_CR));
	ylog("dma_sr = 0x%x\n", Read_Reg(base+REG_SR));

	Write_Reg(base+REG_CR, 0x04);
	ylog("After reset!\n");
	ylog("dma_cr = 0x%x\n", Read_Reg(base+REG_CR));
	ylog("dma_sr = 0x%x\n", Read_Reg(base+REG_SR));
	//for(int i=0;i<10;i++);

	Write_Reg(base+REG_CR, 0x01);
	ylog("After start!\n");
	ylog("dma_cr = 0x%x\n", Read_Reg(base+REG_CR));
	ylog("dma_sr = 0x%x\n", Read_Reg(base+REG_SR));

	while(remaining)
	{
		if (remaining > MAX_SIZE)
		{
			//ylog("Size larger than %d bytes, split!\n", MAX_SIZE);
			size2read = MAX_SIZE;
			remaining -= MAX_SIZE;
		}
		else
		{
			//ylog("Last transfer!\n");
			size2read = remaining;
			remaining = 0;
		}

		Write_Reg(base+REG_ADDR, ddr_addr);
		Write_Reg(base+REG_LENGTH, size2read);

		rc = 0;
		while(!rc)
		{
			rc = read(dev_ddr_rx, buf2read, size2read);
			//if(!rc) ylog("Waiting for hw, read again\n");
			//if(rc) ylog("Actuall read %d bytes\n", rc);
		}
		//assert(rc == size2read);
		cnt += rc;

		//ylog("After read %d bytes!\n", size2read);
		//ylog("dma_cr = 0x%x\n", Read_Reg(base+REG_CR));
		//ylog("dma_sr = 0x%x\n", Read_Reg(base+REG_SR));
		
		ddr_addr += (off_t)size2read;
		buf2read += (off_t)size2read;
	}

	ylog("Totally read %d bytes\n", cnt);

	return cnt;
}


	







