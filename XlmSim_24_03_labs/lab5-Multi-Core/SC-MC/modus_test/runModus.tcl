# Modus Test Solution - ATPG Reference Flow
set_db workdir workdir;					
set_db stop_on_severity error;				
set_option stdout summary;				

file delete -force [get_db workdir]/tbdata;		
file delete -force [get_db workdir]/testresults;	

build_model \
     -designtop      dtmf_chip \
     -designsource   [get_db workdir]/../RTL/dtmf_chip.test_netlist.v \
     -techlib        [get_db workdir]/../LIBS/atpg/include_libraries.v \
     -allowmissingmodules yes \

build_testmode \
     -testmode   COMPRESSION \
     -modedef    COMPRESSION \
     -assignfile [get_db workdir]/../SOURCEFILES/dtmf_chip.COMPRESSION_DECOMP.pinassign \
     -delaymode  zero \

report_test_structures \
     -testmode        COMPRESSION \

verify_test_structures \
     -testmode       COMPRESSION \

build_faultmodel

create_logic_delay_tests \
     -testmode   COMPRESSION \
     -experiment dynamic \
     -hosts	`hostname`[8] \	

commit_tests \
     -testmode     COMPRESSION \
     -inexperiment dynamic \

write_vectors \
     -testmode   COMPRESSION \
     -language   verilog \
     -scanformat parallel \
     -exportdir  [get_db workdir]/testresults/verilog/COMPRESSION_PARALLEL \

write_vectors \
     -testmode   COMPRESSION \
     -language   verilog \
     -scanformat serial \
     -exportdir  [get_db workdir]/testresults/verilog/COMPRESSION_SERIAL \

