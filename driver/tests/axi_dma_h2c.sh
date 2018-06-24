
addr=0x00000000
size=0x10000


./reg_rw /dev/xdma0_user 0x2030 w 0x04 #reset S2MM h2c

./reg_rw /dev/xdma0_user 0x2030 w 0x01 #start S2MM h2c

#prepare h2c transfer (S2MM)
./reg_rw /dev/xdma0_user 0x2048 w $addr  #write h2c addr
./reg_rw /dev/xdma0_user 0x2058 w $size  #write h2c length and trigger dma

#Send data
./dma_to_device -d /dev/xdma0_h2c_0 -f data/datafile_32M.bin -s $size

echo Now read the SR
./reg_rw /dev/xdma0_user 0x2034 w #read SR

echo DONE



