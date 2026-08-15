`include "uvm_macros.svh"
import uvm_pkg::*;


// ============================================================
// Example config
// ============================================================
class alu_config extends uvm_object;
    `uvm_object_utils(alu_config)

    integer int_ex = 2;
    string str_ex = "ConfigExample";
    bit has_scoreboard = 1;
    bit has_coverage = 1;


    function new(string name = "alu_config");
        super.new(name);
    endfunction
endclass

// ============================================================
// DUT interface
// ============================================================
interface alu_if #(parameter WORD=8, ALUOP=4);
    logic [WORD-1:0]  ex_datars1_i;
    logic [WORD-1:0]  ex_datars2_i;
    logic [ALUOP-1:0] ex_aluop_i;
    logic [WORD-1:0]  ex_data_o;
    logic             ex_zerof_o;
endinterface

// ============================================================
// Sequence Item
// ============================================================
class alu_seq_item extends uvm_sequence_item;
    // Inputs
    rand bit [7:0] a;
    rand bit [7:0] b;
    rand bit [3:0]  aluop;
    
    // Outputs
    bit [7:0] y;
    bit        zero;

    // Register of sequence item into UVM factory
    `uvm_object_utils(alu_seq_item)

    // Constructor
    function new(string name="alu_seq_item");
        super.new(name);
    endfunction

    // Restricciones definitivas
    constraint c_ops { 
        aluop inside {
            4'h8, 4'h1, 4'h2, 4'h3,
            4'h4, 4'h5, 4'h6, 4'h7, 
            4'hD, 4'hE, 4'h9, 4'hA
        }; 
    } 

    // virtual function string convert2string();
    //     return $sformatf("a=%0d, b=%0d, aluop=0x%0h, y=%0d, zero=%0b", a, b, aluop, y, zero);
    // endfunction
endclass

// ============================================================
// Bus Functional Model (BFM)
// ============================================================
class alu_bfm;
    virtual alu_if vif;

    // Constructor 
    function new(virtual alu_if vif_);
        vif = vif_;
    endfunction

    // Transfer data to DUT
    task set(alu_seq_item tr);
        vif.ex_datars1_i = tr.a;
        vif.ex_datars2_i = tr.b;
        vif.ex_aluop_i   = tr.aluop;
        #1ns;
    endtask

    // Get data from DUT
    function alu_seq_item get();
        alu_seq_item tr = alu_seq_item::type_id::create("bfm_sample");
        tr.a     = vif.ex_datars1_i;
        tr.b     = vif.ex_datars2_i;
        tr.aluop = vif.ex_aluop_i;
        tr.y     = vif.ex_data_o;
        tr.zero  = vif.ex_zerof_o;
        return tr;
    endfunction
endclass

// ============================================================
// Sequences
// ============================================================
class alu_sequence_rand extends uvm_sequence#(alu_seq_item);
    `uvm_object_utils(alu_sequence_rand)
    int NUM_OF_ITEMS;

    function new(string name="alu_sequence_rand");
        super.new(name);
        NUM_OF_ITEMS = 2;
    endfunction

    task body();
        alu_seq_item req;

        repeat (NUM_OF_ITEMS) begin
            req = alu_seq_item::type_id::create("req_alu_sequence_rand");
            start_item(req);
            if(!req.randomize()) `uvm_error("SEQ", "Randomization failed")
            finish_item(req);
        end
    endtask
endclass

class alu_sequence_directed extends uvm_sequence#(alu_seq_item);
    `uvm_object_utils(alu_sequence_directed)

    function new(string name="alu_sequence_directed");
        super.new(name);
    endfunction

    virtual task body();
        alu_seq_item req;

        `uvm_info("SEQ", "=== START TESTBENCH ===", UVM_NONE);

        // Add
        req = alu_seq_item::type_id::create("add_tr");
        req.a = 8'd10; req.b = 8'd5; req.aluop = 4'h8;
        start_item(req); finish_item(req);

        // Sub
        req = alu_seq_item::type_id::create("sub_tr");
        req.a = 8'd10; req.b = 8'd5; req.aluop = 4'h1;
        start_item(req); finish_item(req);

        // Prod
        req = alu_seq_item::type_id::create("prod_tr");
        req.a = 8'd10; req.b = 8'd5; req.aluop = 4'h2;
        start_item(req); finish_item(req);

        // Div
        req = alu_seq_item::type_id::create("div_tr");
        req.a = 8'd10; req.b = 8'd5; req.aluop = 4'h3;
        start_item(req); finish_item(req);

        // AND
        req = alu_seq_item::type_id::create("and_tr");
        req.a = 8'd10; req.b = 8'd5; req.aluop = 4'h4;
        start_item(req); finish_item(req);

        // XOR
        req = alu_seq_item::type_id::create("xor_tr");
        req.a = 8'd10; req.b = 8'd5; req.aluop = 4'h5;
        start_item(req); finish_item(req);

        // OR
        req = alu_seq_item::type_id::create("or_tr");
        req.a = 8'd10; req.b = 8'd5; req.aluop = 4'h6;
        start_item(req); finish_item(req);

        // Shift left logical
        req = alu_seq_item::type_id::create("sll_tr");
        req.a = 8'd10; req.b = 8'd2; req.aluop = 4'h7;
        start_item(req); finish_item(req);

        // Shift right arith
        req = alu_seq_item::type_id::create("sra_tr");
        req.a = -8'sd8; req.b = 8'd1; req.aluop = 4'hD;
        start_item(req); finish_item(req);

        // Shift right logical
        req = alu_seq_item::type_id::create("srl_tr");
        req.a = -8'sd8; req.b = 8'd1; req.aluop = 4'hE;
        start_item(req); finish_item(req);

        // SLT
        req = alu_seq_item::type_id::create("slt_tr");
        req.a = 8'd5; req.b = 8'd10; req.aluop = 4'h9;
        start_item(req); finish_item(req);

        // SLTU
        req = alu_seq_item::type_id::create("sltu_tr");
        req.a = 8'hF0; req.b = 8'd10; req.aluop = 4'hA;
        start_item(req); finish_item(req);

        // Default
        req = alu_seq_item::type_id::create("def_tr");
        req.a = 8'd0; req.b = 8'd0; req.aluop = 4'h0;
        start_item(req); finish_item(req);
        
        `uvm_info("SEQ", "=== END TESTBENCH ===", UVM_NONE);
    endtask
