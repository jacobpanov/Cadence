/***************************************************************************
* © 1997-2011 Cadence Design Systems, Inc.  All rights reserved.           *
* This work may not be copied, modified, re-published, uploaded, executed, *
* or distributed in any way, in any medium, whether in whole or in part,   *
* without prior written permission from Cadence Design Systems, Inc.       *
****************************************************************************/

module pll(refclk, clk1x, clk2x, reset );
    input  refclk;
    output clk1x;
    output clk2x;
    input reset;

reg clk1x;

always begin
    clk1x = #2 refclk;
end

assign clk2x = (clk1x ^ refclk);


endmodule
