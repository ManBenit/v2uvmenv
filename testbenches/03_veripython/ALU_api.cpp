//** [ API TEMPLATE FOR COMBINATORIAL MODELS ] **/
// MODEL_RTL            It is on refmodel directory.
// INPUT_SIGNAL_NAME    List of input signals.
// OUTPUT_SIGNAL_NAME   List of output signals.

#include "VALU.h"  // Verilator-generated header for the adder module
#include "verilated.h"
#include "verilated_vcd_c.h"

// Pointer to DUT (Device Under Test)
VALU* dut = nullptr;

// Pointer to export waveforms
VerilatedVcdC* tfp = nullptr;
vluint64_t main_time = 0; // Contador de tiempo global para Verilator
double sc_time_stamp() { return main_time; } // Necesario para Verilator

extern "C" {
    // Dump waveform
    void dump(){
        tfp->dump(main_time);
        main_time++;
    }

    // Evaluate
    void sim_eval() {
        dut->eval();  // Evaluate the module
    }

    // Apply reset
    void reset() {
        dut -> ex_datars1_i = 0;
        dut -> ex_datars2_i = 0;
        dut -> ex_aluop_i = 0;
        sim_eval();
    }

    // Initialize DUT
    void init() {
        dut = new VALU();
        tfp = new VerilatedVcdC();

        Verilated::traceEverOn(true);
        dut->trace(tfp, 1); // Signals deep
        tfp->open("dut_signals.vcd");

        reset();
    }

    // Finalize the simulation
    void finalize() {
        if (tfp) {
            tfp->close();
            delete tfp;
            tfp = nullptr;
        }
        if (dut) {
            delete dut;
            dut = nullptr;
        }
    }



    /*############ SETTERS (for inputs) ############*/
    void set_ex_datars1_i(long ex_datars1_i){
        dut->ex_datars1_i = ex_datars1_i;
        sim_eval();
    }

    void set_ex_datars2_i(long ex_datars2_i){
        dut->ex_datars2_i = ex_datars2_i;
        sim_eval();
    }

    void set_ex_aluop_i(long ex_aluop_i){
        dut->ex_aluop_i = ex_aluop_i;
        sim_eval();
    }


    /*############ GETTERS (for outputs) ############*/
    long get_ex_zerof_o() {
        return dut->ex_zerof_o;
    }

    long get_ex_data_o() {
        return dut->ex_data_o;
    }
}

