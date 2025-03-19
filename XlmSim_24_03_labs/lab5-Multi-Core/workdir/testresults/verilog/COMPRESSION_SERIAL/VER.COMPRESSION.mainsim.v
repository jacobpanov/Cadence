//***************************************************************************//
//                           VERILOG MAINSIM FILE                            //
//Cadence(R) Modus(TM) DFT Software Solution, Version 20.10-b013_1, built Apr//
//***************************************************************************//
//                                                                           //
//  FILE CREATED..............April 06, 2020 at 15:40:17                     //
//                                                                           //
//  PROJECT NAME..............workdir                                        //
//                                                                           //
//  TESTMODE..................COMPRESSION                                    //
//                                                                           //
//  TDR.......................dummy.tdr                                      //
//                                                                           //
//  TEST PERIOD...............80000.000TEST TIME UNITS...........ps          //
//  TEST PULSE WIDTH..........8000.000                                       //
//  TEST STROBE OFFSET........72000.000TEST STROBE TYPE..........edge        //
//  TEST BIDI OFFSET..........0.000                                          //
//  TEST PI OFFSET............0.000    X VALUE...................X           //
//                                                                           //
//  SCAN FORMAT...............serial   SCAN OVERLAP..............yes         //
//  SCAN PERIOD...............80000.000SCAN TIME UNITS...........ps          //
//  SCAN PULSE WIDTH..........8000.000                                       //
//  SCAN STROBE OFFSET........8000.000 SCAN STROBE TYPE..........edge        //
//  SCAN BIDI OFFSET..........0.000                                          //
//  SCAN PI OFFSET............0.000    X VALUE...................X           //
//                                                                           //
//                                                                           //
//   Individually set PIs                                                    //
//  "DFT_mask_clk" (PI # 2)                                                  //
//  TEST OFFSET...............8000.000                                       //
//  SCAN OFFSET...............16000.000PULSE WIDTH...............8000.000    //
//                                                                           //
//  "OPCG_LOADCLK" (PI # 5)                                                  //
//  TEST OFFSET...............8000.000                                       //
//  SCAN OFFSET...............16000.000PULSE WIDTH...............8000.000    //
//                                                                           //
//  "scan_clk" (PI # 49)                                                     //
//  TEST OFFSET...............8000.000 PULSE WIDTH...............8000.000    //
//  SCAN OFFSET...............16000.000PULSE WIDTH...............8000.000    //
//                                                                           //
//  Active TESTMODEs TM = 1 ..COMPRESSION                                    //
//                                                                           //
//***************************************************************************//

  `timescale 1 ps / 1 fs

  module workdir_COMPRESSION ;

//***************************************************************************//
//                DEFINE VARIABLES FOR ALL PRIMARY I/O PORTS                 //
//***************************************************************************//

  reg [1:53] stim_PIs;   
  reg [1:53] part_PIs;   

  reg [1:53] stim_CIs;   

  reg [1:42] meas_POs;   
  wire [1:42] part_POs;   

//***************************************************************************//
//                   DEFINE VARIABLES FOR ALL SHIFT CHAINS                   //
//***************************************************************************//

  reg [1:48] stim_CR_1;   reg [1:48] stim_CR_2;   reg [1:48] stim_CR_3;   

  reg [1:48] meas_OR_1;   reg [1:48] meas_OR_2;   reg [1:48] meas_OR_3;   


//***************************************************************************//
//       DEFINE VARIABLES FOR ALL CHANNEL MASK AND MASK ENABLE CHAINS        //
//***************************************************************************//

  reg [1:17] stim_CMSR_1;   reg [1:17] stim_CMSR_2;   reg [1:17] stim_CMSR_3;   



  reg [1:48] stim_CME_0;   

//***************************************************************************//
//                             OTHER DEFINITIONS                             //
//***************************************************************************//

  integer  CYCLE, SCANCYCLE, SERIALCYCLE, PInum, POnum, ORnum, MODENUM, EXPNUM, SCANOPNUM, SEQNUM, TASKNUM, START, NUM_SHIFTS, MultiShift, maxMultiShifts, MultiShiftsLeft, forcePointStart, forcePoint, SCANNUM ; 
  integer  CMD, DATAID, SAVEID, TID, num_files, rc_read, repeat_depth, repeat_heart, repeat_num, MAX, FAILSETID, DIAG_DATAID; 
  integer  test_num, test_num_prev, failed_test_num, num_tests, num_failed_tests, total_num_tests, total_num_failed_tests, total_cycles, scan_num, overlap; 
  integer  num_repeats [1:15]; 
  reg      [1:8185] name_POs [1:42]; 
  reg      [130:0] good_compares, miscompares, miscompare_limit, total_good_compares, total_miscompares, measure_current; 
  reg      [130:0] start_of_repeat [1:15]; 
  reg      [130:0] start_of_current_line, line_number, save_line_number, fseek_offset; 
  reg      sim_trace, sim_heart, sim_range, failset, global_term, sim_debug, sim_more_debug, diag_debug; 
  reg      [1:800] PATTERN, pattern, TESTFILE, INITFILE, SOD, EOD, eventID, DIAG_DEBUG_FILE; 
  reg      [1:8184] DATAFILE, SAVEFILE, COMMENT, FAILSET; 
  reg      [1:4096] PROCESSNAME; 

//***************************************************************************//
//        INSTANTIATE THE STRUCTURE AND CONNECT TO VERILOG VARIABLES         //
//***************************************************************************//

  dtmf_chip
    dtmf_chip_inst (
      .tdigit                 ({part_POs[0041]  ,      // pinName = tdigit[7]; 
                                part_POs[0040]  ,      // pinName = tdigit[6]; 
                                part_POs[0039]  ,      // pinName = tdigit[5]; 
                                part_POs[0038]  ,      // pinName = tdigit[4]; 
                                part_POs[0037]  ,      // pinName = tdigit[3]; 
                                part_POs[0036]  ,      // pinName = tdigit[2]; 
                                part_POs[0035]  ,      // pinName = tdigit[1]; 
                                part_POs[0034]}),      // pinName = tdigit[0]; 
      .tdigit_flag            ( part_POs[0042] ),      // pinName = tdigit_flag; 
      .reset                  ( part_PIs[0048] ),      // pinName = reset;  tf = -SC  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      .int                    ( part_PIs[0012] ),      // pinName = int; testOffset = 0.000000;  scanOffset = 0.000000;  
      .port_pad_data_out      ({part_POs[0024]  ,      // pinName = port_pad_data_out[15];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0023]  ,      // pinName = port_pad_data_out[14];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0022]  ,      // pinName = port_pad_data_out[13];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0021]  ,      // pinName = port_pad_data_out[12];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0020]  ,      // pinName = port_pad_data_out[11];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0019]  ,      // pinName = port_pad_data_out[10];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0033]  ,      // pinName = port_pad_data_out[9];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0032]  ,      // pinName = port_pad_data_out[8];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0031]  ,      // pinName = port_pad_data_out[7];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0030]  ,      // pinName = port_pad_data_out[6];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0029]  ,      // pinName = port_pad_data_out[5];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0028]  ,      // pinName = port_pad_data_out[4];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0027]  ,      // pinName = port_pad_data_out[3];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0026]  ,      // pinName = port_pad_data_out[2];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0025]  ,      // pinName = port_pad_data_out[1];  tf =  SO1 ZSE  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0018]}),      // pinName = port_pad_data_out[0];  tf =  SO  ZSE  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      .port_pad_data_in       ({part_POs[0008]  ,      // pinName = port_pad_data_in[15];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0007]  ,      // pinName = port_pad_data_in[14];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0006]  ,      // pinName = port_pad_data_in[13];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0005]  ,      // pinName = port_pad_data_in[12];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0004]  ,      // pinName = port_pad_data_in[11];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0003]  ,      // pinName = port_pad_data_in[10];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0017]  ,      // pinName = port_pad_data_in[9];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0016]  ,      // pinName = port_pad_data_in[8];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0015]  ,      // pinName = port_pad_data_in[7];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0014]  ,      // pinName = port_pad_data_in[6];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0013]  ,      // pinName = port_pad_data_in[5];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0012]  ,      // pinName = port_pad_data_in[4];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0011]  ,      // pinName = port_pad_data_in[3];  tf =  SO2 ZSE  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0010]  ,      // pinName = port_pad_data_in[2];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0009]  ,      // pinName = port_pad_data_in[1];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
                                part_POs[0002]}),      // pinName = port_pad_data_in[0];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      .scan_en                ( part_PIs[0050] ),      // pinName = scan_en;  tf = +SE  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      .scan_clk               ( part_PIs[0049] ),      // pinName = scan_clk;  tf = -ES  ; testOffset = 8000.000000;  scanOffset = 16000.000000;  
      .mbist_test_mode        ( part_PIs[0013] ),      // pinName = mbist_test_mode;  tf = -TI  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      .test_mode              ( part_PIs[0053] ),      // pinName = test_mode;  tf = +TI  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      .spi_data               ( part_PIs[0051] ),      // pinName = spi_data; testOffset = 0.000000;  scanOffset = 0.000000;  
      .spi_fs                 ( part_PIs[0052] ),      // pinName = spi_fs;  tf = -TI  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      .refclk                 ( part_PIs[0047] ),      // pinName = refclk; testOffset = 0.000000;  scanOffset = 0.000000;  
      .pllrst                 ( part_PIs[0014] ),      // pinName = pllrst; testOffset = 0.000000;  scanOffset = 0.000000;  
      .TDI                    ( part_PIs[0008] ),      // pinName = TDI; testOffset = 0.000000;  scanOffset = 0.000000;  
      .TMS                    ( part_PIs[0009] ),      // pinName = TMS; testOffset = 0.000000;  scanOffset = 0.000000;  
      .TCK                    ( part_PIs[0007] ),      // pinName = TCK; testOffset = 0.000000;  scanOffset = 0.000000;  
      .TRST                   ( part_PIs[0011] ),      // pinName = TRST; testOffset = 0.000000;  scanOffset = 0.000000;  
      .TDO                    ( part_POs[0001] ),      // pinName = TDO; 
      .TRIGGER                ( part_PIs[0010] ),      // pinName = TRIGGER;  tf = +TI  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      .OPCG_ON                ( part_PIs[0006] ),      // pinName = OPCG_ON;  tf = -TI  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      .OPCG_LOADCLK           ( part_PIs[0005] ),      // pinName = OPCG_LOADCLK;  tf = -ES  ; testOffset = 8000.000000;  scanOffset = 16000.000000;  
      .DFT_compression_enable ( part_PIs[0001] ),      // pinName = DFT_compression_enable;  tf = +SE  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      .DFT_spreader           ( part_PIs[0004] ),      // pinName = DFT_spreader;  tf = +SE  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      .DFT_mask_enable        ( part_PIs[0003] ),      // pinName = DFT_mask_enable;  tf = -TC  -CME  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      .DFT_mask_clk           ( part_PIs[0002] )     // pinName = DFT_mask_clk;  tf = -CML  ; testOffset = 8000.000000;  scanOffset = 16000.000000;  
      );

//***************************************************************************//
//                        MAKE SOME OTHER CONNECTIONS                        //
//***************************************************************************//

  assign // BiDi Connections 
    part_POs [2] = part_PIs [15],     // pinName = port_pad_data_in[0];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [3] = part_PIs [16],     // pinName = port_pad_data_in[10];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [4] = part_PIs [17],     // pinName = port_pad_data_in[11];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [5] = part_PIs [18],     // pinName = port_pad_data_in[12];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [6] = part_PIs [19],     // pinName = port_pad_data_in[13];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [7] = part_PIs [20],     // pinName = port_pad_data_in[14];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [8] = part_PIs [21],     // pinName = port_pad_data_in[15];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [9] = part_PIs [22],     // pinName = port_pad_data_in[1];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [10] = part_PIs [23],     // pinName = port_pad_data_in[2];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [11] = part_PIs [24],     // pinName = port_pad_data_in[3];  tf = ZSE   SO2 BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [12] = part_PIs [25],     // pinName = port_pad_data_in[4];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [13] = part_PIs [26],     // pinName = port_pad_data_in[5];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [14] = part_PIs [27],     // pinName = port_pad_data_in[6];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [15] = part_PIs [28],     // pinName = port_pad_data_in[7];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [16] = part_PIs [29],     // pinName = port_pad_data_in[8];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [17] = part_PIs [30],     // pinName = port_pad_data_in[9];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [18] = part_PIs [31],     // pinName = port_pad_data_out[0];  tf = ZSE   SO  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [19] = part_PIs [32],     // pinName = port_pad_data_out[10];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [20] = part_PIs [33],     // pinName = port_pad_data_out[11];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [21] = part_PIs [34],     // pinName = port_pad_data_out[12];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [22] = part_PIs [35],     // pinName = port_pad_data_out[13];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [23] = part_PIs [36],     // pinName = port_pad_data_out[14];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [24] = part_PIs [37],     // pinName = port_pad_data_out[15];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [25] = part_PIs [38],     // pinName = port_pad_data_out[1];  tf = ZSE   SO1 BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [26] = part_PIs [39],     // pinName = port_pad_data_out[2];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [27] = part_PIs [40],     // pinName = port_pad_data_out[3];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [28] = part_PIs [41],     // pinName = port_pad_data_out[4];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [29] = part_PIs [42],     // pinName = port_pad_data_out[5];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [30] = part_PIs [43],     // pinName = port_pad_data_out[6];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [31] = part_PIs [44],     // pinName = port_pad_data_out[7];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [32] = part_PIs [45],     // pinName = port_pad_data_out[8];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [33] = part_PIs [46];      // pinName = port_pad_data_out[9];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
  assign ( weak0, weak1 ) // Termination 
    part_POs [1] = global_term,     // pinName = TDO; 
    part_POs [2] = global_term,     // pinName = port_pad_data_in[0];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [3] = global_term,     // pinName = port_pad_data_in[10];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [4] = global_term,     // pinName = port_pad_data_in[11];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [5] = global_term,     // pinName = port_pad_data_in[12];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [6] = global_term,     // pinName = port_pad_data_in[13];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [7] = global_term,     // pinName = port_pad_data_in[14];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [8] = global_term,     // pinName = port_pad_data_in[15];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [9] = global_term,     // pinName = port_pad_data_in[1];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [10] = global_term,     // pinName = port_pad_data_in[2];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [11] = global_term,     // pinName = port_pad_data_in[3];  tf =  SO2 ZSE  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [12] = global_term,     // pinName = port_pad_data_in[4];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [13] = global_term,     // pinName = port_pad_data_in[5];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [14] = global_term,     // pinName = port_pad_data_in[6];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [15] = global_term,     // pinName = port_pad_data_in[7];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [16] = global_term,     // pinName = port_pad_data_in[8];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [17] = global_term,     // pinName = port_pad_data_in[9];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [18] = global_term,     // pinName = port_pad_data_out[0];  tf =  SO  ZSE  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [19] = global_term,     // pinName = port_pad_data_out[10];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [20] = global_term,     // pinName = port_pad_data_out[11];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [21] = global_term,     // pinName = port_pad_data_out[12];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [22] = global_term,     // pinName = port_pad_data_out[13];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [23] = global_term,     // pinName = port_pad_data_out[14];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [24] = global_term,     // pinName = port_pad_data_out[15];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [25] = global_term,     // pinName = port_pad_data_out[1];  tf =  SO1 ZSE  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [26] = global_term,     // pinName = port_pad_data_out[2];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [27] = global_term,     // pinName = port_pad_data_out[3];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [28] = global_term,     // pinName = port_pad_data_out[4];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [29] = global_term,     // pinName = port_pad_data_out[5];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [30] = global_term,     // pinName = port_pad_data_out[6];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [31] = global_term,     // pinName = port_pad_data_out[7];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [32] = global_term,     // pinName = port_pad_data_out[8];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [33] = global_term,     // pinName = port_pad_data_out[9];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
    part_POs [34] = global_term,     // pinName = tdigit[0]; 
    part_POs [35] = global_term,     // pinName = tdigit[1]; 
    part_POs [36] = global_term,     // pinName = tdigit[2]; 
    part_POs [37] = global_term,     // pinName = tdigit[3]; 
    part_POs [38] = global_term,     // pinName = tdigit[4]; 
    part_POs [39] = global_term,     // pinName = tdigit[5]; 
    part_POs [40] = global_term,     // pinName = tdigit[6]; 
    part_POs [41] = global_term,     // pinName = tdigit[7]; 
    part_POs [42] = global_term;      // pinName = tdigit_flag; 

//***************************************************************************//
//                     OPEN THE FILE AND RUN SIMULATION                      //
//***************************************************************************//

  initial 
    begin 

      $timeformat ( -12, 2, " ps", 10 ); 

      `ifdef sdf_annotate 
        `ifdef SDF_Minimum 
          $sdf_annotate ("default.sdf",dtmf_chip_inst,,"sdf_Min.log","MINIMUM");
        `endif 
        `ifdef SDF_Maximum 
          $sdf_annotate ("default.sdf",dtmf_chip_inst,,"sdf_Max.log","MAXIMUM");
        `endif 
        `ifdef SDF_Typical
          $sdf_annotate ("default.sdf",dtmf_chip_inst,,"sdf_Typ.log","TYPICAL");
        `endif 
      `endif 

      `ifndef NOT_NC 
        if ( $test$plusargs ( "simvision" ) )  begin 
          $shm_open("simvision.shm"); 
          $shm_probe("AC"); 
        end  
      `endif 

      if ( $test$plusargs ( "vcd" ) )  begin 
        $dumpfile("out.vcd"); 
        $dumpvars(0,workdir_COMPRESSION ); 
      end  

      DATAFILE = 0; 
      sim_setup; 

      `ifdef MISCOMPAREDEBUG 
        diag_debug = 1'b0; 
        if ( $value$plusargs ( "MISCOMPAREDEBUGFILE=%s", DIAG_DEBUG_FILE )) begin 
          DIAG_DATAID = $fopen ( DIAG_DEBUG_FILE, "r" ); 
          if ( DIAG_DATAID ) begin 
            diag_debug = 1'b1; 
            $fclose ( DIAG_DATAID ); 
          end  
          else $display ( "\nERROR (TVE-951): Failed to open Diagnostic 'MISCOMPAREDEBUGFILE' file: %0s. \n", DIAG_DEBUG_FILE ); 
        end  
      `endif  

      num_files = 0; 
      for ( TID = 1; TID <= 99; TID = TID + 1 ) begin 
        $sformat ( TESTFILE, "TESTFILE%0d=%s", TID, "%s" ); 
        if ( $value$plusargs ( TESTFILE, DATAFILE )) begin 
          DATAID = $fopen ( DATAFILE, "r" ); 
          if ( DATAID )  begin 
            sim_vector_file; 
            num_files = num_files + 1; 
          end  
          else $display ( "\nERROR (TVE-951): Failed to open the file: %0s. \n", DATAFILE ); 
        end  
      end  

      if ( FAILSETID )  $fclose ( FAILSETID ); 

      if ( DATAFILE )  begin
        $display ( "\nINFO (TVE-203): Cumulative Results: " ); 
        $display ( "                      Number of Files Simulated:  %0d ", num_files ); 
        $display ( "                      Total Number of Cycles:     %0d ", total_cycles ); 
        $display ( "                      Total Number of Tests:      %0d ", total_num_tests ); 
        $display ( "                        - Total Passed Tests:     %0d ", total_num_tests - total_num_failed_tests ); 
        $display ( "                        - Total Failed Tests:     %0d ", total_num_failed_tests ); 
        $display ( "                      Total Number of Compares:   %0.0f ", total_good_compares + total_miscompares ); 
        $display ( "                        - Total Good Compares:    %0.0f ", total_good_compares ); 
        $display ( "                        - Total Miscompares:      %0.0f \n", total_miscompares ); 
      end  
      else $display ( "\nWARNING (TVE-661): No input data files found. The data file must be specified using +TESTFILE1=<string>, +TESTFILE2=<string>, ... The +TESTFILEn=<string> keyword is an NC-Sim command. \n" ); 

      $finish; 

    end  

//***************************************************************************//
//                     DEFINE SIMULATION SETUP PROCEDURE                     //
//***************************************************************************//

  task sim_setup; 
    begin 

      total_good_compares = 0; 
      total_miscompares = 0; 
      miscompare_limit = 0; 
      total_num_tests = 0; 
      total_num_failed_tests = 0; 
      total_cycles = 0; 
      SOD = ""; 
      EOD = ""; 
      START = 0; 
      NUM_SHIFTS = 0; 
      MAX = 1; 

      sim_heart = 1'b0; 
      sim_range = 1'b1; 
      sim_trace = 1'b0; 
      sim_debug = 1'b0; 
      sim_more_debug = 1'b0; 

      global_term = 1'bZ; 

      failset = 1'b0; 
      FAILSETID = 0; 

      CYCLE = 0; 
      SCANCYCLE = 0; 
      SERIALCYCLE = 0; 
      SEQNUM = 0; 
      name_POs [1] = "TDO";      // pinName = TDO; 
      name_POs [2] = "port_pad_data_in[0]";      // pinName = port_pad_data_in[0];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [3] = "port_pad_data_in[10]";      // pinName = port_pad_data_in[10];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [4] = "port_pad_data_in[11]";      // pinName = port_pad_data_in[11];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [5] = "port_pad_data_in[12]";      // pinName = port_pad_data_in[12];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [6] = "port_pad_data_in[13]";      // pinName = port_pad_data_in[13];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [7] = "port_pad_data_in[14]";      // pinName = port_pad_data_in[14];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [8] = "port_pad_data_in[15]";      // pinName = port_pad_data_in[15];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [9] = "port_pad_data_in[1]";      // pinName = port_pad_data_in[1];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [10] = "port_pad_data_in[2]";      // pinName = port_pad_data_in[2];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [11] = "port_pad_data_in[3]";      // pinName = port_pad_data_in[3];  tf =  SO2 ZSE  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [12] = "port_pad_data_in[4]";      // pinName = port_pad_data_in[4];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [13] = "port_pad_data_in[5]";      // pinName = port_pad_data_in[5];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [14] = "port_pad_data_in[6]";      // pinName = port_pad_data_in[6];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [15] = "port_pad_data_in[7]";      // pinName = port_pad_data_in[7];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [16] = "port_pad_data_in[8]";      // pinName = port_pad_data_in[8];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [17] = "port_pad_data_in[9]";      // pinName = port_pad_data_in[9];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [18] = "port_pad_data_out[0]";      // pinName = port_pad_data_out[0];  tf =  SO  ZSE  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [19] = "port_pad_data_out[10]";      // pinName = port_pad_data_out[10];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [20] = "port_pad_data_out[11]";      // pinName = port_pad_data_out[11];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [21] = "port_pad_data_out[12]";      // pinName = port_pad_data_out[12];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [22] = "port_pad_data_out[13]";      // pinName = port_pad_data_out[13];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [23] = "port_pad_data_out[14]";      // pinName = port_pad_data_out[14];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [24] = "port_pad_data_out[15]";      // pinName = port_pad_data_out[15];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [25] = "port_pad_data_out[1]";      // pinName = port_pad_data_out[1];  tf =  SO1 ZSE  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [26] = "port_pad_data_out[2]";      // pinName = port_pad_data_out[2];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [27] = "port_pad_data_out[3]";      // pinName = port_pad_data_out[3];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [28] = "port_pad_data_out[4]";      // pinName = port_pad_data_out[4];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [29] = "port_pad_data_out[5]";      // pinName = port_pad_data_out[5];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [30] = "port_pad_data_out[6]";      // pinName = port_pad_data_out[6];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [31] = "port_pad_data_out[7]";      // pinName = port_pad_data_out[7];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [32] = "port_pad_data_out[8]";      // pinName = port_pad_data_out[8];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [33] = "port_pad_data_out[9]";      // pinName = port_pad_data_out[9];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      name_POs [34] = "tdigit[0]";      // pinName = tdigit[0]; 
      name_POs [35] = "tdigit[1]";      // pinName = tdigit[1]; 
      name_POs [36] = "tdigit[2]";      // pinName = tdigit[2]; 
      name_POs [37] = "tdigit[3]";      // pinName = tdigit[3]; 
      name_POs [38] = "tdigit[4]";      // pinName = tdigit[4]; 
      name_POs [39] = "tdigit[5]";      // pinName = tdigit[5]; 
      name_POs [40] = "tdigit[6]";      // pinName = tdigit[6]; 
      name_POs [41] = "tdigit[7]";      // pinName = tdigit[7]; 
      name_POs [42] = "tdigit_flag";      // pinName = tdigit_flag; 



      if ( $test$plusargs ( "MODUS_DEBUG" ) )  sim_trace = 1'b1; 

      if ( $test$plusargs ( "HEARTBEAT" ) )  sim_heart = 1'b1; 

      if ( $value$plusargs ( "START_RANGE=%s", SOD ) )  sim_range = 1'b0; 

      if ( $value$plusargs ( "END_RANGE=%s", EOD ) ); 

      if ( $value$plusargs ( "miscompare_limit=%0f", miscompare_limit ) ); 

      if ( $test$plusargs ( "FAILSET" ) )  failset = 1'b1; 

      stim_PIs = {53{1'bX}};   
      stim_CIs = 53'bX0XX0XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0XXXX; 
      meas_POs = {42{1'bX}};   
      stim_CR_1 = {48{1'b0}};   stim_CR_2 = {48{1'b0}};   stim_CR_3 = {48{1'b0}};   
      meas_OR_1 = {48{1'bX}};   meas_OR_2 = {48{1'bX}};   meas_OR_3 = {48{1'bX}};   
      stim_CME_0 = {48{1'b0}};   
      stim_CMSR_1 = {17{1'b0}};   stim_CMSR_2 = {17{1'b0}};   stim_CMSR_3 = {17{1'b0}};   

    end  
  endtask  

//***************************************************************************//
//                          FAILSET SETUP PROCEDURE                          //
//***************************************************************************//

  task failset_setup; 
    begin 

      $sformat ( FAILSET, "%0s_FAILSET", DATAFILE ); 
      FAILSETID = $fopen ( FAILSET, "w" ); 
      if ( ! FAILSETID ) 
        $display ( "\nERROR (TVE-951): Failed to open the file: %0s. \n", FAILSET ); 

    end  
  endtask 

//***************************************************************************//
//                           SET UP FOR SIMULATION                           //
//***************************************************************************//

  task sim_vector_file; 
    begin 

      CYCLE = 0; 
      SCANCYCLE = 0; 
      SERIALCYCLE = 0; 
      good_compares = 0; 
      miscompares = 0; 
      measure_current = 0; 
      test_num = 0; 
      test_num_prev = 0; 
      failed_test_num = 0; 
      num_tests = 0; 
      num_failed_tests = 0; 
      scan_num = 0; 
      overlap = 0; 
      repeat_depth = 0; 
      repeat_heart = 1000; 


      $display ( "\nINFO (TVE-200): Simulating vector file: %0s ", DATAFILE ); 

      $display ( "\nINFO (TVE-204): Design:  dtmf_chip   Test Mode:  COMPRESSION   " ); 
      start_of_current_line = $ftell ( DATAID ); 
      line_number = 1; 
      rc_read = $fscanf ( DATAID, "%d", CMD ); 
      while (( rc_read > 0 ) && ( sim_range )) begin 

        cmd_code; 

        if ( rc_read > 0 )  begin 
          if ( sim_range )  begin 
            if (( miscompare_limit > 0 ) & ( miscompares > miscompare_limit ))  begin 
              sim_range = 1'b0; 
              if ( overlap )  num_tests = num_tests - 1; 
              $display ( "\nINFO (TVE-207): The miscompare limit (+miscompare_limit) of %0.0f has been reached. ", miscompare_limit ); 
            end  
            if ( EOD == pattern )  begin 
              sim_range = 1'b0; 
            end  
          end  
          if ( sim_range )  begin 
            start_of_current_line = $ftell ( DATAID ); 
            rc_read = $fscanf ( DATAID, "%d", CMD ); 
            if ( rc_read <= 0 )  begin 
              rc_read = $fgets ( COMMENT, DATAID ); 
              if ( rc_read > 0 )  bad_cmd_code; 
              else  line_number = 0; 
            end  
          end  
          else  line_number = 0; 
        end  
      end  

      if ( line_number == 0 )  begin
        $display ( "\nINFO (TVE-201): Simulation complete on vector file: %0s ", DATAFILE ); 
        $display ( "\nINFO (TVE-206): Results for vector file: %0s ", DATAFILE ); 
        $display ( "                      Number of Cycles:           %0d ", CYCLE ); 
        $display ( "                      Number of Tests:            %0d ", num_tests ); 
        $display ( "                        - Passed Tests:           %0d ", num_tests - num_failed_tests ); 
        $display ( "                        - Failed Tests:           %0d ", num_failed_tests ); 
        $display ( "                      Number of Compares:         %0.0f ", good_compares + miscompares ); 
        $display ( "                        - Good Compares:          %0.0f ", good_compares ); 
        $display ( "                        - Miscompares:            %0.0f ", miscompares ); 
        $display ( "                      Time:                       %t \n", $time ); 
      end  

      $fclose ( DATAID ); 

      total_good_compares = total_good_compares + good_compares; 

      total_miscompares = total_miscompares + miscompares; 

      total_num_tests = total_num_tests + num_tests; 

      total_num_failed_tests = total_num_failed_tests + num_failed_tests; 

      total_cycles = total_cycles + CYCLE; 

    end  
  endtask  

//***************************************************************************//
//                           DEFINE TEST PROCEDURE                           //
//***************************************************************************//

  task test_cycle; 
    begin 

      CYCLE = CYCLE + 1; 
      SERIALCYCLE = SERIALCYCLE + 1; 
     #0.000000;        // 0.000000 ps;  From the start of the cycle.
      part_PIs [1] = stim_PIs [1];      // pinName = DFT_compression_enable;  tf = +SE  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [3] = stim_PIs [3];      // pinName = DFT_mask_enable;  tf = -TC  -CME  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [4] = stim_PIs [4];      // pinName = DFT_spreader;  tf = +SE  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [6] = stim_PIs [6];      // pinName = OPCG_ON;  tf = -TI  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [7] = stim_PIs [7];      // pinName = TCK; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [8] = stim_PIs [8];      // pinName = TDI; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [9] = stim_PIs [9];      // pinName = TMS; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [10] = stim_PIs [10];      // pinName = TRIGGER;  tf = +TI  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [11] = stim_PIs [11];      // pinName = TRST; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [12] = stim_PIs [12];      // pinName = int; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [13] = stim_PIs [13];      // pinName = mbist_test_mode;  tf = -TI  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [14] = stim_PIs [14];      // pinName = pllrst; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [47] = stim_PIs [47];      // pinName = refclk; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [48] = stim_PIs [48];      // pinName = reset;  tf = -SC  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [50] = stim_PIs [50];      // pinName = scan_en;  tf = +SE  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [51] = stim_PIs [51];      // pinName = spi_data; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [52] = stim_PIs [52];      // pinName = spi_fs;  tf = -TI  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [53] = stim_PIs [53];      // pinName = test_mode;  tf = +TI  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [15] = stim_PIs [15];      // pinName = port_pad_data_in[0];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [16] = stim_PIs [16];      // pinName = port_pad_data_in[10];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [17] = stim_PIs [17];      // pinName = port_pad_data_in[11];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [18] = stim_PIs [18];      // pinName = port_pad_data_in[12];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [19] = stim_PIs [19];      // pinName = port_pad_data_in[13];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [20] = stim_PIs [20];      // pinName = port_pad_data_in[14];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [21] = stim_PIs [21];      // pinName = port_pad_data_in[15];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [22] = stim_PIs [22];      // pinName = port_pad_data_in[1];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [23] = stim_PIs [23];      // pinName = port_pad_data_in[2];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [24] = stim_PIs [24];      // pinName = port_pad_data_in[3];  tf = ZSE   SO2 BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [25] = stim_PIs [25];      // pinName = port_pad_data_in[4];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [26] = stim_PIs [26];      // pinName = port_pad_data_in[5];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [27] = stim_PIs [27];      // pinName = port_pad_data_in[6];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [28] = stim_PIs [28];      // pinName = port_pad_data_in[7];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [29] = stim_PIs [29];      // pinName = port_pad_data_in[8];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [30] = stim_PIs [30];      // pinName = port_pad_data_in[9];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [31] = stim_PIs [31];      // pinName = port_pad_data_out[0];  tf = ZSE   SO  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [32] = stim_PIs [32];      // pinName = port_pad_data_out[10];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [33] = stim_PIs [33];      // pinName = port_pad_data_out[11];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [34] = stim_PIs [34];      // pinName = port_pad_data_out[12];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [35] = stim_PIs [35];      // pinName = port_pad_data_out[13];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [36] = stim_PIs [36];      // pinName = port_pad_data_out[14];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [37] = stim_PIs [37];      // pinName = port_pad_data_out[15];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [38] = stim_PIs [38];      // pinName = port_pad_data_out[1];  tf = ZSE   SO1 BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [39] = stim_PIs [39];      // pinName = port_pad_data_out[2];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [40] = stim_PIs [40];      // pinName = port_pad_data_out[3];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [41] = stim_PIs [41];      // pinName = port_pad_data_out[4];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [42] = stim_PIs [42];      // pinName = port_pad_data_out[5];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [43] = stim_PIs [43];      // pinName = port_pad_data_out[6];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [44] = stim_PIs [44];      // pinName = port_pad_data_out[7];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [45] = stim_PIs [45];      // pinName = port_pad_data_out[8];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [46] = stim_PIs [46];      // pinName = port_pad_data_out[9];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
     #8000.000000;        // 8000.000000 ps;  From the start of the cycle.
      part_PIs [2] = stim_PIs [2];      // pinName = DFT_mask_clk;  tf = -CML  ; testOffset = 8000.000000;  scanOffset = 16000.000000;  
      part_PIs [5] = stim_PIs [5];      // pinName = OPCG_LOADCLK;  tf = -ES  ; testOffset = 8000.000000;  scanOffset = 16000.000000;  
      part_PIs [49] = stim_PIs [49];      // pinName = scan_clk;  tf = -ES  ; testOffset = 8000.000000;  scanOffset = 16000.000000;  
     #8000.000000;        // 16000.000000 ps;  From the start of the cycle.
      part_PIs [49] = stim_CIs [49];      // pinName = scan_clk;  tf = -ES  ; testOffset = 8000.000000;  scanOffset = 16000.000000;  
     #56000.000000;        // 72000.000000 ps;  From the start of the cycle.

      for ( POnum = 1; POnum <= 42; POnum = POnum + 1 ) begin 
        if (( part_POs [ POnum ] !== meas_POs [ POnum ] ) & ( meas_POs [ POnum ] !== 1'bX )) begin 
          if ( test_num != failed_test_num )  begin 
            num_failed_tests = num_failed_tests + 1; 
            failed_test_num = test_num; 
          end  
          miscompares = miscompares + 1; 
          $display ( "\nWARNING (TVE-650): PO miscompare at Test: %0d  Odometer: %0s  Relative Cycle: %0d  Time: %0t ", test_num, PATTERN, CYCLE, $time ); 
          $display ( "           Expected: %0b   Simulated: %0b   On PO: %0s   ", meas_POs [ POnum ], part_POs [ POnum ], name_POs [ POnum ] ); 

          if (( failset ) & ( FAILSETID == 0 ))  failset_setup; 
          if ( FAILSETID ) begin 
            $fdisplay ( FAILSETID, " Chip %0s pad %0s pattern %0s position %0d value %0b ", "dtmf_chip", name_POs [ POnum ], PATTERN, -1, part_POs [ POnum ] ); 
          end  
        end  
        else if ( meas_POs [ POnum ] !== 1'bX )  good_compares = good_compares + 1; 
      end  
     #8000.000000;        // 80000.000000 ps;  From the start of the cycle.
      meas_POs = {42{1'bX}}; 

    end  
  endtask  

//***************************************************************************//
//                       DEFINE SCAN PRECOND PROCEDURE                       //
//***************************************************************************//

  task Scan_Preconditioning_Sequence_TM_1_SEQ_1_SOP_1; 
    begin 

      PROCESSNAME = "SCAN PRECONDITIONING (Scan_Preconditioning_Sequence)";
      stim_PIs [1] = 1'b1;      // pinName = DFT_compression_enable;  tf = +SE  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [3] = 1'b0;      // pinName = DFT_mask_enable;  tf = -TC  -CME  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [4] = 1'b1;      // pinName = DFT_spreader;  tf = +SE  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [24] = 1'bZ;      // pinName = port_pad_data_in[3];  tf = ZSE   SO2 BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [31] = 1'bZ;      // pinName = port_pad_data_out[0];  tf = ZSE   SO  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [32] = 1'bZ;      // pinName = port_pad_data_out[10];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [33] = 1'bZ;      // pinName = port_pad_data_out[11];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [34] = 1'bZ;      // pinName = port_pad_data_out[12];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [35] = 1'bZ;      // pinName = port_pad_data_out[13];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [36] = 1'bZ;      // pinName = port_pad_data_out[14];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [37] = 1'bZ;      // pinName = port_pad_data_out[15];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [38] = 1'bZ;      // pinName = port_pad_data_out[1];  tf = ZSE   SO1 BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [39] = 1'bZ;      // pinName = port_pad_data_out[2];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [40] = 1'bZ;      // pinName = port_pad_data_out[3];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [41] = 1'bZ;      // pinName = port_pad_data_out[4];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [42] = 1'bZ;      // pinName = port_pad_data_out[5];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [43] = 1'bZ;      // pinName = port_pad_data_out[6];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [44] = 1'bZ;      // pinName = port_pad_data_out[7];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [45] = 1'bZ;      // pinName = port_pad_data_out[8];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [46] = 1'bZ;      // pinName = port_pad_data_out[9];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [50] = 1'b1;      // pinName = scan_en;  tf = +SE  ; testOffset = 0.000000;  scanOffset = 0.000000;  

      test_cycle; 
      PROCESSNAME = "";
      PROCESSNAME = "";

    end  
  endtask  

//***************************************************************************//
//                DEFINE CHANNEL MASK SCAN SEQUENCE PROCEDURE                //
//***************************************************************************//

  task ChannelMask_Cycle_Sequence_TM_1_SEQ_2_SOP_1; 
    begin 

      PROCESSNAME = "CHANNEL MASK SCAN SEQUENCE (ChannelMask_Cycle_Sequence)";
      START = MAX - NUM_SHIFTS; 
      for ( SCANCYCLE = 1; SCANCYCLE <= MAX; SCANCYCLE = SCANCYCLE + 1 ) begin 
        CYCLE = CYCLE + 1; 
        SERIALCYCLE = SERIALCYCLE + 1; 
     #0.000000;        // 0.000000 ps;  From the start of the cycle.
        part_PIs [15] = stim_CMSR_1 [ 0 + SCANCYCLE ];      // pinName = port_pad_data_in[0];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
        part_PIs [22] = stim_CMSR_2 [ 0 + SCANCYCLE ];      // pinName = port_pad_data_in[1];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
        part_PIs [23] = stim_CMSR_3 [ 0 + SCANCYCLE ];      // pinName = port_pad_data_in[2];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
     #16000.000000;        // 16000.000000 ps;  From the start of the cycle.
        part_PIs [2] = 1'b1;      // pinName = DFT_mask_clk;  tf = -CML  ; testOffset = 8000.000000;  scanOffset = 16000.000000;  
     #8000.000000;        // 24000.000000 ps;  From the start of the cycle.
        part_PIs [2] = 1'b0;      // pinName = DFT_mask_clk;  tf = -CML  ; testOffset = 8000.000000;  scanOffset = 16000.000000;  
     #56000.000000;        // 80000.000000 ps;  From the start of the cycle.
      end  
      stim_CMSR_1 = {17{1'b0}};   stim_CMSR_2 = {17{1'b0}};   stim_CMSR_3 = {17{1'b0}};   
      stim_PIs = part_PIs; 
      SCANCYCLE = 0; 
      NUM_SHIFTS = 0; 
      PROCESSNAME = "";

    end  
  endtask  

//***************************************************************************//
//                      DEFINE SCAN SEQUENCE PROCEDURE                       //
//***************************************************************************//

  task Scan_Sequence_TM_1_SEQ_3_SOP_1; 
    begin 

      PROCESSNAME = "SCAN SEQUENCE (Scan_Sequence)";
      if ( overlap )  test_num = test_num - 1; 
      START = 0; 
      for ( SCANCYCLE = 1; SCANCYCLE <= MAX; SCANCYCLE = SCANCYCLE + 1 ) begin 
        CYCLE = CYCLE + 1; 
        SERIALCYCLE = SERIALCYCLE + 1; 
     #0.000000;        // 0.000000 ps;  From the start of the cycle.
        part_PIs [3] = stim_CME_0 [ 0 + SCANCYCLE ];      // pinName = DFT_mask_enable;  tf = -TC  -CME  ; testOffset = 0.000000;  scanOffset = 0.000000;  
        part_PIs [15] = stim_CR_1 [ 0 + SCANCYCLE ];      // pinName = port_pad_data_in[0];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
        part_PIs [22] = stim_CR_2 [ 0 + SCANCYCLE ];      // pinName = port_pad_data_in[1];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
        part_PIs [23] = stim_CR_3 [ 0 + SCANCYCLE ];      // pinName = port_pad_data_in[2];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
     #8000.000000;        // 8000.000000 ps;  From the start of the cycle.

        if (( part_POs [18] !== meas_OR_1 [ 0 + SCANCYCLE ] ) & ( meas_OR_1 [ 0 + SCANCYCLE ] !== 1'bX )) begin      // pinName = port_pad_data_out[0];  tf =  SO  ZSE  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
          if ( test_num != failed_test_num )  begin 
            num_failed_tests = num_failed_tests + 1; 
            failed_test_num = test_num; 
          end  
          miscompares = miscompares + 1; 
          $display ( "\nWARNING (TVE-660): Serial scan miscompare at Test: %0d  Odometer: %0s  Relative Cycle: %0d  Time: %0t ", test_num, PATTERN, CYCLE, $time ); 
          $display ( "           Expected: %0b   Simulated: %0b   Measured on Scan Cycle: %0d   Measured at SO: %0s   ", meas_OR_1 [ 0 + SCANCYCLE ], part_POs [18], SCANCYCLE, name_POs [18] ); 

          if (( failset ) & ( FAILSETID == 0 ))  failset_setup; 
          if ( FAILSETID ) begin 
            $fdisplay ( FAILSETID, " Chip %0s pad %0s pattern %0s position %0d value %0b ", "dtmf_chip", name_POs [18], PATTERN, SCANCYCLE, part_POs [18] ); 
          end  
        end  
        else  begin 
          if ( meas_OR_1 [ 0 + SCANCYCLE ] !== 1'bX )  begin 
            good_compares = good_compares + 1;
          end 
        end 

        if (( part_POs [25] !== meas_OR_2 [ 0 + SCANCYCLE ] ) & ( meas_OR_2 [ 0 + SCANCYCLE ] !== 1'bX )) begin      // pinName = port_pad_data_out[1];  tf =  SO1 ZSE  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
          if ( test_num != failed_test_num )  begin 
            num_failed_tests = num_failed_tests + 1; 
            failed_test_num = test_num; 
          end  
          miscompares = miscompares + 1; 
          $display ( "\nWARNING (TVE-660): Serial scan miscompare at Test: %0d  Odometer: %0s  Relative Cycle: %0d  Time: %0t ", test_num, PATTERN, CYCLE, $time ); 
          $display ( "           Expected: %0b   Simulated: %0b   Measured on Scan Cycle: %0d   Measured at SO: %0s   ", meas_OR_2 [ 0 + SCANCYCLE ], part_POs [25], SCANCYCLE, name_POs [25] ); 

          if (( failset ) & ( FAILSETID == 0 ))  failset_setup; 
          if ( FAILSETID ) begin 
            $fdisplay ( FAILSETID, " Chip %0s pad %0s pattern %0s position %0d value %0b ", "dtmf_chip", name_POs [25], PATTERN, SCANCYCLE, part_POs [25] ); 
          end  
        end  
        else  begin 
          if ( meas_OR_2 [ 0 + SCANCYCLE ] !== 1'bX )  begin 
            good_compares = good_compares + 1;
          end 
        end 

        if (( part_POs [11] !== meas_OR_3 [ 0 + SCANCYCLE ] ) & ( meas_OR_3 [ 0 + SCANCYCLE ] !== 1'bX )) begin      // pinName = port_pad_data_in[3];  tf =  SO2 ZSE  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
          if ( test_num != failed_test_num )  begin 
            num_failed_tests = num_failed_tests + 1; 
            failed_test_num = test_num; 
          end  
          miscompares = miscompares + 1; 
          $display ( "\nWARNING (TVE-660): Serial scan miscompare at Test: %0d  Odometer: %0s  Relative Cycle: %0d  Time: %0t ", test_num, PATTERN, CYCLE, $time ); 
          $display ( "           Expected: %0b   Simulated: %0b   Measured on Scan Cycle: %0d   Measured at SO: %0s   ", meas_OR_3 [ 0 + SCANCYCLE ], part_POs [11], SCANCYCLE, name_POs [11] ); 

          if (( failset ) & ( FAILSETID == 0 ))  failset_setup; 
          if ( FAILSETID ) begin 
            $fdisplay ( FAILSETID, " Chip %0s pad %0s pattern %0s position %0d value %0b ", "dtmf_chip", name_POs [11], PATTERN, SCANCYCLE, part_POs [11] ); 
          end  
        end  
        else  begin 
          if ( meas_OR_3 [ 0 + SCANCYCLE ] !== 1'bX )  begin 
            good_compares = good_compares + 1;
          end 
        end 
     #8000.000000;        // 16000.000000 ps;  From the start of the cycle.
        part_PIs [49] = 1'b1;      // pinName = scan_clk;  tf = -ES  ; testOffset = 8000.000000;  scanOffset = 16000.000000;  
        part_PIs [5] = 1'b1;      // pinName = OPCG_LOADCLK;  tf = -ES  ; testOffset = 8000.000000;  scanOffset = 16000.000000;  
     #8000.000000;        // 24000.000000 ps;  From the start of the cycle.
        part_PIs [49] = 1'b0;      // pinName = scan_clk;  tf = -ES  ; testOffset = 8000.000000;  scanOffset = 16000.000000;  
        part_PIs [5] = 1'b0;      // pinName = OPCG_LOADCLK;  tf = -ES  ; testOffset = 8000.000000;  scanOffset = 16000.000000;  
     #56000.000000;        // 80000.000000 ps;  From the start of the cycle.
      end  
      meas_OR_1 = {48{1'bX}};   meas_OR_2 = {48{1'bX}};   meas_OR_3 = {48{1'bX}};   
      stim_CR_1 = {48{1'b0}};   stim_CR_2 = {48{1'b0}};   stim_CR_3 = {48{1'b0}};   
      stim_CME_0 = {48{1'b0}};   
      stim_PIs = part_PIs; 
      SCANCYCLE = 0; 
      NUM_SHIFTS = 0; 
      if ( overlap )  test_num = test_num + 1; 
      PROCESSNAME = "";

    end  
  endtask  

//***************************************************************************//
//                        DEFINE SCAN EXIT PROCEDURE                         //
//***************************************************************************//

  task Scan_Exit_Sequence_TM_1_SEQ_4_SOP_1; 
    begin 

      PROCESSNAME = "SCAN EXIT (Scan_Exit_Sequence)";
      stim_PIs [24] = 1'bZ;      // pinName = port_pad_data_in[3];  tf = ZSE   SO2 BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [31] = 1'bZ;      // pinName = port_pad_data_out[0];  tf = ZSE   SO  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [32] = 1'bZ;      // pinName = port_pad_data_out[10];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [33] = 1'bZ;      // pinName = port_pad_data_out[11];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [34] = 1'bZ;      // pinName = port_pad_data_out[12];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [35] = 1'bZ;      // pinName = port_pad_data_out[13];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [36] = 1'bZ;      // pinName = port_pad_data_out[14];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [37] = 1'bZ;      // pinName = port_pad_data_out[15];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [38] = 1'bZ;      // pinName = port_pad_data_out[1];  tf = ZSE   SO1 BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [39] = 1'bZ;      // pinName = port_pad_data_out[2];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [40] = 1'bZ;      // pinName = port_pad_data_out[3];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [41] = 1'bZ;      // pinName = port_pad_data_out[4];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [42] = 1'bZ;      // pinName = port_pad_data_out[5];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [43] = 1'bZ;      // pinName = port_pad_data_out[6];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [44] = 1'bZ;      // pinName = port_pad_data_out[7];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [45] = 1'bZ;      // pinName = port_pad_data_out[8];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [46] = 1'bZ;      // pinName = port_pad_data_out[9];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      stim_PIs [3] = 1'b0;      // pinName = DFT_mask_enable;  tf = -TC  -CME  ; testOffset = 0.000000;  scanOffset = 0.000000;  

      scan_cycle; 
      PROCESSNAME = "";

    end  
  endtask  

//***************************************************************************//
//                        DEFINE TIMED TEST PROCEDURE                        //
//***************************************************************************//

  task TBphantomLogicSeq1_20200406193611__0; 
    begin 

      if ( sim_trace )  $display ( "\nRunning task:  TBphantomLogicSeq1_20200406193611__0 " ); 

      CYCLE = CYCLE + 1; 
      SERIALCYCLE = SERIALCYCLE + 1; 
     #25.000000;        // 25.000000 ps;  From the start of the cycle.
      part_PIs[0049] = stim_PIs[0049]; 
     #1200.000000;        // 1225.000000 ps;  From the start of the cycle.
      part_PIs[0049] = stim_CIs[0049]; 
     #7675.000000;        // 8900.000000 ps;  From the start of the cycle.
      stim_PIs[0002] = 1'b0; 
      stim_PIs[0005] = 1'b0; 
      stim_PIs[0049] = 1'b0; 

    end  
  endtask  

//***************************************************************************//
//                        DEFINE TIMED TEST PROCEDURE                        //
//***************************************************************************//

  task TBphantomLogicSeq1_20200406193611__1; 
    begin 

      if ( sim_trace )  $display ( "\nRunning task:  TBphantomLogicSeq1_20200406193611__1 " ); 

      CYCLE = CYCLE + 1; 
      SERIALCYCLE = SERIALCYCLE + 1; 
     #25.000000;        // 25.000000 ps;  From the start of the cycle.
      part_PIs[0049] = stim_PIs[0049]; 
     #1200.000000;        // 1225.000000 ps;  From the start of the cycle.
      part_PIs[0049] = stim_CIs[0049]; 
     #1275.000000;        // 2500.000000 ps;  From the start of the cycle.
      stim_PIs[0002] = 1'b0; 
      stim_PIs[0005] = 1'b0; 
      stim_PIs[0049] = 1'b0; 

    end  
  endtask  

//***************************************************************************//
//                           DEFINE SCAN PROCEDURE                           //
//***************************************************************************//

  task scan_cycle; 
    begin 

      CYCLE = CYCLE + 1; 
      SERIALCYCLE = SERIALCYCLE + 1; 
     #0.000000;        // 0.000000 ps;  From the start of the cycle.
      part_PIs [1] = stim_PIs [1];      // pinName = DFT_compression_enable;  tf = +SE  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [3] = stim_PIs [3];      // pinName = DFT_mask_enable;  tf = -TC  -CME  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [4] = stim_PIs [4];      // pinName = DFT_spreader;  tf = +SE  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [6] = stim_PIs [6];      // pinName = OPCG_ON;  tf = -TI  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [7] = stim_PIs [7];      // pinName = TCK; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [8] = stim_PIs [8];      // pinName = TDI; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [9] = stim_PIs [9];      // pinName = TMS; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [10] = stim_PIs [10];      // pinName = TRIGGER;  tf = +TI  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [11] = stim_PIs [11];      // pinName = TRST; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [12] = stim_PIs [12];      // pinName = int; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [13] = stim_PIs [13];      // pinName = mbist_test_mode;  tf = -TI  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [14] = stim_PIs [14];      // pinName = pllrst; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [47] = stim_PIs [47];      // pinName = refclk; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [48] = stim_PIs [48];      // pinName = reset;  tf = -SC  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [50] = stim_PIs [50];      // pinName = scan_en;  tf = +SE  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [51] = stim_PIs [51];      // pinName = spi_data; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [52] = stim_PIs [52];      // pinName = spi_fs;  tf = -TI  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [53] = stim_PIs [53];      // pinName = test_mode;  tf = +TI  ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [15] = stim_PIs [15];      // pinName = port_pad_data_in[0];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [16] = stim_PIs [16];      // pinName = port_pad_data_in[10];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [17] = stim_PIs [17];      // pinName = port_pad_data_in[11];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [18] = stim_PIs [18];      // pinName = port_pad_data_in[12];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [19] = stim_PIs [19];      // pinName = port_pad_data_in[13];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [20] = stim_PIs [20];      // pinName = port_pad_data_in[14];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [21] = stim_PIs [21];      // pinName = port_pad_data_in[15];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [22] = stim_PIs [22];      // pinName = port_pad_data_in[1];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [23] = stim_PIs [23];      // pinName = port_pad_data_in[2];  tf =  SI   CMI  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [24] = stim_PIs [24];      // pinName = port_pad_data_in[3];  tf = ZSE   SO2 BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [25] = stim_PIs [25];      // pinName = port_pad_data_in[4];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [26] = stim_PIs [26];      // pinName = port_pad_data_in[5];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [27] = stim_PIs [27];      // pinName = port_pad_data_in[6];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [28] = stim_PIs [28];      // pinName = port_pad_data_in[7];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [29] = stim_PIs [29];      // pinName = port_pad_data_in[8];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [30] = stim_PIs [30];      // pinName = port_pad_data_in[9];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [31] = stim_PIs [31];      // pinName = port_pad_data_out[0];  tf = ZSE   SO  BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [32] = stim_PIs [32];      // pinName = port_pad_data_out[10];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [33] = stim_PIs [33];      // pinName = port_pad_data_out[11];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [34] = stim_PIs [34];      // pinName = port_pad_data_out[12];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [35] = stim_PIs [35];      // pinName = port_pad_data_out[13];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [36] = stim_PIs [36];      // pinName = port_pad_data_out[14];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [37] = stim_PIs [37];      // pinName = port_pad_data_out[15];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [38] = stim_PIs [38];      // pinName = port_pad_data_out[1];  tf = ZSE   SO1 BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [39] = stim_PIs [39];      // pinName = port_pad_data_out[2];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [40] = stim_PIs [40];      // pinName = port_pad_data_out[3];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [41] = stim_PIs [41];      // pinName = port_pad_data_out[4];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [42] = stim_PIs [42];      // pinName = port_pad_data_out[5];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [43] = stim_PIs [43];      // pinName = port_pad_data_out[6];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [44] = stim_PIs [44];      // pinName = port_pad_data_out[7];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [45] = stim_PIs [45];      // pinName = port_pad_data_out[8];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
      part_PIs [46] = stim_PIs [46];      // pinName = port_pad_data_out[9];  tf = BIDI ; testOffset = 0.000000;  scanOffset = 0.000000;  
     #8000.000000;        // 8000.000000 ps;  From the start of the cycle.

      for ( POnum = 1; POnum <= 42; POnum = POnum + 1 ) begin 
        if (( part_POs [ POnum ] !== meas_POs [ POnum ] ) & ( meas_POs [ POnum ] !== 1'bX )) begin 
          if ( test_num != failed_test_num )  begin 
            num_failed_tests = num_failed_tests + 1; 
            failed_test_num = test_num; 
          end  
          miscompares = miscompares + 1; 
          $display ( "\nWARNING (TVE-650): PO miscompare at Test: %0d  Odometer: %0s  Relative Cycle: %0d  Time: %0t ", test_num, PATTERN, CYCLE, $time ); 
          $display ( "           Expected: %0b   Simulated: %0b   On PO: %0s   ", meas_POs [ POnum ], part_POs [ POnum ], name_POs [ POnum ] ); 

          if (( failset ) & ( FAILSETID == 0 ))  failset_setup; 
          if ( FAILSETID ) begin 
            $fdisplay ( FAILSETID, " Chip %0s pad %0s pattern %0s position %0d value %0b ", "dtmf_chip", name_POs [ POnum ], PATTERN, -1, part_POs [ POnum ] ); 
          end  
        end  
        else if ( meas_POs [ POnum ] !== 1'bX )  good_compares = good_compares + 1; 
      end  
     #8000.000000;        // 16000.000000 ps;  From the start of the cycle.
      part_PIs [2] = stim_PIs [2];      // pinName = DFT_mask_clk;  tf = -CML  ; testOffset = 8000.000000;  scanOffset = 16000.000000;  
      part_PIs [5] = stim_PIs [5];      // pinName = OPCG_LOADCLK;  tf = -ES  ; testOffset = 8000.000000;  scanOffset = 16000.000000;  
      part_PIs [49] = stim_PIs [49];      // pinName = scan_clk;  tf = -ES  ; testOffset = 8000.000000;  scanOffset = 16000.000000;  
     #8000.000000;        // 24000.000000 ps;  From the start of the cycle.
      part_PIs [2] = stim_CIs [2];      // pinName = DFT_mask_clk;  tf = -CML  ; testOffset = 8000.000000;  scanOffset = 16000.000000;  
      part_PIs [5] = stim_CIs [5];      // pinName = OPCG_LOADCLK;  tf = -ES  ; testOffset = 8000.000000;  scanOffset = 16000.000000;  
      part_PIs [49] = stim_CIs [49];      // pinName = scan_clk;  tf = -ES  ; testOffset = 8000.000000;  scanOffset = 16000.000000;  
     #56000.000000;        // 80000.000000 ps;  From the start of the cycle.
      meas_POs = {42{1'bX}}; 

    end  
  endtask  

//***************************************************************************//
//                 READ COMMANDS AND DATA AND RUN SIMULATION                 //
//***************************************************************************//

  task cmd_code; 
    begin 

      if ( sim_trace )  $display ( "\nCommand code:  %0d ", CMD ); 

      case ( CMD ) 

        000: begin 
          rc_read = 0;  // This will stop execution 
          line_number = line_number + 1; 
        end  

        100: begin 
          rc_read = $fgets ( COMMENT, DATAID ); 
          if ( rc_read > 0 )  begin 
          end  
          else  begin 
            $display ( "\nERROR (TVE-998): Unrecognizable data at line %0.0f in file: %0s \n", line_number, DATAFILE ); 
            $display ( "  Command code = %0d, Unrecognized data = %0s \n", CMD, COMMENT ); 
          end  
          line_number = line_number + 1; 
        end  

        104: begin 
          rc_read = $fgets ( PROCESSNAME, DATAID ); 
          if ( rc_read > 0 )  begin 
          end  
          else  begin 
            $display ( "\nERROR (TVE-998): Unrecognizable data at line %0.0f in file: %0s \n", line_number, DATAFILE ); 
            $display ( "  Command code = %0d, Unrecognized data = %0s \n", CMD, PROCESSNAME ); 
          end  
          line_number = line_number + 1; 
        end  

        110: begin 
          rc_read = $fgets ( COMMENT, DATAID ); 
          if ( rc_read > 0 )  begin 
            $display ( "\n %0s ", COMMENT ); 
          end  
          else  begin 
            $display ( "\nERROR (TVE-998): Unrecognizable data at line %0.0f in file: %0s \n", line_number, DATAFILE ); 
            $display ( "  Command code = %0d, Unrecognized data = %0s \n", CMD, COMMENT ); 
          end  
          line_number = line_number + 1; 
        end  

        151: begin 
          test_num_prev = test_num; 
          rc_read = $fscanf ( DATAID, "%d", test_num ); 
          if ( rc_read > 0 )  begin 
            if ( test_num != test_num_prev )  num_tests = num_tests + 1; 
          end  
          else  bad_cmd_code; 

          rc_read = $fscanf ( DATAID, "%d", scan_num ); 
          if ( rc_read > 0 )  begin 
          end  
          else  bad_cmd_code; 

          rc_read = $fscanf ( DATAID, "%d", overlap ); 
          if ( rc_read > 0 )  begin 
          end  
          else  bad_cmd_code; 

          line_number = line_number + 1; 
        end  

        200: begin 
          if ( rc_read > 0 )  begin 
            rc_read = $fscanf ( DATAID, "%b", stim_PIs [1:53] ); 
            if ( rc_read <= 0 )  bad_cmd_code; 
            line_number = line_number + 1; 
          end  
        end  

        201: begin 
          if ( rc_read > 0 )  begin 
            rc_read = $fscanf ( DATAID, "%b", stim_CIs [1:53] ); 
            if ( rc_read <= 0 )  bad_cmd_code; 
            line_number = line_number + 1; 
          end  
        end  

        202: begin 
          if ( rc_read > 0 )  begin 
            rc_read = $fscanf ( DATAID, "%b", meas_POs [1:42] ); 
            if ( rc_read <= 0 )  bad_cmd_code; 
            line_number = line_number + 1; 
          end  
        end  

        203: begin 
          rc_read = $fscanf ( DATAID, "%b", global_term ); 
          if ( rc_read > 0 )  begin 
          end  
          else  bad_cmd_code; 
          line_number = line_number + 1; 
        end  

        300: begin 
          rc_read = $fscanf ( DATAID, "%d", MODENUM ); 
          if ( rc_read <= 0 )  bad_cmd_code; 
          else  begin 

            case ( MODENUM ) 

              1: begin 
                rc_read = $fscanf ( DATAID, "%d", SCANNUM ); 
                if ( rc_read <= 0 )  bad_cmd_code; 
                else  begin 

                  case ( SCANNUM ) 

                    1: begin 

                      if ( rc_read > 0 )  begin 
                        rc_read = $fscanf ( DATAID, "%b", stim_CR_1 [1:48] ); 
                        if ( rc_read <= 0 )  bad_cmd_code; 
                        line_number = line_number + 1; 
                      end  
                    end  

                    2: begin 

                      if ( rc_read > 0 )  begin 
                        rc_read = $fscanf ( DATAID, "%b", stim_CR_2 [1:48] ); 
                        if ( rc_read <= 0 )  bad_cmd_code; 
                        line_number = line_number + 1; 
                      end  
                    end  

                    3: begin 

                      if ( rc_read > 0 )  begin 
                        rc_read = $fscanf ( DATAID, "%b", stim_CR_3 [1:48] ); 
                        if ( rc_read <= 0 )  bad_cmd_code; 
                        line_number = line_number + 1; 
                      end  
                    end  

                  endcase  
                end  
              end  

            endcase  
          end  
        end  

        301: begin 
          rc_read = $fscanf ( DATAID, "%d", MODENUM ); 
          if ( rc_read <= 0 )  bad_cmd_code; 
          else  begin 

            case ( MODENUM ) 

              1: begin 
                rc_read = $fscanf ( DATAID, "%d", SCANNUM ); 
                if ( rc_read <= 0 )  bad_cmd_code; 
                else  begin 

                  case ( SCANNUM ) 

                    1: begin 

                      if ( rc_read > 0 )  begin 
                        rc_read = $fscanf ( DATAID, "%b", meas_OR_1 [1:48] ); 
                        if ( rc_read <= 0 )  bad_cmd_code; 
                        line_number = line_number + 1; 
                      end  
                    end  

                    2: begin 

                      if ( rc_read > 0 )  begin 
                        rc_read = $fscanf ( DATAID, "%b", meas_OR_2 [1:48] ); 
                        if ( rc_read <= 0 )  bad_cmd_code; 
                        line_number = line_number + 1; 
                      end  
                    end  

                    3: begin 

                      if ( rc_read > 0 )  begin 
                        rc_read = $fscanf ( DATAID, "%b", meas_OR_3 [1:48] ); 
                        if ( rc_read <= 0 )  bad_cmd_code; 
                        line_number = line_number + 1; 
                      end  
                    end  

                  endcase  
                end  
              end  

            endcase  
          end  
        end  

        302: begin 
          rc_read = $fscanf ( DATAID, "%d", MODENUM ); 
          if ( rc_read <= 0 )  bad_cmd_code; 
          else  begin 

            case ( MODENUM ) 

              1: begin 
                rc_read = $fscanf ( DATAID, "%d", SCANNUM ); 
                if ( rc_read <= 0 )  bad_cmd_code; 
                else  begin 

                  case ( SCANNUM ) 

                    0: begin 

                      if ( rc_read > 0 )  begin 
                        rc_read = $fscanf ( DATAID, "%b", stim_CME_0 [1:48] ); 
                        if ( rc_read <= 0 )  bad_cmd_code; 
                        line_number = line_number + 1; 
                      end  
                    end  

                  endcase  
                end  
              end  

            endcase  
          end  
        end  

        303: begin 
          rc_read = $fscanf ( DATAID, "%d", SCANNUM ); 
          if ( rc_read <= 0 )  bad_cmd_code; 
          else  begin 

            case ( SCANNUM ) 

              1: begin 

                if ( rc_read > 0 )  begin 
                  rc_read = $fscanf ( DATAID, "%b", stim_CMSR_1 [1:17] ); 
                  if ( rc_read <= 0 )  bad_cmd_code; 
                  line_number = line_number + 1; 
                end  
              end  

              2: begin 

                if ( rc_read > 0 )  begin 
                  rc_read = $fscanf ( DATAID, "%b", stim_CMSR_2 [1:17] ); 
                  if ( rc_read <= 0 )  bad_cmd_code; 
                  line_number = line_number + 1; 
                end  
              end  

              3: begin 

                if ( rc_read > 0 )  begin 
                  rc_read = $fscanf ( DATAID, "%b", stim_CMSR_3 [1:17] ); 
                  if ( rc_read <= 0 )  bad_cmd_code; 
                  line_number = line_number + 1; 
                end  
              end  

            endcase  
          end  
        end  

        400: begin 
          if ( sim_range )  test_cycle; 
          line_number = line_number + 1; 
        end  

        403: begin 
          if ( sim_range )  scan_cycle; 
          line_number = line_number + 1; 
        end  

        500: begin 
          repeat_depth = repeat_depth + 1; 
          rc_read = $fscanf ( DATAID, "%d", num_repeats [repeat_depth] ); 
          if ( rc_read > 0 )  begin 
            start_of_repeat[repeat_depth] = $ftell ( DATAID ); 
          end  
          else  bad_cmd_code; 
          if ((sim_range & sim_heart) && repeat_heart) 
            $display ( "\nINFO (TVE-202): Simulating Test: %0d  Odometer: %0s  Relative Cycle: %0d  Time: %0t  Tests Passed %0d of %0d, Failed %0d.  Start of %0d cycles of a repeat loop.", test_num, pattern, CYCLE + 1, $time, num_tests - num_failed_tests, num_tests, num_failed_tests, num_repeats [repeat_depth] ); 
          line_number = line_number + 1; 
        end  

        501: begin 
          num_repeats [repeat_depth] = num_repeats [repeat_depth] - 1; 
          if ( num_repeats [repeat_depth] )  begin 
            if ((sim_range & sim_heart) && repeat_heart && (num_repeats [repeat_depth] % repeat_heart == 0 )) 
              $display ( "\nINFO (TVE-202): Simulating Test: %0d  Odometer: %0s  Relative Cycle: %0d  Time: %0t  Tests Passed %0d of %0d, Failed %0d.  Number of cycles remaining in this repeat loop is %0d.", test_num, pattern, CYCLE + 1, $time, num_tests - num_failed_tests, num_tests, num_failed_tests, num_tests, num_repeats [repeat_depth] ); 
            rc_read = $fseek ( DATAID, start_of_repeat [repeat_depth], 0 ); 
            rc_read = 1; 
            fseek_offset = $ftell ( DATAID ); 
            if ( fseek_offset != start_of_repeat [repeat_depth] )  begin 
              $display ( "\nERROR (TVE-956): An ncsim limitation in the fseek routine has been reached.  The size of the Verilog Data file is so big that it can not support branching using fseek in ncsim.  Any branching after 2147483647 (0x7fffffff) bytes of data will not run correctly under ncsim.  It is recommended that you break up the Verilog Data file using the keyword maxvectorsperfile.  The Verilog Data file:  %0s  \n", DATAFILE ); 
              rc_read = 0;  // This will stop execution 
            end  
          end  
          else  repeat_depth = repeat_depth - 1; 
          line_number = line_number + 1; 
        end  

        600: begin 
          rc_read = $fscanf ( DATAID, "%d", MODENUM ); 
          if ( rc_read <= 0 )  bad_cmd_code; 
          else  begin 

            case ( MODENUM ) 

              1: begin 
                rc_read = $fscanf ( DATAID, "%d", SEQNUM ); 
                if ( rc_read <= 0 )  bad_cmd_code; 
                else  begin 

                  case ( SEQNUM ) 

                    1: begin 
                      rc_read = $fscanf ( DATAID, "%d", MAX ); 
                      if ( rc_read > 0 )  begin 
                        if ( sim_range )  Scan_Preconditioning_Sequence_TM_1_SEQ_1_SOP_1; 
                      end  
                      else  bad_cmd_code; 
                      line_number = line_number + 1; 
                    end  

                    2: begin 
                      rc_read = $fscanf ( DATAID, "%d", MAX ); 
                      if ( rc_read > 0 )  begin 
                        if ( sim_range )  ChannelMask_Cycle_Sequence_TM_1_SEQ_2_SOP_1; 
                      end  
                      else  bad_cmd_code; 
                      line_number = line_number + 1; 
                    end  

                    3: begin 
                      rc_read = $fscanf ( DATAID, "%d", MAX ); 
                      if ( rc_read > 0 )  begin 
                        if ( sim_range )  Scan_Sequence_TM_1_SEQ_3_SOP_1; 
                      end  
                      else  bad_cmd_code; 
                      line_number = line_number + 1; 
                    end  

                    4: begin 
                      rc_read = $fscanf ( DATAID, "%d", MAX ); 
                      if ( rc_read > 0 )  begin 
                        if ( sim_range )  Scan_Exit_Sequence_TM_1_SEQ_4_SOP_1; 
                      end  
                      else  bad_cmd_code; 
                      line_number = line_number + 1; 
                    end  

                  endcase  
                end  
              end 

            endcase  
          end  
        end  

        850: begin 
          rc_read = $fscanf ( DATAID, "%d", TASKNUM ); 
          if ( rc_read <= 0 )  bad_cmd_code; 
          else  begin 

            case ( TASKNUM ) 

              1: begin 
                if ( sim_range )  TBphantomLogicSeq1_20200406193611__0; 
              end  

              2: begin 
                if ( sim_range )  TBphantomLogicSeq1_20200406193611__1; 
              end  

            endcase  
          end  
          line_number = line_number + 1; 
        end  

        900: begin 
          rc_read = $fscanf ( DATAID, "%s", pattern ); 
          if ( rc_read > 0 )  begin 
            if ( SOD == pattern )  begin 
              sim_range = 1'b1; 
            end  
            if ( scan_num > 0 )  begin 
              if ( overlap )  $display ( "\nINFO (TVE-205): Simulating Test: %0d  Odometer: %0s  Relative Cycle: %0d  Time: %0t  Relative Scan: %0d  Overlap Tests %0d and %0d.  Tests Passed %0d of %0d, Failed %0d. ", test_num - 1, pattern, CYCLE + 1, $time, scan_num, test_num - 1, test_num, num_tests - num_failed_tests - 1, num_tests - 1, num_failed_tests ); 
              else  $display ( "\nINFO (TVE-205): Simulating Test: %0d  Odometer: %0s  Relative Cycle: %0d  Time: %0t  Relative Scan: %0d  Tests Passed %0d of %0d, Failed %0d. ", test_num, pattern, CYCLE + 1, $time, scan_num, num_tests - num_failed_tests, num_tests, num_failed_tests ); 
              scan_num = 0; 
            end  
            else if ( sim_range & sim_heart )  begin 
              $display ( "\nINFO (TVE-202): Simulating Test: %0d  Odometer: %0s  Relative Cycle: %0d  Time: %0t  Tests Passed %0d of %0d, Failed %0d. ", test_num, pattern, CYCLE + 1, $time, num_tests - num_failed_tests, num_tests, num_failed_tests ); 
            end  
          end  
          else  bad_cmd_code; 
          line_number = line_number + 1; 
        end  

        901: begin 
          rc_read = $fscanf ( DATAID, "%s", PATTERN ); 
          if ( rc_read > 0 )  begin 
          end  
          else  bad_cmd_code; 
          line_number = line_number + 1; 
        end  

        903: begin 
          measure_current = measure_current + 1; 
          line_number = line_number + 1; 
        end  

        904: begin 
          rc_read = $fscanf ( DATAID, "%s", eventID ); 
          if ( rc_read > 0 )  begin 
            `ifdef MISCOMPAREDEBUG 
              if ( diag_debug ) begin 
                $processSimulationDebugFile ( DIAG_DEBUG_FILE, "dtmf_chip_inst", eventID ); 
              end 
            `endif 
          end  
          else  bad_cmd_code; 
          line_number = line_number + 1; 
        end  

        905: begin 
          rc_read = $fscanf ( DATAID, "%s", eventID ); 
          if ( rc_read > 0 )  begin 
            `ifdef MISCOMPAREDEBUG 
              if ( diag_debug ) begin 
                $processSimulationDebugFile ( DIAG_DEBUG_FILE, "dtmf_chip_inst", eventID ); 
              end 
            `endif 
          end  
          else  bad_cmd_code; 
          line_number = line_number + 1; 
        end  


        default: begin 
          bad_cmd_code; 
          rc_read = 0;  // This will stop execution 
          line_number = line_number + 1; 
        end  

      endcase  

    end  
  endtask  

//***************************************************************************//
//                          PRINT BAD CMD CODE DATA                          //
//***************************************************************************//

  task bad_cmd_code; 
    begin 

      $display ( "\nERROR (TVE-998): Unrecognizable data at line %0.0f in file: %0s \n", line_number, DATAFILE ); 
      start_of_current_line = $ftell ( DATAID ); 
      rc_read = $fgets ( COMMENT, DATAID ); 
      $display ( "  Command code = %0d, Unrecognized data = %0s \n", CMD, COMMENT ); 
      rc_read = 0;  // This will stop execution 

    end  
  endtask  

  endmodule 
