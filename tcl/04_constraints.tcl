################################################################################
# Script: 04_constraints.tcl
# Descripción: Crea y aplica constraints XDC para el diseño
# Autor: FPGA Senior Engineer
# Fecha: 2024
# Vivado: 2022.2
################################################################################

# Verificar que el proyecto esté abierto
if {![info exists ::env(VIVADO_PROJECT_NAME)]} {
    set proj_name "kria_k26_gty_loopback"
    open_project ./${proj_name}/${proj_name}.xpr
}

# Crear archivo de constraints
set constraints_file "./constraints/gty_loopback.xdc"

# Constraints para Kria K26
set constraints_content {
################################################################################
# Constraints file for GTY Loopback on Kria K26
# Author: FPGA Senior Engineer
# Date: 2024
################################################################################

# Clock constraints
# Ajustar según los relojes disponibles en el board
# Ejemplo para reloj diferencial de 200 MHz (ajustar según board)
create_clock -period 5.000 -name sysclk [get_ports sysclk_p]

# Clock groups
set_clock_groups -asynchronous \
    -group [get_clocks sysclk] \
    -group [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ "*gtwiz_userclk_tx_usrclk*"}]] \
    -group [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ "*gtwiz_userclk_rx_usrclk*"}]]

# I/O Standards
set_property IOSTANDARD LVDS [get_ports sysclk_p]
set_property IOSTANDARD LVDS [get_ports sysclk_n]

# Reset
set_property IOSTANDARD LVCMOS18 [get_ports sys_rst_n]

# LEDs (ajustar según pines disponibles en Kria K26)
# Estos son ejemplos, verificar pinout real del board
# set_property PACKAGE_PIN <pin> [get_ports led0]
# set_property IOSTANDARD LVCMOS18 [get_ports led0]
# set_property PACKAGE_PIN <pin> [get_ports led1]
# set_property IOSTANDARD LVCMOS18 [get_ports led1]
# set_property PACKAGE_PIN <pin> [get_ports led2]
# set_property IOSTANDARD LVCMOS18 [get_ports led2]
# set_property PACKAGE_PIN <pin> [get_ports led3]
# set_property IOSTANDARD LVCMOS18 [get_ports led3]

# Timing constraints para GTY
# False paths entre dominios de clock asíncronos
set_false_path -from [get_clocks sysclk] -to [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ "*gtwiz_userclk_tx_usrclk*"}]]
set_false_path -from [get_clocks sysclk] -to [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ "*gtwiz_userclk_rx_usrclk*"}]]

# Multi-cycle paths (si aplica)
# set_multicycle_path -setup 2 -from [get_clocks sysclk] -to [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ "*gtwiz_userclk_tx_usrclk*"}]]

# GTY Reference Clock constraints
# Ajustar según la configuración del GTY Wizard
# Los relojes de referencia GTY se configuran automáticamente por el IP,
# pero podemos añadir constraints adicionales si es necesario

# Nota: Para un diseño real, descomentar y ajustar los pines de LEDs
# según el pinout del Kria K26 SOM
}

# Escribir el archivo
set fp [open ${constraints_file} w]
puts ${fp} ${constraints_content}
close ${fp}

puts "Archivo de constraints creado: ${constraints_file}"

# Agregar constraints al proyecto
add_files -fileset constrs_1 -norecurse ${constraints_file}

puts "=========================================="
puts "Constraints aplicadas al proyecto"
puts "Archivo: ${constraints_file}"
puts "=========================================="

# Guardar proyecto
save_project

