############################
###    COMPONENT FILE    ###
############################

from pyuvm import uvm_component, uvm_tlm_analysis_fifo, uvm_get_port
from cocotb_coverage.coverage import CoverPoint, CoverCross, coverage_db

from utils import dict_to_namespace
from default_seqitem import Response as DefaultSeqitemResponse

class CoverageCollector(uvm_component):
    def __init__(self, name, parent):
        super().__init__(name, parent)
        self.num_transactions = 0

    
    @CoverPoint("alu.op",
                xf=lambda tr: tr.ex_aluop_i,
                bins=[
                    0x8,  # add
                    0x1,  # sub
                    0x2,  # mul
                    0x3,  # div
                    0x4,  # and
                    0x5,  # xor
                    0x6,  # or
                    0x7,  # sll
                    0xD,  # sra
                    0xE,  # srl
                    0x9,  # slt
                    0xA   # sltu
                ])
    @CoverPoint("alu.zero",
                xf=lambda tr: tr.ex_zerof_o,
                bins=[0, 1])
    @CoverCross("alu.op_x_zero", items=["alu.op", "alu.zero"])
    def _sample_coverage(self, tr: DefaultSeqitemResponse):
        """Coverage sampling"""
        pass






    def build_phase(self):
        super().build_phase()
        self.dut_result_fifo = uvm_tlm_analysis_fifo('dut_result_fifo', self)
        self.result_get_port = uvm_get_port('result_get_port', self)
        
    def connect_phase(self):
        super().connect_phase()
        self.result_get_port.connect(self.dut_result_fifo.get_export)
        self.result_export = self.dut_result_fifo.analysis_export

    def check_phase(self):
        super().check_phase()

        """You can check actions here"""
    




    def report_phase(self):
        coverage_db.export_to_xml(filename="OSimon/coverage_report.xml")
        
    
    def write(self, t):
        self.tr = t.copy()
        self.logger.info(f'Received from Monitor in WRITE')


        transaction = dict_to_namespace({
            # Resquest
            'ex_aluop_i': t.ins['ex_aluop_i'],
            'ex_datars1_i': t.ins['ex_datars1_i'],
            'ex_datars2_i': t.ins['ex_datars2_i'],
            # Response
            'ex_zerof_o': t.outs['ex_zerof_o'],
            'ex_data_o': t.outs['ex_data_o']
        })
        

        # transaction = t.try_get()
        # self.logger.info(f'{transaction}')
        # self.logger.info(f'Values to be sampled: alu.op={transaction['ex_aluop_i']}, alu.zero={transaction['ex_zerof_o']}')



        self.num_transactions += 1
        self._sample_coverage(transaction)

        """
        Analyze here each transaction with DUT. Recommended to use assertions.
        assert <condition>, 'Error message'
        """


