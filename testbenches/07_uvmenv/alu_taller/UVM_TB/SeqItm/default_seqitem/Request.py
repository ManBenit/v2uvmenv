############################
###    COMPONENT FILE    ###
############################

import random
import json
from pyuvm import uvm_sequence_item

class Request(uvm_sequence_item):
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



    def __str__(self):
        item_dict = {
            'ex_aluop_i': self.ex_aluop_i,
            'ex_datars1_i': self.ex_datars1_i,
            'ex_datars2_i': self.ex_datars2_i
        }
        return f'Transaction request -> {json.dumps(item_dict)}'
        
    