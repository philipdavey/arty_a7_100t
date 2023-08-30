# Configure Paths / Values
##########################

set script_dir [pwd]
set output dir $script_dir/vivado
set source_dir ../source

set project_name arty_a7_100t_vivado
set part_num xc7a100tcsg324-1

# Create Vivado Project:
create_project -force $project_name $output_dir -part $part_num

# Add RTL files: