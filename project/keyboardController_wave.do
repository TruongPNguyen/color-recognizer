onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /keyboardController_testbench/clk
add wave -noupdate /keyboardController_testbench/reset
add wave -noupdate /keyboardController_testbench/makeBreak
add wave -noupdate /keyboardController_testbench/sampleDone
add wave -noupdate /keyboardController_testbench/outCode
add wave -noupdate /keyboardController_testbench/dut/lastOutCode
add wave -noupdate /keyboardController_testbench/redCountAudioRequest
add wave -noupdate /keyboardController_testbench/greenCountAudioRequest
add wave -noupdate /keyboardController_testbench/redAudioRequest
add wave -noupdate /keyboardController_testbench/greenAudioRequest
add wave -noupdate /keyboardController_testbench/sampleDoneAck
add wave -noupdate /keyboardController_testbench/dut/ps
add wave -noupdate /keyboardController_testbench/dut/ns
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {232 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {0 ps} {1 ns}
