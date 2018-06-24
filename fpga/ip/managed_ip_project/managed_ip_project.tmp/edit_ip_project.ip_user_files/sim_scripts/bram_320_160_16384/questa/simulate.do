onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib bram_320_160_16384_opt

do {wave.do}

view wave
view structure
view signals

do {bram_320_160_16384.udo}

run -all

quit -force
