`default_nettype none;

module HWThreadTest;

  logic [1:0] CoinValue, ShapeLocation;
  logic [2:0] LoadShape;
  logic [3:0] Znarly, Zood, RoundNumber, NumGames;
  logic [11:0] Guess;
  logic CoinInserted, StartGame, GradeIt, LoadShapeNow, GameWon, reset, clock;

  initial begin
    assign clock = 0;
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

  HWThread DUT(.*);

  initial begin
    $monitor($time,, "etc.");

    // Initialize States:
    CoinValue <= 2'd0;
    ShapeLocation <= 2'd0;
    LoadShape <= 3'd0;
    LoadShapeNow <= 3'd0;
    Znarly <= 4'd0; Zood <= 4'd0;
    RoundNumber <= 4'd0;
    NumGames <= 4'd0;
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
    coinValue <= 2'd3; // Pentagon (NumGames = 1)
    @(posedge clock);
    coinValue <= 2'd0;

    #5 coinValue <= 2'd3; // Pentagon (NumGames = 2)
    @(posedge clock);
    coinValue <= 2'd0;

    #5 coinValue <= 2'd2; // Triangle (NumGames = 3)
    @(posedge clock);
    coinValue <= 2'd0;

    @(posedge clock);
    @(posedge clock);
    @(posedge clock);

    // Starting the game... (NumGames = 2)
    StartGame <= 1;
    LoadShapeNow <= 1;
    @(posedge clock);

    ShapeLocation <= 2'd0; // Loading the 0th index of the master pattern
    LoadShape <= 3'b011; // O
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
    {firstShape, secondShape, thirdShape, fourthShape} <= {T, T, T, D};
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
    {firstShape, secondShape, thirdShape, fourthShape} <= {O, D, T, T};
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
    {firstShape, secondShape, thirdShape, fourthShape} <= {T, T, D, O};
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