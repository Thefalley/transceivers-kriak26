# Proyecto GTY Loopback para Xilinx Kria K26

## Descripción del Proyecto

Este proyecto implementa un diseño de transceivers GTY en modo loopback interno para la placa Xilinx Kria K26 SOM (System-on-Module). El diseño utiliza exclusivamente scripts TCL para garantizar reproducibilidad y control de versiones.

**Características principales:**
- Transceivers GTY configurados en modo loopback interno (Near_End_PCS)
- Flujo completamente automatizado mediante scripts TCL
- Sistema de checkpoints para análisis y depuración
- Integración con ILA para debug
- Programación vía JTAG

**Tipo de Loopback:**
- **Near_End_PCS (PCS Loopback)**: El loopback ocurre en la capa Physical Coding Sublayer (PCS), antes de la serialización. Los datos TX se conectan directamente a RX sin salir del chip. Este modo es ideal para:
  - Verificar la funcionalidad del GTY sin necesidad de hardware externo
  - Probar la lógica de datos y protocolos
  - Debug y validación del diseño

## Requisitos

### Hardware
- **Placa**: Xilinx Kria K26 SOM
- **Part**: xczu5ev-sfvc784-1-e (Zynq UltraScale+)
- **Cable JTAG**: Para programación y debug

### Software
- **Vivado**: 2022.2 (versión exacta requerida)
- **Sistema Operativo**: Linux
- **Git**: Para control de versiones

### Licencias
- Vivado 2022.2 con licencia válida
- Licencia para transceivers GTY (incluida en licencias estándar)

## Estructura del Repositorio

```
repo_git/
├── tcl/                          # Scripts TCL del flujo de diseño
│   ├── 00_create_project.tcl     # Crear proyecto Vivado
│   ├── 01_board_part.tcl         # Configurar board part
│   ├── 02_gtwizard_create.tcl    # Crear instancia GTY Wizard
│   ├── 03_design_connect.tcl     # Diseño top-level y conexiones
│   ├── 04_constraints.tcl        # Constraints XDC
│   ├── 05_synth_and_checkpoint.tcl  # Síntesis + checkpoint
│   ├── 06_impl_and_checkpoint.tcl   # Implementación + checkpoints
│   ├── 07_build_bitstream.tcl    # Generar bitstream
│   ├── 08_program_jtag.tcl       # Programar vía JTAG
│   └── 09_debug_ila.tcl          # Configurar ILA para debug
│
├── checkpoints/                  # Checkpoints del diseño (DCP)
│   ├── post_synth.dcp            # Checkpoint post-síntesis
│   ├── post_place.dcp            # Checkpoint post-placement
│   └── post_route.dcp            # Checkpoint post-routing
│
├── src/
│   └── rtl/                      # Código RTL
│       └── gty_loopback_top.v    # Módulo top-level
│
├── constraints/                   # Constraints XDC
│   └── gty_loopback.xdc          # Constraints del diseño
│
├── README.md                     # Este archivo
└── .gitignore                    # Archivos ignorados por git
```

## Cómo Ejecutar el Flujo TCL

### Opción 1: Ejecución Paso a Paso (Recomendado para primera vez)

Abrir Vivado 2022.2 y ejecutar en la TCL Console:

```tcl
# Paso 1: Crear proyecto
source ./tcl/00_create_project.tcl

# Paso 2: Configurar board part
source ./tcl/01_board_part.tcl

# Paso 3: Crear GTY Wizard
source ./tcl/02_gtwizard_create.tcl

# Paso 4: Crear diseño top-level
source ./tcl/03_design_connect.tcl

# Paso 5: Aplicar constraints
source ./tcl/04_constraints.tcl

# Paso 6: Síntesis y checkpoint
source ./tcl/05_synth_and_checkpoint.tcl

# Paso 7: Implementación y checkpoints
source ./tcl/06_impl_and_checkpoint.tcl

# Paso 8: Generar bitstream
source ./tcl/07_build_bitstream.tcl

# Paso 9: Programar dispositivo (requiere hardware conectado)
source ./tcl/08_program_jtag.tcl

# Paso 10: Configurar ILA (opcional, para debug)
source ./tcl/09_debug_ila.tcl
```

### Opción 2: Ejecución desde Línea de Comandos (Batch Mode)

```bash
# Ejecutar todo el flujo desde cero
vivado -mode batch -source tcl/00_create_project.tcl
vivado -mode batch -source tcl/01_board_part.tcl
# ... (continuar con cada script)

# O crear un script maestro que ejecute todos
vivado -mode batch -source run_all.tcl
```

### Opción 3: Reanudar desde Checkpoint

Si ya tienes un checkpoint y quieres continuar desde ahí:

