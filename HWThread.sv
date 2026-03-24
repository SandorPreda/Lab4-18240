// `default_nettype none

module systemFSM (
  // Control points
  output logic add_or_sub,
  output logic tc_en,
  output logic another_round,
  output logic shape_reset, 
  output logic R_en_grader, R_clear_grader,
  output logic count_cl,
  output logic [2:0] outputState,

  //For VGA only
  output logic LoadNumGames, LoadGuess, ClearGame,
  output logic DisplayMasterPattern, LoadZnarlyZood,

  // Status points
  input logic loaded,
  input logic startgame_real,
  input logic gamedone,
  input logic reset,
  input logic clock,
  input logic GradeIt, GameWon,
  input logic CoinInserted);

  assign outputState = currState;

  enum logic [2:0] {
    WAIT = 3'b000,
    INSERTED = 3'b001,
    ENTERED = 3'b010,
    START = 3'b011,
    GRADING = 3'b100
    } currState, nextState;

  // Sequential logic for state transitions and ouputs
  always_comb begin      
    // Default outputs
    add_or_sub = 1;
    tc_en = 0;
    another_round = 0;
    shape_reset = 0;
    R_en_grader = 0;
    R_clear_grader = 0;
    DisplayMasterPattern = 0;
    LoadNumGames = 0;
    LoadGuess = 0;
    ClearGame = 0;
    LoadZnarlyZood = 0;
    count_cl = 0;

    // FSM control logic
    // Default state: remain in current state
    nextState = currState;
    case (currState)
      WAIT: begin
        count_cl = 1;
        R_clear_grader = 1;
        // If we insert a coin, store the value of the coin and add it to
        // the total coins register
        if (CoinInserted) begin
          nextState = INSERTED;
          add_or_sub = 1;
          tc_en = 1;
        end

        // When start game is asserted, subtract 4 coins from the total
        // coins register 
        else if (startgame_real) begin
          nextState = ENTERED;
          add_or_sub = 0;
          tc_en = 1;
          LoadNumGames = 1;
          shape_reset = 1;
        end
      end

      INSERTED: begin
        // Loop repeatedly until CoinInserted gets deasserted to prevent
        // double counting (Note: default outputs = nothing is calculated)
        if (~CoinInserted) begin
           nextState = WAIT;
           LoadNumGames = 1;
        end 
        else begin
           nextState = INSERTED;
           add_or_sub = 1;
           LoadNumGames = 1;
        end
      end

      ENTERED: begin
        // Start the actual game if the master pattern is loaded
        if (loaded) begin
          nextState = START;
          R_en_grader = 0;
          R_clear_grader = 1;
        end

        // Else, stay to load the master pattern
        else begin
          nextState = ENTERED;
        end
      end

      START: begin
        // If the game is won and done, reset everything
        if (GameWon || gamedone) begin
          nextState = WAIT;
          shape_reset = 1;
          ClearGame = 1;
          R_clear_grader = 1;
        end

        // If GradeIt is asserted, grade the game
        else if (GradeIt) begin
          nextState = GRADING;
          R_en_grader = 1;
          R_clear_grader = 0;
          LoadGuess = 1;
          LoadZnarlyZood = 1;
        end

        // Else, wait in this state until GradeIt is asserted
        else begin
          nextState = START;
          R_en_grader = 0;
          R_clear_grader = 0;
          DisplayMasterPattern = 1;
        end
      end

      GRADING: begin
        // Grade the round
        if (GameWon) begin
          nextState = WAIT;
          shape_reset = 1;
          ClearGame = 1;
          R_clear_grader = 1;
          R_en_grader = 0;
        end

        else if (~GradeIt) begin
          nextState = START;
          another_round = 1;
          R_en_grader = 0;
          R_clear_grader = 0;
        end

        // Loop repeatedly until GradeIt is deasserted to avoid grading
        // the same round multiple times
        else begin
          nextState = GRADING;
          R_en_grader = 0;
          R_clear_grader = 0;
        end
      end
    endcase
  end

  always_ff @(posedge clock, posedge reset)
    if (reset)
      currState <= WAIT;
    else
      currState <= nextState;

endmodule: systemFSM

