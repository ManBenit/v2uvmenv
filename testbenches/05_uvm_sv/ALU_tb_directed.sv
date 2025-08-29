`include "uvm_macros.svh"
import uvm_pkg::*;

// ------------------------------------------------------------
// Interface del DUT
// ------------------------------------------------------------
interface alu_if #(parameter WORD=32, ALUOP=4);
  logic [WORD-1:0] ex_datars1_i;
  logic [WORD-1:0] ex_datars2_i;
  logic [ALUOP-1:0] ex_aluop_i;
  logic [WORD-1:0] ex_data_o;
  logic            ex_zerof_o;
endinterface

// ------------------------------------------------------------
// Sequence Item (request/response)
// Objeto mutable
// ------------------------------------------------------------
class ALUSeqItem extends uvm_sequence_item;
  // Inputs
  rand bit [31:0] a;
  rand bit [31:0] b;
  rand bit [3:0]  aluop;
  
  // Outputs
  bit [31:0] y;
  bit     zero;

  // Register of sequnce item into UVM factory.
  `uvm_object_utils(ALUSeqItem)

  //Constructor
  function new(string name="ALUSeqItem");
    super.new(name);
  endfunction

  // Restricciones definitivas
  constraint c_ops { 
    aluop inside {
      4'h8,
      4'h1,
      4'h2, 
      4'h3,
      4'h4,
      4'h5,
      4'h6,
      4'h7, 
      4'hD, 
      4'hE, 
      4'h9, 
      4'hA
    }; 
  } 

  /*function string convert2string();
    return $sformatf("a=%0d, b=%0d, aluop=0x%0h, y=%0d, zero=%0b", a, b, aluop, y, zero);
  endfunction*/
  
endclass

// ------------------------------------------------------------
// Sequence
// ------------------------------------------------------------
class ALUSequence_Rand extends uvm_sequence#(ALUSeqItem);
  `uvm_object_utils(ALUSequence_Rand)
  int NUM_OF_ITEMS;

  function new(string name="ALUSequence_Rand");
    super.new(name);
    NUM_OF_ITEMS = 4;
  endfunction

  task body();
    ALUSeqItem req;

    repeat (NUM_OF_ITEMS) begin
      req = ALUSeqItem::type_id::create("req_ALUSequence_Rand");
      start_item(req);
      // Restricciones temporales
      //if(!req.randomize() with { a inside {[0:10]}; b inside {[0:10]};}) `uvm_error("SEQ", "Randomization failed")
      if(!req.randomize()) `uvm_error("SEQ", "Randomization failed")
      finish_item(req);
    end
  endtask
endclass

class ALUSequence_Directed extends uvm_sequence#(ALUSeqItem);
  `uvm_object_utils(ALUSequence_Directed)

  function new(string name="ALUSequence_Directed");
    super.new(name);
  endfunction

  virtual task body();
    ALUSeqItem req;

    `uvm_info("SEQ", "=== START TESTBENCH ===", UVM_NONE);

    // Add
    req = ALUSeqItem::type_id::create("add_tr");
    req.a = 32'd10; req.b = 32'd5; req.aluop = 4'h8;
    start_item(req); finish_item(req);

    // Sub
    req = ALUSeqItem::type_id::create("sub_tr");
    req.a = 32'd10; req.b = 32'd5; req.aluop = 4'h1;
    start_item(req); finish_item(req);

    // Prod
    req = ALUSeqItem::type_id::create("prod_tr");
    req.a = 32'd10; req.b = 32'd5; req.aluop = 4'h2;
    start_item(req); finish_item(req);

    // Div
    req = ALUSeqItem::type_id::create("div_tr");
    req.a = 32'd10; req.b = 32'd5; req.aluop = 4'h3;
    start_item(req); finish_item(req);

    // AND
    req = ALUSeqItem::type_id::create("and_tr");
    req.a = 32'd10; req.b = 32'd5; req.aluop = 4'h4;
    start_item(req); finish_item(req);

    // XOR
    req = ALUSeqItem::type_id::create("xor_tr");
    req.a = 32'd10; req.b = 32'd5; req.aluop = 4'h5;
    start_item(req); finish_item(req);

    // OR
    req = ALUSeqItem::type_id::create("or_tr");
    req.a = 32'd10; req.b = 32'd5; req.aluop = 4'h6;
    start_item(req); finish_item(req);

    // Shift left logical
    req = ALUSeqItem::type_id::create("sll_tr");
    req.a = 32'd10; req.b = 32'd2; req.aluop = 4'h7;
    start_item(req); finish_item(req);

    // Shift right arith
    req = ALUSeqItem::type_id::create("sra_tr");
    req.a = -32'sd8; req.b = 32'd1; req.aluop = 4'hD;
    start_item(req); finish_item(req);

    // Shift right logical
    req = ALUSeqItem::type_id::create("srl_tr");
    req.a = -32'sd8; req.b = 32'd1; req.aluop = 4'hE;
    start_item(req); finish_item(req);

    // SLT
    req = ALUSeqItem::type_id::create("slt_tr");
    req.a = 32'd5; req.b = 32'd10; req.aluop = 4'h9;
    start_item(req); finish_item(req);

    // SLTU
    req = ALUSeqItem::type_id::create("sltu_tr");
    req.a = 32'hFFFFFFF0; req.b = 32'd10; req.aluop = 4'hA;
    start_item(req); finish_item(req);

    // Default
    /*req = ALUSeqItem::type_id::create("def_tr");
    req.a = 32'd0; req.b = 32'd0; req.aluop = 4'h0;
    start_item(req); finish_item(req);*/

    `uvm_info("SEQ", "=== END TESTBENCH ===", UVM_NONE);
  endtask
endclass


// ------------------------------------------------------------
// Driver
// ------------------------------------------------------------
class ALUDriver extends uvm_driver#(ALUSeqItem);
  `uvm_component_utils(ALUDriver)
  virtual alu_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    // Recuperar objeto, parseado a virtual alu_if; obtenerlo mediante su nombre y guardarlo en vif local
    if(!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "No se encontró la interfaz")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      ALUSeqItem req;
      seq_item_port.get_next_item(req);
      vif.ex_datars1_i = req.a;
      vif.ex_datars2_i = req.b;
      vif.ex_aluop_i   = req.aluop;
      #1ns;
      seq_item_port.item_done();
    end
  endtask
endclass

// ------------------------------------------------------------
// Monitor
// ------------------------------------------------------------
class ALUMonitor extends uvm_monitor;
  `uvm_component_utils(ALUMonitor)
  virtual alu_if vif;
  uvm_analysis_port#(ALUSeqItem) send;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    send = new("send_monitor", this);
  endfunction

  function void build_phase(uvm_phase phase);
    // Recuperar objeto, parseado a virtual alu_if; obtenerlo mediante su nombre y guardarlo en vif local
    if(!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "No se encontró la interfaz")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      ALUSeqItem transaction = ALUSeqItem::type_id::create("monitor_item");
      #1ns;
      transaction.a     = vif.ex_datars1_i;
      transaction.b     = vif.ex_datars2_i;
      transaction.aluop = vif.ex_aluop_i;
      transaction.y     = vif.ex_data_o;
      transaction.zero  = vif.ex_zerof_o;
      `uvm_info("MON", transaction.convert2string(), UVM_MEDIUM)
      send.write(transaction);
    end
  endtask
endclass

// ------------------------------------------------------------
// Agent
// ------------------------------------------------------------
class ALUAgent extends uvm_agent;
  `uvm_component_utils(ALUAgent)

  ALUDriver driver;
  ALUMonitor monitor;
  uvm_sequencer#(ALUSeqItem) seqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    driver  = ALUDriver::type_id::create("driver", this);
    monitor  = ALUMonitor::type_id::create("monitor", this);
    seqr = uvm_sequencer#(ALUSeqItem)::type_id::create("seqr", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass

// ------------------------------------------------------------
// Scoreboard con modelo de referencia
// ------------------------------------------------------------

