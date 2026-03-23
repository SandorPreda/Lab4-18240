`default_nettype none

module Decoder
  # (parameter WIDTH = 16)
  (input logic en,
   input logic [$clog2(WIDTH)-1:0] I,
   output logic [WIDTH-1:0] D);

   always_comb begin
       D = '0;
       if (en) D[I] = 1'b1;
   end


endmodule: Decoder


module BarrelShifter
   (input logic [15:0] V,
    input logic [3:0] by,
    output logic [15:0] S);

   assign S = V << by;

endmodule: BarrelShifter

module MultibitMultiplexer
   #(parameter BITWIDTH = 8, parameter OPTIONS = 8)
   (input logic  [(BITWIDTH*OPTIONS)-1:0] I,
    input logic [$clog2(OPTIONS)-1:0] S,
    output logic [BITWIDTH-1:0] Y);

    assign Y = I[BITWIDTH*S +: BITWIDTH];

endmodule: MultibitMultiplexer

module Multiplexer
   #(parameter WIDTH = 8)
   (input logic  [WIDTH-1:0] I,
    input logic [$clog2(WIDTH)-1:0] S,
    output Y);

   assign Y = I[S];

endmodule: Multiplexer

module Mux2to1
   #(parameter WIDTH = 8)
   (input logic S,
    input logic [WIDTH-1:0] I0, I1,
    output logic [WIDTH-1:0] Y);

    assign Y = (S) ? I1 : I0;

endmodule: Mux2to1

module MagComp
   #(parameter WIDTH = 8)
   (input logic [WIDTH-1:0] A, B,
    output logic AeqB, AltB, AgtB);

    assign AeqB = (A == B);
    assign AltB = (A < B);
    assign AgtB= (A > B);

endmodule: MagComp

module Comparator
   #(parameter WIDTH = 8)
   (input logic [WIDTH-1:0] A, B,
    output logic AeqB);

    assign AeqB = (A == B);

endmodule: Comparator

module Adder
  #(parameter WIDTH = 8)
  (input  logic cin,
   input  logic [WIDTH-1:0] A, B,
   output logic cout,
   output logic [WIDTH-1:0] sum);


   assign {cout, sum} = A + B + cin;

endmodule: Adder

module Subtracter
  #(parameter WIDTH = 8)
  (input  logic bin,
   input  logic [WIDTH-1:0] A, B,
   output logic bout,
   output logic [WIDTH-1:0] diff);


   assign {bout, diff} = {1'b0, A} - {1'b0, B} - bin;

endmodule: Subtracter

module DFlipFlop
    (input logic D, clock, reset_L, preset_L,
     output logic Q);

    always_ff @(posedge clock or negedge reset_L or negedge preset_L) begin
        if (!reset_L) Q <= 1'b0;
        else if (!preset_L) Q <= 1'b1;
        else Q <= D;
    end

endmodule: DFlipFlop

module Register
   #(parameter WIDTH = 8)
   (input logic [WIDTH-1:0] D,
    input logic en, clear, clock,
    output logic [WIDTH-1:0] Q);

   always_ff @(posedge clock) begin
       if (clear) Q <= '0;
       else if (en) Q <= D;
   end

endmodule: Register

module Counter
   #(parameter WIDTH = 8)
   (input logic [WIDTH-1:0] D,
    input logic en, clear, load, up, clock,
    output logic [WIDTH-1:0] Q);

   always_ff @(posedge clock) begin
       if (clear) Q <= '0;
       else if (load) Q <= D;
       else if (en) begin
           if (up) Q <= Q + 1'b1;
           else Q <= Q - 1'b1;
       end
    end

endmodule: Counter

module ShiftRegisterSIPO
   #(parameter WIDTH = 8)
   (input logic serial, en, left, clock,
    output logic [WIDTH-1:0] Q);

   always_ff @(posedge clock) begin
       if (en) begin
           if (left) Q <= {Q[WIDTH-2:0], serial};
           else Q <= {serial, Q[WIDTH-1:1]};
       end
   end

endmodule: ShiftRegisterSIPO

module ShiftRegisterPIPO
   #(parameter WIDTH = 8)
   (input logic [WIDTH-1:0] D,
    input logic load, en, left, clock,
    output logic [WIDTH-1:0] Q);

   always_ff @(posedge clock) begin
       if (load) Q <= D;
       else if (en) begin
           if (left) Q <= {Q[WIDTH-2:0], 1'b0};
           else Q <= {1'b0, Q[WIDTH-1:1]};
       end
   end

endmodule: ShiftRegisterPIPO

module BarrelShiftRegister
   #(parameter WIDTH = 8)
   (input logic [WIDTH-1:0] D,
    input logic [1:0] by,
    input logic load, en, clock,
    output logic [WIDTH-1:0] Q);

   always_ff @(posedge clock) begin
       if (load) Q <= D;
       else if (en) Q <= Q << by;
   end

endmodule: BarrelShiftRegister

module Synchronizer
  (input logic async, clock,
   output logic sync);

   logic regu;

   always_ff @(posedge clock) begin
       regu <= async;
       sync <= regu;
   end

endmodule: Synchronizer

module BusDriver
    #(parameter WIDTH = 8)
    (input logic [WIDTH-1:0] data,
     input logic en,
     inout wire [WIDTH-1:0] bus,
     output logic [WIDTH-1:0] buff);

     assign bus = en ? data : 'z;
     assign buff = bus;

endmodule: BusDriver

module Memory
   #(parameter DW = 16,
               AW = 8,
               W = (1<<AW))
   (input logic re, we, clock,
    input logic [AW-1:0] addr,
    inout tri [DW-1:0] data);

    logic [DW-1:0] M[W];
    logic [DW-1:0] rData;

    assign data = (re) ? rData: 'bz;

    always_ff @(posedge clock) begin
       if (we) M[addr] <= data;
    end

    always_comb rData = M[addr];

endmodule: Memory