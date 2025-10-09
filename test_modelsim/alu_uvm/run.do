# ============================================================
# Script de simulación genérico para ModelSim / QuestaSim
# Autor: (Tu nombre)
# Descripción:
#   - Limpia la librería de trabajo
#   - Compila todos los archivos Verilog/SystemVerilog
#   - Ejecuta el testbench en modo consola o GUI
#   - Guarda las ondas en un archivo .wlf para análisis posterior
# ============================================================

# === Limpiar y crear librería de trabajo ===
if [file exists work] {
    vdel -all
}
vlib work

# === Compilar los módulos ===
# Ajusta la lista de archivos según tu proyecto
#### vlog Sumador.v ALU.v tb.sv
vlog -sv +incdir+. Sumador.v ALU.v tb.sv

# === Cargar el testbench ===
# -voptargs=+acc  habilita acceso completo a señales
# +UVM_NO_RELNOTES suprime mensajes innecesarios de UVM si usas pyuvm o uvm
#### vsim -voptargs=+acc tb
vsim -voptargs=+acc +UVM_NO_RELNOTES +UVM_VERBOSITY=UVM_LOW top

# === Registrar todas las señales ===
log -r /*

# === Ejecutar la simulación completa ===
# Si el testbench tiene $stop, fuerza la salida con run -all y luego quit
onfinish stop
run -all

# === Guardar ondas ===
# Se genera un archivo de ondas (waves.wlf) siempre, sin depender de GUI
if {[file exists waves.wlf]} {
    file delete -force waves_prev.wlf
    file rename -force waves.wlf waves_prev.wlf
}
write wave -window .main_pane.wave waves.wlf

# === Guardar información complementaria ===
# Estos comandos solo se ejecutan si estás en GUI
if {[info exists ::env(DISPLAY)]} {
    catch {write format wave -window .main_pane.wave wave.do}
    catch {write list all_signals.list}
    catch {write transcript transcript.log}
}

# === Mensaje final ===
puts "SUCCESS: Completed simulation."
puts "Waveform file saved at: waves.wlf"
puts "You can open it with: vsim -view waves.wlf"

# === Salir ===
quit 


