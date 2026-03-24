`default_nettype none;

module Grader
  (input logic [11:0] Guess,
   input logic GradeIt, clock, reset,
   output logic [3:0] Zood, Znarly);

  logic [11:0] MasterPattern;
  logic [2:0] firstGuess, secondGuess, thirdGuess, fourthGuess;

  assign firstGuess  = Guess[11:9];
  assign secondGuess = Guess[8:6];
  assign thirdGuess  = Guess[5:3];
  assign fourthGuess = Guess[2:0];
  
  enum logic [2:0] {
    T = 3'b001,
    C = 3'b010,
    O = 3'b011,
    D = 3'b100,
    I = 3'b101,
    Z = 3'b110
  } firstShape, secondShape, thirdShape, fourthShape;

  enum logic {
    START = 0,
    COMPUTE = 1
  } currState, nextState;

  // Assign the shapes
  assign firstShape = T; 
  assign secondShape = T;
  assign thirdShape = D;
  assign fourthShape = O;
  assign MasterPattern = {firstShape, secondShape, thirdShape, fourthShape}; 

  // Instantiate registers and register logic
  logic [2:0] R1_out, R2_out, R3_out, R4_out;
  logic R_en, R_clear;

  Register #(3) R1(.clock(clock), .D(firstGuess), .Q(R1_out), .en(R_en),
                   .clear(R_clear));

  Register #(3) R2(.clock(clock), .D(secondGuess), .Q(R2_out), .en(R_en),
                   .clear(R_clear));

  Register #(3) R3(.clock(clock), .D(thirdGuess), .Q(R3_out), .en(R_en),
                   .clear(R_clear));

  Register #(3) R4(.clock(clock), .D(fourthGuess), .Q(R4_out), .en(R_en),
                   .clear(R_clear));

  // Instantiate comparators and comparator logic
  logic C1_out, C2_out, C3_out, C4_out, C5_out, C6_out, C7_out, C8_out,
        C9_out, C10_out, C11_out, C12_out, C13_out, C14_out, C15_out,
        C16_out;

  logic C1_final, C2_final, C3_final, C4_final, C5_final, C6_final,
        C7_final, C8_final, C9_final, C10_final, C11_final, C12_final,
        C13_final, C14_final, C15_final, C16_final;

  // firstGuess
  Comparator #(3) C1(.A(R1_out), .B(firstShape), .AeqB(C1_out));
  Comparator #(3) C2(.A(R1_out), .B(secondShape), .AeqB(C2_out));
  Comparator #(3) C3(.A(R1_out), .B(thirdShape), .AeqB(C3_out));
  Comparator #(3) C4(.A(R1_out), .B(fourthShape), .AeqB(C4_out));

  // secondGuess
  Comparator #(3) C5(.A(R2_out), .B(secondShape), .AeqB(C5_out));
  Comparator #(3) C6(.A(R2_out), .B(firstShape), .AeqB(C6_out));
  Comparator #(3) C7(.A(R2_out), .B(thirdShape), .AeqB(C7_out));
  Comparator #(3) C8(.A(R2_out), .B(fourthShape), .AeqB(C8_out));

  // thirdGuess
  Comparator #(3) C9(.A(R3_out), .B(thirdShape), .AeqB(C9_out));
  Comparator #(3) C10(.A(R3_out), .B(firstShape), .AeqB(C10_out));
  Comparator #(3) C11(.A(R3_out), .B(secondShape), .AeqB(C11_out));
  Comparator #(3) C12(.A(R3_out), .B(fourthShape), .AeqB(C12_out));

  // fourthGuess
  Comparator #(3) C13(.A(R4_out), .B(fourthShape), .AeqB(C13_out));
  Comparator #(3) C14(.A(R4_out), .B(firstShape), .AeqB(C14_out));
  Comparator #(3) C15(.A(R4_out), .B(secondShape), .AeqB(C15_out));
  Comparator #(3) C16(.A(R4_out), .B(thirdShape), .AeqB(C16_out));

  // Tier 1 comparators should always be enabled
  assign C1_final  = C1_out;
  assign C5_final  = C5_out;
  assign C9_final  = C9_out;
  assign C13_final = C13_out;

  // Tier 2 comparators can be disabled by T1 Comparators
  assign C2_final  = C2_out & ~(C1_final | C5_final);
  assign C6_final  = C6_out & ~(C1_final | C5_final);
  assign C10_final = C10_out & ~(C1_final | C6_final | C9_final);
  assign C14_final = C14_out & ~(C1_final | C6_final | C10_final |
                      C13_final);

  // Tier 3 comparators can be disabled by T1/2 Comparators
  assign C3_final  = C3_out & ~(C1_final | C2_final | C9_final);
  assign C7_final  = C7_out & ~(C3_final | C5_final | C6_final | C9_final);
  assign C11_final = C11_out & ~(C2_final | C5_final | C9_final |
                      C10_final);
  assign C15_final = C15_out & ~(C2_final | C5_final | C11_final |
                      C13_final | C14_final);

  // Tier 4 comparators can be disabled by T1/2/3 Comparators
  assign C4_final  = C4_out & ~(C1_final | C2_final | C3_final | C13_final);
  assign C8_final  = C8_out & ~(C4_final | C5_final | C6_final | C7_final |
                     C13_final);
  assign C12_final = C12_out & ~(C4_final | C8_final | C9_final | C10_final |
                      C11_final | C13_final);
  assign C16_final = C16_out & ~(C3_final | C7_final | C9_final | C13_final |
                      C14_final | C15_final);

  // Summing Znarly with Adders
  logic [3:0] A1_out, A2_out, A3_out, A4_out,
              A5_out, A6_out, A7_out, A8_out, A9_out;
  
  Adder #(4) A1(.A({3'd0, C1_final}), .B({3'd0, C5_final}), .cin(1'b0),
                .sum(A1_out), .cout());
  Adder #(4) A2(.A({3'd0, C9_final}), .B({3'd0, C13_final}), .cin(1'b0),
                .sum(A2_out), .cout());
  Adder #(4) A3(.A(A1_out), .B(A2_out), .cin(1'b0), .sum(Znarly), .cout());

  // Summing Zood with Adders
  Adder #(4) A4(.A({3'd0, C2_final}), .B({3'd0, C3_final}), .cin(C4_final),
                .sum(A4_out), .cout());
  Adder #(4) A5(.A({3'd0, C6_final}), .B({3'd0, C7_final}), .cin(C8_final),
                .sum(A5_out), .cout());
  Adder #(4) A6(.A({3'd0, C10_final}), .B({3'd0, C11_final}), .cin(C12_final),
                .sum(A6_out), .cout());
  Adder #(4) A7(.A({3'd0, C14_final}), .B({3'd0, C15_final}), .cin(C16_final),
                .sum(A7_out), .cout());
  Adder #(4) A8(.A(A4_out), .B(A5_out), .cin(1'b0), .sum(A8_out), .cout());
  Adder #(4) A9(.A(A6_out), .B(A7_out), .cin(1'b0), .sum(A9_out), .cout());
  Adder #(4) A10(.A(A8_out), .B(A9_out), .cin(1'b0), .sum(Zood), .cout());

  // Sequential logic for FSM
  always_comb begin
    case (currState)
      START: begin
        nextState = (GradeIt) ? COMPUTE : START;
        R_en = (GradeIt) ? 1 : 0;
        R_clear = (GradeIt) ? 0 : 1;
      end

      COMPUTE: begin
        nextState = (GradeIt) ? COMPUTE : START;
        R_en = 0;
        R_clear = (GradeIt) ? 0 : 1;
      end
    endcase
  end

  always_ff @(posedge clock, posedge reset)
    if (reset)
      currState = START;
    else
      currState = nextState;

endmodule: Grader

module Grader_woFSM
  (input logic [11:0] Guess,
   input logic clock, reset,
   input logic R_en, R_clear,
   input logic [11:0] MasterPattern,
   output logic [3:0] Zood, Znarly);

  logic [2:0] firstGuess, secondGuess, thirdGuess, fourthGuess;

  assign firstGuess  = Guess[11:9];
  assign secondGuess = Guess[8:6];
  assign thirdGuess  = Guess[5:3];
  assign fourthGuess = Guess[2:0];
  
  enum logic [2:0] {
    T = 3'b001,
    C = 3'b010,
    O = 3'b011,
    D = 3'b100,
    I = 3'b101,
    Z = 3'b110
  } firstShape, secondShape, thirdShape, fourthShape;

  enum logic {
    START = 0,
    COMPUTE = 1
  } currState, nextState;

  assign firstShape = MasterPattern[11:9];
  assign secondShape = MasterPattern[8:6];
  assign thirdShape = MasterPattern[5:3];
  assign fourthShape = MasterPattern[2:0];


  // Instantiate registers and register logic
  logic [2:0] R1_out, R2_out, R3_out, R4_out;

  Register #(3) R1(.clock(clock), .D(firstGuess), .Q(R1_out), .en(R_en),
                   .clear(R_clear));

  Register #(3) R2(.clock(clock), .D(secondGuess), .Q(R2_out), .en(R_en),
                   .clear(R_clear));

  Register #(3) R3(.clock(clock), .D(thirdGuess), .Q(R3_out), .en(R_en),
                   .clear(R_clear));

  Register #(3) R4(.clock(clock), .D(fourthGuess), .Q(R4_out), .en(R_en),
                   .clear(R_clear));

  // Instantiate comparators and comparator logic
  logic C1_out, C2_out, C3_out, C4_out, C5_out, C6_out, C7_out, C8_out,
        C9_out, C10_out, C11_out, C12_out, C13_out, C14_out, C15_out,
        C16_out;

  logic C1_final, C2_final, C3_final, C4_final, C5_final, C6_final,
        C7_final, C8_final, C9_final, C10_final, C11_final, C12_final,
        C13_final, C14_final, C15_final, C16_final;

  // firstGuess
  Comparator #(3) C1(.A(R1_out), .B(firstShape), .AeqB(C1_out));
  Comparator #(3) C2(.A(R1_out), .B(secondShape), .AeqB(C2_out));
  Comparator #(3) C3(.A(R1_out), .B(thirdShape), .AeqB(C3_out));
  Comparator #(3) C4(.A(R1_out), .B(fourthShape), .AeqB(C4_out));

  // secondGuess
  Comparator #(3) C5(.A(R2_out), .B(secondShape), .AeqB(C5_out));
  Comparator #(3) C6(.A(R2_out), .B(firstShape), .AeqB(C6_out));
  Comparator #(3) C7(.A(R2_out), .B(thirdShape), .AeqB(C7_out));
  Comparator #(3) C8(.A(R2_out), .B(fourthShape), .AeqB(C8_out));

  // thirdGuess
  Comparator #(3) C9(.A(R3_out), .B(thirdShape), .AeqB(C9_out));
  Comparator #(3) C10(.A(R3_out), .B(firstShape), .AeqB(C10_out));
  Comparator #(3) C11(.A(R3_out), .B(secondShape), .AeqB(C11_out));
  Comparator #(3) C12(.A(R3_out), .B(fourthShape), .AeqB(C12_out));

  // fourthGuess
  Comparator #(3) C13(.A(R4_out), .B(fourthShape), .AeqB(C13_out));
  Comparator #(3) C14(.A(R4_out), .B(firstShape), .AeqB(C14_out));
  Comparator #(3) C15(.A(R4_out), .B(secondShape), .AeqB(C15_out));
  Comparator #(3) C16(.A(R4_out), .B(thirdShape), .AeqB(C16_out));

  // Tier 1 comparators should always be enabled
  assign C1_final  = C1_out;
  assign C5_final  = C5_out;
  assign C9_final  = C9_out;
  assign C13_final = C13_out;

  // Tier 2 comparators can be disabled by T1 Comparators
  assign C2_final  = C2_out & ~(C1_final | C5_final);
  assign C6_final  = C6_out & ~(C1_final | C5_final);
  assign C10_final = C10_out & ~(C1_final | C6_final | C9_final);
  assign C14_final = C14_out & ~(C1_final | C6_final | C10_final |
                      C13_final);

  // Tier 3 comparators can be disabled by T1/2 Comparators
  assign C3_final  = C3_out & ~(C1_final | C2_final | C9_final);
  assign C7_final  = C7_out & ~(C3_final | C5_final | C6_final | C9_final);
  assign C11_final = C11_out & ~(C2_final | C5_final | C9_final |
                      C10_final);
  assign C15_final = C15_out & ~(C2_final | C5_final | C11_final |
                      C13_final | C14_final);

  // Tier 4 comparators can be disabled by T1/2/3 Comparators
  assign C4_final  = C4_out & ~(C1_final | C2_final | C3_final | C13_final);
  assign C8_final  = C8_out & ~(C4_final | C5_final | C6_final | C7_final |
                     C13_final);
  assign C12_final = C12_out & ~(C4_final | C8_final | C9_final | C10_final |
                      C11_final | C13_final);
  assign C16_final = C16_out & ~(C3_final | C7_final | C9_final | C13_final |
                      C14_final | C15_final);

  // Summing Znarly with Adders
  logic [3:0] A1_out, A2_out, A3_out, A4_out,
              A5_out, A6_out, A7_out, A8_out, A9_out;
  
  Adder #(4) A1(.A({3'd0, C1_final}), .B({3'd0, C5_final}), .cin(1'b0),
                .sum(A1_out), .cout());
  Adder #(4) A2(.A({3'd0, C9_final}), .B({3'd0, C13_final}), .cin(1'b0),
                .sum(A2_out), .cout());
  Adder #(4) A3(.A(A1_out), .B(A2_out), .cin(1'b0), .sum(Znarly), .cout());

  // Summing Zood with Adders
  Adder #(4) A4(.A({3'd0, C2_final}), .B({3'd0, C3_final}), .cin(C4_final),
                .sum(A4_out), .cout());
  Adder #(4) A5(.A({3'd0, C6_final}), .B({3'd0, C7_final}), .cin(C8_final),
                .sum(A5_out), .cout());
  Adder #(4) A6(.A({3'd0, C10_final}), .B({3'd0, C11_final}), .cin(C12_final),
                .sum(A6_out), .cout());
  Adder #(4) A7(.A({3'd0, C14_final}), .B({3'd0, C15_final}), .cin(C16_final),
                .sum(A7_out), .cout());
  Adder #(4) A8(.A(A4_out), .B(A5_out), .cin(1'b0), .sum(A8_out), .cout());
  Adder #(4) A9(.A(A6_out), .B(A7_out), .cin(1'b0), .sum(A9_out), .cout());
  Adder #(4) A10(.A(A8_out), .B(A9_out), .cin(1'b0), .sum(Zood), .cout());

endmodule: Grader_woFSM

module GraderTest;
  logic [11:0] Guess;
  logic GradeIt, reset;
  logic [3:0] Znarly, Zood;
  // logic clock;

  logic clock;
  initial begin
    clock = 0;
    forever #5 clock = ~clock;
  end

  enum logic [2:0] {
    T = 3'b001,
    C = 3'b010,
    O = 3'b011,
    D = 3'b100,
    I = 3'b101,
    Z = 3'b110
  } firstShape, secondShape, thirdShape, fourthShape;

  assign Guess = {firstShape, secondShape, thirdShape, fourthShape};

  Grader DUT(.clock(clock), .*);

  initial begin
    $monitor($time,, "reset=%b|Zood=%d|Znarly=%d",
             reset, Zood, Znarly);
    // Initialize variables
    reset <= 1;
    GradeIt <= 0;
    {firstShape, secondShape, thirdShape, fourthShape} <= {T, T, T, D};
    @(posedge clock);

    // Release reset
    #5 reset <= 0;
    @(posedge clock);

    // Here, Zoog and Znarly should be 0 since GradeIt is not asserted
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);

    // Test 1: Master: TTDO, Guess: TTTD (1 Zood, 2 Znarly) works
    #5 GradeIt <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    #5 GradeIt <= 0;

    // Zoog and Znarly should go back to 0 here once GradeIt gets deasserted
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);

    // Test 2: Master: TTDO, Guess: CCCC (0 Zood, 0 Znarly)
    #5 GradeIt <= 1;
    {firstShape, secondShape, thirdShape, fourthShape} <= {C, C, C, C};
    @(posedge clock);
    @(posedge clock);
    #5 GradeIt <= 0;
    @(posedge clock);
    @(posedge clock);

    // Test 3: Master: TTDO, Guess: TDOT (3 Zood, 1 Znarly) 
    #5 GradeIt <= 1;
    {firstShape, secondShape, thirdShape, fourthShape} <= {T, D, O, T};
    @(posedge clock);
    @(posedge clock);
    #5 GradeIt <= 0;
    @(posedge clock);
    @(posedge clock);

    // Test 4: Master: TTDO, Guess: TTTT (0 Zood, 2 Znarly)
    #5 GradeIt <= 1;
    {firstShape, secondShape, thirdShape, fourthShape} <= {T, T, T, T};
    @(posedge clock);
    @(posedge clock);
    #5 GradeIt <= 0;
    @(posedge clock);
    @(posedge clock);
  
    // Test 5: Master: TTDO, Guess: ODTT (4 Zood, 0 Znarly)
    #5 GradeIt <= 1;
    {firstShape, secondShape, thirdShape, fourthShape} <= {O, D, T, T};
    @(posedge clock);
    @(posedge clock);
    #5 GradeIt <= 0;
    @(posedge clock);
    @(posedge clock);

    // Test 6: Master: TTDO, Guess: TOOO (0 Zood, 2 Znarly)
    #5 GradeIt <= 1;
    {firstShape, secondShape, thirdShape, fourthShape} <= {T, O, O, O};
    @(posedge clock);
    #5 GradeIt <= 0;
    @(posedge clock);

    // Test 7: Master: TTDO, Guess: DOTT (4 Zood, 0 Znarly)
    #5 GradeIt <= 1;
    {firstShape, secondShape, thirdShape, fourthShape} <= {D, O, T, T};
    @(posedge clock);
    #5 GradeIt <= 0;
    @(posedge clock);

    // Test 8: Master: TTDO, Guess: DDDD (0 Zood, 1 Znarly)
    #5 GradeIt <= 1;
    {firstShape, secondShape, thirdShape, fourthShape} <= {D, D, D, D};
    @(posedge clock);
    #5 GradeIt <= 0;
    @(posedge clock);

    // Test 9: Master: TTDO, Guess: OOOT (2 Zood, 0 Znarly)
    #5 GradeIt <= 1;
    {firstShape, secondShape, thirdShape, fourthShape} <= {O, O, O, T};
    @(posedge clock);
    #5 GradeIt <= 0;
    @(posedge clock);

    // Test 10: Master: TTDO, Guess: TOTT (2 Zood, 1 Znarly)
    #5 GradeIt <= 1;
    {firstShape, secondShape, thirdShape, fourthShape} <= {T, O, T, T};
    @(posedge clock);
    #5 GradeIt <= 0;
    @(posedge clock);
    #10 $finish;
  end

endmodule: GraderTest