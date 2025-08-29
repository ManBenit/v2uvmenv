import cocotb
import pyuvm
from cocotb.triggers import Timer
from pyuvm import uvm_test, uvm_sequence, uvm_sequencer, uvm_driver, uvm_monitor, uvm_agent, uvm_env, uvm_root, uvm_sequence_item, uvm_analysis_port, uvm_analysis_export, ConfigDB, uvm_subscriber, uvm_scoreboard
from pyuvm import *
import random
import json
import copy
from types import SimpleNamespace



class ALUReferenceModel:
    def __init__(self):
        self.WORD = 32
        self.MASK = (1 << self.WORD) - 1  # 0xFFFFFFFF para 32 bits

    def _to_signed(self, val):
        """Convierte un valor a entero con signo en 'bits' bits."""
        if val & (1 << (self.WORD - 1)):
            return val - (1 << self.WORD)
        return val

    def verify(self, *, ex_aluop_i, ex_datars1_i, ex_datars2_i):
        # entradas hex a enteros
        rs1 = int(ex_datars1_i, 16) & self.MASK
        rs2 = int(ex_datars2_i, 16) & self.MASK
        aluop = int(ex_aluop_i, 16) & 0xF

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
        elif aluop == 0xD: # SRA (shift aritmético a la derecha)
            ex_data_o = (self._to_signed(rs1) >> (rs2 & (self.WORD - 1))) & self.MASK
        elif aluop == 0xE: # SRL (shift lógico a la derecha)
            ex_data_o = (rs1 >> (rs2 & (self.WORD - 1))) & self.MASK
        elif aluop == 0x9: # SLT (signed)
            ex_data_o = int(self._to_signed(rs1) < self._to_signed(rs2))
        elif aluop == 0xA: # SLTU (unsigned)
            ex_data_o = int(rs1 < rs2)
        else:
            ex_data_o = 0

        ex_zerof_o = 1 if ex_data_o == 0 else 0

        # Regresar en hexadecimal (con formato 0xXXXXXXXX)
        return hex(ex_data_o), ex_zerof_o


# ===================== BFM =====================
class ALUBFM:
    def __init__(self):
        self.dut = cocotb.top

    async def set(self, op, a, b):
        self.dut.ex_datars1_i.value = a
        self.dut.ex_datars2_i.value = b
        self.dut.ex_aluop_i.value = op
        await Timer(1, units='ns')
    
    async def get(self):
        return self.dut.ex_data_o.value, self.dut.ex_zerof_o.value
        


# ===================== Sequence Item =====================
# En PyUVM se divide en Request y Response porque este no es una clase mutable de manera nativa como en SV
class ALUSeqItemRequest(uvm_sequence_item):
    def __init__(self, name):
        super().__init__(name)
        self.ex_aluop_i = 0
        self.ex_datars1_i = 0
        self.ex_datars2_i = 0

    def randomize(self):
        # No hay constraints nativos, así que se simulan
        self.ex_aluop_i = random.choice([
            0x8,
            0x1,
            0x2, 
            0x3,
            0x4,
            0x5,
            0x6,
            0x7, 
            0xD, 
            0xE, 
            0x9, 
            0xA,        
        ])
        self.ex_datars1_i = random.randint(0, 100)
        self.ex_datars2_i = random.randint(0, 100)


class ALUSeqItemResponse(uvm_sequence_item):
    def __init__(self, name):
        super().__init__(name)
        # Inputs
        self.ex_aluop_i = 0
        self.ex_datars1_i = 0
        self.ex_datars2_i = 0
        # Outputs
        self.ex_data_o = 0 
        self.ex_zerof_o = 0

    def dict_to_namespace(self, d):
        for key, value in d.items():
            if isinstance(value, dict):
                d[key] = self.dict_to_namespace(value)
        return SimpleNamespace(**d)
    
    def do(self):
        self.item_dict = {
            'request': {
                'ex_aluop_i': self.ex_aluop_i,
                'ex_datars1_i': self.ex_datars1_i,
                'ex_datars2_i': self.ex_datars2_i
            },
            'response':{
                'ex_zerof_o': self.ex_zerof_o,
                'ex_data_o': self.ex_data_o
            }
        }

    def get_response(self):
        return self.dict_to_namespace(self.item_dict)
    
    # Tranferencia entre componentes UVM a travez de TLM
    def copy(self):
        return copy.deepcopy(self)
    
    def __str__(self):
        return f'Transaction response -> {json.dumps(self.item_dict, indent=4)}'
    

