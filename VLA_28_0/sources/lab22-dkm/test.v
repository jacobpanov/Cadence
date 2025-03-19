`timescale 1 ns / 100 ps

module test;
 
  // nets and variables
  reg        CLK             ;
  reg        RST             ;
  reg        LOAD_COINS      ;
  reg        LOAD_CANS       ;
  reg  [7:0] NICKELS         ;
  reg  [7:0] DIMES           ;
  reg  [7:0] CANS            ;
  reg        NICKEL_IN       ;
  reg        DIME_IN         ;
  reg        QUARTER_IN      ;
  wire       EMPTY           ;
  wire       DISPENSE        ;
  wire       NICKEL_OUT      ;
  wire       DIME_OUT        ;
  wire       TWO_DIME_OUT    ;
  wire       USE_EXACT       ;

  // instance of drink machine
  dkm
  dkm_inst
  (
    CLK             ,
    RST             ,
    LOAD_COINS      ,
    LOAD_CANS       ,
    NICKELS         ,
    DIMES           ,
    CANS            ,
    NICKEL_IN       ,
    DIME_IN         ,
    QUARTER_IN      ,
    EMPTY           ,
    DISPENSE        ,
    NICKEL_OUT      ,
    DIME_OUT        ,
    TWO_DIME_OUT    ,
    USE_EXACT        
  );


  task reset;
    begin
      @(negedge CLK);
      RST        <= 1 ;
      LOAD_COINS <= 0 ;
      LOAD_CANS  <= 0 ;
      NICKEL_IN  <= 0 ;
      DIME_IN    <= 0 ;
      QUARTER_IN <= 0 ;
      @(negedge CLK);
      RST        <= 0 ;
    end
  endtask

  task add_coins;
    input integer nickels  ;
    input integer dimes    ;
    begin
      @(negedge CLK);
      NICKELS    <= nickels ;
      DIMES      <= dimes   ;
      LOAD_COINS <= 1       ;
      @(negedge CLK);
      LOAD_COINS <= 0       ;
    end
  endtask

  task add_cans;
    input integer cans ;
    begin
      @(negedge CLK);
      CANS      <= cans    ;
      LOAD_CANS <= 1       ;
      @(negedge CLK);
      LOAD_CANS <= 0       ;
    end
  endtask

  task insert_nickel;
    begin
      @(negedge CLK);
      NICKEL_IN <= 1 ;
      @(negedge CLK);
      NICKEL_IN <= 0 ;
    end
  endtask

  task insert_dime;
    begin
      @(negedge CLK);
      DIME_IN <= 1 ;
      @(negedge CLK);
      DIME_IN <= 0 ;
    end
  endtask

  task insert_quarter;
    begin
      @(negedge CLK);
      QUARTER_IN <= 1 ;
      @(negedge CLK);
      QUARTER_IN <= 0 ;
    end
  endtask

  task expect;
    input  expect_empty        ;
    input  expect_dispense     ;
    input  expect_nickel_out   ;
    input  expect_dime_out     ;
    input  expect_two_dime_out ;
    input  expect_use_exact    ;
    if ( EMPTY        !== expect_empty
      || DISPENSE     !== expect_dispense
      || NICKEL_OUT   !== expect_nickel_out
      || DIME_OUT     !== expect_dime_out
      || TWO_DIME_OUT !== expect_two_dime_out
      || USE_EXACT    !== expect_use_exact )
      begin
      end
  endtask

  // clock
  initial repeat (62) begin CLK=1; #0.5; CLK=0; #0.5; end

  initial
    begin : TEST
      integer interactive;
      $display ("CANS 1 ;  COINS 0,0 ;  INSERT 0,0,2"); // 50
      reset;           expect (1, 0, 0, 0, 0, 1); // EMPTY, USE_EXACT
      add_cans(1);     expect (0, 0, 0, 0, 0, 1); // USE_EXACT
      insert_quarter;  expect (0, 0, 0, 0, 0, 1); // USE_EXACT
      insert_quarter;  expect (1, 1, 0, 0, 0, 1); // EMPTY, DISPENSE, USE_EXACT
      $display ("CANS 1 ;  COINS 1,2 ;  INSERT 0,3,1"); // 55
      reset;           expect (1, 0, 0, 0, 0, 1); // EMPTY, USE_EXACT
      add_cans(1);     expect (0, 0, 0, 0, 0, 1); // USE_EXACT
      add_coins(1,2);  expect (0, 0, 0, 0, 0, 0);
      insert_dime;     expect (0, 0, 0, 0, 0, 0);
      insert_dime;     expect (0, 0, 0, 0, 0, 0);
      insert_dime;     expect (0, 0, 0, 0, 0, 0);
      insert_quarter;  expect (1, 1, 1, 0, 0, 1); // EMPTY, DISPENSE, NICKEL_OUT, USE_EXACT
      $display ("CANS 1 ;  COINS 1,2 ;  INSERT 0,1,2"); // 60
      reset;           expect (1, 0, 0, 0, 0, 1); // EMPTY, USE_EXACT
      add_cans(1);     expect (0, 0, 0, 0, 0, 1); // USE_EXACT
      add_coins(1,2);  expect (0, 0, 0, 0, 0, 0);
      insert_dime;     expect (0, 0, 0, 0, 0, 0);
      insert_quarter;  expect (0, 0, 0, 0, 0, 0);
      insert_quarter;  expect (1, 1, 0, 1, 0, 1); // EMPTY, DISPENSE, DIME_OUT, USE_EXACT
      $display ("CANS 1 ;  COINS 2,3 ;  INSERT 1,1,2"); // 65
      reset;           expect (1, 0, 0, 0, 0, 1); // EMPTY, USE_EXACT
      add_cans(1);     expect (0, 0, 0, 0, 0, 1); // USE_EXACT
      add_coins(2,3);  expect (0, 0, 0, 0, 0, 0);
      insert_nickel;   expect (0, 0, 0, 0, 0, 0);
      insert_dime;     expect (0, 0, 0, 0, 0, 0);
      insert_quarter;  expect (0, 0, 0, 0, 0, 0);
      insert_quarter;  expect (1, 1, 1, 1, 0, 0); // EMPTY, DISPENSE, NICKEL_OUT, DIME_OUT
      $display ("CANS 1 ;  COINS 1,4 ;  INSERT 1,1,2"); // 70
      reset;           expect (1, 0, 0, 0, 0, 1); // EMPTY, USE_EXACT
      add_cans(1);     expect (0, 0, 0, 0, 0, 1); // USE_EXACT
      add_coins(1,4);  expect (0, 0, 0, 0, 0, 0);
      insert_dime;     expect (0, 0, 0, 0, 0, 0);
      insert_dime;     expect (0, 0, 0, 0, 0, 0);
      insert_quarter;  expect (0, 0, 0, 0, 0, 0);
      insert_quarter;  expect (1, 1, 0, 0, 1, 0); // EMPTY, DISPENSE, TWO_DIME_OUT
    end

endmodule

