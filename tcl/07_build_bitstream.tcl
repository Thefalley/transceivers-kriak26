################################################################################
# Script: 07_build_bitstream.tcl
# Descripción: Genera el bitstream desde el checkpoint post-routing
# Autor: FPGA Senior Engineer
# Fecha: 2024
# Vivado: 2022.2
################################################################################

# Abrir checkpoint post-routing si existe, sino ejecutar implementación
if {[file exists ./checkpoints/post_route.dcp]} {
    puts "Abriendo checkpoint post-routing..."
    open_checkpoint ./checkpoints/post_route.dcp
} else {
    puts "Checkpoint post-routing no encontrado. Ejecutando implementación..."
    if {[file exists ./checkpoints/post_synth.dcp]} {
        open_checkpoint ./checkpoints/post_synth.dcp
        source ./tcl/06_impl_and_checkpoint.tcl
    } else {
        error "No se encontró checkpoint post-síntesis. Ejecutar síntesis primero."
    }
}

puts "=========================================="
puts "Generando bitstream..."
puts "=========================================="

# Configurar opciones de bitstream
# -bin_file: genera archivo .bin además de .bit
# -force: sobrescribe si existe
write_bitstream -force -bin_file -file ./kria_k26_gty_loopback.bit

# Verificar que el bitstream se generó correctamente
if {![file exists ./kria_k26_gty_loopback.bit]} {
    error "Error al generar bitstream"
}

puts "=========================================="
puts "Bitstream generado exitosamente:"
puts "  - ./kria_k26_gty_loopback.bit"
puts "  - ./kria_k26_gty_loopback.bin"
puts ""
puts "El archivo .bit se usa con Vivado Hardware Manager"
puts "El archivo .bin se puede usar para programación por boot"
puts "=========================================="

# Generar reporte de memoria (si aplica)
if {[llength [get_cells -hierarchical -filter {NAME =~ "*gtwizard*"}]] > 0} {
    write_mem_info -force ./checkpoints/mem_info.txt
    puts "Información de memoria guardada en ./checkpoints/mem_info.txt"
}

# Guardar proyecto
save_project