# ===================== Sequence =====================
class ALUSequence_Rand(uvm_sequence):
    def __init__(self, name='ALUSequence_Rand'):
        super().__init__(name)
        self.NUM_OF_ITEMS = 4

    async def body(self):
        for _ in range(self.NUM_OF_ITEMS):
            req = ALUSeqItemRequest('req_ALUSeqItemRequest_Rand')
            await self.start_item(req)
            req.randomize()
            await self.finish_item(req)

class ALUSequence_Directed(uvm_sequence):
    def __init__(self, name='ALUSequence_Rand'):
        super().__init__(name)

    async def body(self):
        # await super().body()
        inputs= [
            (0x8, 10, 5),       # Add
            (0x1, 10, 5),       # Sub
            (0x2, 10, 5),       # Prod
            (0x3, 10, 5),       # Div
            (0x4, 10, 5),       # AND
            (0x5, 10, 5),       # XOR
            (0x6, 10, 5),       # OR
            (0x7, 10, 2),       # Shift left logical
            (0xD, -8, 1),           # Shift right arith
            (0xE, -8, 1),           # Shift right logical
            (0x9, 5, 10),           # SLT
            (0xA, 0xFFFFFFF0, 10),  # SLTU
        ]
        
        for i in inputs:
            ex_aluop_i, ex_datars1_i, ex_datars2_i = i
            req = ALUSeqItemRequest('req_ALUSeqItemRequest_Rand')
            await self.start_item(req)

            # Siempre aleatorizar, en caso de que no se envien valores a todas las entradas.
            req.randomize()
            req.ex_aluop_i = ex_aluop_i
            req.ex_datars1_i = ex_datars1_i
            req.ex_datars2_i = ex_datars2_i
            
            await self.finish_item(req)

# ===================== Driver =====================
class ALUDriver(uvm_driver):
    def __init__(self, name, parent, bfm=None):
        super().__init__(name, parent)

    def build_phase(self):
        super().build_phase()
        super().build_phase()
        self.bfm = ALUBFM()

    async def run_phase(self):
        await super().run_phase()
        while True:
            seq_item = await self.seq_item_port.get_next_item()
            await self.bfm.set(
                seq_item.ex_aluop_i, 
                seq_item.ex_datars1_i, 
                seq_item.ex_datars2_i
            )

            self.seq_item_port.item_done()


# ===================== Monitor =====================
class ALUMonitor(uvm_monitor):
    def __init__(self, name, parent):
        super().__init__(name, parent)

    def build_phase(self):
        super().build_phase()
        self.bfm = ALUBFM()
        self.logger.info('[MON] build phase')
        self.send = uvm_analysis_port('send_monitor', self)

    async def run_phase(self):
        await super().run_phase()
        while True:
            transaction = ALUSeqItemResponse('monitor_item')
            await Timer(1, units='ns')  # Simular delay de monitoreo

            transaction.ex_aluop_i = hex(self.bfm.dut.ex_aluop_i.value.integer)
            transaction.ex_datars1_i = hex(self.bfm.dut.ex_datars1_i.value.integer)
            transaction.ex_datars2_i = hex(self.bfm.dut.ex_datars2_i.value.integer)

            transaction.ex_data_o = hex(self.bfm.dut.ex_data_o.value.integer)
            transaction.ex_zerof_o = hex(self.bfm.dut.ex_zerof_o.value.integer)
            transaction.do()

            self.logger.info(f'[MON] valor del resultado: {transaction}')
            self.send.write(transaction)


# ===================== Agent =====================
class ALUAgent(uvm_agent):
    def __init__(self, name, parent):
        super().__init__(name, parent)


    def build_phase(self):
        super().build_phase()
        self.driver = ALUDriver('driver', self)
        self.monitor = ALUMonitor('monitor', self)
        self.seqr = uvm_sequencer('seqr', self)
        #ConfigDB().set(None, '*', 'SEQR', self.seqr)

    def connect_phase(self):
        super().connect_phase()

        self.driver.seq_item_port.connect(self.seqr.seq_item_export)


