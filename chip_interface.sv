/** FILE
 *  chip_interface.sv
 *
 *  BRIEF
 *  This is a chip interface couples mastermindVGA.sv with the 40MHz clk
 *  to drive the VGA and a 200 MHz clk to drive the VGA to hdmi input.
 *  Includes HDMI_TX & clk_wizard for a proper HDMI output
 *  for the AMD FPGA.
 *
 *  This includes a couple 'TO DO:'s that students should fill out
 *  to properly connect with their mastermind
 *
 *  AUTHOR
 *  Angie Shere (ashere)
 *
 */

module ChipInterface (
    input  logic        CLOCK_100,
    input  logic [ 3:0] BTN,
    input  logic [15:0] SW,
    output logic [ 3:0] D2_AN, D1_AN,
    output logic [ 7:0] D2_SEG, D1_SEG,
    output logic        hdmi_clk_n, hdmi_clk_p,
    output logic [ 2:0] hdmi_tx_p, hdmi_tx_n,
    output logic [15:0] LD
    );

    //TO DO:
    // - Include your game here!
    // - Declare connecting wires/signals to/from your game
    // - Use those wires/signals to connect to the MastermindVGA and
    //   EightSevenSegmentDisplays modules below

/*
 *  BEWARE CHANGING CODE BELOW THIS LINE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 *
 *  You will need to connect your signals to these modules by changing what
 *  is written in the ( ... ) parenthesis places.  You shouldn't have to make
 *  any other changes than those connections.
 */

    // Don't change these signals
    logic [7:0] VGA_R, VGA_G, VGA_B;
    logic       VGA_BLANK_N, VGA_CLK, VGA_SYNC_N;
    logic       VGA_VS, VGA_HS;
    logic       reset_sync;

    MastermindVGA mmVGA(.clk_40MHz,
                        .VGA_R,
                        .VGA_G,
                        .VGA_B,
                        .VGA_BLANK_N,
                        .VGA_CLK,
                        .VGA_SYNC_N,
                        .VGA_VS,
                        .VGA_HS,
                        .reset(reset_sync),
                        .numGames( ... ),
                        .loadNumGames( ... ),
                        .roundNumber( ... ),
                        .guess( ... ),
                        .loadGuess( ... ),
                        .znarly( ... ), 
                        .zood( ... ), 
                        .clearGame( ... ),
                        .masterPattern( ... ),
                        .displayMasterPattern( ... ),
			.loadZnarlyZood( ... )
                       );


    EightSevenSegmentDisplays displays(.HEX7( ... ), 
                                       .HEX6( ... ), 
                                       .HEX5( ... ), 
                                       .HEX4( ... ),
                                       .HEX3( ... ), 
                                       .HEX2( ... ), 
                                       .HEX1( ... ), 
                                       .HEX0( ... ),
                                       .CLOCK_100,
                                       .reset( ... ),
                                       .dec_points( ... ),
                                       .blank( ... ),  
                                       .D2_AN,
                                       .D1_AN,
                                       .D2_SEG,
                                       .D1_SEG
                                      );

    Synchronizer sync_reset(.async( ... ), 
                            .clock(clk_40MHz), 
                            .sync(reset_sync)
                           );

/*
 *  DO NOT EDIT CODE BELOW THIS LINE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 *  If you do, the Zorgmeister will Zzzzzt you!
 */

    logic clk_40MHz, clk_200MHz;
    logic locked;
    
    // 2 clk freq outputs
    clk_wiz_0 clk_wiz (
        .clk_out1(clk_40MHz),
        .clk_out2(clk_200MHz),
        .reset(1'b0), 
        .locked(locked),
        .clk_in1(CLOCK_100)
    );

    //convert sigs from VGA to HDMI converter
    hdmi_tx_0 vga_to_hdmi (
        //clk and reset
        .pix_clk(clk_40MHz),
        .pix_clkx5(clk_200MHz),
        .pix_clk_locked(locked),
    
        .rst(reset_sync),

        //color and sync Signals
        .red(VGA_R),
        .green(VGA_G),
        .blue(VGA_B),

        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .vde(VGA_BLANK_N),

        //differential outputs
        .TMDS_CLK_P(hdmi_clk_p),          
        .TMDS_CLK_N(hdmi_clk_n),          
        .TMDS_DATA_P(hdmi_tx_p),        
        .TMDS_DATA_N(hdmi_tx_n)          
    );

endmodule : ChipInterface
