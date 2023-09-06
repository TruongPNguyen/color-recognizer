onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /audioSelect_testbench/CLOCK_50
add wave -noupdate /audioSelect_testbench/reset
add wave -noupdate /audioSelect_testbench/greenCount
add wave -noupdate /audioSelect_testbench/redCount
add wave -noupdate /audioSelect_testbench/greenAudioRequest
add wave -noupdate /audioSelect_testbench/greenCountAudioRequest
add wave -noupdate /audioSelect_testbench/redAudioRequest
add wave -noupdate /audioSelect_testbench/redCountAudioRequest
add wave -noupdate /audioSelect_testbench/sampleDone
add wave -noupdate /audioSelect_testbench/CODEC_write
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {996 ps}
