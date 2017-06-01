#create_clock -period 5.000 -name dly_clk_p -waveform {0.000 2.500} [get_ports dly_clk_p]

#set_property PACKAGE_PIN AJ32 [get_ports {cascade_out[0]}]
#set_property PACKAGE_PIN AK32 [get_ports {cascade_out[1]}]

set_property PACKAGE_PIN AP40 [get_ports re_sync_in]
set_property PACKAGE_PIN AM39 [get_ports dly_rdy]



set_property IOSTANDARD LVCMOS18 [get_ports dly_rdy]
set_property IOSTANDARD LVCMOS18 [get_ports re_sync_in]


set_property PACKAGE_PIN AN39 [get_ports {tap_out[0]}]
set_property PACKAGE_PIN AR37 [get_ports {tap_out[1]}]
set_property PACKAGE_PIN AT37 [get_ports {tap_out[2]}]
set_property PACKAGE_PIN AP41 [get_ports {tap_out[4]}]
set_property PACKAGE_PIN AR35 [get_ports {tap_out[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {tap_out[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {tap_out[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {tap_out[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {tap_out[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {tap_out[0]}]

set_property PACKAGE_PIN K37 [get_ports {ch_d0_p[0]}]
set_property PACKAGE_PIN K38 [get_ports {ch_d0_n[0]}]
set_property PACKAGE_PIN N39 [get_ports {ch_d1_p[0]}]
set_property PACKAGE_PIN N40 [get_ports {ch_d1_n[0]}]
set_property IOSTANDARD LVDS [get_ports {ch_d0_p[0]}]
set_property IOSTANDARD LVDS [get_ports {ch_d1_p[0]}]
set_property IOSTANDARD LVDS [get_ports {ch_d0_n[0]}]
set_property IOSTANDARD LVDS [get_ports {ch_d1_n[0]}]

set_property PACKAGE_PIN R40 [get_ports {ch_d0_p[1]}]
set_property PACKAGE_PIN P40 [get_ports {ch_d0_n[1]}]
set_property PACKAGE_PIN N38 [get_ports {ch_d1_p[1]}]
set_property PACKAGE_PIN M39 [get_ports {ch_d1_n[1]}]
set_property IOSTANDARD LVDS [get_ports {ch_d0_p[1]}]
set_property IOSTANDARD LVDS [get_ports {ch_d1_p[1]}]
set_property IOSTANDARD LVDS [get_ports {ch_d0_n[1]}]
set_property IOSTANDARD LVDS [get_ports {ch_d1_n[1]}]


set_property PACKAGE_PIN M37 [get_ports {ch_d0_p[2]}]
set_property PACKAGE_PIN M38 [get_ports {ch_d0_n[2]}]
set_property PACKAGE_PIN K42 [get_ports {ch_d1_p[2]}]
set_property PACKAGE_PIN J42 [get_ports {ch_d1_n[2]}]
set_property IOSTANDARD LVDS [get_ports {ch_d0_p[2]}]
set_property IOSTANDARD LVDS [get_ports {ch_d1_p[2]}]
set_property IOSTANDARD LVDS [get_ports {ch_d0_n[2]}]
set_property IOSTANDARD LVDS [get_ports {ch_d1_n[2]}]


set_property PACKAGE_PIN H40 [get_ports {ch_d0_p[3]}]
set_property PACKAGE_PIN H41 [get_ports {ch_d0_n[3]}]
set_property PACKAGE_PIN P41 [get_ports {ch_d1_p[3]}]
set_property PACKAGE_PIN N41 [get_ports {ch_d1_n[3]}]
set_property IOSTANDARD LVDS [get_ports {ch_d0_p[3]}]
set_property IOSTANDARD LVDS [get_ports {ch_d1_p[3]}]
set_property IOSTANDARD LVDS [get_ports {ch_d0_n[3]}]
set_property IOSTANDARD LVDS [get_ports {ch_d1_n[3]}]



set_property IOSTANDARD LVDS [get_ports dco_p]
set_property IOSTANDARD LVDS [get_ports dco_n]
set_property PACKAGE_PIN K39 [get_ports dco_p]
set_property PACKAGE_PIN K40 [get_ports dco_n]
create_clock -period 2.000 -name dco_p -waveform {0.000 1.000} [get_ports dco_p]

set_property PACKAGE_PIN L39 [get_ports fco_p]
set_property IOSTANDARD LVDS [get_ports fco_p]
set_property IOSTANDARD LVDS [get_ports fco_n]

set_property IOSTANDARD LVDS [get_ports osc_in_p]
set_property IOSTANDARD LVDS [get_ports osc_in_n]
set_property PACKAGE_PIN H19 [get_ports osc_in_p]
set_property PACKAGE_PIN G18 [get_ports osc_in_n]
#vc709 osc_in
#dac3484evm cdce62005 in
create_clock -period 5.000 -name osc_in_p -waveform {0.000 2.500} [get_ports osc_in_p]



set_property IOSTANDARD LVCMOS18 [get_ports user_pushbutton_g]

### dac spi interface
set_property IOSTANDARD LVCMOS18 [get_ports SCLK]
set_property IOSTANDARD LVCMOS18 [get_ports SDENB]
set_property PACKAGE_PIN J30 [get_ports SDENB]
set_property PACKAGE_PIN N31 [get_ports SDIO]
set_property PACKAGE_PIN U28 [get_ports SCLK]
###dac3484evm interface
#set_property PACKAGE_PIN R30 [get_ports {Q_p[0]}]
#set_property PACKAGE_PIN N28 [get_ports {Q_p[1]}]
#set_property PACKAGE_PIN W30 [get_ports {Q_p[2]}]
#set_property PACKAGE_PIN M36 [get_ports {Q_p[3]}]
#set_property PACKAGE_PIN F40 [get_ports {Q_p[4]}]
#set_property PACKAGE_PIN G41 [get_ports {Q_p[5]}]
#set_property PACKAGE_PIN H40 [get_ports {Q_p[6]}]
#set_property PACKAGE_PIN P41 [get_ports {Q_p[7]}]
#set_property PACKAGE_PIN U31 [get_ports {Q_p[8]}]
#set_property PACKAGE_PIN M28 [get_ports {Q_p[9]}]
#set_property PACKAGE_PIN T29 [get_ports {Q_p[10]}]
#set_property PACKAGE_PIN R28 [get_ports {Q_p[12]}]
#set_property PACKAGE_PIN Y29 [get_ports {Q_p[13]}]
#set_property PACKAGE_PIN K37 [get_ports {Q_p[14]}]
#set_property PACKAGE_PIN R40 [get_ports {Q_p[15]}]
#set_property PACKAGE_PIN K29 [get_ports {Q_p[11]}]
#set_property PACKAGE_PIN V29 [get_ports frame_p]
#set_property PACKAGE_PIN M32 [get_ports DataCLk_p]
#set_property PACKAGE_PIN V30 [get_ports SYNC_p]
#set_property IOSTANDARD LVDS [get_ports frame_p]
#set_property IOSTANDARD LVCMOS18 [get_ports SDIO]
#set_property IOSTANDARD LVDS [get_ports SYNC_p]
#set_property IOSTANDARD LVDS [get_ports DataCLk_p]
#set_property PACKAGE_PIN AV40 [get_ports user_pushbutton_g]
#set_property PACKAGE_PIN N38 [get_ports a_d0_p]
#set_property IOSTANDARD LVDS [get_ports {Q_p[15]}]
#set_property IOSTANDARD LVDS [get_ports {Q_p[14]}]
#set_property IOSTANDARD LVDS [get_ports {Q_p[13]}]
#set_property IOSTANDARD LVDS [get_ports {Q_p[12]}]
#set_property IOSTANDARD LVDS [get_ports {Q_p[11]}]
#set_property IOSTANDARD LVDS [get_ports {Q_p[10]}]
#set_property IOSTANDARD LVDS [get_ports {Q_p[9]}]
#set_property IOSTANDARD LVDS [get_ports {Q_p[8]}]
#set_property IOSTANDARD LVDS [get_ports {Q_p[7]}]
#set_property IOSTANDARD LVDS [get_ports {Q_p[6]}]
#set_property IOSTANDARD LVDS [get_ports {Q_p[5]}]
#set_property IOSTANDARD LVDS [get_ports {Q_p[4]}]
#set_property IOSTANDARD LVDS [get_ports {Q_p[3]}]
#set_property IOSTANDARD LVDS [get_ports {Q_p[2]}]
#set_property IOSTANDARD LVDS [get_ports {Q_p[1]}]
#set_property IOSTANDARD LVDS [get_ports {Q_p[0]}]
## dac3484evm interface
#set_property BEL BUFR [get_cells crg_dcms_inst/BUFR_inst]
#set_property LOC BUFR_X0Y38 [get_cells crg_dcms_inst/BUFR_inst]
#set_property BEL MMCME2_ADV [get_cells crg_dcms_inst/dcm_global/U0/mmcm_adv_inst]
#set_property PACKAGE_PIN L39 [get_ports osc_in_p]
#set_property PACKAGE_PIN L40 [get_ports osc_in_n]
##clk from fmc generated by cdce62005
#set_property PACKAGE_PIN J40 [get_ports fco_p]


#set_property LOC MMCME2_ADV_X0Y9 [get_cells crg_dcms_inst/dcm_global/U0/mmcm_adv_inst]








set_property OFFCHIP_TERM NONE [get_ports SCLK]
set_property OFFCHIP_TERM NONE [get_ports SDENB]
set_property OFFCHIP_TERM NONE [get_ports SDIO]
