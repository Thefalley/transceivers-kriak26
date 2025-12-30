################################################################################
# Script: 08_program_jtag.tcl
# Descripción: Programa el bitstream en el dispositivo vía JTAG
# Autor: FPGA Senior Engineer
# Fecha: 2024
# Vivado: 2022.2
################################################################################

# Verificar que el bitstream existe
set bitstream_file "./kria_k26_gty_loopback.bit"

if {![file exists ${bitstream_file}]} {
    error "Bitstream no encontrado: ${bitstream_file}. Ejecutar 07_build_bitstream.tcl primero."
}

puts "=========================================="
puts "Configurando conexión JTAG..."
puts "=========================================="

# Abrir hardware manager
# Nota: Este script asume que el hardware está conectado
# Si no está conectado, el usuario debe conectarlo manualmente

# Abrir hardware target
# open_hw_manager
# connect_hw_server
# open_hw_target

# Alternativa: usar comandos directos si el hardware ya está conectado
# Esto requiere que el hardware manager esté abierto y el target conectado

puts "IMPORTANTE: Este script requiere que:"
puts "  1. El hardware esté conectado vía JTAG"
puts "  2. El hardware manager esté abierto"
puts "  3. El target esté abierto"
puts ""
puts "Para ejecutar manualmente:"
puts "  1. Abrir Vivado Hardware Manager"
puts "  2. Conectar al servidor (local o remoto)"
puts "  3. Abrir target (auto-connect o manual)"
puts "  4. Ejecutar:"
puts "     program_hw_devices [lindex [get_hw_devices] 0] -bitfile ${bitstream_file}"
puts ""

# Comando para programar (descomentar cuando el hardware esté conectado)
# set hw_device [lindex [get_hw_devices] 0]
# current_hw_device ${hw_device}
# set_property PROGRAM.FILE ${bitstream_file} [current_hw_device]
# program_hw_devices [current_hw_device]

# Alternativa: usar open_hw_manager y luego ejecutar manualmente
# o usar este script desde la línea de comandos con hardware conectado

puts "=========================================="
puts "Script de programación JTAG preparado"
puts "Bitstream: ${bitstream_file}"
puts ""
puts "Para programar, ejecutar en Hardware Manager:"
puts "  program_hw_devices [lindex [get_hw_devices] 0] -bitfile ${bitstream_file}"
puts "=========================================="

# Si se ejecuta desde batch mode, intentar conectar automáticamente
if {[catch {open_hw_manager} result]} {
    puts "WARNING: No se pudo abrir hardware manager automáticamente"
    puts "Abrir manualmente y ejecutar los comandos mostrados arriba"
} else {
    puts "Hardware manager abierto. Conectando..."
    if {[catch {connect_hw_server} result]} {
        puts "WARNING: No se pudo conectar al servidor hardware"
    } else {
        puts "Servidor hardware conectado"
        if {[catch {open_hw_target} result]} {
            puts "WARNING: No se pudo abrir target. Verificar conexión JTAG"
        } else {
            puts "Target abierto. Programando dispositivo..."
            set hw_device [lindex [get_hw_devices] 0]
            if {${hw_device} ne ""} {
                current_hw_device ${hw_device}
                set_property PROGRAM.FILE ${bitstream_file} [current_hw_device]
                program_hw_devices [current_hw_device]
                puts "Dispositivo programado exitosamente"
            }
        }
    }
}