class ALUScoreboard extends uvm_scoreboard;
  `uvm_component_utils(ALUScoreboard)

  uvm_analysis_imp#(ALUSeqItem, ALUScoreboard) imp;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    imp = new("imp", this);
  endfunction

  // Implementación interna del Scoreboard
  virtual function bit [31:0] ref_model(ALUSeqItem tr);
      case (tr.aluop)
        4'h8: return tr.a + tr.b;                        // ADD
        4'h1: return tr.a - tr.b;                        // SUB
        4'h2: return tr.a * tr.b;                        // MUL
        4'h3: return (tr.b != 0) ? tr.a / tr.b : '0;     // DIV, evita división por 0
        4'h4: return tr.a & tr.b;                        // AND
        4'h5: return tr.a ^ tr.b;                        // XOR
        4'h6: return tr.a | tr.b;                        // OR
        4'h7: return tr.a << tr.b;                          // Shift
        4'hD: return $signed(tr.a) >>> tr.b;             // SRA (aritmético a la derecha)
        4'hE: return tr.a >> tr.b;                       // SRL (lógico a la derecha)
        4'h9: return ($signed(tr.a) < $signed(tr.b));    // SLT (signed)
        4'hA: return (tr.a < tr.b);                      // SLTU (unsigned)
        default: return '0;
      endcase
  endfunction

  function void write(ALUSeqItem tr);
    bit [31:0] refm;

    // IMPRESIÓN DE VALORES //////
    case (tr.aluop)
      4'h8: $display("Add: %d + %d = %d", tr.a, tr.b, tr.y);
      4'h1: $display("Sub: %d - %d = %d", tr.a, tr.b, tr.y);
      4'h2: $display("Prod: %d * %d = %d", tr.a, tr.b, tr.y);
      4'h3: $display("Div: %d / %d = %d", tr.a, tr.b, tr.y);
      4'h4: $display("AND: %b & %b = %b", tr.a, tr.b, tr.y);
      4'h5: $display("XOR: %b ^ %b = %b", tr.a, tr.b, tr.y);
      4'h6: $display("OR: %b | %b = %b", tr.a, tr.b, tr.y);
      4'h7: begin
              $display("Shift Left 2: %d << %d = %d", tr.a, tr.b, tr.y);
              $display("Shift Left 2: %b << %b = %b", tr.a, tr.b, tr.y);
            end
      4'hD: begin
              $display("Shift Right Arith: %d >>> %d = %d", tr.a, tr.b, tr.y);
              $display("Shift Right Arith: %b >>> %b = %b", tr.a, tr.b, tr.y);
            end
      4'hE: begin
              $display("Shift Right Logical: %d >> %d = %d", tr.a, tr.b, tr.y);
              $display("Shift Right Logical: %b >> %b = %b", tr.a, tr.b, tr.y);
            end
      4'h9: $display("SLT: %d < %d ? %d", tr.a, tr.b, tr.y);
      4'hA: $display("SLTU: %h < %h ? %d", tr.a, tr.b, tr.y);
      default: $display("Default: output = %d", tr.y);
    endcase
    ///////////////////////////////

    refm = ref_model(tr);  // Esto puede llamar a un modelo RTL instanciado

    if (tr.y === refm)
      `uvm_info("SCB", $sformatf("PASS: %s", tr.convert2string()), UVM_LOW)
    else
      `uvm_error("SCB", $sformatf("FAIL: DUT=%0d REF=%0d", tr.y, refm))
  endfunction
endclass

// ------------------------------------------------------------
// Coverage Collector
// ------------------------------------------------------------
class ALUCoverage extends uvm_subscriber#(ALUSeqItem);
  `uvm_component_utils(ALUCoverage)

  ALUSeqItem tr;  
  int unsigned num_transactions;

  // Covergroup de operaciones y zero flag (Cobertura funcional)
  covergroup alu_cg;
    option.per_instance = 1; // Cada colector con uss propios contadores de bins

    cp_aluop: coverpoint tr.aluop {
      bins add    = {4'h8};
      bins sub    = {4'h1};
      bins mul    = {4'h2};
      bins div    = {4'h3};
      bins andop  = {4'h4};
      bins xorop  = {4'h5};
      bins orop   = {4'h6};
      bins sll    = {4'h7};
      bins sra    = {4'hD};
      bins srl    = {4'hE};
      bins slt    = {4'h9};
      bins sltu   = {4'hA};
      illegal_bins others = default;
    }

    cp_zero: coverpoint tr.zero {
      bins zero_set   = {1};
      bins zero_clear = {0};
    }

    // Verificar combinaciones de valores
    aluop_x_zero : cross cp_aluop, cp_zero;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    alu_cg = new();
    num_transactions = 0;
  endfunction

  // Se samplea explícitamente aquí
  function void write(ALUSeqItem t);
    tr = t;
    num_transactions++;
    alu_cg.sample(); // Actualizar cobertura
  endfunction

  function void report_phase(uvm_phase phase);
    real cov = alu_cg.get_inst_coverage();
    `uvm_info("COV", $sformatf("Cobertura funcional alcanzada: %0.2f%%", cov), UVM_NONE)
    `uvm_info("COV", $sformatf("Número total de transacciones observadas: %0d", num_transactions), UVM_NONE)
  endfunction
endclass







// ------------------------------------------------------------
// Environment
// ------------------------------------------------------------
class ALUEnv extends uvm_env;
  `uvm_component_utils(ALUEnv)
  ALUAgent agent;
  ALUScoreboard scb;
  ALUCoverage cov;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    agent = ALUAgent::type_id::create("agent", this);
    scb   = ALUScoreboard::type_id::create("scb", this);
    cov   = ALUCoverage::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    agent.monitor.send.connect(scb.imp);
    agent.monitor.send.connect(cov.analysis_export);
  endfunction
endclass

// ------------------------------------------------------------
// Test
// ------------------------------------------------------------
class ALUTest extends uvm_test;
  `uvm_component_utils(ALUTest)
  ALUEnv env;
  ALUSequence_Rand seq_rand;
  ALUSequence_Directed seq_directed;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    env = ALUEnv::type_id::create("env", this);
    seq_rand = ALUSequence_Rand::type_id::create("seq_rand");
    seq_directed = ALUSequence_Directed::type_id::create("seq_directed");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq_rand.start(env.agent.seqr);
    //seq_directed.start(env.agent.seqr);
    phase.drop_objection(this);
  endtask

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology(); 
  endfunction
endclass



// ------------------------------------------------------------
// Top
// ------------------------------------------------------------
module top;
  alu_if intf();

  ALU dut(
    .ex_datars1_i(intf.ex_datars1_i),
    .ex_datars2_i(intf.ex_datars2_i),
    .ex_aluop_i(intf.ex_aluop_i),
    .ex_data_o(intf.ex_data_o),
    .ex_zerof_o(intf.ex_zerof_o)
  );

  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars;
    uvm_config_db#(virtual alu_if)::set(null, "*", "vif", intf);
    run_test("ALUTest");
  end
endmodule
