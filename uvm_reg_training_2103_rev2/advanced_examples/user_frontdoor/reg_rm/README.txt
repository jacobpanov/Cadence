Model Generation Lab

This lab uses Cadence's reg_verifier tool to convert an IP-XACT XML register
specification into a UVM register model.

Use the following command to generate the register model:

reg_verifier -domain uvmreg -top reg_rm.xml -dut_name custom_regs -out_file custom_regs -cov -quicktest -pkg custom_regs_pkg -top_level_class_name reg_model

where:
-domain uvmreg creates a UVM register model
-top reg_rm.xml is the input IP-XACT register definition file
-dut_name is custom_regs, the name of the top level component in the IP-XACT file
-out_file custom_regs is the name of the output file containing the UVM register model
-cov enables coverage
-quicktest creates the quicktest testbench
-pkg creates a package named reg_rm_pkg for the register model
-top_level_class_name <user_defined_name> allows a user-defined name to be used as the type of the top level of the register model


The output file is created in the directory reg_verifier_dir/uvmreg. To
run the quicktest, change to this directory and execute:

> make run_test

Check the printed register hierarchy matches your expectations.


