# Guía Rápida de Inicio

## Ejecución Rápida del Flujo Completo

### Desde Vivado TCL Console

```tcl
# Opción 1: Ejecutar todo el flujo
source ./tcl/run_all.tcl

# Opción 2: Ejecutar paso a paso
source ./tcl/00_create_project.tcl
source ./tcl/01_board_part.tcl
source ./tcl/02_gtwizard_create.tcl
source ./tcl/03_design_connect.tcl
source ./tcl/04_constraints.tcl
source ./tcl/05_synth_and_checkpoint.tcl
source ./tcl/06_impl_and_checkpoint.tcl
source ./tcl/07_build_bitstream.tcl
```

### Desde Línea de Comandos (Batch Mode)

```bash
vivado -mode batch -source tcl/run_all.tcl
```

## Reanudar desde Checkpoint

```tcl
# Desde síntesis
open_checkpoint ./checkpoints/post_synth.dcp
source ./tcl/06_impl_and_checkpoint.tcl
source ./tcl/07_build_bitstream.tcl

# Desde placement
open_checkpoint ./checkpoints/post_place.dcp
route_design
write_checkpoint -force ./checkpoints/post_route.dcp
source ./tcl/07_build_bitstream.tcl

# Desde routing
open_checkpoint ./checkpoints/post_route.dcp
source ./tcl/07_build_bitstream.tcl
```

## Programar Dispositivo

```tcl
# Requiere hardware conectado vía JTAG
source ./tcl/08_program_jtag.tcl
```

## Verificar Configuración del IP

Si hay problemas con la configuración del GTY Wizard:

```tcl
# Ver propiedades del IP
set ip_instance [get_ips gty_wizard_0]
report_property ${ip_instance}

# Ver todos los parámetros CONFIG
get_property CONFIG.* ${ip_instance}
```

## Troubleshooting Rápido

### Error: IP no encontrado
- Verificar que Vivado 2022.2 está instalado
- Verificar licencias de GTY

### Error: Board part no encontrado
- El diseño funciona sin board part (solo con part)
- Verificar: `get_board_parts`

### Error: Timing violations
- Revisar constraints de reloj
- Verificar false paths entre dominios asíncronos

## Estructura de Archivos Importantes

```
tcl/                    # Scripts TCL del flujo
checkpoints/            # Checkpoints DCP (regenerables)
src/rtl/               # Código RTL (generado por 03_design_connect.tcl)
constraints/           # Constraints XDC
```

## Próximos Pasos Después de Generar Bitstream

1. Revisar reportes en `./checkpoints/`
2. Programar dispositivo: `source ./tcl/08_program_jtag.tcl`
3. (Opcional) Configurar ILA: `source ./tcl/09_debug_ila.tcl`
4. Verificar funcionamiento del loopback

