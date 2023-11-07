import struct
import torch

# def hex_to_bfloat(hex_string):

#     # 使用int函数将十六进制字符串转换为整数
#     int_value = int(hex_string, 16)
#     print(int_value)
#     # 使用float函数将整数转换为浮点数
#     float_value = float.fromhex(hex(int_value))
    
#     # 使用torch.bfloat16函数将浮点数转换为bfloat16
#     torch_float_value = torch.tensor(float_value)
#     bfloat_value = torch_float_value.to(torch.bfloat16)

#     return bfloat_value

def bfloat_to_hex(f):
    # 使用struct模块将浮点数转换为二进制表示
    b = struct.pack('!f', f)
    # 将二进制数据转换为十六进制字符串
    hex_string = ''.join(format(byte, '02x') for byte in b)
    bfloat_hex_string = hex_string[0:4]
    return bfloat_hex_string

def bfloat_to_binary(f):
    # 使用struct模块将浮点数转换为二进制表示
    b = struct.pack('!f', f)

    # 将二进制数据转换为字符串
    binary_string = ''.join(format(byte, '08b') for byte in b)
    bfloat_binary_string = binary_string[0:16]
    return bfloat_binary_string

def hex_to_bfloat(hex_string):
    # 将十六进制字符串转换为二进制字符串
    integer = int(hex_string, 16)
    binary_string = bin(integer)
    binary_string = binary_string[2:]
    print(hex_string)
    print(binary_string)
    # 将二进制字符串转换为bfloat16
    sign = int(binary_string[0],2)
    exponent = int(binary_string[1:9],2)
    mantissa = int(binary_string[9:16],2)
    print(sign)
    print(exponent) 
    print(mantissa)
    # set zero and subnormal to zero
    if exponent == 0:
        bfloat16 = 0
    else:
        # convert to float
        f = (-1)**sign * 2**(exponent-127) * (1+mantissa/2**7)
        # convert to bfloat16
        bfloat16 = torch.tensor(f).to(torch.bfloat16)

    print(bfloat16)
    return bfloat16

# # 示例用法
# f = 3.14
# f = torch.tensor(f)
# f = f.to(torch.bfloat16)
# binary = bfloat_to_binary(f)
# hex = bfloat_to_hex(f)
# print(binary)
# print(hex)

# 从文本文件中读取十六进制数
input_path = 'stim_inputs.txt'
with open(input_path, 'r') as file:
    hex_string = file.readline().strip()

# 将十六进制数转换为BF16
bfloat_inputs = hex_to_bfloat(hex_string[0:4])
print(bfloat_inputs)