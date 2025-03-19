`timescale 1 ns / 1 ns

module dkm
(
  input  wire       CLK             ,
  input  wire       RST             ,
  input  wire       LOAD_COINS      ,
  input  wire       LOAD_CANS       ,
  input  wire [7:0] NICKELS         ,
  input  wire [7:0] DIMES           ,
  input  wire [7:0] CANS            ,
  input  wire       NICKEL_IN       ,
  input  wire       DIME_IN         ,
  input  wire       QUARTER_IN      ,
  output reg        EMPTY           ,
  output reg        DISPENSE        ,
  output reg        NICKEL_OUT      ,
  output reg        DIME_OUT        ,
  output reg        TWO_DIME_OUT    ,
  output reg        USE_EXACT        
) ;

  integer count_cans    ;
  integer count_nickels ;
  integer count_dimes   ;
  integer count_deposit ;


  task check_exact;
    input integer temp_count_nickels  ;
    input integer temp_count_dimes    ;
    USE_EXACT <= ( temp_count_nickels < 1 || temp_count_dimes < 2 ) ;
  endtask


  task add_coins;
    integer temp_count_nickels ;
    integer temp_count_dimes   ;
    begin
      temp_count_nickels  = count_nickels  + NICKELS  ;
      temp_count_dimes    = count_dimes    + DIMES    ;
      check_exact (temp_count_nickels, temp_count_dimes) ;
      count_nickels  <= temp_count_nickels  ;
      count_dimes    <= temp_count_dimes    ;
    end
  endtask


  task add_cans;
    begin
      count_cans <= count_cans + CANS ;
      EMPTY      <= 0 ;
    end
  endtask


  task dispense_can;
    begin
      DISPENSE      <= 1 ;
      EMPTY         <= (count_cans == 1 ) ;
      count_cans    <= count_cans - 1 ;
      count_deposit <= 0 ;
    end
  endtask

  task issue_nickels;
    input integer count ;
    integer temp_count_nickels ;
    begin
      temp_count_nickels  = count_nickels - count ;
      check_exact (temp_count_nickels, count_dimes) ;
      count_nickels <= temp_count_nickels ;
      NICKEL_OUT <= 1 ;
    end
  endtask


  task issue_dimes;
    input integer count ;
    integer temp_count_dimes ;
    begin
      temp_count_dimes  = count_dimes - count ;
      check_exact (count_nickels, temp_count_dimes) ;
      count_dimes <= temp_count_dimes ;
      if ( count == 1 ) DIME_OUT <= 1; else TWO_DIME_OUT <= 1;
    end
  endtask


  task make_change;
    input integer temp_count_deposit;
    integer change_back;
    begin
      change_back = temp_count_deposit - 50 ;
      case ( change_back ) // parallel case
         5: if ( count_nickels >= 1 ) issue_nickels (1) ;
        10: if ( count_dimes   >= 1 ) issue_dimes   (1) ; else
         // if ( count_nickels >= 2 ) issue_nickels (2) ; else
            if ( count_nickels >= 1 ) issue_nickels (1) ; // short change
        15: if ( count_dimes   >= 1 )
              begin
                issue_dimes (1) ;
                if ( count_nickels >= 1 ) issue_nickels (1) ;
              end
            else
           // if ( count_nickels >= 3 ) issue_nickels (3) ; else
           // if ( count_nickels >= 2 ) issue_nickels (2) ; else // short change
              if ( count_nickels >= 1 ) issue_nickels (1) ;      // short change
        20: if ( count_dimes >= 2 ) issue_dimes (2) ; else
            if ( count_dimes >= 1 )
              begin
               issue_dimes (1) ;
            // if ( count_nickels >= 2 ) issue_nickels (2) ; else
               if ( count_nickels >= 1 ) issue_nickels (1) ; // short change
              end
            else
           // if ( count_nickels >= 4 ) issue_nickels (4) ; else
           // if ( count_nickels >= 3 ) issue_nickels (3) ; else // short change
           // if ( count_nickels >= 2 ) issue_nickels (2) ; else // short change
              if ( count_nickels >= 1 ) issue_nickels (1) ;      // short change
      endcase
    end
  endtask


  task transact;
    input integer value ;
    integer temp_count_deposit ;
    begin
      temp_count_deposit = count_deposit + value ;
      if ( temp_count_deposit < 50 )
        count_deposit <= temp_count_deposit ;
      else
        if ( !EMPTY )
          begin
            dispense_can;
            make_change (temp_count_deposit);
          end
    end
  endtask

  always @(posedge CLK)
    if ( RST )
      begin
        count_cans      <= 0 ;
        count_nickels   <= 0 ;
        count_dimes     <= 0 ;
        count_deposit   <= 0 ;
        EMPTY           <= 1 ;
        DISPENSE        <= 0 ;
        NICKEL_OUT      <= 0 ;
        DIME_OUT        <= 0 ;
        TWO_DIME_OUT    <= 0 ;
        USE_EXACT       <= 1 ;
      end
    else
      begin
        DISPENSE        <= 0;
        NICKEL_OUT      <= 0 ;
        DIME_OUT        <= 0 ;
        TWO_DIME_OUT    <= 0 ;
        case ( 1 ) // parallel case
          LOAD_COINS : add_coins;
          LOAD_CANS  : add_cans;
          NICKEL_IN  : transact(5);
          DIME_IN    : transact(10);
          QUARTER_IN : transact(25);
        endcase
      end

endmodule

