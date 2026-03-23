`default_nettype none

module mainHardware(
    input logic [1:0] CoinValue, 
    input logic [11:0] Guess,
    input logic GradeIt, CLOCK100, reset, StartGame, LoadShapeNow,
    input logic [2:0] LoadShape, 
    input logic [1:0] ShapeLocation
    output logic CoinInserted, GameWon,
    output logic [3:0] Zood, Znarly,
    output logic [3:0] NumGames, Round Number
    //FSM control and monitor logic
    output logic loaded);

    logic cv_cl, cv_en;
    logic [1:0] cv_reg;

    Register #(2) cvalueReg (.clock(CLOCK100), .clear(cv_cl), .en(cv_en),
                             .D(CoinValue), .Q(cv_reg));

    logic [2:0] coin;

    MultibitMultiplexer #(.BITWIDTH(3), .OPTIONS(4)) 
                        cv_mux (.I(12'b101011001000),
                                .S(cv_reg), .Y(coin));

    logic [4:0] coin_sum;
    logic [4:0] coin_difference;
    logic [4:0] total_coins;

    Adder #(5) coin_adder (.A(total_coins), .B({0,0,coin}), .cin(0), .cout,
                           .sum(coin_sum));

    Adder #(5) coin_subtractor (.A(total_coins) .B(5'b00100), .cin(1), 
                                .cout, .sum(coin_difference));

   logic [4:0] prereg_total;

   //needs control in FSM
   logic add_or_sub;

    MultibitMultiplexer #(.BITWIDTH(5), .OPTIONS(2)) 
                        add_sub_mux (.I({coin_sum, coin_difference}), 
                                     .S(add_or_sub), .Y(prereg_total));
    
    //needs control in FSM 
    logic tc_en;

    Register #(5) total_coin_register (.clock(CLOCK100), .en(tc_en), 
                                       .clear(reset), .D(prereg_total),
                                       .Q(total_coins));

    BarrelShiftRegister #(5) barrelshifter (.clock(CLOCK100), .en(1), .load(1),
                                            .by(2'b10), .D(total_coins),
                                            .Q({0, 0, NumGames}));

    logic inserted_async;

    assign inserted_async = CoinValue[1] | CoinValue[0];

    Synchronizer insert_synchronizer (.clock(CLOCK100), .async(inserted_async),
                                      .sync(CoinInserted));

    logic enough_games;

    MagComp #(4) enough_games_comp (.A(NumGames), .B(4'b0000), 
                                    .AgtB(enough_games));

    //need monitor FSM point here
    logic startgame_real;

    assign startgame_real = enough_games & StartGame;

    Comparator #(3) win_checker (.A(Zood), .B(3'b100), .AeqB(GameWon));
    
    //need control point here FSM
    logic another_round;
    
    logic [3:0] total_rounds;
    
    Counter #(4) round_counter (.clock(CLOCK100), .clear(reset), .up(1),
                           .load(0), .Q(total_rounds));

    //need FSM monitor for this
    logic gamedone;

    Comparator #(4) is_gamedone (.A(total_rounds), .B(4'b1000), 
                                 .AeqB(gamedone));

    Decoder #(4) position_en (.en(LoadShapeNow), .I(ShapeLocation), 
                              .D(shape_pos_en));

    
    
    //needs FSM control
    logic shape_reset;
    
    //Shape1 Register Logic
    logic shape1reg_en;
    logic shape1Q;

    assign shape1reg_en = (~(shape1Q[2] | shape1Q[1] | shape1Q[0]) 
                           & shape_pos_en[3]);
    Register #(3) Shape1Reg (.en(shape1reg_en), .clear(shape_reset),
                             .clock(CLOCK100), .D(LoadShape), .Q(shape1Q));

    //Shape 2 Register Logic                       
    logic shape2reg_en;
    logic shape2Q;
    
    assign shape2reg_en = (~(shape2Q[2] | shape2Q[1] | shape2Q[0]) 
                           & shape_pos_en[2]);
    Register #(3) Shape2Reg (.en(shape2reg_en), .clear(shape_reset),
                             .clock(CLOCK100), .D(LoadShape), .Q(shape2Q));

    //Shape 3 Register Logic                       
    logic shape3reg_en;
    logic shape3Q;
    
    assign shape3reg_en = (~(shape3Q[2] | shape3Q[1] | shape3Q[0]) 
                           & shape_pos_en[1]);
    Register #(3) Shape3Reg (.en(shape3reg_en), .clear(shape_reset),
                             .clock(CLOCK100), .D(LoadShape), .Q(shape3Q));

    //Shape 4 Register Logic                       
    logic shape4reg_en;
    logic shape4Q;
    
    assign shape4reg_en = (~(shape4Q[2] | shape4Q[1] | shape4Q[0]) 
                           & shape_pos_en[0]);
    Register #(3) Shape4Reg (.en(shape4reg_en), .clear(shape_reset),
                             .clock(CLOCK100), .D(LoadShape), .Q(shape4Q));

    assign loaded = (~(shape1Q[2] | shape1Q[1] | shape1Q[0]) &
                     ~(shape2Q[2] | shape2Q[1] | shape2Q[0]) &
                     ~(shape3Q[2] | shape3Q[1] | shape3Q[0]) &
                     ~(shape4Q[2] | shape4Q[1] | shape4Q[0]))

