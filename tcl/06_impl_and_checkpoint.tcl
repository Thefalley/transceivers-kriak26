################################################################################
# Script: 06_impl_and_checkpoint.tcl
# Descripción: Ejecuta implementación (place & route) y guarda checkpoints
# Autor: FPGA Senior Engineer
# Fecha: 2024
# Vivado: 2022.2
################################################################################

# Verificar que el proyecto esté abierto o abrir desde checkpoint
if {![info exists ::env(VIVADO_PROJECT_NAME)]} {
    # Intentar abrir desde checkpoint post-síntesis si existe
    if {[file exists ./checkpoints/post_synth.dcp]} {
        puts "Abriendo checkpoint post-síntesis..."
        open_checkpoint ./checkpoints/post_synth.dcp
    } else {
        set proj_name "kria_k26_gty_loopback"
        open_project ./${proj_name}/${proj_name}.xpr
        # Si no hay checkpoint, ejecutar síntesis primero
        source ./tcl/05_synth_and_checkpoint.tcl
    }
}

# Asegurar que el directorio de checkpoints existe
file mkdir ./checkpoints

puts "=========================================="
puts "Iniciando implementación (Place & Route)..."
puts "=========================================="

# Ejecutar placement
puts "Ejecutando placement..."
place_design

# Verificar que el placement fue exitoso
if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    error "Placement falló. Revisar reportes."
}

puts "Placement completado exitosamente"

# Generar reportes post-placement
puts "Generando reportes post-placement..."

report_utilization -file ./checkpoints/post_place_utilization.rpt -pb ./checkpoints/post_place_utilization.pb
report_timing_summary -file ./checkpoints/post_place_timing.rpt
report_clock_networks -file ./checkpoints/post_place_clock_networks.rpt
report_io -file ./checkpoints/post_place_io.rpt

# Guardar checkpoint post-placement
# Este checkpoint permite:
# - Reanudar desde routing sin re-placear
# - Analizar placement y optimizaciones
# - Debug de problemas de placement
write_checkpoint -force ./checkpoints/post_place.dcp

puts "Checkpoint guardado: ./checkpoints/post_place.dcp"

# Ejecutar routing
puts "Ejecutando routing..."
route_design

# Verificar que el routing fue exitoso
if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    error "Routing falló. Revisar reportes."
}

puts "Routing completado exitosamente"

# Generar reportes post-routing
puts "Generando reportes post-routing..."

report_utilization -file ./checkpoints/post_route_utilization.rpt -pb ./checkpoints/post_route_utilization.pb
report_timing_summary -file ./checkpoints/post_route_timing.rpt -max_paths 10
report_clock_networks -file ./checkpoints/post_route_clock_networks.rpt
report_power -file ./checkpoints/post_route_power.rpt
report_drc -file ./checkpoints/post_route_drc.rpt
report_methodology -file ./checkpoints/post_route_methodology.rpt

# Reporte específico para GTY
# Verificar status de transceivers
if {[llength [get_cells -hierarchical -filter {NAME =~ "*gtwizard*"}]] > 0} {
    puts "Generando reporte de GTY..."
    # Reporte de propiedades del GTY
    report_property [get_cells -hierarchical -filter {NAME =~ "*gtwizard*"}] -file ./checkpoints/post_route_gty_properties.rpt
}

# Guardar checkpoint post-routing
# Este checkpoint permite:
# - Reanudar desde bitstream generation sin re-routear
# - Análisis completo del diseño implementado
# - Debug de timing y routing
write_checkpoint -force ./checkpoints/post_route.dcp

puts "=========================================="
puts "Checkpoints guardados:"
puts "  - ./checkpoints/post_place.dcp (post-placement)"
puts "  - ./checkpoints/post_route.dcp (post-routing)"
puts ""
puts "Para reanudar desde placement:"
puts "  open_checkpoint ./checkpoints/post_place.dcp"
puts ""
puts "Para reanudar desde routing:"
puts "  open_checkpoint ./checkpoints/post_route.dcp"
puts "=========================================="

# Guardar proyecto
save_project

