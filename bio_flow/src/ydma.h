#ifndef YDMA_H
#define YDMA_H

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <string.h> //for strerror
#include <unistd.h> //for close
#include <stdint.h> //for uint32_t
#include <sys/types.h>
#include <sys/mman.h>
#include <assert.h>

#include <fstream>
using namespace std;

#include "ydevice.h"

#define FATAL do { fprintf(stderr, "Error at line %d, file %s (%d) [%s]\n", __LINE__, __FILE__, errno, strerror(errno)); exit(1); } while(0)

#define LOG_DEBUG

#ifdef LOG_DEBUG
#define ylog(x...) printf(x)
#else
#define ylog(x...) 
#endif

#define MAP_SIZE (5*4096UL)
#define MAP_MASK (MAP_SIZE - 1)

#define DEV_REG "/dev/xdma0_user"
#define DEV_DDR_TX "/dev/xdma0_h2c_0"
#define DEV_DDR_RX "/dev/xdma0_c2h_0"
#define DEV_STRM_TX "/dev/xdma0_h2c_1"
#define DEV_STRM_RX "/dev/xdma0_c2h_1"

#define MAX_SIZE 0x100000 
#define LENGTH 0x1000  //for test_main.cpp

#define DDR_DMA_C2H_BASE 0X2000
#define DDR_DMA_H2C_BASE 0X2030
#define REG_CR 0x00
#define REG_SR 0x04
#define REG_ADDR 0x18
#define REG_LENGTH 0x28












#endif