module mainHardware(
  input logic [1:0] CoinValue, 
  input logic [11:0] Guess,
  input logic GradeIt, clock, reset, StartGame, LoadShapeNow,
  input logic [2:0] LoadShape, 
  input logic [1:0] ShapeLocation,
  input logic CoinInserted,

  output logic GameWon,
  output logic [3:0] Zood, Znarly,
  output logic [3:0] NumGames, RoundNumber,
  output logic [11:0] MasterPattern,

  //FSM control logic
  input logic add_or_sub,
  input logic tc_en,
  input logic another_round,
  input logic shape_reset, 
  input logic R_en_grader, R_clear_grader,
  input logic count_cl,

  //FSM monitor logic
  output logic loaded,
  output logic startgame_real,
  output logic gamedone);



  logic [2:0] coin;

  Mux4to1 #(3) cv_mux (
    .I0(3'd0),
    .I1(3'd1),
    .I2(3'd3),
    .I3(3'd5),
    .S(CoinValue),
    .Y(coin)
  );

  logic [4:0] coin_sum;
  logic [4:0] coin_difference;
  logic [4:0] total_coins;
  logic adder_cout;

  Adder #(5) coin_adder (.A(total_coins), .B({2'b00, coin}), .cin(1'd0),
                          .cout(adder_cout), .sum(coin_sum));

  Adder #(5) coin_subtractor (.A(total_coins), .B(-5'd4), .cin(1'd0), 
                              .cout(), .sum(coin_difference));

  logic [4:0] prereg_total;

  Mux2to1 #(5) add_sub_mux (
    .I0(coin_difference),
    .I1(coin_sum),
    .S(add_or_sub),
    .Y(prereg_total)
  );
  
  Register #(5) total_coin_register (.clock(clock), .en(tc_en & ~adder_cout), 
                                     .clear(reset), .D(prereg_total),
                                     .Q(total_coins));

  // Calculating the NumGames count
  
  assign NumGames = total_coins[4:2];


  logic enough_games;

  MagComp #(4) enough_games_comp (.A(NumGames), .B(4'b0000), 
                                  .AgtB(enough_games), .AltB(), .AeqB());


  assign startgame_real = enough_games & StartGame;

  Comparator #(4) win_checker (.A(Znarly), .B(4'b0100), .AeqB(GameWon));
  
  
  
  
  Counter #(4) round_counter (.clock(clock), .clear(reset | count_cl), .up(1'd1),
                          .load(1'd0), .Q(RoundNumber), .D(), .en(another_round));

  

  Comparator #(4) is_gamedone (.A(RoundNumber), .B(4'b1000), 
                                .AeqB(gamedone));

  logic [3:0] shape_pos_en;
  Decoder #(4) position_en (.en(LoadShapeNow), .I(ShapeLocation), 
                            .D(shape_pos_en));

  //Shape1 Register Logic
  logic shape1reg_en;
  logic [2:0] shape1Q;

  assign shape1reg_en = (~(shape1Q[2] | shape1Q[1] | shape1Q[0]) 
                          & shape_pos_en[3]);
  Register #(3) Shape1Reg (.en(shape1reg_en), .clear(shape_reset),
                            .clock(clock), .D(LoadShape), .Q(shape1Q));

  //Shape 2 Register Logic                       
  logic shape2reg_en;
  logic [2:0] shape2Q;
  
  assign shape2reg_en = (~(shape2Q[2] | shape2Q[1] | shape2Q[0]) 
                          & shape_pos_en[2]);
  Register #(3) Shape2Reg (.en(shape2reg_en), .clear(shape_reset),
                            .clock(clock), .D(LoadShape), .Q(shape2Q));

  //Shape 3 Register Logic                       
  logic shape3reg_en;
  logic [2:0] shape3Q;
  
  assign shape3reg_en = (~(shape3Q[2] | shape3Q[1] | shape3Q[0]) 
                          & shape_pos_en[1]);
  Register #(3) Shape3Reg (.en(shape3reg_en), .clear(shape_reset),
                            .clock(clock), .D(LoadShape), .Q(shape3Q));

  //Shape 4 Register Logic                       
  logic shape4reg_en;
  logic [2:0] shape4Q;
  
  assign shape4reg_en = (~(shape4Q[2] | shape4Q[1] | shape4Q[0]) 
                          & shape_pos_en[0]);
  Register #(3) Shape4Reg (.en(shape4reg_en), .clear(shape_reset),
                            .clock(clock), .D(LoadShape), .Q(shape4Q));

  assign loaded = ((shape1Q[2] | shape1Q[1] | shape1Q[0]) &
                    (shape2Q[2] | shape2Q[1] | shape2Q[0]) &
                    (shape3Q[2] | shape3Q[1] | shape3Q[0]) &
                    (shape4Q[2] | shape4Q[1] | shape4Q[0]));
  
  
  assign MasterPattern = {shape1Q, shape2Q, shape3Q, shape4Q};

  Grader_woFSM grader (.Guess, .clock, .reset, .R_en(R_en_grader),
                       .R_clear(R_clear_grader), .GradeIt, .Zood, .Znarly,
                       .MasterPattern(MasterPattern));

endmodule: mainHardware