```tcl
# Reanudar desde síntesis
open_checkpoint ./checkpoints/post_synth.dcp
source ./tcl/06_impl_and_checkpoint.tcl

# O reanudar desde placement
open_checkpoint ./checkpoints/post_place.dcp
route_design
write_checkpoint -force ./checkpoints/post_route.dcp

# O reanudar desde routing
open_checkpoint ./checkpoints/post_route.dcp
source ./tcl/07_build_bitstream.tcl
```

## Tabla de Tareas

| ID | Tarea                               | Script TCL                     | Estado | Notas |
|----|-------------------------------------|--------------------------------|--------|-------|
| 01 | Crear proyecto Vivado               | 00_create_project.tcl          | OK     | Proyecto base creado |
| 02 | Configurar board / part             | 01_board_part.tcl              | OK     | Part: xczu5ev-sfvc784-1-e |
| 03 | Instanciar GTY Wizard               | 02_gtwizard_create.tcl         | OK     | IP GTY configurado |
| 04 | Loopback interno GTY funcional      | 03_design_connect.tcl          | OK     | Near_End_PCS loopback |
| 05 | Aplicar constraints                 | 04_constraints.tcl             | OK     | Constraints XDC creadas |
| 06 | Síntesis + checkpoint               | 05_synth_and_checkpoint.tcl    | TODO   | Requiere ejecución |
| 07 | Placement + checkpoint              | 06_impl_and_checkpoint.tcl     | TODO   | Requiere ejecución |
| 08 | Routing + checkpoint                | 06_impl_and_checkpoint.tcl     | TODO   | Requiere ejecución |
| 09 | Generar bitstream                   | 07_build_bitstream.tcl         | TODO   | Requiere ejecución |
| 10 | Programar vía JTAG                  | 08_program_jtag.tcl            | TODO   | Requiere hardware |
| 11 | Configurar ILA para debug           | 09_debug_ila.tcl               | TODO   | Opcional |

**Leyenda:**
- **OK**: Script creado y listo para ejecutar
- **TODO**: Pendiente de ejecución/validación
- **FAIL**: Error conocido (ver sección de problemas)

## Checkpoints Generados

Los checkpoints (DCP) permiten guardar el estado del diseño en diferentes etapas y reanudar el flujo sin re-ejecutar pasos anteriores.

### post_synth.dcp
- **Cuándo se genera**: Después de la síntesis
- **Contiene**: Netlist sintetizado, constraints aplicadas, estado del diseño
- **Propósito**: 
  - Reanudar implementación sin re-sintetizar
  - Analizar resultados de síntesis
  - Debug de problemas de síntesis
- **Uso**: `open_checkpoint ./checkpoints/post_synth.dcp`

### post_place.dcp
- **Cuándo se genera**: Después del placement
- **Contiene**: Diseño con componentes colocados en el FPGA
- **Propósito**:
  - Reanudar routing sin re-placear
  - Analizar placement y optimizaciones
  - Debug de problemas de placement
- **Uso**: `open_checkpoint ./checkpoints/post_place.dcp`

### post_route.dcp
- **Cuándo se genera**: Después del routing
- **Contiene**: Diseño completamente implementado con routing
- **Propósito**:
  - Reanudar generación de bitstream sin re-routear
  - Análisis completo del diseño implementado
  - Debug de timing y routing
- **Uso**: `open_checkpoint ./checkpoints/post_route.dcp`

## Historial de Hitos (Milestones)

### Milestone 1: Estructura Base (Fecha: 2024)
- ✅ Estructura de directorios creada
- ✅ Scripts TCL base implementados
- ✅ README y documentación inicial

### Milestone 2: Diseño RTL (Pendiente)
- ⏳ Módulo top-level implementado
- ⏳ GTY Wizard configurado
- ⏳ Loopback funcional

### Milestone 3: Síntesis Exitosa (Pendiente)
- ⏳ Síntesis sin errores
- ⏳ Checkpoint post-síntesis generado
- ⏳ Reportes de utilización y timing

### Milestone 4: Implementación Exitosa (Pendiente)
- ⏳ Placement y routing completados
- ⏳ Checkpoints post-place y post-route generados
- ⏳ Timing closure alcanzado

### Milestone 5: Bitstream Generado (Pendiente)
- ⏳ Bitstream generado sin errores
- ⏳ Archivos .bit y .bin creados

### Milestone 6: Validación en Hardware (Pendiente)
- ⏳ Dispositivo programado vía JTAG
- ⏳ Loopback verificado funcionalmente
- ⏳ ILA configurado y funcionando

## Notas de Debug y Problemas Conocidos

### Debug de GTY

#### Señales Clave para Monitorear
- **gtpowergood**: Indica que el GTY tiene alimentación estable
- **txresetdone**: Indica que el reset de TX está completo
- **rxresetdone**: Indica que el reset de RX está completo
- **cplllock / qplllock**: Indica que el PLL está bloqueado