endclass

// ============================================================
// Driver
// ============================================================
class alu_driver extends uvm_driver#(alu_seq_item);
    `uvm_component_utils(alu_driver)
    
    virtual alu_if vif;
    alu_bfm bfm_inst;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "No se encontró la interfaz")
        bfm_inst = new(vif);
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            alu_seq_item req;
            seq_item_port.get_next_item(req);
            
            // === Method 1: Using BFM ===
            bfm_inst.set(req);
            
            // === Method 2: Using direct interface ===
            /*vif.ex_datars1_i = req.a;
            vif.ex_datars2_i = req.b;
            vif.ex_aluop_i   = req.aluop;
            #1ns; */
            
            seq_item_port.item_done();
        end
    endtask
endclass

// ============================================================
// Monitor
// ============================================================
class alu_monitor extends uvm_monitor;
    `uvm_component_utils(alu_monitor)
    
    virtual alu_if vif;
    alu_bfm bfm_inst;
    uvm_analysis_port#(alu_seq_item) send;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        send = new("send_monitor", this);
    endfunction

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "No se encontró la interfaz")
        bfm_inst = new(vif);
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            alu_seq_item transaction;
            
            // === Method 1: Using BFM ===
            transaction = bfm_inst.get();
            
            // === Method 2: Direct interface ===
            /*transaction.a     = vif.ex_datars1_i;
            transaction.b     = vif.ex_datars2_i;
            transaction.aluop = vif.ex_aluop_i;
            transaction.y     = vif.ex_data_o;
            transaction.zero  = vif.ex_zerof_o; */

            `uvm_info("MON", transaction.convert2string(), UVM_MEDIUM)
            send.write(transaction);
            #1ns;
        end
    endtask
endclass

// ============================================================
// Agent
// ============================================================
class alu_agent extends uvm_agent;
    `uvm_component_utils(alu_agent)

    alu_driver driver;
    alu_monitor monitor;
    uvm_sequencer#(alu_seq_item) seqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        driver  = alu_driver::type_id::create("driver", this);
        monitor = alu_monitor::type_id::create("monitor", this);
        seqr    = uvm_sequencer#(alu_seq_item)::type_id::create("seqr", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        driver.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass

