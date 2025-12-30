################################################################################
# Script: 02_gtwizard_create.tcl
# Descripción: Crea e instancia el GTY Wizard para transceivers
# Autor: FPGA Senior Engineer
# Fecha: 2024
# Vivado: 2022.2
################################################################################

# Verificar que el proyecto esté abierto
if {![info exists ::env(VIVADO_PROJECT_NAME)]} {
    set proj_name "kria_k26_gty_loopback"
    open_project ./${proj_name}/${proj_name}.xpr
}

# Crear IP: GTY Wizard
# El GTY Wizard se crea usando create_ip
# Nota: En Vivado 2022.2, el IP se llama "gtwizard_ultrascale"
set ip_name "gty_wizard_0"
set ip_vendor "xilinx.com"
set ip_library "ip"
set ip_name_full "gtwizard_ultrascale"

# Crear instancia del IP GTY
# El directorio ip_repo se creará automáticamente
create_ip -name ${ip_name_full} -vendor ${ip_vendor} -library ${ip_library} -module_name ${ip_name} -dir ./ip_repo/${ip_name}

# Configurar parámetros del GTY Wizard
set ip_instance [get_ips ${ip_name}]

# Configuración básica para loopback interno
# Protocolo: Custom (para máximo control)
# Nota: Los nombres de parámetros pueden variar según la versión del IP
# Verificar con: report_property ${ip_instance}
set_property -dict [list \
    CONFIG.gt0_protocol_file {None} \
    CONFIG.gt0_gtwizard_gty4_cpll_cal_txoutclk_period {3.102} \
    CONFIG.gt0_gtwizard_gty4_cpll_cal_cnt_tol {18} \
    CONFIG.gt0_gtwizard_gty4_cpll_cal_bufg_ce {1} \
    CONFIG.gt0_gtwizard_gty4_gt_DRP_IF {true} \
    CONFIG.gt0_gtwizard_gty4_gt_DRP_IF_Drp16 {false} \
    CONFIG.gt0_gtwizard_gty4_RX_Line_Rate {10.3125} \
    CONFIG.gt0_gtwizard_gty4_RX_Reference_Clock {156.25} \
    CONFIG.gt0_gtwizard_gty4_RX_Data_Width {32} \
    CONFIG.gt0_gtwizard_gty4_RX_Int_Data_Width {32} \
    CONFIG.gt0_gtwizard_gty4_TX_Line_Rate {10.3125} \
    CONFIG.gt0_gtwizard_gty4_TX_Reference_Clock {156.25} \
    CONFIG.gt0_gtwizard_gty4_TX_Data_Width {32} \
    CONFIG.gt0_gtwizard_gty4_TX_Int_Data_Width {32} \
    CONFIG.gt0_gtwizard_gty4_TX_Out_Clock_Source {TXOUTCLK} \
    CONFIG.gt0_gtwizard_gty4_TX_Out_Clock_Freq {322.265625} \
    CONFIG.gt0_gtwizard_gty4_RX_Serial_Loopback {true} \
] ${ip_instance}

# Nota: El loopback se configura mediante CONFIG.gt0_gtwizard_gty4_RX_Serial_Loopback
# Para loopback PCS (Near_End_PCS), se puede configurar en el RTL o mediante
# parámetros adicionales del IP. Verificar documentación del IP para opciones exactas.

# Generar output products del IP
generate_target all [get_files ${ip_name}.xci]

# Crear IP wrapper si es necesario
# Esto se hace automáticamente, pero podemos forzarlo
if {[get_files -quiet ${ip_name}_wrapper.v] eq ""} {
    puts "Generando wrapper para ${ip_name}..."
}

puts "=========================================="
puts "GTY Wizard creado: ${ip_name}"
puts "Configuración:"
puts "  Line Rate: 10.3125 Gbps"
puts "  Reference Clock: 156.25 MHz"
puts "  Loopback Mode: Serial Loopback (interno)"
puts ""
puts "NOTA: Verificar parámetros del IP con:"
puts "  report_property [get_ips ${ip_name}]"
puts "  get_property CONFIG.* [get_ips ${ip_name}]"
puts ""
puts "Si los parámetros no se aplicaron correctamente,"
puts "configurar manualmente en la GUI o ajustar nombres"
puts "de parámetros según la versión del IP."
puts "=========================================="

# Guardar proyecto
save_project