#### Comandos TCL Útiles para Debug

```tcl
# Reportar propiedades del GTY
report_property [get_cells -hierarchical -filter {NAME =~ "*gtwizard*"}]

# Reportar redes de reloj
report_clock_networks

# Reportar timing del GTY
report_timing -from [get_pins -hierarchical -filter {NAME =~ "*gtwizard*/*tx*"}]

# Verificar constraints aplicadas
report_methodology

# Verificar DRC
report_drc
```

### Problemas Conocidos

#### 1. Board Part No Encontrado
**Síntoma**: Warning al ejecutar `01_board_part.tcl` sobre board part no encontrado.

**Solución**: 
- Verificar instalación de board files: `get_board_parts`
- El diseño funciona solo con el part, el board part es opcional
- Ajustar el nombre del board part en el script si es necesario

#### 2. GTY Wizard No Genera Correctamente
**Síntoma**: Error al generar output products del GTY Wizard.

**Solución**:
- Verificar que la licencia de GTY está activa
- Verificar que el part soporta GTY (xczu5ev sí lo soporta)
- Revisar parámetros de configuración del GTY Wizard

#### 3. Timing Violations
**Síntoma**: Violaciones de timing después de routing.

**Solución**:
- Revisar constraints de reloj (especialmente entre dominios asíncronos)
- Verificar que los false paths están correctamente definidos
- Ajustar estrategias de placement y routing si es necesario

#### 4. ILA No Visible en Hardware Manager
**Síntoma**: ILA no aparece después de programar el dispositivo.

**Solución**:
- Verificar que el ILA está correctamente instanciado en el RTL
- Verificar que el bitstream incluye el ILA
- Asegurar que el clock del ILA está activo

### Reportes Generados

Los siguientes reportes se generan automáticamente en `./checkpoints/`:

- `post_synth_utilization.rpt`: Utilización de recursos post-síntesis
- `post_synth_timing.rpt`: Análisis de timing post-síntesis
- `post_synth_clock_networks.rpt`: Redes de reloj
- `post_synth_power.rpt`: Estimación de potencia
- `post_place_utilization.rpt`: Utilización post-placement
- `post_place_timing.rpt`: Timing post-placement
- `post_place_io.rpt`: Asignación de I/O
- `post_route_utilization.rpt`: Utilización final
- `post_route_timing.rpt`: Timing final (con routing)
- `post_route_power.rpt`: Potencia estimada final
- `post_route_drc.rpt`: Design Rule Checks
- `post_route_methodology.rpt`: Verificaciones de metodología

## Control de Versiones con Git

### Mensajes de Commit Recomendados

```bash
# Después de crear estructura base
git add .
git commit -m "feat: estructura inicial del proyecto con scripts TCL base"

# Después de cada script funcional
git add tcl/XX_script_name.tcl
git commit -m "feat: implementar script XX_script_name.tcl para [descripción]"

# Después de generar checkpoint
git add checkpoints/post_*.dcp
git commit -m "build: generar checkpoint post-[etapa]"

# Después de corregir problemas
git add [archivos modificados]
git commit -m "fix: [descripción del problema corregido]"

# Después de actualizar documentación
git add README.md
git commit -m "docs: actualizar documentación [sección]"
```

### Archivos a Versionar
- ✅ Scripts TCL (`tcl/*.tcl`)
- ✅ Código RTL (`src/rtl/*.v`)
- ✅ Constraints (`constraints/*.xdc`)
- ✅ README.md
- ✅ .gitignore

### Archivos NO a Versionar (ver .gitignore)
- ❌ Checkpoints DCP (muy grandes, regenerables)
- ❌ Archivos de proyecto Vivado (`.xpr`, `.runs/`, etc.)
- ❌ IP generados (`ip_repo/`)
- ❌ Bitstreams (`.bit`, `.bin`)
- ❌ Reportes (`.rpt`)

## Referencias

- [Xilinx GTY Transceivers User Guide (UG578)](https://www.xilinx.com/support/documentation/user_guides/ug578-ultrascale-gty-transceivers.pdf)
- [Xilinx Kria K26 SOM Documentation](https://www.xilinx.com/products/som/kria/k26-som.html)
- [Vivado Design Suite User Guide (UG910)](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2022_2/ug910-vivado-getting-started.pdf)
- [Vivado TCL Command Reference Guide (UG835)](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2022_2/ug835-vivado-tcl-commands.pdf)

## Autor

FPGA Senior Engineer - Especializado en Xilinx Kria K26, GTY Transceivers y Vivado 2022.2

## Licencia

Este proyecto es para uso interno/laboratorio. Verificar licencias de Xilinx para uso comercial.
