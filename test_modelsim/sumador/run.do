# ========================================
# Script de simulación para sumador
# ========================================

# Limpiar y preparar librería
vdel -all
vlib work

# Compilar DUT y testbench
vlog adder.sv tb.sv

# Cargar testbench en modo consola
vsim tb -voptargs=+acc

# Agregar todas las señales del testbench al registro de ondas
log -r /*

# Ejecutar la simulación
run -all

# Guardar la forma de onda para abrir con QuestaSim
write format wave -window .main_pane.wave wave.do
write list all_signals.list
write transcript transcript.log
write wave -window .main_pane.wave waves.wlf

# Salir del simulador
quit








