################################################################################
# Script: 01_board_part.tcl
# Descripción: Configura el board part para Kria K26 SOM
# Autor: FPGA Senior Engineer
# Fecha: 2024
# Vivado: 2022.2
################################################################################

# Verificar que el proyecto esté abierto
if {![info exists ::env(VIVADO_PROJECT_NAME)]} {
    set proj_name "kria_k26_gty_loopback"
    open_project ./${proj_name}/${proj_name}.xpr
}

# Board part para Kria K26 SOM
# Nota: El board part exacto puede variar según la instalación de Vivado
# Verificar con: get_board_parts
set board_part "xilinx.com:k26c:part0:1.0"

# Intentar configurar board part
# Si no está disponible, usar solo el part
if {[lsearch [get_board_parts] ${board_part}] >= 0} {
    set_property board_part ${board_part} [current_project]
    puts "Board part configurado: ${board_part}"
} else {
    puts "WARNING: Board part ${board_part} no encontrado"
    puts "Usando solo part: xczu5ev-sfvc784-1-e"
    puts "Verificar board parts disponibles con: get_board_parts"
}

# Verificar configuración actual
set current_part [get_property PART [current_project]]
set current_board [get_property BOARD_PART [current_project]]

puts "=========================================="
puts "Configuración de Board/Part:"
puts "  Part: ${current_part}"
puts "  Board: ${current_board}"
puts "=========================================="

# Guardar proyecto
save_project

