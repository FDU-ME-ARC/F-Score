onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+bram_320_160_16384 -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.bram_320_160_16384 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {bram_320_160_16384.udo}

run -all

endsim

quit -force
