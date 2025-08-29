############################
###    COMPONENT FILE    ###
############################

import ctypes # Used if you define a _do_with_verilator()
from RefModel import RefModel
from pyuvm import uvm_analysis_port


class DefaultRefModelImpl(RefModel):
    def __init__(self, name, parent, abstract_param='default'):
        super().__init__(name, parent, abstract_param)
        # Uncomment the next two lines if you will use a verilated reference model
        ###self.sim = ctypes.CDLL('../RTLRef/SOME_RTL_MODEL_DIRECTORY/libmodel.so')
        ###self.sim.init()
        self.WORD = 32
        self.MASK = (1 << self.WORD) - 1  # 0xFFFFFFFF para 32 bits


    def build_phase(self):
        super().build_phase()
        self.send = uvm_analysis_port('send_refmodel', self)


    def makeTest(self):
        return self._do_with_python()
    
    def set_inputs(self, *, ex_aluop_i,ex_datars1_i,ex_datars2_i):
        self.ex_aluop_i = ex_aluop_i
        self.ex_datars1_i = ex_datars1_i
        self.ex_datars2_i = ex_datars2_i

        self.send.write(self._do_with_python())



    def _to_signed(self, val):
        """Convierte un valor a entero con signo en 'bits' bits."""
        if val & (1 << (self.WORD - 1)):
            return val - (1 << self.WORD)
        return val

    def _do_with_python(self): 
        # entradas hex a enteros
        rs1 = self.ex_datars1_i & self.MASK
        rs2 = self.ex_datars2_i & self.MASK
        aluop = self.ex_aluop_i & 0xF

        alu_operations = {
            0x8:  lambda rs1, rs2, MASK, WORD, _to_signed: (rs1 + rs2) & MASK,                  # ADD
            0x1:  lambda rs1, rs2, MASK, WORD, _to_signed: (rs1 - rs2) & MASK,                  # SUB
            0x2:  lambda rs1, rs2, MASK, WORD, _to_signed: (rs1 * rs2) & MASK,                  # MUL
            0x3:  lambda rs1, rs2, MASK, WORD, _to_signed: ((rs1 // rs2) & MASK) if rs2 != 0 else 0,  # DIV
            0x4:  lambda rs1, rs2, MASK, WORD, _to_signed: rs1 & rs2,                            # AND
            0x5:  lambda rs1, rs2, MASK, WORD, _to_signed: rs1 ^ rs2,                            # XOR
            0x6:  lambda rs1, rs2, MASK, WORD, _to_signed: rs1 | rs2,                            # OR
            0x7:  lambda rs1, rs2, MASK, WORD, _to_signed: (rs1 << rs2) & MASK,                    # Shift left
            0xD:  lambda rs1, rs2, MASK, WORD, _to_signed: (_to_signed(rs1) >> (rs2 & (WORD - 1))) & MASK,  # SRA
            0xE:  lambda rs1, rs2, MASK, WORD, _to_signed: (rs1 >> (rs2 & (WORD - 1))) & MASK,   # SRL
            0x9:  lambda rs1, rs2, MASK, WORD, _to_signed: int(_to_signed(rs1) < _to_signed(rs2)),  # SLT
            0xA:  lambda rs1, rs2, MASK, WORD, _to_signed: int(rs1 < rs2)                        # SLTU
        }

        self.ex_data_o = alu_operations.get(
            aluop,
            lambda rs1, rs2, MASK, WORD, _to_signed: 0  # default
        )(rs1, rs2, self.MASK, self.WORD, self._to_signed)


        self.ex_zerof_o = 1 if self.ex_data_o == 0 else 0        

        # Finally return the result to compare 
        # (assign your correct values)
        return {
            'ex_zerof_o': self.ex_zerof_o,
            'ex_data_o': self.ex_data_o
        }
    


    def _do_with_verilator(self):
        """Write here your Verilated model handling"""
        
        """
        For example:
        self.sim.set_a(self.a)
        self.sim.set_b(self.b)
        sum = self.sim.get_sum()
        """

        # Finally return the result to compare 
        # (assign your correct values)
        return {
            'ex_zerof_o': None,
            'ex_data_o': None
        }

    

    
          
          

