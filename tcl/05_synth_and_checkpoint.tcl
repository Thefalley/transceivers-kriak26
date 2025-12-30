################################################################################
# Script: 05_synth_and_checkpoint.tcl
# Descripción: Ejecuta síntesis y guarda checkpoint post-síntesis
# Autor: FPGA Senior Engineer
# Fecha: 2024
# Vivado: 2022.2
################################################################################

# Verificar que el proyecto esté abierto
if {![info exists ::env(VIVADO_PROJECT_NAME)]} {
    set proj_name "kria_k26_gty_loopback"
    open_project ./${proj_name}/${proj_name}.xpr
}

# Asegurar que el directorio de checkpoints existe
file mkdir ./checkpoints

puts "=========================================="
puts "Iniciando síntesis..."
puts "=========================================="

# Ejecutar síntesis
# -flatten_hierarchy puede ser "none", "full", o "rebuilt"
# -mode puede ser "out_of_context" o "default"
synth_design -top gty_loopback_top \
    -part xczu5ev-sfvc784-1-e \
    -flatten_hierarchy rebuilt \
    -mode default

# Verificar que la síntesis fue exitosa
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    error "Síntesis falló. Revisar reportes."
}

puts "Síntesis completada exitosamente"

# Generar reportes útiles
puts "Generando reportes post-síntesis..."

# Reporte de utilización
report_utilization -file ./checkpoints/post_synth_utilization.rpt -pb ./checkpoints/post_synth_utilization.pb

# Reporte de timing
report_timing_summary -file ./checkpoints/post_synth_timing.rpt

# Reporte de clocks
report_clock_networks -file ./checkpoints/post_synth_clock_networks.rpt

# Reporte de poder (estimado)
report_power -file ./checkpoints/post_synth_power.rpt

puts "Reportes generados en ./checkpoints/"

# Guardar checkpoint post-síntesis
# Este checkpoint permite:
# - Reanudar el flujo desde placement sin re-sintetizar
# - Analizar el diseño post-síntesis
# - Debug de problemas de síntesis
write_checkpoint -force ./checkpoints/post_synth.dcp

puts "=========================================="
puts "Checkpoint guardado: ./checkpoints/post_synth.dcp"
puts "Este checkpoint contiene:"
puts "  - Diseño sintetizado (netlist)"
puts "  - Constraints aplicadas"
puts "  - Estado completo del diseño"
puts ""
puts "Para reanudar desde este punto:"
puts "  open_checkpoint ./checkpoints/post_synth.dcp"
puts "=========================================="

# Guardar proyecto
save_project

