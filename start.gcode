M300 S60 P10 ; chirp

M17 ; enable steppers
M862.3 P "[printer_model]" ; printer model check
M862.1 P[nozzle_diameter] ; nozzle diameter check
M115 U3.12.2 ; tell printer latest fw version

M117 Initializing
M555 X{(min(print_bed_max[0], first_layer_print_min[0] + 32) - 32)} Y{(max(0, first_layer_print_min[1]) - 4)} W{((min(print_bed_max[0], max(first_layer_print_min[0] + 32, first_layer_print_max[0])))) - ((min(print_bed_max[0], first_layer_print_min[0] + 32) - 32))} H{((first_layer_print_max[1])) - ((max(0, first_layer_print_min[1]) - 4))}

G90 ; use absolute coordinates
M83 ; extruder relative mode

; Reset speed and extrusion rates
M200 D0 ; disable volumetric e
M220 S100 ; reset speed
M221 S100 ; reset extrusion rate


; Set initial warmup temps
M117 Nozzle preheat

M140 S[first_layer_bed_temperature] ; set bed temp
{if filament_type[initial_tool]=="PC" or filament_type[initial_tool]=="NYLON"}
M104 S{first_layer_temperature[initial_tool]-25} ; set extruder temp for bed leveling
M109 R{first_layer_temperature[initial_tool]-25} ; wait for temp
{elsif filament_type[initial_tool]=="FLEX"}
M104 S210 ; set extruder temp for bed leveling
M109 R210 ; wait for temp
{else}
M104 S170 ; set extruder temp for bed leveling
M109 R170 ; wait for temp
{endif}

M84 E ; turn off E motor

M117 Homing
G28 ; home all without mesh bed level
; probe to clean the nozzle
G1 X{(min(print_bed_max[0], first_layer_print_min[0] + 32) - 32)+32} Y{((first_layer_print_min[1]) - 4)} Z{5} F4800
M302 S160 ; lower cold extrusion limit to 160C

{if filament_type[initial_tool]=="FLEX"}
G1 E-4 F2400 ; retraction
{else}
G1 E-2 F2400 ; retraction
{endif}

M84 E ; turn off E motor

G29 P9 X{(min(print_bed_max[0], first_layer_print_min[0] + 32) - 32)} Y{(max(0, first_layer_print_min[1]) - 4)} W{32} H{4}

{if first_layer_bed_temperature[initial_tool]<=60}M106 S100{endif}

G0 X{(min(print_bed_max[0], first_layer_print_min[0] + 32) - 32)} Y{(max(0, first_layer_print_min[1]) - 4)} Z{40} F10000

M190 S[first_layer_bed_temperature] ; wait for bed temp

M107

;
; MBL
;
M117 Leveling
M84 E ; turn off E motor
G29 ; mesh bed leveling
M104 S[first_layer_temperature] ; set extruder temp
G0 X{(min(print_bed_max[0], first_layer_print_min[0] + 32) - 32)} Y{(max(0, first_layer_print_min[1]) - 4) + 4 - 4.5} Z{30} F4800

M109 S[first_layer_temperature] ; wait for extruder temp
G1 Z0.2 F720
G92 E0

M569 S0 E ; set spreadcycle mode for extruder


M117 Purging
;
; Extrude purge line
;
{if filament_type[initial_tool]=="FLEX"}
G1 E4 F2400 ; deretraction
{else}
G1 E2 F2400 ; deretraction
{endif}

; move right
G1 X{(min(print_bed_max[0], first_layer_print_min[0] + 32) - 32) + 32} E{32 * 0.15} F1000
; move down
G1 Y{(max(0, first_layer_print_min[1]) - 4) + 4 - 4.5 - 1.5} E{1.5 * 0.15} F1000
; move left
G1 X{(min(print_bed_max[0], first_layer_print_min[0] + 32) - 32)} E{32 * 0.30} F800

G92 E0
M221 S100 ; set flow to 100%

M300 S40 P10 ; chirp
M117 Print in progress