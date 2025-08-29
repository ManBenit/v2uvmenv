#include "VALU.h"        // Cabecera generada por Verilator
#include "verilated.h"   // Soporte de Verilator
#include "verilated_vcd_c.h" // Formas de onda de Verilator
#include <iostream>
#include <iomanip>
#include <bitset>

vluint64_t main_time = 0; // Contador de tiempo global para Verilator
double sc_time_stamp() { return main_time; } // Necesario para Verilator

int main(int argc, char** argv) {

    Verilated::commandArgs(argc, argv);


    Verilated::traceEverOn(true); // $dumpvar

    VALU* dut = new VALU;
    VerilatedVcdC* tfp = new VerilatedVcdC;

    dut->trace(tfp, 1); // Signals deep
    tfp->open("dut_signals.vcd");



    std::cout << "=== START TESTBENCH ===" << std::endl;

    // Variables para facilitar asignaciones
    uint32_t WORD = 32;
    uint32_t ALUOP = 4;

    // Entradas iniciales
    dut->ex_datars1_i = 10;
    dut->ex_datars2_i = 5;

    // Add
    dut->ex_aluop_i = 0x8;
    dut->eval();
    tfp->dump(main_time++);
    std::cout << "Add: " << (int32_t)dut->ex_datars1_i
              << " + " << (int32_t)dut->ex_datars2_i
              << " = " << (int32_t)dut->ex_data_o
              << " (expected 15)" << std::endl;

    // Sub
    dut->ex_aluop_i = 0x1;
    dut->eval();
    tfp->dump(main_time++);
    std::cout << "Sub: " << (int32_t)dut->ex_datars1_i
              << " - " << (int32_t)dut->ex_datars2_i
              << " = " << (int32_t)dut->ex_data_o
              << " (expected 5)" << std::endl;

    // Prod
    dut->ex_aluop_i = 0x2;
    dut->eval();
    tfp->dump(main_time++);
    std::cout << "Prod: " << (int32_t)dut->ex_datars1_i
              << " * " << (int32_t)dut->ex_datars2_i
              << " = " << (int32_t)dut->ex_data_o
              << " (expected 50)" << std::endl;

    // Div
    dut->ex_aluop_i = 0x3;
    dut->eval();
    tfp->dump(main_time++);
    std::cout << "Div: " << (int32_t)dut->ex_datars1_i
              << " / " << (int32_t)dut->ex_datars2_i
              << " = " << (int32_t)dut->ex_data_o
              << " (expected 2)" << std::endl;

    // AND
    dut->ex_aluop_i = 0x4;
    dut->eval();
    tfp->dump(main_time++);
    std::cout << "AND: " << std::bitset<32>(dut->ex_datars1_i)
              << " & " << std::bitset<32>(dut->ex_datars2_i)
              << " = " << std::bitset<32>(dut->ex_data_o) << std::endl;

    // XOR
    dut->ex_aluop_i = 0x5;
    dut->eval();
    tfp->dump(main_time++);
    std::cout << "XOR: " << std::bitset<32>(dut->ex_datars1_i)
              << " ^ " << std::bitset<32>(dut->ex_datars2_i)
              << " = " << std::bitset<32>(dut->ex_data_o) << std::endl;

    // OR
    dut->ex_aluop_i = 0x6;
    dut->eval();
    tfp->dump(main_time++);
    std::cout << "OR: " << std::bitset<32>(dut->ex_datars1_i)
              << " | " << std::bitset<32>(dut->ex_datars2_i)
              << " = " << std::bitset<32>(dut->ex_data_o) << std::endl;

    // Shift left logical
    dut->ex_aluop_i = 0x7;
    dut->ex_datars2_i = 0x2;
    dut->eval();
    tfp->dump(main_time++);
    std::cout << "Shift Left 2: " << (int32_t)dut->ex_datars1_i
              << " << 2 = " << (int32_t)dut->ex_data_o << std::endl;
    std::cout << "Shift Left 2: " << std::bitset<32>(dut->ex_datars1_i)
              << " << 2 = " << std::bitset<32>(dut->ex_data_o) << std::endl;

    // Shift right arithmetic
    dut->ex_aluop_i = 0xD;
    dut->ex_datars1_i = (int32_t)-8; // negativo
    dut->ex_datars2_i = 1;
    dut->eval();
    tfp->dump(main_time++);
    std::cout << "Shift Right Arith: " << (int32_t)dut->ex_datars1_i
              << " >>> " << (int32_t)dut->ex_datars2_i
              << " = " << (int32_t)dut->ex_data_o << std::endl;
    std::cout << "Shift Right Arith: " << std::bitset<32>(dut->ex_datars1_i)
              << " >>> " << std::bitset<32>(dut->ex_datars2_i)
              << " = " << std::bitset<32>(dut->ex_data_o) << std::endl;

    // Shift right logical
    dut->ex_aluop_i = 0xE;
    dut->eval();
    tfp->dump(main_time++);
    std::cout << "Shift Right Logical: " << (int32_t)dut->ex_datars1_i
              << " >> " << (int32_t)dut->ex_datars2_i
              << " = " << (int32_t)dut->ex_data_o << std::endl;
    std::cout << "Shift Right Logical: " << std::bitset<32>(dut->ex_datars1_i)
              << " >> " << std::bitset<32>(dut->ex_datars2_i)
              << " = " << std::bitset<32>(dut->ex_data_o) << std::endl;

    // SLT (signed)
    dut->ex_aluop_i = 0x9;
    dut->ex_datars1_i = 5;
    dut->ex_datars2_i = 10;
    dut->eval();
    tfp->dump(main_time++);
    std::cout << "SLT: " << (int32_t)dut->ex_datars1_i
              << " < " << (int32_t)dut->ex_datars2_i
              << " ? " << (int32_t)dut->ex_data_o << std::endl;

    // SLTU (unsigned)
    dut->ex_aluop_i = 0xA;
    dut->ex_datars1_i = 0xFFFFFFF0;
    dut->ex_datars2_i = 10;
    dut->eval();
    tfp->dump(main_time++);
    //std::cout << std::hex << std::uppercase; // (Forzar salida hexadecimal)
    std::cout << "SLTU: " << (int32_t)dut->ex_datars1_i
              << " < " << (int32_t)dut->ex_datars2_i
              << " ? " << (int32_t)dut->ex_data_o << std::endl;
    //std::cout << std::dec; // (Recuperar salida decimal)

    // Default
    dut->ex_aluop_i = 0x0;
    dut->eval();
    tfp->dump(main_time++);
    std::cout << "Default: output = " << (int32_t)dut->ex_data_o
              << " (expected 0)" << std::endl;

    std::cout << "=== END TESTBENCH ===" << std::endl;

    delete dut;
    return 0;
}