// ============================================================
// Scoreboard with reference model
// ============================================================
class alu_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(alu_scoreboard)

    uvm_analysis_imp#(alu_seq_item, alu_scoreboard) imp;
    alu_config got_cfg;
    integer got_intdir;
    string got_strdir;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        imp = new("imp", this);
    endfunction

    virtual function bit [7:0] ref_model(alu_seq_item tr);
        case (tr.aluop)
            4'h8: return tr.a + tr.b;                        
            4'h1: return tr.a - tr.b;                        
            4'h2: return tr.a * tr.b;                        
            4'h3: return (tr.b != 0) ? tr.a / tr.b : '0;     
            4'h4: return tr.a & tr.b;                        
            4'h5: return tr.a ^ tr.b;                        
            4'h6: return tr.a | tr.b;                        
            4'h7: return tr.a << tr.b;                       
            4'hD: return $signed(tr.a) >>> tr.b;             
            4'hE: return tr.a >> tr.b;                       
            4'h9: return ($signed(tr.a) < $signed(tr.b));    
            4'hA: return (tr.a < tr.b);                      
            default: return '0;
        endcase
    endfunction

    function void extract_phase(uvm_phase phase);
        super.extract_phase(phase);

        uvm_config_db#(alu_config)::get(this, "*", "alu_cfg", got_cfg);
        uvm_config_db#(int)::get(this, "*", "int_direct", got_intdir);
        uvm_config_db#(string)::get(this, "*", "real_direct", got_strdir);
        
        `uvm_info    ("SCB", $sformatf("alu_cfg.int_ex = %0d",         got_cfg.int_ex),         UVM_NONE)
        `uvm_info    ("SCB", $sformatf("alu_cfg.str_ex = %s",          got_cfg.str_ex),         UVM_LOW)
        `uvm_info    ("SCB", $sformatf("alu_cfg.has_scoreboard = %0d", got_cfg.has_scoreboard), UVM_MEDIUM) // Default verbosity
        `uvm_info    ("SCB", $sformatf("alu_cfg.has_coverage = %0d",   got_cfg.has_coverage),   UVM_HIGH)
        `uvm_info    ("SCB", $sformatf("int_direct = %0d",             got_intdir),             UVM_FULL)
        `uvm_info    ("SCB", $sformatf("real_direct = %0d",            got_strdir),             UVM_DEBUG)
        `uvm_warning ("SCB", $sformatf("This is a WARNING"))
        `uvm_error   ("SCB", $sformatf("This is an ERROR"))
        //`uvm_fatal   ("SCB", $sformatf("This is a FATAL"))
    endfunction

    function void write(alu_seq_item tr);
        bit [7:0] refm;

        // Printing with format //////
        case (tr.aluop)
            4'h8: $display("Add: %0d + %0d = %0d", tr.a, tr.b, tr.y);
            4'h1: $display("Sub: %0d - %0d = %0d", tr.a, tr.b, tr.y);
            4'h2: $display("Prod: %0d * %0d = %0d", tr.a, tr.b, tr.y);
            4'h3: $display("Div: %0d / %0d = %0d", tr.a, tr.b, tr.y);
            4'h4: $display("AND: %0b & %0b = %0b", tr.a, tr.b, tr.y);
            4'h5: $display("XOR: %0b ^ %0b = %0b", tr.a, tr.b, tr.y);
            4'h6: $display("OR: %0b | %0b = %0b", tr.a, tr.b, tr.y);
            4'h7: begin
                $display("Shift Left 2: %0d << %0d = %0d", tr.a, tr.b, tr.y);
                $display("Shift Left 2: %0b << %0b = %0b", tr.a, tr.b, tr.y);
            end
            4'hD: begin
                $display("Shift Right Arith: %0d >>> %0d = %0d", tr.a, tr.b, tr.y);
                $display("Shift Right Arith: %0b >>> %0b = %0b", tr.a, tr.b, tr.y);
            end
            4'hE: begin
                $display("Shift Right Logical: %0d >> %0d = %0d", tr.a, tr.b, tr.y);
                $display("Shift Right Logical: %0b >> %0b = %0b", tr.a, tr.b, tr.y);
            end
            4'h9: $display("SLT: %0d < %0d ? %0d", tr.a, tr.b, tr.y);
            4'hA: $display("SLTU: 0x%0h < 0x%0h ? %0d", tr.a, tr.b, tr.y);
            default: $display("Default: output = %0d", tr.y);
        endcase
        ///////////////////////////////

        refm = ref_model(tr);

        if (tr.y === refm)
            `uvm_info("SCB", $sformatf("PASS: %s", tr.convert2string()), UVM_LOW)
        else
            `uvm_error("SCB", $sformatf("FAIL: DUT=%0d REF=%0d", tr.y, refm))
    endfunction
