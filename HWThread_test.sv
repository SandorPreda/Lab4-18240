// `default_nettype none;

module HWThreadTest;
    // Control points
    logic add_or_sub;
    logic tc_en;
    logic another_round;
    logic shape_reset;
    logic R_en_grader, R_clear_grader;
    logic count_cl;

    // Status points
    logic loaded;
    logic startgame_real;
    logic gamedone;
    logic reset;
    logic clock;
    logic GradeIt, GameWon;
    logic CoinInserted;

    // Other pieces
    logic [1:0] CoinValue;
    logic [11:0] Guess;
    logic StartGame, LoadShapeNow;
    logic [2:0] LoadShape;
    logic [1:0] ShapeLocation;
    logic [3:0] Zood, Znarly;
    logic [3:0] NumGames, RoundNumber;
    logic [11:0] MasterPattern;

    logic LoadNumGames, LoadGuess, ClearGame;
    logic DisplayMasterPattern, LoadZnarlyZood;
    logic [2:0] outputState;
    logic gameWonLED;

    //FSM
    systemFSM fsm (.*);
    mainHardware hwthread (.*);

  initial begin
    clock = 0;
    forever #1 clock = ~clock;
  end

  enum logic [2:0] {
    T = 3'b001,
    C = 3'b010,
    O = 3'b011,
    D = 3'b100,
    I = 3'b101,
    Z = 3'b110
  } firstGuess, secondGuess, thirdGuess, fourthGuess;
  assign Guess = {firstGuess, secondGuess, thirdGuess, fourthGuess};

  initial begin
    $monitor($time,, "State=%s|CoinValue=%b|NumGames=%b|MasterPattern=%b",
             fsm.currState.name, CoinValue, NumGames, MasterPattern);

    // Initialize States:
    CoinValue <= 2'd0;
    ShapeLocation <= 2'd0;
    LoadShape <= 3'd0;
    LoadShapeNow <= 3'd0;
    reset <= 1;

    @(posedge clock);
    #5 reset <= 0; // Release Reset

    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);

    StartGame <= 1; // Should do nothing since we have no credits
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    StartGame <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);

    // Loading coins in
    CoinInserted <= 1;
    CoinValue <= 2'd3; // Pentagon (NumGames = 1)
    #10;
    @(posedge clock);
    CoinInserted <= 0;
    @(posedge clock);
    @(posedge clock);
    CoinValue <= 2'd0;
    

    #5;
    CoinInserted <= 1;
    CoinValue <= 2'd3; // Pentagon (NumGames = 2)
    #10;
    CoinInserted <= 0;
    @(posedge clock);
    CoinValue <= 2'd0;

    #5;
    CoinInserted <= 1;
    CoinValue <= 2'd2; // Triangle (NumGames = 3)
    #10;
    CoinInserted <= 0;
    @(posedge clock);
    CoinValue <= 2'd0;

    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    


    // Starting the game... (NumGames = 2)
    StartGame <= 1;
    @(posedge clock);
    StartGame <= 0;
    LoadShapeNow <= 1;
    @(posedge clock);

    ShapeLocation <= 2'd0; // Loading the 0th index of the master pattern
    LoadShape <= 3'b011; // O
    LoadShapeNow <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);


    ShapeLocation <= 2'd1; // Loading the 1st index of the master pattern
    LoadShape <= 3'b100; // D
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);

    ShapeLocation <= 2'd3; // Loading the 3rd index of the master pattern
    LoadShape <= 3'b001; // T
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);

    ShapeLocation <= 2'd3; // Reloading the 3rd index (should do nothing)
    LoadShape <= 3'b110; // Z
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);

    ShapeLocation <= 2'd2; // Loading the 2nd index of the master pattern
    LoadShape <= 3'b001; // T
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);

    ShapeLocation <= 2'd0; // Reloading the 0th index (should do nothing)
    LoadShape <= 3'b110; // Z
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);

    // The master pattern is set, and further loads should have no effect
    // The master pattern should be: TTDO
    LoadShapeNow <= 0;
    ShapeLocation <= 2'd2; // Reloading the 0th index (should do nothing)
    LoadShape <= 3'b101; // I
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    
    

    // First Guess: TTTD (1 Zood, 2 Znarly)
    @(posedge clock);
    {firstGuess, secondGuess, thirdGuess, fourthGuess} <= {T, T, T, D};
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);


    // Second Guess: ODTT (4 Zood, 0 Znarly)
    @(posedge clock);
    {firstGuess, secondGuess, thirdGuess, fourthGuess} <= {O, D, T, T};
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
   
    // Third Guess: TTTD (1 Zood, 2 Znarly)
    @(posedge clock);
    {firstGuess, secondGuess, thirdGuess, fourthGuess} <= {T, T, D, O};
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 1;
    @(posedge clock);
    GradeIt <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);

    #5 $finish;

    // Fourth Guess: ODTT (4 Zood, 0 Znarly)

    @(posedge clock);
    {firstGuess, secondGuess, thirdGuess, fourthGuess} <= {O, D, T, T};
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);

    // Third Guess: TTTD (1 Zood, 2 Znarly)
    @(posedge clock);
    {firstGuess, secondGuess, thirdGuess, fourthGuess} <= {T, T, T, D};
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);


    // Fourth Guess: ODTT (4 Zood, 0 Znarly)
    @(posedge clock);
    {firstGuess, secondGuess, thirdGuess, fourthGuess} <= {O, D, T, T};
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);

    // Fifth Guess: TTTD (1 Zood, 2 Znarly)
    @(posedge clock);
    {firstGuess, secondGuess, thirdGuess, fourthGuess} <= {T, T, T, D};
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);


    // Sixth Guess: ODTT (4 Zood, 0 Znarly)
    @(posedge clock);
    {firstGuess, secondGuess, thirdGuess, fourthGuess} <= {O, D, T, T};
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);

    // Seventh Guess: TTTD (1 Zood, 2 Znarly)
    @(posedge clock);
    {firstGuess, secondGuess, thirdGuess, fourthGuess} <= {T, T, T, D};
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);


    // Eighth Guess: ODTT (4 Zood, 0 Znarly)
    @(posedge clock);
    {firstGuess, secondGuess, thirdGuess, fourthGuess} <= {O, D, T, T};
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);

    // Nine Guess: TTTD (1 Zood, 2 Znarly) Should not get here
    @(posedge clock);
    {firstGuess, secondGuess, thirdGuess, fourthGuess} <= {T, T, T, D};
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);

    // Final Guess: TTDO (0 Zood, 4 Znarly)
    @(posedge clock);
    {firstGuess, secondGuess, thirdGuess, fourthGuess} <= {T, T, D, O};
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 1;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    GradeIt <= 0;
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);

    #5 $finish;

    // Now return to the initial state
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    @(posedge clock);
    #20 $finish;

  end

endmodule: HWThreadTest