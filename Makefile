
ICEDIR=~/tools/lscc/iCEcube2.2014.04
DIAMOND_DIR=/usr/local/diamond/3.2_x64
PGR=$(DIAMOND_DIR)/bin/lin64/pgrcmd
XCF=proj_ice/program_diamond.xcf

syn:
	$(ICEDIR)/sbt_backend/bin/linux/opt/synpwrap/synpwrap \
	    -prj proj_ice/syn.prj
	tclsh proj_ice/icecube_flow.tcl

mul:
	$(ICEDIR)/sbt_backend/bin/linux/opt/synpwrap/synpwrap \
	    -prj proj_ice/mul_accum_syn.prj
	tclsh proj_ice/mul_acum_ice_flow.tcl

lse:
	$(ICEDIR)/LSE/bin/lin/synthesis -f proj_ice/lse.prj
	tclsh proj_ice/icecube_flow.tcl

prog:
	-sudo rmmod ftdi_sio
	$(PGR) -infile $(XCF) -cabletype usb2 -portaddress FTUSB-0
	sudo modprobe ftdi_sio
