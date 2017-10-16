#!/usr/bin/tclsh

set app_name            "fsbl"
set app_type            {Zynq FSBL}
set bsp_name            "fsbl_bsp"
set hw_name             "design_1_wrapper_hw_platform_0"
set hwspec_file         "design_1_wrapper.hdf"
set proc_name           "ps7_cortexa9_0"

if {[info exists project_name     ] == 0} {
    set project_name        "project"
}
if {[info exists project_directory] == 0} {
    set project_directory   [pwd]
}
if {[info exists sdk_workspace] == 0} {
    set sdk_workspace       [file join $project_directory $project_name.sdk]
}

if {[info commands sdk::setws] ne ""} {
    sdk::setws        $sdk_workspace
} else {
    sdk set_workspace $sdk_workspace
}

if {[info commands sdk::createhw] ne ""} {
    sdk::createhw         -name $hw_name -hwspec [file join $sdk_workspace $hwspec_file]
} else {
    sdk create_hw_project -name $hw_name -hwspec [file join $sdk_workspace $hwspec_file]
}

# sdk::create_bsp_project -name $bsp_name -hwproject $hw_name -proc $proc_name -os standalone

hsi::open_hw_design  [file join $sdk_workspace $hw_name "system.hdf"]
hsi::create_sw_design $bsp_name -proc $proc_name -os standalone
hsi::add_library xilffs
hsi::generate_bsp -sw $bsp_name -dir [file join $sdk_workspace $bsp_name] -compile
hsi::close_sw_design  $bsp_name

sdk create_app_project -name $app_name -hwproject $hw_name -proc $proc_name -os standalone -lang C -app $app_type -bsp $bsp_name

sdk build_project $app_name

exit
