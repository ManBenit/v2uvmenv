############################
###    COMPONENT FILE    ###
############################

from pyuvm import uvm_sequence

"""
Import all request from a seqence item, with an specific alias for each.
Use: 
    uvmenv --show-seqitems
to show the available sequence items on your project.
Example:
from your_seqitem import Request as YourRequestAlias
"""
from default_seqitem import Request as DefaultSeqitemRequest

# Set the number of items you want to send
NUM_OF_ITEMS = 1

class DirectedSequence(uvm_sequence):
    def __init__(self, name):
        super().__init__(name)
    
    
    async def body(self):
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

        for _ in range(NUM_OF_ITEMS):
            for input in inputs:
                """ Use the class invoked with your_seqitem module, for example:
                req = YourRequestAlias('req_DirectedSequence')
                """
                req = DefaultSeqitemRequest('req_DirectedSequence')

                await self.start_item(req)
                """ Write the focused or random sequence of stimulus here, example:
                req.randomize()
                req.signal1        = 8
                req.signal2        = 0
                """
                req.randomize()
                req.ex_aluop_i, req.ex_datars1_i, req.ex_datars2_i = input

                await self.finish_item(req)



