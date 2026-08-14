import cocotb
import pyuvm
from cocotb.triggers import Timer
from pyuvm import uvm_test, uvm_sequence, uvm_sequencer, uvm_driver, uvm_monitor, uvm_agent, uvm_env, uvm_root, uvm_sequence_item, uvm_analysis_port, uvm_analysis_export, ConfigDB, uvm_subscriber, uvm_scoreboard
from pyuvm import *
import random
import json
import copy
from types import SimpleNamespace


# ============================================================
# Golden model written on Python
# ============================================================
class AluReferenceModel:
    def __init__(self):
        self.WORD = 8
        self.MASK = (1 << self.WORD) - 1  # 0xFF para 8 bits

    def _to_signed(self, val):
        """Convierte un valor a entero con signo en 'bits' bits."""
        if val & (1 << (self.WORD - 1)):
            return val - (1 << self.WORD)
        return val

    def verify(self, *, ex_aluop_i, ex_datars1_i, ex_datars2_i):
        rs1 = ex_datars1_i & self.MASK
        rs2 = ex_datars2_i & self.MASK
        aluop = ex_aluop_i & 0xF

        if aluop == 0x8:   # ADD
            ex_data_o = (rs1 + rs2) & self.MASK
        elif aluop == 0x1: # SUB
            ex_data_o = (rs1 - rs2) & self.MASK
        elif aluop == 0x2: # MUL
            ex_data_o = (rs1 * rs2) & self.MASK
        elif aluop == 0x3: # DIV, evita div/0
            ex_data_o = (rs1 // rs2) & self.MASK if rs2 != 0 else 0
        elif aluop == 0x4: # AND
            ex_data_o = rs1 & rs2
        elif aluop == 0x5: # XOR
            ex_data_o = rs1 ^ rs2
        elif aluop == 0x6: # OR
            ex_data_o = rs1 | rs2
        elif aluop == 0x7: # Shift left
            ex_data_o = (rs1 << rs2) & self.MASK
        elif aluop == 0xD: # SRA (shift right arithmetic)
            ex_data_o = (self._to_signed(rs1) >> (rs2 & (self.WORD - 1))) & self.MASK
        elif aluop == 0xE: # SRL (shift right logical)
            ex_data_o = (rs1 >> (rs2 & (self.WORD - 1))) & self.MASK
        elif aluop == 0x9: # SLT (signed)
            ex_data_o = int(self._to_signed(rs1) < self._to_signed(rs2))
        elif aluop == 0xA: # SLTU (unsigned)
            ex_data_o = int(rs1 < rs2)
        else:
            ex_data_o = 0

        ex_zerof_o = 1 if ex_data_o == 0 else 0

        return ex_data_o, ex_zerof_o


# ============================================================
# Sequence Item
# ============================================================
class AluSeqItem(uvm_sequence_item):
    def __init__(self, name):
        super().__init__(name)
        # Inputs
        self.ex_aluop_i = 0
        self.ex_datars1_i = 0
        self.ex_datars2_i = 0
        # Outputs
        self.ex_data_o = 0 
        self.ex_zerof_o = 0

    def randomize(self):
        self.ex_aluop_i = random.choice([
            0x8, 0x1, 0x2, 0x3,
            0x4, 0x5, 0x6, 0x7, 
            0xD, 0xE, 0x9, 0xA,        
        ])
        self.ex_datars1_i = random.randint(0, 100)
        self.ex_datars2_i = random.randint(0, 100)
    
    def __str__(self):
        item_dict = {
            'request': {
                'ex_aluop_i':   hex(self.ex_aluop_i),
                'ex_datars1_i': hex(self.ex_datars1_i),
                'ex_datars2_i': hex(self.ex_datars2_i)
            },
            'response':{
                'ex_zerof_o':   hex(self.ex_zerof_o),
                'ex_data_o':    hex(self.ex_data_o)
            }
        }
        #return f'{json.dumps(item_dict, indent=4)}'
        return f'{item_dict}'


# ============================================================
# Bus Functional Model (BFM)
# ============================================================
from abc import ABC, ABCMeta, abstractmethod
class SingletonMeta(ABCMeta, type):
    _instances = {}
    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super().__call__(*args, **kwargs)
        return cls._instances[cls]
class AluBfm(ABC, metaclass=SingletonMeta):
    def __init__(self):
        self.dut = cocotb.top
        self.tr = None

    async def set(self, tr: uvm_sequence_item):
        self.tr = tr
        self.dut.ex_datars1_i.value = self.tr.ex_datars1_i
        self.dut.ex_datars2_i.value = self.tr.ex_datars2_i
        self.dut.ex_aluop_i.value = self.tr.ex_aluop_i
        await Timer(1, units='ns')
    
    async def get(self):
        self.tr.ex_data_o = self.dut.ex_data_o.value.integer
        self.tr.ex_zerof_o = self.dut.ex_zerof_o.value.integer
        return self.tr



    

# ============================================================
# Sequences
# ============================================================
class AluSequenceRand(uvm_sequence):
    def __init__(self, name='AluSequenceRand'):
        super().__init__(name)
        self.NUM_OF_ITEMS = 4

    async def body(self):
        for _ in range(self.NUM_OF_ITEMS):
            req = AluSeqItem('req_AluSeqItem_Rand')
            await self.start_item(req)
            req.randomize()
            await self.finish_item(req)

class AluSequenceDirected(uvm_sequence):
    def __init__(self, name='AluSequenceDirected'):
        super().__init__(name)

    async def body(self):
        inputs= [
            (0x8, 10, 5),           # Add
            (0x1, 10, 5),           # Sub
            (0x2, 10, 5),           # Prod
            (0x3, 10, 5),           # Div
            (0x4, 10, 5),           # AND
            (0x5, 10, 5),           # XOR
            (0x6, 10, 5),           # OR
            (0x7, 10, 2),           # Shift left logical
            (0xD, -8, 1),           # Shift right arith
            (0xE, -8, 1),           # Shift right logical
            (0x9, 5, 10),           # SLT
            (0xA, 0xF0, 10),  # SLTU
        ]
        
        for i in inputs:
            ex_aluop_i, ex_datars1_i, ex_datars2_i = i
            req = AluSeqItem('req_AluSeqItem_Directed')
            await self.start_item(req)

            req.randomize()
            req.ex_aluop_i = ex_aluop_i
            req.ex_datars1_i = ex_datars1_i
            req.ex_datars2_i = ex_datars2_i
            
            await self.finish_item(req)


# ============================================================
# Driver
# ============================================================
class AluDriver(uvm_driver):
    def __init__(self, name, parent):
        super().__init__(name, parent)

    def build_phase(self):
        super().build_phase()
        self.bfm = AluBfm()

    async def run_phase(self):
        await super().run_phase()
        while True:
            req = await self.seq_item_port.get_next_item()
            
            # === Method 1: Using BFM ===
            await self.bfm.set(req)

            # === Method 2: Using direct interface (cocotb.top) ===
            '''dut = cocotb.top
            dut.ex_aluop_i.value = req.ex_aluop_i
            dut.ex_datars1_i.value = req.ex_datars1_i
            dut.ex_datars2_i.value = req.ex_datars2_i
            await Timer(1, units='ns')'''

            self.seq_item_port.item_done()


# ============================================================
# Monitor
# ============================================================
class AluMonitor(uvm_monitor):
    def __init__(self, name, parent):
        super().__init__(name, parent)

    def build_phase(self):
        super().build_phase()
        self.bfm = AluBfm()
        self.logger.info('[MON] build phase')
        self.send = uvm_analysis_port('send_monitor', self)

    async def run_phase(self):
        await super().run_phase()
        while True:
            transaction = AluSeqItem('monitor_item')
            await Timer(1, units='ns')  # Simular delay de monitoreo

            # === Method 1: Using BFM ===
            transaction = await self.bfm.get()
            print(f'{transaction}')

            # === Method 2: Direct interface (cocotb.top) ===
            '''dut = cocotb.top
            transaction.ex_aluop_i = dut.ex_aluop_i.value.integer
            transaction.ex_datars1_i = dut.ex_datars1_i.value.integer
            transaction.ex_datars2_i = dut.ex_datars2_i.value.integer
            transaction.ex_data_o = dut.ex_data_o.value.integer
            transaction.ex_zerof_o = dut.ex_zerof_o.value.integer'''

            self.logger.info(f'[MON] valor del resultado: {transaction}')
            self.send.write(copy.copy(transaction))


# ============================================================
# Agent
# ============================================================
class AluAgent(uvm_agent):
    def __init__(self, name, parent):
        super().__init__(name, parent)

    def build_phase(self):
        super().build_phase()
        self.driver = AluDriver('driver', self)
        self.monitor = AluMonitor('monitor', self)
        self.seqr = uvm_sequencer('seqr', self)

    def connect_phase(self):
        super().connect_phase()
        self.driver.seq_item_port.connect(self.seqr.seq_item_export)


# ============================================================
# Scoreboard 
# ============================================================
class AluScoreboard(uvm_scoreboard, uvm_subscriber):
    def __init__(self, name, parent):
        super().__init__(name, parent)
        self.ref_model = AluReferenceModel()
    
    def build_phase(self):
        super().build_phase()

    def write(self, tr):
        op =  tr.ex_aluop_i
        rs1 = tr.ex_datars1_i
        rs2 = tr.ex_datars2_i
        out = tr.ex_data_o

        # Printing with format //////
        if op == 0x8:
            print(f'Add: {rs1} + {rs2} = {out}')
        elif op == 0x1:
            print(f'Sub: {rs1} - {rs2} = {out}')
        elif op == 0x2:
            print(f'Prod: {rs1} * {rs2} = {out}')
        elif op == 0x3:
            print(f'Div: {rs1} / {rs2} = {out}')
        elif op == 0x4:
            print(f'AND: {bin(rs1)} & {bin(rs2)} = {bin(out)}')
        elif op == 0x5:
            print(f'XOR: {bin(rs1)} ^ {bin(rs2)} = {bin(out)}')
        elif op == 0x6:
            print(f'OR: {bin(rs1)} | {bin(rs2)} = {bin(out)}')
        elif op == 0x7:
            print(f'Shift Left 2: {rs1} << {rs2} = {out}')
            print(f'Shift Left 2: {bin(rs1)} << {bin(rs2)} = {bin(out)}')
        elif op == 0xD:
            print(f'Shift Right Arith: {rs1} >>> {rs2} = {out}')
            print(f'Shift Right Arith: {bin(rs1)} >>> {bin(rs2)} = {bin(out)}')
        elif op == 0xE:
            print(f'Shift Right Logical: {rs1} >> {rs2} = {out}')
            print(f'Shift Right Logical: {bin(rs1)} >> {bin(rs2)} = {bin(out)}')
        elif op == 0x9:
            print(f'SLT: {rs1} < {rs2} ? {out}')
        elif op == 0xA:
            print(f'SLTU: {hex(rs1)} < {hex(rs2)} ? {out}')
        else:
            print(f'Default: output = {out}')
        #/////////////////////////////

        ref_res, ref_zero = self.ref_model.verify(
            ex_aluop_i   =  tr.ex_aluop_i,
            ex_datars1_i =  tr.ex_datars1_i,
            ex_datars2_i =  tr.ex_datars2_i
        )

        if ref_res != 'def':
            assert tr.ex_data_o == ref_res, f'[SCB] FAIL data: DUT={tr.ex_data_o} REF={ref_res}'
            assert tr.ex_zerof_o == ref_zero, f'[SCB] FAIL zero: DUT={tr.ex_zerof_o} REF={ref_zero}'


# ============================================================
# Coverage (Subscriber)
# ============================================================
class AluCoverage(uvm_subscriber):
    def __init__(self, name, parent):
        super().__init__(name, parent)
        self.num_transactions = 0

        self.aluop_bins = {
            0x8: 0, 0x1: 0, 0x2: 0, 0x3: 0,
            0x4: 0, 0x5: 0, 0x6: 0, 0x7: 0,
            0xD: 0, 0xE: 0, 0x9: 0, 0xA: 0
        }
        self.zero_bins = {0: 0, 1: 0}
        self.cross_bins = {}

    def write(self, tr):
        self.num_transactions += 1
        
        op = tr.ex_aluop_i
        z_flag = tr.ex_zerof_o

        if op in self.aluop_bins:
            self.aluop_bins[op] += 1
        if z_flag in self.zero_bins:
            self.zero_bins[z_flag] += 1

        key = (op, z_flag)
        self.cross_bins[key] = self.cross_bins.get(key, 0) + 1

    def report_phase(self):
        super().report_phase()
        aluop_cov = 100 * sum(1 for v in self.aluop_bins.values() if v > 0) / len(self.aluop_bins)
        zero_cov = 100 * sum(1 for v in self.zero_bins.values() if v > 0) / len(self.zero_bins)
        cross_cov = 100 * sum(1 for v in self.cross_bins.values() if v > 0) / (len(self.aluop_bins) * len(self.zero_bins))

        self.logger.info(f'[COV] Coverage aluop: {aluop_cov:.2f}%')
        self.logger.info(f'[COV] Coverage zero: {zero_cov:.2f}%')
        self.logger.info(f'[COV] Cross coverage: {cross_cov:.2f}%')
        self.logger.info(f'[COV] Total transactions: {self.num_transactions}')

# ============================================================
# Environment
# ============================================================
class AluEnv(uvm_env):
    def __init__(self, name, parent, bfm=None):
        super().__init__(name, parent)

    def build_phase(self):
        super().build_phase()
        self.agent = AluAgent('agent', self)
        self.scb = AluScoreboard('scb', self)
        self.cov = AluCoverage('cov', self)

    def connect_phase(self):
        super().connect_phase()
        self.agent.monitor.send.connect(self.cov.analysis_export)
        self.agent.monitor.send.connect(self.scb.analysis_export)


# ============================================================
# Test
# ============================================================
class AluTest(uvm_test):
    def __init__(self, name, parent):
        super().__init__(name, parent)
        self.seq_rand = AluSequenceRand('seq_rand')
        self.seq_directed = AluSequenceDirected('seq_directed')

    def build_phase(self):
        super().build_phase()
        self.env = AluEnv('env', self)
        ConfigDB().set(None, "env.*", "dut", cocotb.top)

    async def run_phase(self):
        self.raise_objection()
        await self.seq_rand.start(self.env.agent.seqr)
        await self.seq_directed.start(self.env.agent.seqr)
        self.drop_objection()


# ============================================================
# Top
# ============================================================
@cocotb.test() 
async def test(dut): 
    await uvm_root().run_test('AluTest')
    