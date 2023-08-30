

# Configure Paths / Values
####################################################################
set script_dir [pwd]
set output_dir $script_dir/vivado
set source_dir ../source

set project_name arty_a7_100t_vivado
set part_num xc7a100tcsg324-1

# Create Vivado Project:
####################################################################
create_project -force $project_name $output_dir -part $part_num

# Add RTL files:
####################################################################
cd $source_dir

# IP Cores:
add_files -norecurse ip_cores/clk_wiz_0/clk_wiz_0.xci

add_files -norecurse arty_top.vhd
add_files -norecurse vga_driver/vga_driver.vhd

# Add XDC file:
####################################################################
add_files -norecurse arty_a7_100_master.xdc