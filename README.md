# mmu2_1S_klipper_config

Unified  macros for printer and touch-mi  support

```
[gcode_macro VARS_PRINTER]
variable_end_x_pos: 10
variable_end_y_pos: 10
variable_touchmi_x_pos: 375
variable_touchmi_y_pos: -10
variable_touchmi_x_center_pos: 200
variable_touchmi_y_center_pos: 200
variable_touchmi_z_height: 20
variable_enable_mmu: 1
variable_enable_servo: 0
variable_enable_z_tilt: 0
variable_enable_clean_nozzle: 0
variable_clean_x_pos: -14
variable_clean_y_pos: 81
variable_change_filament_x_pos: 125
variable_change_filament_y_pos: -10
variable_change_length_slow: 10
variable_change_length_fast: 0
gcode:

[include  printer-macros.cfg]
```
