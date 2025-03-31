import re
import pyperclip

class AssemblyCode:
    opcodes = {
        "NOP": 0, "ADD": 1, "SUB": 2, "MUL": 3, "NAND": 4, "SHL": 5, "SHR": 6, "TEST": 7,
        "OUT": 32, "IN": 33, "BRR": 64, "BRR.N": 65, "BRR.Z": 66, "BR": 67, "BR.N": 68, "BR.Z": 69,
        "BR.SUB": 70, "RETURN": 71, "LOAD": 16, "STORE": 17, "LOADIMM": 18, "MOV": 19,
        "PUSH": 96, "POP": 97, "LOAD.SP": 98, "RTI": 99
    }

    formats_to_regex = {
        "A0": r"^(NOP|RETURN|RTI)$",
        "A1": r"^(ADD|SUB|MUL|NAND)\s+r(\d),\s*r(\d),\s*r(\d)$",
        "A2": r"^(SHL|SHR)\s+r(\d)#(\d+)$",
        "A3": r"^(TEST|OUT|IN|PUSH|POP|LOAD\.SP)\s+r(\d)$",
        "B1": r"^(BRR|BRR\.N|BRR\.Z)\s+([+-]?\d+)$",
        "B2": r"^(BR|BR\.N|BR\.Z|BR\.SUB)\s+r(\d)\+([+-]?\d+)$",
        "L1": r"^(LOADIMM)(\.upper|\.lower)\s+#(\d+)$",
        "L2": r"^(LOAD|STORE|MOV)\s+r(\d),\s*(?:@r(\d)|r(\d))$"
    }

    def get_attributes(self, code):
        for format_, pattern in AssemblyCode.formats_to_regex.items():

            if re.match(pattern, code):
                attr = re.findall(pattern, code)[0]
                
                self.format = format_

                # Get the opcode
                if isinstance(attr, str) or self.format == "A0":
                    self.opcode = AssemblyCode.opcodes[attr]
                    return
                else:
                    self.opcode = AssemblyCode.opcodes[attr[0]]

                    for x in attr[1:]:
                        if x == ".upper" or x == ".lower":
                            imm = 1 if x == ".upper" else 0
                            self.attributes.append(imm)
                        else:
                            self.attributes.append(int(x))
                    return
                
        raise SyntaxError(f"Syntax error for the following code: {code}")

    def __init__(self, code):
        self.opcode = None
        self.format = None
        self.attributes = []
        self.get_attributes(code)

    def to_bitstream(self):
        bitstream = self.opcode << 9

        if self.format == "A1":
            bitstream += (self.attributes[0] << 6)
            bitstream += (self.attributes[1] << 3)
            bitstream += (self.attributes[2])

        elif self.format == "A2":
            bitstream += (self.attributes[0] << 6)
            bitstream += (self.attributes[1])

        elif self.format == "A3":
            bitstream += (self.attributes[0] << 6)

        elif self.format == "B1":
            bitstream += (self.attributes[0])

        elif self.format == "B2":
            bitstream += (self.attributes[0] << 6)
            bitstream += (self.attributes[1])

        elif self.format == "L1":
            bitstream += (self.attributes[0] << 8)
            bitstream += (self.attributes[1])

        elif self.format == "L2":
            bitstream += (self.attributes[0] << 6)
            bitstream += (self.attributes[1] << 3)

        return bitstream
    
    def assemble(code_block, indent=4):
        spacing = " "*4*indent

        low_level_src_code = ""

        codes = [AssemblyCode(code.strip()) for code in code_block.split("\n") if code.strip() and code.strip()[0] != '.' and code.strip()[0:1]]
        
        for i, code in enumerate(codes):
            hex_digits = f"{code.to_bitstream():04x}"
            low_level_src_code += f"{spacing}{i} => X\"{hex_digits}\",\n".upper()

        print(low_level_src_code)
        pyperclip.copy(low_level_src_code)


code_block = """
.code
    IN    r2
    IN    r3
    NOP
    NOP
    NOP
    NOP
    ADD   r1, r2, r3
    NOP
    NOP
    NOP
    NOP
    TEST  r1
"""
AssemblyCode.assemble(code_block)
