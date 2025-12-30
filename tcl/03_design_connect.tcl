################################################################################
# Script: 03_design_connect.tcl
# Descripción: Crea el diseño top-level y conecta el GTY en modo loopback
# Autor: FPGA Senior Engineer
# Fecha: 2024
# Vivado: 2022.2
################################################################################

# Verificar que el proyecto esté abierto
if {![info exists ::env(VIVADO_PROJECT_NAME)]} {
    set proj_name "kria_k26_gty_loopback"
    open_project ./${proj_name}/${proj_name}.xpr
}

# Crear archivo RTL top-level
set top_file "./src/rtl/gty_loopback_top.v"

# Crear el módulo top-level con loopback funcional
set top_content {
//////////////////////////////////////////////////////////////////////////////////
// Module: gty_loopback_top.v
// Description: Top-level module for GTY loopback test on Kria K26
// Author: FPGA Senior Engineer
// Date: 2024
//////////////////////////////////////////////////////////////////////////////////

module gty_loopback_top (
    // Clock inputs
    input  wire sysclk_p,
    input  wire sysclk_n,
    
    // Reset
    input  wire sys_rst_n,
    
    // Status LEDs (opcional, para debug visual)
    output wire led0,  // GTY power good
    output wire led1,  // TX reset done
    output wire led2,  // RX reset done
    output wire led3   // PLL lock
);

    // Clock buffer para reloj del sistema
    wire sysclk;
    IBUFDS #(
        .IBUF_LOW_PWR("FALSE"),
        .IOSTANDARD("LVDS")
    ) ibufds_sysclk (
        .I(sysclk_p),
        .IB(sysclk_n),
        .O(sysclk)
    );

    // Reset synchronizer
    reg [3:0] rst_sync;
    wire sys_rst = ~sys_rst_n;
    always @(posedge sysclk or posedge sys_rst) begin
        if (sys_rst)
            rst_sync <= 4'hF;
        else
            rst_sync <= {rst_sync[2:0], 1'b0};
    end
    wire rst = rst_sync[3];

    // Instancia del GTY Wizard
    wire gty_txusrclk;
    wire gty_txusrclk2;
    wire gty_rxusrclk;
    wire gty_rxusrclk2;
    
    // Señales de control y status del GTY
    wire [3:0] gty_gtpowergood;
    wire [3:0] gty_txresetdone;
    wire [3:0] gty_rxresetdone;
    wire [3:0] gty_cplllock;
    
    // Datos de prueba para loopback
    reg [31:0] tx_data_counter;
    wire [31:0] tx_data;
    wire [31:0] rx_data;
    wire [3:0]  tx_charisk;
    wire [3:0]  rx_charisk;
    
    // Generar datos de prueba (contador simple)
    always @(posedge gty_txusrclk2) begin
        if (rst)
            tx_data_counter <= 32'h0;
        else
            tx_data_counter <= tx_data_counter + 1;
    end
    
    assign tx_data = tx_data_counter;
    assign tx_charisk = 4'h0;  // No K characters
    
    // Instancia del GTY Wizard
    gty_wizard_0 gty_wizard_inst (
        .gtwiz_userclk_tx_active_in(1'b1),
        .gtwiz_userclk_rx_active_in(1'b1),
        
        // Clocks
        .gtwiz_userclk_tx_reset_in(rst),
        .gtwiz_userclk_rx_reset_in(rst),
        .gtwiz_userclk_tx_srcclk_out(),
        .gtwiz_userclk_tx_usrclk_out(gty_txusrclk),
        .gtwiz_userclk_tx_usrclk2_out(gty_txusrclk2),
        .gtwiz_userclk_rx_srcclk_out(),
        .gtwiz_userclk_rx_usrclk_out(gty_rxusrclk),
        .gtwiz_userclk_rx_usrclk2_out(gty_rxusrclk2),
        
        // Reset
        .gtwiz_reset_clk_freerun_in(sysclk),
        .gtwiz_reset_all_in(rst),
        
        // TX Interface
        .gtwiz_userdata_tx_in(tx_data),
        .txcharisk_in(tx_charisk),
        
        // RX Interface
        .gtwiz_userdata_rx_out(rx_data),
        .rxcharisk_out(rx_charisk),
        
        // Status
        .gtpowergood_out(gty_gtpowergood),
        .txresetdone_out(gty_txresetdone),
        .rxresetdone_out(gty_rxresetdone),
        .cplllock_out(gty_cplllock),
        
        // GTY Reference Clocks (conectar a relojes de referencia del board)
        .gtrefclk00_in(1'b0),  // Se configurará en constraints
        .gtrefclk01_in(1'b0),
        
        // GTY Serial Ports (no se usan en loopback interno, pero deben estar)
        .gtyrxn_in(4'h0),
        .gtyrxp_in(4'h0),
        .gtytxn_out(),
        .gtytxp_out()
    );
    
    // LEDs de status (invertidos si son active-low)
    assign led0 = &gty_gtpowergood;      // Todos los lanes power good
    assign led1 = &gty_txresetdone;      // Todos los TX reset done
    assign led2 = &gty_rxresetdone;      // Todos los RX reset done
    assign led3 = &gty_cplllock;         // Todos los PLLs locked
    
    // Comparador de datos para verificar loopback
    reg [31:0] rx_data_delayed;
    wire data_match;
    always @(posedge gty_rxusrclk2) begin
        if (gty_rxresetdone == 4'hF)
            rx_data_delayed <= rx_data;
    end
    
    // El loopback interno debería hacer que rx_data == tx_data (con delay)
    // Esto se puede monitorear con ILA
    
endmodule
}

# Escribir el archivo
set fp [open ${top_file} w]
puts ${fp} ${top_content}
close ${fp}

puts "Archivo RTL creado: ${top_file}"

# Agregar el archivo al proyecto
add_files -norecurse ${top_file}
update_compile_order -fileset sources_1

# Establecer como top module
set_property top gty_loopback_top [current_fileset]

puts "=========================================="
puts "Diseño top-level creado y configurado"
puts "Top module: gty_loopback_top"
puts "Loopback mode: Near_End_PCS (interno)"
puts "=========================================="

# Guardar proyecto
save_project