endclass

// ============================================================
// Coverage (Subscriber)
// ============================================================
class alu_coverage extends uvm_subscriber#(alu_seq_item);
    `uvm_component_utils(alu_coverage)

    alu_seq_item tr;  
    int unsigned num_transactions;

    covergroup alu_cg;
        option.per_instance = 1; 

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
        }
        cp_zero: coverpoint tr.zero {
            bins zero_set   = {1};
            bins zero_clear = {0};
        }
        aluop_x_zero : cross cp_aluop, cp_zero;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        alu_cg = new();
        num_transactions = 0;
    endfunction

    function void write(alu_seq_item t);
        tr = t;
        num_transactions++;
        alu_cg.sample(); 
    endfunction

    function void report_phase(uvm_phase phase);
        real cov = alu_cg.get_inst_coverage();
        `uvm_info("COV", $sformatf("Functional coverage reached: %0.2f%%", cov), UVM_NONE)
        `uvm_info("COV", $sformatf("Total transactions: %0d", num_transactions), UVM_NONE)
    endfunction
endclass

// ============================================================
// Environment
// ============================================================
class alu_env extends uvm_env;
    `uvm_component_utils(alu_env)
    alu_agent agent;
    alu_scoreboard scb;
    alu_coverage cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        agent = alu_agent::type_id::create("agent", this);
        scb   = alu_scoreboard::type_id::create("scb", this);
        cov   = alu_coverage::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        agent.monitor.send.connect(scb.imp);
        agent.monitor.send.connect(cov.analysis_export);
    endfunction
endclass

// ============================================================
// Test
// ============================================================
class alu_test extends uvm_test;
    `uvm_component_utils(alu_test)
    alu_env env;
    alu_sequence_rand seq_rand;
    alu_sequence_directed seq_directed;

    alu_config cfg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        cfg = alu_config::type_id::create("cfg");
        cfg.int_ex = 9;
        cfg.str_ex = "Changed";
        cfg.has_scoreboard = 1;
        cfg.has_coverage = 0;

        uvm_config_db#(alu_config)::set(this, "*", "alu_cfg", cfg);
        uvm_config_db#(int)::set(this, "*", "int_direct", 50);
        uvm_config_db#(real)::set(this, "*", "real_direct", 9.5);

        env = alu_env::type_id::create("env", this);
        seq_rand = alu_sequence_rand::type_id::create("seq_rand");
        seq_directed = alu_sequence_directed::type_id::create("seq_directed");
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq_rand.start(env.agent.seqr);
         seq_directed.start(env.agent.seqr);
        phase.drop_objection(this);
    endtask

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology(); 
    endfunction
endclass

// ============================================================
// Top
// ============================================================
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
        // ============================================================-
        // Block for EDA playground
        // ============================================================-
        // $dumpfile("dump.vcd"); 
        // $dumpvars;
        
        uvm_config_db#(virtual alu_if)::set(null, "*", "vif", intf);
        run_test("alu_test");
    end
endmodule