# ===================== Scoreboard =====================
class ALUScoreboard(uvm_scoreboard, uvm_subscriber):
    def __init__(self, name, parent):
        super().__init__(name, parent)
        self.ref_model = ALUReferenceModel()  # instancia del modelo de referencia
    
    def build_phase(self):
        super().build_phase()

    def write(self, tr):
        # Impresión de valores como en el SystemVerilog
        if tr.ex_aluop_i == 0x8:
            print(f'Add: {tr.ex_datars1_i} + {tr.ex_datars2_i} = {tr.ex_data_o}')
        elif tr.ex_aluop_i == 0x1:
            print(f'Sub: {tr.ex_datars1_i} - {tr.ex_datars2_i} = {tr.ex_data_o}')
        elif tr.ex_aluop_i == 0x2:
            print(f'Prod: {tr.ex_datars1_i} * {tr.ex_datars2_i} = {tr.ex_data_o}')
        elif tr.ex_aluop_i == 0x3:
            print(f'Div: {tr.ex_datars1_i} / {tr.ex_datars2_i} = {tr.ex_data_o}')
        elif tr.ex_aluop_i == 0x4:
            print(f'AND: {bin(tr.ex_datars1_i)} & {bin(tr.ex_datars2_i)} = {bin(tr.ex_data_o)}')
        elif tr.ex_aluop_i == 0x5:
            print(f'XOR: {bin(tr.ex_datars1_i)} ^ {bin(tr.ex_datars2_i)} = {bin(tr.ex_data_o)}')
        elif tr.ex_aluop_i == 0x6:
            print(f'OR: {bin(tr.ex_datars1_i)} | {bin(tr.ex_datars2_i)} = {bin(tr.ex_data_o)}')
        elif tr.ex_aluop_i == 0x7:
            print(f'Shift Left 2: {tr.ex_datars1_i} << {tr.ex_datars2_i} = {tr.ex_data_o}')
            print(f'Shift Left 2: {bin(tr.ex_datars1_i)} << {bin(tr.ex_datars2_i)} = {bin(tr.ex_data_o)}')
        elif tr.ex_aluop_i == 0xD:
            print(f'Shift Right Arith: {tr.ex_datars1_i} >>> {tr.ex_datars2_i} = {tr.ex_data_o}')
            print(f'Shift Right Arith: {bin(tr.ex_datars1_i)} >>> {bin(tr.ex_datars2_i)} = {bin(tr.ex_data_o)}')
        elif tr.ex_aluop_i == 0xE:
            print(f'Shift Right Logical: {tr.ex_datars1_i} >> {tr.ex_datars2_i} = {tr.ex_data_o}')
            print(f'Shift Right Logical: {bin(tr.ex_datars1_i)} >> {bin(tr.ex_datars2_i)} = {bin(tr.ex_data_o)}')
        elif tr.ex_aluop_i == 0x9:
            print(f'SLT: {tr.ex_datars1_i} < {tr.ex_datars2_i} ? {tr.ex_data_o}')
        elif tr.ex_aluop_i == 0xA:
            print(f'SLTU: {hex(tr.ex_datars1_i)} < {hex(tr.ex_datars2_i)} ? {tr.ex_data_o}')
        else:
            print(f'Default: output = {tr.ex_data_o}')

        # Llamada al modelo de referencia
        ref_res, ref_zero = self.ref_model.verify(
            ex_aluop_i   =  tr.ex_aluop_i,
            ex_datars1_i =  tr.ex_datars1_i,
            ex_datars2_i =  tr.ex_datars2_i
        )

        ##Comparación DUT vs Modelo
        ### Forma no bloqueante
        # if tr.ex_data_o == ref_res:
        #     self.logger.info(f'[SCB] PASS data: {tr}')
        # else:
        #     self.logger.error(f'[SCB] FAIL data: DUT={tr.ex_data_o} REF={ref_res}')

        # if int(tr.ex_zerof_o, 16) == ref_zero:
        #     self.logger.info(f'[SCB] PASS zero: {tr}')
        # else:
        #     self.logger.error(f'[SCB] FAIL zero: DUT={tr.ex_zerof_o} REF={ref_zero}')

        ### Forma bloqueante (recomendada)
        if ref_res != 'def':
            assert tr.ex_data_o == ref_res, f'[SCB] FAIL data: DUT={tr.ex_data_o} REF={ref_res}'
            assert int(tr.ex_zerof_o, 16) == ref_zero, f'[SCB] FAIL zero: DUT={tr.ex_zerof_o} REF={ref_zero}'



