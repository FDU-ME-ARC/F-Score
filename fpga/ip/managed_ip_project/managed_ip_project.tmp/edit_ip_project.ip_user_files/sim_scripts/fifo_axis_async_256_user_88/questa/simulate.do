onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fifo_axis_async_256_user_88_opt

do {wave.do}

view wave
view structure
view signals

do {fifo_axis_async_256_user_88.udo}

run -all

quit -force
