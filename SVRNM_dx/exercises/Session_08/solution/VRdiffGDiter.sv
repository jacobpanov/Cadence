// --- Begin Copyright Block -----[ do not move or remove ]------
// Copyright (c) 2020, Cadence Design Systems, Inc. All rights reserved.

// The model contained herein is the proprietary and confidential information 
// of Cadence, and is supplied subject to, and may be used only by Cadences 
// customer in accordance with a previously executed license and maintenance 
// agreement between Cadence and that customer. This model is intended for use 
// with products only from Cadence Design Systems, Inc.  The use or sharing of 
// any models from this library or any of its modified/extended form is 
// strictly prohibited with any non-Cadence products.

// ALL MATERIALS FURNISHED BY CADENCE HEREUNDER ARE PROVIDED "AS IS" WITHOUT 
// WARRANTY OF ANY KIND, AND CADENCE SPECIFICALLY DISCLAIMS ANY WARRANTY OF 
// NONINFRINGEMENT, FITNESS FOR A PARTICULAR PURPOSE OR MERCHANTABILITY. 
// CADENCE SHALL NOT BE LIABLE FOR ANY COSTS OF PROCUREMENT OF SUBSTITUTES, 
// LOSS OF PROFITS, INTERRUPTION OF BUSINESS, OR FOR ANY OTHER SPECIAL, 
// CONSEQUENTIAL OR INCIDENTAL DAMAGES, HOWEVER CAUSED, WHETHER FOR BREACH OF 
// WARRANTY, CONTRACT, TORT, NEGLIGENCE, STRICT LIABILITY OR OTHERWISE.
// --------------------------------------------------------------

// VRdiffGDiter: Diffl Source Model using $cged function.

// This model adds in voltage tolerance, iteration limiter, error messaging.
// Note that iteration counting is only applicable to significant changes of 
// value, so iteration counter must be nested inside of the update mechanism.
// Placing it outside of that check would result in counting iterations that
// didn't affect the model.  This model also passes the initial evaluation at
// each timepoint through directly, only performing tolerance range check on
// iterations after the initial eval at the timepoint.    

import EE_pkg::*;

module VRdiffGDiter (inout EEnet P,N, input real vval,rval);

parameter real vtol=1e-4;  // voltage update tolerance
parameter real rtol=0.1;   // resistance update tolerance
parameter real iterMax=20; // max iterations at one timepoint before error

real VPx,RPx,VNx,RNx;      // external values with tolerance limiting
EEnet Pext,Next;           // measured external drive to P & N

int NXiter,PXiter;         // number external iterations at P & N
real TsaveN,TsaveP;        // last timepoint value
int iterErr;               // error counter 

initial $cged(P, Pext);	   // copy P drivers to Pext
initial $cged(N, Next);    // copy N drivers to Next

always @(Pext.V,Pext.R) begin      // tolerance-limited changes to VPx,RPx
 if ($realtime>TsaveP) begin       // if new timepoint, 
   PXiter=0; TsaveP=$realtime;     //  reset iteration counter
   VPx=Pext.V; RPx=Pext.R;         //  and perform update
 end
 else if (abs(Pext.V-VPx)<vtol && abs(Pext.R-RPx)<rtol); // skip if within tols
 else begin                        // otherwise update
   if (PXiter<iterMax) begin       // if within bound, 
     VPx=Pext.V; RPx=Pext.R;       //  perform update
   end
   else if (PXiter==iterMax) begin // when crossing iteration limit,
     $display(                     //  print error message
      "*ERROR* VRdiffGDiter %M P exceeds iterMax:  T=%.2fns  dV=%.6fV  dR=%.1f", 
                                    $realtime,abs(Pext.V-VPx),abs(Pext.R-RPx));
     iterErr++;                    //  and bump error count
   end                             // no ext updates when above iteration limit.
   PXiter++;                       // bump iteration count
 end
end

always @(Next.V,Next.R) begin      // tolerance-limited changes to VNx,RNx
 if ($realtime>TsaveN) begin       // if new timepoint, 
   NXiter=0; TsaveN=$realtime;     //  reset iteration counter
   VNx=Next.V; RNx=Next.R;         //  and perform update
 end
 else if (abs(Next.V-VNx)<vtol && abs(Next.R-RNx)<rtol); // skip if within tols
 else begin                        // otherwise needs to update
   if (NXiter<iterMax) begin       // if within bound, 
     VNx=Next.V; RNx=Next.R;       //  perform update
   end
   else if (NXiter==iterMax) begin // when crossing iteration limit,
     $display(                     //  print error message
      "*ERROR* VRdiffGDiter %M N exceeds iterMax:  T=%.2fns  dV=%.6fV  dR=%.1f", 
                                    $realtime,abs(Next.V-VNx),abs(Next.R-RNx));
     iterErr++;                    //  and bump error count
   end                             // no ext updates when above iteration limit.
   NXiter++;                       // bump iteration count
 end
end

assign N = '{VPx-vval, 0, RPx+rval};
assign P = '{VNx+vval, 0, RNx+rval};

endmodule

