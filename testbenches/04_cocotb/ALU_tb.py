import cocotb
from cocotb.triggers import Timer
#from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
#from cocotb.clock import Clock


# Test cases
test_cases = [
    # (op, rs1, rs2)
    {'op': 0x8, 'rs1': 10, 'rs2': 5},
    {'op': 0xD, 'rs1': -0x8, 'rs2': 0x1},  # SRA
    {'op': 0x9, 'rs1': 0x5, 'rs2': 0xA},   # SLT
    {'op': 0xA, 'rs1': 0xFFFFFFF0, 'rs2': 0xA}  # SLTU
]

def mask32(val):
    return val & 0xFFFFFFFF

@cocotb.test()
async def alu_test(dut):
    print('=== START TESTBENCH ===')

    # Caso base: cargar operandos
    dut.ex_datars1_i.value = test_cases[0]['rs1']
    dut.ex_datars2_i.value = test_cases[0]['rs2']

    # Case 8: Add
    dut.ex_aluop_i.value = 0x8
    await Timer(1, units='ns')
    print(f'Add: {test_cases[0]['rs1']} + {test_cases[0]['rs2']} = {int(dut.ex_data_o.value)} (expected 15)')
    #assert dut.ex_data_o.value==15, f'Falló ({test_cases[0]['rs1']} + {test_cases[0]['rs2']} = {int(dut.ex_data_o.value)} (expected 15))'

    # Case 1: Sub
    dut.ex_aluop_i.value = 0x1
    await Timer(1, units='ns')
    print(f'Sub: {test_cases[0]['rs1']} - {test_cases[0]['rs2']} = {int(dut.ex_data_o.value)} (expected 5)')

    # Case 2: Prod
    dut.ex_aluop_i.value = 0x2
    await Timer(1, units='ns')
    print(f'Prod: {test_cases[0]['rs1']} * {test_cases[0]['rs2']} = {int(dut.ex_data_o.value)} (expected 50)')

    # Case 3: Div
    dut.ex_aluop_i.value = 0x3
    await Timer(1, units='ns')
    print(f'Div: {test_cases[0]['rs1']} / {test_cases[0]['rs2']} = {int(dut.ex_data_o.value)} (expected 2)')

    # Case 4: AND
    dut.ex_aluop_i.value = 0x4
    await Timer(1, units='ns')
    print('AND: {} & {} = {}'.format(
        format(mask32(test_cases[0]['rs1']), '032b'),
        format(mask32(test_cases[0]['rs2']), '032b'),
        format(mask32(int(dut.ex_data_o.value)), '032b')
    ))

    # Case 5: XOR
    dut.ex_aluop_i.value = 0x5
    await Timer(1, units='ns')
    print('XOR: {} & {} = {}'.format(
        format(mask32(test_cases[0]['rs1']), '032b'),
        format(mask32(test_cases[0]['rs2']), '032b'),
        format(mask32(int(dut.ex_data_o.value)), '032b')
    ))

    # Case 6: OR
    dut.ex_aluop_i.value = 0x6
    await Timer(1, units='ns')
    print('OR: {} & {} = {}'.format(
        format(mask32(test_cases[0]['rs1']), '032b'),
        format(mask32(test_cases[0]['rs2']), '032b'),
        format(mask32(int(dut.ex_data_o.value)), '032b')
    ))

    # Case 7: Shift left logical of 2
    dut.ex_aluop_i.value = 0x7
    dut.ex_datars2_i.value = 0x2
    await Timer(1, units='ns')
    res = int(dut.ex_data_o.value)
    print('Shift Left 2: {} << 2 = {}'.format(
        test_cases[0]['rs1'],
        res
    ))
    print('Shift Left 2: {} << 2 = {}'.format(
        format(mask32(test_cases[0]['rs1']), '032b'),
        format(mask32(res), '032b')
    ))

    # Case D: Shift right arith
    dut.ex_aluop_i.value = 0xD
    dut.ex_datars1_i.value = test_cases[1]['rs1']
    dut.ex_datars2_i.value = test_cases[1]['rs2']
    await Timer(1, units='ns')
    res = int(dut.ex_data_o.value)
    print('Shift Right Arith: {} >>> {} = {}'.format(
        test_cases[1]['rs1'],
        test_cases[1]['rs2'],
        res
    ))
    print('Shift Right Arith: {} >>> {} = {}'.format(
        format(mask32(test_cases[1]['rs1']), '032b'),
        format(mask32(test_cases[1]['rs2']), '032b'),
        format(mask32(res), '032b')
    ))
    

    # Case E: Shift right logical
    dut.ex_aluop_i.value = 0xE
    await Timer(1, units='ns')
    res = int(dut.ex_data_o.value)
    print('Shift Right Logical: {} >> {} = {}'.format(
        test_cases[1]['rs1'],
        test_cases[1]['rs2'],
        res
    ))
    print('Shift Right Logical: {} >> {} = {}'.format(
        format(mask32(test_cases[1]['rs1']), '032b'),
        format(mask32(test_cases[1]['rs2']), '032b'),
        format(mask32(res), '032b')
    ))

    # Case 9: SLT (signed)
    dut.ex_aluop_i.value = 0x9
    dut.ex_datars1_i.value = test_cases[2]['rs1']
    dut.ex_datars2_i.value = test_cases[2]['rs2']
    await Timer(1, units='ns')
    print('SLT: {} < {} ? {}'.format(
        test_cases[2]['rs1'],
        test_cases[2]['rs2'],
        int(dut.ex_data_o.value)
    ))

    # Case A: SLTU (unsigned)
    dut.ex_aluop_i.value = 0xA
    dut.ex_datars1_i.value = test_cases[3]['rs1']
    dut.ex_datars2_i.value = test_cases[3]['rs2']
    await Timer(1, units='ns')
    print('SLTU: {} < {} ? {}'.format(
        (test_cases[3]['rs1'] ^ (1 << 31)) - (1 << 31),
        test_cases[3]['rs2'],
        int(dut.ex_data_o.value)
    ))

    # Case default
    dut.ex_aluop_i.value = 0x0
    await Timer(1, units='ns')
    print(f'Default: output = {int(dut.ex_data_o.value)} (expected 0)')

    print('=== END TESTBENCH ===')

