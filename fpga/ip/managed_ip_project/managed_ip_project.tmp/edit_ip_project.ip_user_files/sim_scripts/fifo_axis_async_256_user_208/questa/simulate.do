onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fifo_axis_async_256_user_208_opt

do {wave.do}

view wave
view structure
view signals

do {fifo_axis_async_256_user_208.udo}

run -all

quit -force
