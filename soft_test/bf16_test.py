import struct
import torch

def hex_to_bfloat(hex_string):
    # 使用int函数将十六进制字符串转换为整数
    int_value = int(hex_string, 16)

    # 使用float函数将整数转换为浮点数
    float_value = float.fromhex(hex(int_value))

    # 使用torch.bfloat16函数将浮点数转换为bfloat16
    torch_float_value = torch.tensor(float_value)
    bfloat_value = torch_float_value.to(torch.bfloat16)

    return bfloat_value

def bfloat_to_binary(f):
    # 使用struct模块将浮点数转换为二进制表示
    b = struct.pack('!f', f)

    # 将二进制数据转换为字符串
    binary_string = ''.join(format(byte, '08b') for byte in b)
    bfloat_binary_string = binary_string[0:16]
    return bfloat_binary_string