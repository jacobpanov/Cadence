/***************************************************************************
* © 1997-2011 Cadence Design Systems, Inc.  All rights reserved.           *
* This work may not be copied, modified, re-published, uploaded, executed, *
* or distributed in any way, in any medium, whether in whole or in part,   *
* without prior written permission from Cadence Design Systems, Inc.       *
****************************************************************************/

`ifdef PLL_MODEL
`else
module pll(refclk, clk1x, clk2x, reset);
    input  refclk;
    output clk1x;
    output clk2x;
    input reset;

    buf (clk1x, refclk);
    buf (clk2x, refclk);

endmodule
`endif
