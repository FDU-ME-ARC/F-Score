onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fifo_async_fwft_512_opt

do {wave.do}

view wave
view structure
view signals

do {fifo_async_fwft_512.udo}

run -all

quit -force
