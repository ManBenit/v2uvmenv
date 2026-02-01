# === Clean and create library ===
if [file exists work] { vdel -all }
vlib work

# === 1. Compile DUT and testbench with coverage flags ===
# -cover sbcexf: enables coverage of Statements, Branches, Conditions, Expressions, FSMs.
vlog -sv -cover sbcexf +incdir+. Sumador.v ALU.v tb.sv

# === 2. Load simulation with coverage ===
vsim -voptargs=+acc -coverage +UVM_NO_RELNOTES +UVM_VERBOSITY=UVM_LOW top

# === Register and run ===
log -r /*
onfinish stop
run -all

# === 3. Generate reports ===
# Save coverage database
coverage save -onexit coverage_report.ucdb
vcover report -details coverage_report.ucdb -output coverage_summary.txt

# === Save waveforms and close ===
if {[file exists waves.wlf]} {
    file delete -force waves_prev.wlf
    file rename -force waves.wlf waves_prev.wlf
}
write wave -window .main_pane.wave waves.wlf

# === Guardar información complementaria ===
# These commands run only if GUI is used
if {[info exists ::env(DISPLAY)]} {
    catch {write format wave -window .main_pane.wave wave.do}
    catch {write list all_signals.list}
    catch {write transcript transcript.log}
}

puts "SUCCESS: Simulation and Coverage report generated."
quit