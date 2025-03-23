Custom Access Lab

This lab customizes an existing register model using callbacks to define access policies beyond those natively supported in UVM.

Generating the model is not part of the lab, but for further study and experiementation, the IP-XACT XML register specification and
generation script is provided.
 
Use the following command to generate the register model:

reg_verifier -domain uvmreg -top custom_regs_2-0.xml -dut_name custom_regs -out_file custom_regs -cov -quicktest -pkg custom_regs_pkg

Refer to lab02_generation for an explanation of these options; the outputs generated and how to verify the model.


