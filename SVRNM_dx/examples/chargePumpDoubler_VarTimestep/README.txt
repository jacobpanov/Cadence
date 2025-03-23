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

Two complete designs and testbenches are included in this directory.
1 - Charge pump DC-DC converter (doubler) from Exercise 9B using CapGeq and CapDeq 
    from the $COMMON/EEnet library, but the Cpump capacitor has the parameter 
    rxflag=1, which activates its timestep adaptation, allowing it to take larger 
    timesteps when it thinks it can. To return to the behavior from Exercise 9B, set 
    rxflag = 0 in line 76 of src/doubler_Cap_eq.sv

2 - Same DC-DC converter, but using the capacitor models CapGx and CapDx from $COMMON/EEnet,
    which will automatically vary their time steps based on the signal behavior, limited by
    the parameters tmin and tmax, which can be set in the files*.f files by defining TMIN and
    TMAX.

Two simulations are possible. Interactive simulations with SimVision are launched by 
including the *_gui_* file of choice on the xrun command line with '-f'. Background 
simulations, intended for comparing total run-time between the capacitor models, repeat
the test pattern 100 times, exit when complete, and save no waveforms.

Summary of run commands (run in /tb):

xrun -f files_gui_Cap_eq.f              Interactive simulation with Cap*eq models
xrun -f files_Cap_eq.f                  Batch simulation, 100 repeats, with Cap*eq models
xrun -f files_gui_Cap_x.f               Interactive simulation with Cap*x models
xrun -f files_Cap_x.f                   Batch simulation, 100 repeats, with Cap*x models
