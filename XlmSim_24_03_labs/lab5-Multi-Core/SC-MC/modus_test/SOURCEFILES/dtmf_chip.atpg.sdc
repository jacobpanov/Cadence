
# Set the SDC version being used
set sdc_version 1.4

# Set the current design
current_design dtmf_chip

# The following SDC timing constraints are relevant for ATPG
#    - set_false_path
#    - set_multicycle_path
#    - set_disable_timing
#    - set_case_analysis

# Example SDC Constraint
set_false_path -to DTMF_INST0/RESULTS_CONV_INST/r852_reg_1_/D
