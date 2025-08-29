import ctypes

# Load shared library
sim = ctypes.CDLL('./obj_dir/libalu.so')

# Initialize simulation
sim.init()

# Test cases
test_cases = [
    # (op, rs1, rs2)
    {'op': 0x8, 'rs1': 10, 'rs2': 5},
    {'op': 0xD, 'rs1': -0x8, 'rs2': 0x1}, # SRA
    {'op': 0x9, 'rs1': 0x5, 'rs2': 0xA}, # SLT
    {'op': 0xA, 'rs1': 0xFFFFFFF0, 'rs2': 0xA}  # SLTU
]

print('=== START TESTBENCH ===')

# Operands
sim.set_ex_datars1_i(test_cases[0]['rs1'])
sim.set_ex_datars2_i(test_cases[0]['rs2'])

# Case 8: Add
sim.set_ex_aluop_i(0x8)
sim.dump()
print(f'Add: {test_cases[0]['rs1']} + {test_cases[0]['rs2']} = {sim.get_ex_data_o()} (expected 15)')

# Case 1: Sub
sim.set_ex_aluop_i(0x1)
sim.dump()
print(f'Sub: {test_cases[0]['rs1']} - {test_cases[0]['rs2']} = {sim.get_ex_data_o()} (expected 5)')

# Case 2: Prod
sim.set_ex_aluop_i(0x2)
sim.dump()
print(f'Prod: {test_cases[0]['rs1']} * {test_cases[0]['rs2']} = {sim.get_ex_data_o()} (expected 50)')

# Case 3: Div
sim.set_ex_aluop_i(0x3)
sim.dump()
print(f'Div: {test_cases[0]['rs1']} / {test_cases[0]['rs2']} = {sim.get_ex_data_o()} (expected 2)')

# Case 4: AND
sim.set_ex_aluop_i(0x4)
sim.dump()
print('AND: {} & {} = {}'.format(   
    format(test_cases[0]['rs1'] & 0xFFFFFFFF, '032b'),
    format(test_cases[0]['rs2'] & 0xFFFFFFFF, '032b'),
    format(sim.get_ex_data_o() & 0xFFFFFFFF, '032b')    
))

# Case 5: XOR
sim.set_ex_aluop_i(0x5)
sim.dump()
print('XOR: {} & {} = {}'.format(   
    format(test_cases[0]['rs1'] & 0xFFFFFFFF, '032b'),
    format(test_cases[0]['rs2'] & 0xFFFFFFFF, '032b'),
    format(sim.get_ex_data_o() & 0xFFFFFFFF, '032b')    
))

# Case 6: OR
sim.set_ex_aluop_i(0x6)
sim.dump()
print('OR: {} & {} = {}'.format(   
    format(test_cases[0]['rs1'] & 0xFFFFFFFF, '032b'),
    format(test_cases[0]['rs2'] & 0xFFFFFFFF, '032b'),
    format(sim.get_ex_data_o() & 0xFFFFFFFF, '032b')    
))

# Case 7: Shift left logical of 2
sim.set_ex_aluop_i(0x7)
sim.set_ex_datars2_i(0x2)
sim.dump()
res = sim.get_ex_data_o()
print('Shift Left 2: {} << 2 = {}'.format(   
    test_cases[0]['rs1'],
    res
))
print('Shift Left 2: {} << 2 = {}'.format(   
    format(test_cases[0]['rs1'] & 0xFFFFFFFF, '032b'),
    format(res & 0xFFFFFFFF, '032b')    
))

# Case D: Shift right arith
sim.set_ex_aluop_i(0xD)
sim.set_ex_datars1_i(test_cases[1]['rs1'])
sim.set_ex_datars2_i(test_cases[1]['rs2'])
sim.dump()
res = sim.get_ex_data_o()
print('Shift Right Arith: {} >>> {} = {}'.format(   
    test_cases[1]['rs1'],
    test_cases[1]['rs2'],
    res
))
print('Shift Right Arith: {} >>> {} = {}'.format(   
    format(test_cases[1]['rs1'] & 0xFFFFFFFF, '032b'),
    format(test_cases[1]['rs2'] & 0xFFFFFFFF, '032b'),
    format(res & 0xFFFFFFFF, '032b')    
))

# Case E: Shift right logical
sim.set_ex_aluop_i(0xE)
sim.dump()
res = sim.get_ex_data_o()
print('Shift Right Logical: {} >> {} = {}'.format(   
    test_cases[1]['rs1'],
    test_cases[1]['rs2'],
    res
))
print('Shift Right Logical: {} >> {} = {}'.format(   
    format(test_cases[1]['rs1'] & 0xFFFFFFFF, '032b'),
    format(test_cases[1]['rs2'] & 0xFFFFFFFF, '032b'),
    format(res & 0xFFFFFFFF, '032b')    
))

# Case 9: SLT (signed)
sim.set_ex_aluop_i(0x9)
sim.set_ex_datars1_i(test_cases[2]['rs1'])
sim.set_ex_datars2_i(test_cases[2]['rs2'])
sim.dump()
print('SLT: {} < {} ? {}'.format(   
    test_cases[2]['rs1'],
    test_cases[2]['rs2'],
    sim.get_ex_data_o()   
))

# Case A: SLTU (unsigned)
sim.set_ex_aluop_i(0xA)
sim.set_ex_datars1_i(test_cases[3]['rs1'])
sim.set_ex_datars2_i(test_cases[3]['rs2'])
sim.dump()
print('SLTU: {} < {} ? {}'.format(   
    format(test_cases[3]['rs1'] & 0xFFFFFFFF, '08x'),
    test_cases[3]['rs2'],
    sim.get_ex_data_o()   
))

# Case default
sim.set_ex_aluop_i(0x0)
sim.dump()
print(f'Default: output = {sim.get_ex_data_o()} (expected 0)')

sim.finalize()
print("=== END TESTBENCH ===")







