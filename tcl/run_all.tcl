################################################################################
# Script: run_all.tcl
# Descripción: Script maestro que ejecuta todo el flujo de diseño
# Autor: FPGA Senior Engineer
# Fecha: 2024
# Vivado: 2022.2
#
# Uso: source ./tcl/run_all.tcl
#      o: vivado -mode batch -source tcl/run_all.tcl
################################################################################

puts "=========================================="
puts "Iniciando flujo completo de diseño GTY Loopback"
puts "Kria K26 - Vivado 2022.2"
puts "=========================================="

# Cambiar al directorio del proyecto si es necesario
set script_dir [file dirname [file normalize [info script]]]
set project_root [file dirname ${script_dir}]
cd ${project_root}

# Ejecutar cada paso del flujo
puts "\n[1/9] Creando proyecto..."
source ${script_dir}/00_create_project.tcl

puts "\n[2/9] Configurando board part..."
source ${script_dir}/01_board_part.tcl

puts "\n[3/9] Creando GTY Wizard..."
source ${script_dir}/02_gtwizard_create.tcl

puts "\n[4/9] Creando diseño top-level..."
source ${script_dir}/03_design_connect.tcl

puts "\n[5/9] Aplicando constraints..."
source ${script_dir}/04_constraints.tcl

puts "\n[6/9] Ejecutando síntesis..."
source ${script_dir}/05_synth_and_checkpoint.tcl

puts "\n[7/9] Ejecutando implementación..."
source ${script_dir}/06_impl_and_checkpoint.tcl

puts "\n[8/9] Generando bitstream..."
source ${script_dir}/07_build_bitstream.tcl

puts "\n[9/9] Flujo completo finalizado"
puts "=========================================="
puts "Próximos pasos:"
puts "  1. Revisar reportes en ./checkpoints/"
puts "  2. Programar dispositivo: source ./tcl/08_program_jtag.tcl"
puts "  3. Configurar ILA (opcional): source ./tcl/09_debug_ila.tcl"
puts "=========================================="

