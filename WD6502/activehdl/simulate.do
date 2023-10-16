transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+T_MEMORY_MANAGER  -L xil_defaultlib -L secureip -O5 xil_defaultlib.T_MEMORY_MANAGER

do {T_MEMORY_MANAGER.udo}

run 1000ns

endsim

quit -force
