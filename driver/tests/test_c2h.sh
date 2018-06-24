
addr=0x00000000
size=0x0100


./reg_rw /dev/xdma0_user 0x2000 w 0x04 #reset MM2S c2h

./reg_rw /dev/xdma0_user 0x2000 w 0x01 #start MM2S c2h


#prepare c2h transfer (MM2S)
./reg_rw /dev/xdma0_user 0x2018 w $addr #write c2h addr
./reg_rw /dev/xdma0_user 0x2028 w 0x00100 #write c2h length and trigger dma

#Recv data
./dma_from_device -d /dev/xdma0_c2h_0 -f data/outputfile.bin -s $size


echo Now read the SR
./reg_rw /dev/xdma0_user 0x2004 w #read SR

echo DONE



