################################################################################
# Script: 09_debug_ila.tcl
# Descripción: Configura ILA (Integrated Logic Analyzer) para debug de GTY
# Autor: FPGA Senior Engineer
# Fecha: 2024
# Vivado: 2022.2
################################################################################

# Este script debe ejecutarse después de tener un checkpoint post-routing
# o después de generar el bitstream con ILA incluido

# Abrir checkpoint post-routing
if {[file exists ./checkpoints/post_route.dcp]} {
    puts "Abriendo checkpoint post-routing..."
    open_checkpoint ./checkpoints/post_route.dcp
} else {
    error "Checkpoint post-routing no encontrado. Ejecutar implementación primero."
}

puts "=========================================="
puts "Configurando ILA para debug de GTY..."
puts "=========================================="

# Crear ILA IP para monitorear señales GTY
set ila_name "ila_gty_debug"
create_ip -name ila -vendor xilinx.com -library ip -module_name ${ila_name} -dir ./ip_repo/${ila_name}

# Configurar ILA
set ila_instance [get_ips ${ila_name}]

# Configuración del ILA
# - Número de probes: suficientes para monitorear señales clave
# - Sample depth: ajustar según memoria disponible
set_property -dict [list \
    CONFIG.C_PROBE0_WIDTH {4} \
    CONFIG.C_PROBE1_WIDTH {4} \
    CONFIG.C_PROBE2_WIDTH {4} \
    CONFIG.C_PROBE3_WIDTH {4} \
    CONFIG.C_PROBE4_WIDTH {32} \
    CONFIG.C_PROBE5_WIDTH {32} \
    CONFIG.C_PROBE6_WIDTH {4} \
    CONFIG.C_NUM_OF_PROBES {7} \
    CONFIG.C_DATA_DEPTH {8192} \
    CONFIG.C_EN_STRG_QUAL {1} \
    CONFIG.C_ADV_TRIGGER {true} \
    CONFIG.C_INPUT_PIPE_STAGES {1} \
] ${ila_instance}

# Generar output products
generate_target all [get_files ${ila_name}.xci]

puts "ILA IP creado: ${ila_name}"

# Nota: Para conectar el ILA a las señales del diseño, se necesita:
# 1. Modificar el RTL top-level para instanciar el ILA
# 2. Conectar las señales de interés a los probes del ILA
# 3. Re-sintetizar e implementar

# Señales recomendadas para monitorear:
# - Probe 0: gty_gtpowergood[3:0]
# - Probe 1: gty_txresetdone[3:0]
# - Probe 2: gty_rxresetdone[3:0]
# - Probe 3: gty_cplllock[3:0]
# - Probe 4: tx_data[31:0]
# - Probe 5: rx_data[31:0]
# - Probe 6: rx_charisk[3:0]

puts "=========================================="
puts "ILA configurado para monitorear:"
puts "  - GTY power good status"
puts "  - TX/RX reset done signals"
puts "  - PLL lock status"
puts "  - TX/RX data buses"
puts "  - RX character indicators"
puts ""
puts "NOTA: Para usar el ILA:"
puts "  1. Modificar gty_loopback_top.v para instanciar el ILA"
puts "  2. Conectar las señales de interés a los probes"
puts "  3. Re-ejecutar síntesis e implementación"
puts "  4. Generar nuevo bitstream con ILA"
puts "  5. Programar dispositivo y abrir ILA en Hardware Manager"
puts "=========================================="

# Script de ejemplo para modificar el top-level (comentado)
# Este sería un ejemplo de cómo instanciar el ILA en el RTL:
set ila_instantiation_example {
// Ejemplo de instanciación ILA en gty_loopback_top.v
// Agregar después de la instancia del GTY Wizard:

ila_gty_debug ila_inst (
    .clk(gty_txusrclk2),  // Clock para sampling
    .probe0(gty_gtpowergood),
    .probe1(gty_txresetdone),
    .probe2(gty_rxresetdone),
    .probe3(gty_cplllock),
    .probe4(tx_data),
    .probe5(rx_data),
    .probe6(rx_charisk)
);
}

puts "Ejemplo de instanciación ILA guardado en comentarios del script"

# Guardar proyecto
save_project

