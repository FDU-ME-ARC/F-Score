
size=0x0080


#Recv data
./dma_from_device -d /dev/xdma0_c2h_1 -f result/one_package.bin -s $size

echo DONE