# ===================== Coverage (Subscriber) =====================
class ALUCoverage(uvm_subscriber):
    def __init__(self, name, parent):
        super().__init__(name, parent)
        self.num_transactions = 0

        # Diccionario de bins (igual que los coverpoints)
        self.aluop_bins = {
            0x8: 0, # add
            0x1: 0, # sub
            0x2: 0, # mul
            0x3: 0, # div
            0x4: 0, # andop
            0x5: 0, # xorop
            0x6: 0, # orop
            0x7: 0, # sll
            0xD: 0, # sra
            0xE: 0, # srl
            0x9: 0, # slt
            0xA: 0  #sltu
        }
        self.zero_bins = {
            0: 0, 
            1: 0
        }
        self.cross_bins = {}  # (aluop, zero) -> contador

    def write(self, tr):
        self.num_transactions += 1

        # Actualizar aluop bins
        if tr.ex_aluop_i in self.aluop_bins:
            self.aluop_bins[tr.ex_aluop_i] += 1

        # Actualizar zero bins
        if tr.ex_zerof_o in self.zero_bins:
            self.zero_bins[tr.zero] += 1

        # Actualizar cross
        key = (tr.ex_aluop_i, tr.ex_zerof_o)
        self.cross_bins[key] = self.cross_bins.get(key, 0) + 1

    def report_phase(self):
        super().report_phase()
        # Calcular % cobertura (igual que get_inst_coverage())
        aluop_cov = 100 * sum(1 for v in self.aluop_bins.values() if v > 0) / len(self.aluop_bins)
        zero_cov = 100 * sum(1 for v in self.zero_bins.values() if v > 0) / len(self.zero_bins)
        cross_cov = 100 * sum(1 for v in self.cross_bins.values() if v > 0) / (len(self.aluop_bins) * len(self.zero_bins))

        # Reportar
        self.logger.info(f'[COV] Cobertura aluop: {aluop_cov:.2f}%')
        self.logger.info(f'[COV] Cobertura zero: {zero_cov:.2f}%')
        self.logger.info(f'[COV] Cobertura cruzada: {cross_cov:.2f}%')
        self.logger.info(f'[COV] Número total de transacciones observadas: {self.num_transactions}')

# ===================== Environment =====================
class ALUEnv(uvm_env):
    def __init__(self, name, parent, bfm=None):
        super().__init__(name, parent)

    def build_phase(self):
        super().build_phase()
        self.agent = ALUAgent('agent', self)
        self.scb = ALUScoreboard('scb', self)
        self.cov = ALUCoverage('cov', self)

    def connect_phase(self):
        super().connect_phase()
        self.agent.monitor.send.connect(self.cov.analysis_export)
        self.agent.monitor.send.connect(self.scb.analysis_export)


# ===================== Test =====================
class ALUTest(uvm_test):
    def __init__(self, name, parent):
        super().__init__(name, parent)
        self.seq_rand = ALUSequence_Rand('seq_rand')
        self.seq_directed = ALUSequence_Directed('seq_directed')

    def build_phase(self):
        super().build_phase()
        self.env = ALUEnv('env', self)
        ConfigDB().set(None, "env.*", "dut", cocotb.top)

    async def run_phase(self):
        self.raise_objection()
        await self.seq_rand.start(self.env.agent.seqr)
        #await self.seq_directed.start(self.env.agent.seqr)
        self.drop_objection()


# ===================== Cocotb Integration =====================
@cocotb.test() 
async def test(dut): 
    await uvm_root().run_test('ALUTest')

