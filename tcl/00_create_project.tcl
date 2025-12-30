################################################################################
# Script: 00_create_project.tcl
# Descripción: Crea un proyecto Vivado nuevo para Kria K26 con transceivers GTY
# Autor: FPGA Senior Engineer
# Fecha: 2024
# Vivado: 2022.2
################################################################################

# Limpiar cualquier proyecto existente
if {[file exists ${proj_dir}]} {
    file delete -force ${proj_dir}
}

# Variables del proyecto
set proj_name "kria_k26_gty_loopback"
set proj_dir "./${proj_name}"
set part_name "xczu5ev-sfvc784-1-e"

# Crear proyecto en modo Project Mode (no Non-Project Mode)
create_project ${proj_name} ${proj_dir} -part ${part_name} -force

# Configurar proyecto
set_property target_language Verilog [current_project]
set_property default_lib work [current_project]

# Configurar simulación (opcional, para futuras pruebas)
set_property simulator_language Mixed [current_project]

puts "=========================================="
puts "Proyecto ${proj_name} creado exitosamente"
puts "Part: ${part_name}"
puts "Directorio: ${proj_dir}"
puts "=========================================="

# Guardar proyecto
save_project

